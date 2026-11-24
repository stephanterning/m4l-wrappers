// The builder supplies the documented plug-in name, VST3 class ID and parameter names.
inlets = 3;
outlets = 4; // vst~, wrapper events, stereo Drive, output stage
const patch = this.patcher;
const nativeHost = () => patch.getnamed("maxPlugin");
const temp = "Tempfolder:/m4l-host-" + Date.now() + "-" + Math.floor(Math.random() * 0x100000000).toString(16);
const exportPath = temp + "-export.vstpreset";
const presetPath = temp + "-import.vstpreset";
const alphabet = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";
const restoreProbe = product.restoreProbe ?? 1;
const gainParameters = product.autoGain;
const knownTrim = 0, automaticTrim = 1, unknownTrim = 2;
let phase = "idle", state = "-", names = [], mapping = [], inverse = [];
let attempts, reportedLatency = -1;
const restoreError = "The plug-in could not restore its state from this Live Set.";
let probeValue, probeReply, probePass;
let autoGainEnabled = false, lastDrive, trimDisplay;
const recallTask = new Task(importAndCheck, this);
const inspectTask = new Task(inspect, this);
const finishTask = new Task(finish, this);
const latencyTask = new Task(function () { if (phase === "ready") outlet(0, "get", -10); }, this);
const editorTask = new Task(checkEditorWindow, this);
let editorRequested = false, closedRect = null, reportedRect = null, openingChecks = 0;

function encode(bytes) {
    let result = "";
    for (let i = 0; i < bytes.length; i += 3) {
        const bits = (bytes[i] << 16) | ((bytes[i+1] || 0) << 8) | (bytes[i+2] || 0);
        result += alphabet[bits >>> 18] + alphabet[(bits >>> 12) & 63] +
            (i+1 < bytes.length ? alphabet[(bits >>> 6) & 63] : "=") +
            (i+2 < bytes.length ? alphabet[bits & 63] : "=");
    }
    return result;
}
function decode(text) {
    if (!text || text.length > 349528 || text.length % 4 || !/^[A-Za-z0-9+/]+={0,2}$/.test(text)) throw Error("Invalid saved state.");
    const bytes = [];
    for (let i = 0; i < text.length; i += 4) {
        let bits = 0;
        for (let j = 0; j < 4; j++) bits = (bits << 6) | Math.max(0, alphabet.indexOf(text[i+j]));
        bytes.push((bits >>> 16) & 255);
        if (text[i+2] !== "=") bytes.push((bits >>> 8) & 255);
        if (text[i+3] !== "=") bytes.push(bits & 255);
    }
    return bytes;
}
function writeFile(path, bytes) {
    const f = new File(path, "write");
    try {
        if (!f.isopen) throw Error("Could not open the temporary preset.");
        f.eof = 0;
        for (let i = 0; i < bytes.length; i += 4096) f.writebytes(bytes.slice(i, i+4096));
        if (f.position !== bytes.length) throw Error("Could not write the temporary preset.");
    } finally { f.close(); }
}
function bytesOf(text) { return Array.from(text, c => c.charCodeAt(0)); }
function little(value, n) {
    const bytes = [];
    while (n--) { bytes.push(value % 256); value = Math.floor(value / 256); }
    return bytes;
}
function legacyPreset(bytes) {
    return bytesOf("VST3").concat(little(1,4),bytesOf(product.cid),little(48+bytes.length,8),bytes,
        bytesOf("List"),little(1,4),bytesOf("Comp"),little(48,8),little(bytes.length,8));
}
// The VST3 preset directory uses little-endian 64-bit offsets. Reject unsafe indexes
// before extracting the vendor's opaque component or handing a saved preset to Max.
function parsePreset(bytes) {
    function tag(at, size) { return String.fromCharCode(...bytes.slice(at, at + size)); }
    function integer(at, size) {
        if (at < 0 || at + size > bytes.length) throw Error("Incomplete VST3 directory.");
        let value = 0;
        for (let i = size-1; i >= 0; i--) value = value * 256 + bytes[at+i];
        if (!Number.isSafeInteger(value)) throw Error("Invalid VST3 offset.");
        return value;
    }
    if (bytes.length < 76 || tag(0,4) !== "VST3" || integer(4,4) !== 1 ||
        tag(8,32).toUpperCase() !== product.cid) throw Error("Unexpected VST3 preset.");
    const at = integer(40,8);
    if (at < 48 || tag(at,4) !== "List") throw Error("Invalid VST3 directory.");
    const count = integer(at+4,4);
    if (count > (bytes.length-at-8)/20) throw Error("Incomplete VST3 directory.");
    let component, otherState = false;
    for (let i = 0; i < count; i++) {
        const ix = at + 8 + 20*i, name = tag(ix,4);
        const offset = integer(ix+4,8), length = integer(ix+12,8);
        if (offset < 48 || offset > at || length > at-offset) throw Error("Invalid VST3 chunk.");
        if (name === "Comp") {
            if (component || !length) throw Error("Invalid VST3 component state.");
            component = bytes.slice(offset, offset+length);
        } else if (length && name !== "Info") otherState = true;
    }
    if (!component) throw Error("No VST3 component state.");
    return {component, otherState};
}
function readFile(path) {
    const f = new File(path, "read");
    try {
        if (!f.isopen || f.eof <= 0 || f.eof > 262144) throw Error("The plug-in snapshot could not be read.");
        return f.readbytes(f.eof);
    } finally { f.close(); }
}
function setLatency(value) {
    if (value === reportedLatency) return;
    reportedLatency = value;
    outlet(1, "latency", value);
}
function fail(detail) {
    phase = "failed";
    outlet(3, "wet", 0);
    setLatency(0);
    outlet(1, "loaderror", detail);
}
function load(encoded) {
    endEditorSession();
    inspectTask.cancel(); finishTask.cancel(); recallTask.cancel(); latencyTask.cancel();
    outlet(3, "wet", 0); setLatency(0);
    phase = "discovering";
    state = String(encoded); attempts = 0;
    if (gainParameters) {
        autoGainEnabled = false;
        lastDrive = undefined;
        trimDisplay = undefined;
    }
    outlet(0, "unplug");
    // A fresh name lookup is silent. Max may show a global confirmation dialog for scan.
    outlet(0, "plug_vst3", product.name);
    inspectTask.schedule(250);
}
function inspect() {
    const id = nativeHost().getattr("currentplug");
    if (!id && ++attempts < 12) { inspectTask.schedule(250); return; }
    if (!id) { fail("Check that the VST3 is installed and available to Max."); return; }
    // Max can resolve another format with the same display name. Confirm the
    // portable VST3 class ID from the vendor preset before enabling audio.
    try {
        writeFile(exportPath, []);
        outlet(0, "write", exportPath);
        parsePreset(readFile(exportPath));
    } catch (error) { fail("The expected VST3 plug-in could not be loaded."); return; }
    phase = "parameters";
    names = [];
    outlet(0, "params");
    mapping = product.parameters.map(name => {
        const aliases = product.aliases && product.aliases[name] || [name];
        const matches = names.map((candidate, i) => aliases.includes(candidate) ? i+1 : 0).filter(Boolean);
        return matches.length === 1 ? matches[0] : 0;
    });
    inverse = [];
    for (let i = 0; i < mapping.length; ++i) {
        const name = product.parameters[i];
        if (!mapping[i]) {
            fail("The VST3 parameter “" + name + "” is missing or ambiguous."); return;
        }
        inverse[mapping[i]] = i;
    }
    phase = "restoring";
    try {
        if (state !== "-") {
            const full = state.startsWith("preset1_");
            const bytes = full ? decode(state.slice(8)) : legacyPreset(decode(state));
            parsePreset(bytes);
            writeFile(presetPath, bytes);
            probePass = 0;
            prepareReadback();
            return;
        }
    } catch (error) { fail(restoreError); return; }
    finishTask.schedule(120);
}
// vst~ does not return a success flag for read. While muted, change one continuous
// parameter and verify the preset replaces it. A second marker handles a real
// preset whose stored value happens to equal the first marker. The wrapper never
// sends these private host edits to Live or stores them in the instance bank.
function prepareReadback() {
    probeValue = probePass === 0 ? 0.25 : 0.75;
    outlet(0, [mapping[restoreProbe], probeValue]);
    recallTask.schedule(100);
}
function importAndCheck() {
    if (phase !== "restoring") return;
    probeReply = null;
    outlet(0, "get", mapping[restoreProbe]);
    if (probeReply === null || Math.abs(probeReply-probeValue) > 0.01) { fail(restoreError); return; }
    outlet(0, "read", presetPath);
    finishTask.schedule(150);
}
function finish() {
    if (phase !== "restoring") return;
    if (state !== "-") {
        probeReply = null;
        outlet(0, "get", mapping[restoreProbe]);
        if (probeReply === null) { fail(restoreError); return; }
        if (Math.abs(probeReply-probeValue) < 0.01) {
            if (probePass++ === 0) { prepareReadback(); return; }
            fail(restoreError); return;
        }
    }
    phase = "ready";
    outlet(1, "ready");
    // The restored preset is authoritative for Decapitator. Read its values for
    // the panel and Live parameter displays without replaying the old controls.
    if (product.restoreFromPlugin) {
        if (gainParameters) showTrim(knownTrim);
        for (const index of mapping) outlet(0, "get", index);
    }
    outlet(0, "get", -10);
    outlet(3, "wet", 1);
}
function snapshot() {
    if (phase !== "ready") return;
    try {
        // Start from an empty destination so a failed write cannot return a previous snapshot.
        writeFile(exportPath, []);
        outlet(0, "write", exportPath);
        const bytes = readFile(exportPath), chunks = parsePreset(bytes);
        // The two current VST3s export only component state. In that case the stored
        // symbol stays readable by v1.3, without a format conversion on Live Set save.
        const completePreset = product.restoreFromPlugin || chunks.otherState;
        outlet(1, "plugstate", completePreset ? "preset1_" + encode(bytes) : encode(chunks.component));
    } catch (error) { post("Could not capture the plug-in state: " + error.message + "\n"); }
}
function showTrim(mode) {
    if (trimDisplay === mode) return;
    trimDisplay = mode;
    outlet(1, "autoTrim", mode);
}
function observeAutoGain(slot, value) {
    if (!gainParameters) return;
    if (slot === gainParameters.drive) {
        lastDrive = value;
    } else if (slot === gainParameters.enabled) {
        autoGainEnabled = value >= 0.5;
        // Turning AutoGain off does not verify an unreported trim value.
        if (trimDisplay === automaticTrim || trimDisplay === unknownTrim)
            showTrim(autoGainEnabled ? automaticTrim : unknownTrim);
    } else if (slot === gainParameters.trim) {
        showTrim(knownTrim);
    }
}
function parameterChanged(index, value) {
    if (index === -10) { if (phase === "ready") setLatency(value); return; }
    const slot = inverse[index];
    if (slot === undefined || !Number.isFinite(value) || value < 0 || value > 1) return;
    if (phase === "restoring") { if (slot === restoreProbe) probeReply = value; return; }
    if (phase !== "ready") return;
    observeAutoGain(slot, value);
    outlet(1, "edited", slot, value);
    if (product.parameters[slot] === "Quality") latencyTask.schedule(30);
}
function anything() {
    if (inlet === 1 && phase === "parameters") names.push(messagename);
}
function list(index, value, top, right, bottom) {
    if (inlet !== 2) return;
    if (index === -9) {
        if ([value, top, right, bottom].every(Number.isFinite))
            reportedRect = [value, top, right, bottom].join(",");
    } else parameterChanged(index, value);
}
function param(slot, value) {
    if (phase !== "ready" || !mapping[slot]) return;
    if (gainParameters) {
        const driveEdit = slot === gainParameters.drive;
        const enablesAutoGain = slot === gainParameters.enabled && !autoGainEnabled && value >= 0.5;
        const linkedEdit = autoGainEnabled && (driveEdit || slot === gainParameters.punish);
        // A repeated Drive write could reapply the plug-in's compensation over a manual trim.
        if (linkedEdit && driveEdit && value === lastDrive) return;
        // These writes can change the audible trim without vst~ reporting its new value.
        if (enablesAutoGain || linkedEdit) showTrim(automaticTrim);
        observeAutoGain(slot, value);
    }
    outlet(0, [mapping[slot], value]);
    if (product.parameters[slot] === "Quality") latencyTask.schedule(30);
}
// v8.codebox handles "open" itself. Translate only at the vst~ outlet.
function editorRect() {
    reportedRect = null;
    outlet(0, "get", -9);
    return reportedRect;
}
function endEditorSession() {
    editorTask.cancel();
    if (!editorRequested) return;
    editorRequested = false;
    outlet(1, "editorWindow", 0);
}
function checkEditorWindow() {
    if (!editorRequested) return;
    const rect = editorRect();
    // These editors revert to the pre-open rectangle on close. Sample it per
    // instance so window placement, scale and monitor choice need no constants.
    if (rect !== null && rect !== closedRect) openingChecks = 0;
    else if (openingChecks === 0 || --openingChecks === 0) {
        endEditorSession();
        return;
    }
    editorTask.schedule(250);
}
function openPlugin() {
    if (phase !== "ready" || editorRequested) return;
    closedRect = editorRect();
    outlet(0, "open");
    editorRequested = true;
    openingChecks = 4;
    outlet(1, "editorWindow", 1);
    if (closedRect !== null) checkEditorWindow();
}
function closePlugin() {
    if (!editorRequested) return;
    outlet(0, "wclose");
    endEditorSession();
}
function drive(db) { outlet(2, "output", db); }
function output(db) { outlet(3, "output", db); }
function metering(token) {
    outlet(3, "metering", token);
    if (product.restoreFromPlugin && token % 2 === 1) refreshLatency();
}
function refreshLatency() { if (phase === "ready") latencyTask.schedule(50); }
function notifydeleted() { editorTask.cancel(); inspectTask.cancel(); finishTask.cancel(); recallTask.cancel(); latencyTask.cancel(); }
