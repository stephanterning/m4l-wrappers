inlets = 1;
outlets = 2;
const patch = this.patcher;
const pluginName = "Soundtoys Decapitator";
const pointerControls = ["preDrive", "postOutput", "driveLink", "param1", "param3", "param4", "param5", "param6", "param10"];
let phase = "cold", queue = null, key = "";
const warningTask = new Task(flush, this);
const loadTimeout = new Task(function () {
    if (phase === "loading") loaderror("The VST3 host did not respond.");
}, this);

function panel() { return patch.getnamed("face"); }
function parameter(index) { return patch.getnamed("param" + index); }
const clamp01 = value => Math.max(0, Math.min(1, Number(value)));
const values = parameters.map(p => normalize(p, p.initial));
function normalize(p, value) {
    const scaled = p.log ? Math.log(value / p.low) / Math.log(p.high / p.low)
                         : (value - p.low) / (p.high - p.low);
    return clamp01(scaled);
}
function denormalize(p, normalized) {
    if (p.log) return p.low * Math.pow(p.high / p.low, normalized);
    const value = p.low + normalized * (p.high - p.low);
    return p.choices ? Math.round(value) : value;
}
function render() { panel().message("values", ...values); }
function autoTrim(mode) { panel().message("autoTrim", mode); }

function storedState() {
    const data = patch.getnamed("bankState").getvalueof();
    const value = Array.isArray(data) ? data[data.length - 1] : data;
    const state = String(value ?? "").replace(/^symbol[, ]/, "");
    return state === "0" ? "" : state;
}
function plugstate(data) {
    captureErrorShown = false;
    if (phase === "ready" && storedState() !== String(data))
        patch.getnamed("bankState").message("symbol", String(data));
}
const saveSoon = new Task(function () {
    if (phase === "ready") outlet(0, "snapshot");
}, this);
function queueSnapshot() {
    saveSoon.cancel();
    saveSoon.schedule(150);
}
const driveSlot = 1, punishSlot = 2, autoSlot = 7, trimSlot = 10;
let recalling = false;
function rememberTrimSource(index, value) {
    const enabled = index === autoSlot ? value : values[autoSlot];
    let source;
    if (index === trimSlot) source = -1;
    else if (enabled >= 0.5 && [autoSlot, driveSlot, punishSlot].includes(index)) {
        const drive = index === driveSlot ? value : values[driveSlot];
        const punish = index === punishSlot ? value : values[punishSlot];
        source = 1 + drive + 2 * Math.round(punish);
    } else return;
    const storage = patch.getnamed("trimOrigin");
    if (Math.abs(Number(storage.getvalueof()) - source) > 1e-6) storage.message("float", source);
}
function control(index, value) {
    const p = parameters[index];
    if (phase !== "ready" || !p) return;
    const normalized = normalize(p, value);
    if (index === trimSlot || Math.abs(values[index] - normalized) > 1e-6)
        rememberTrimSource(index, normalized);
    noteParameter(index, normalized);
    values[index] = normalized;
    outlet(0, "param", index, values[index]);
    // On recall with AutoGain enabled, the vendor preset carries a manual trim.
    if (index === trimSlot && values[autoSlot] >= 0.5) queueSnapshot();
    render();
}
function param(index, value) {
    const p = parameters[index];
    if (phase === "ready" && p)
        parameter(index).message(p.choices ? "int" : "float", denormalize(p, clamp01(value)));
}
function edited(index, value) {
    const p = parameters[index];
    if (phase !== "ready" || !p) return;
    const normalized = clamp01(value);
    if (editorShowing && Math.abs(normalize(p, parameter(index).getvalueof()) - normalized) > 1e-6) {
        if (!recalling) rememberTrimSource(index, normalized);
        parameter(index).message("set", denormalize(p, normalized));
    }
    noteParameter(index, normalized);
    values[index] = normalized;
    render();
    if (editorShowing) queueSnapshot();
}
function initialized() {
    for (const slot of [1, 3, 4, 5, 6, 10]) patch.bringtofront(parameter(slot));
    syncGains();
    watchTransport();
    if (phase === "cold") { render(); load(); }
}
function load() {
    clear();
    status("loading");
    loadTimeout.schedule(15000);
    loadSavedPlugin();
}
function ready() {
    loadTimeout.cancel();
    clear();
    const desired = parameters.map((p,i) => normalize(p, parameter(i).getvalueof()));
    const autoGainOn = desired[autoSlot] >= 0.5;
    const origin = Number(patch.getnamed("trimOrigin").getvalueof());
    recalling = true;
    status("ready");
    try {
        if (!autoGainOn && origin >= 1) {
            // Recreate the last automatic compensation before restoring later
            // edits made with AutoGain off. Its audible trim can be unreported.
            outlet(0,"reconcile",autoSlot,0);
            outlet(0,"reconcile",driveSlot,origin >= 3 ? origin-3 : origin-1);
            outlet(0,"reconcile",punishSlot,origin >= 3 ? 1 : 0);
            outlet(0,"param",autoSlot,1);
        }
        outlet(0,"reconcile",autoSlot,desired[autoSlot]);
        desired.forEach((v,i) => {
            if (i !== trimSlot && i !== autoSlot) outlet(0,"reconcile",i,v);
        });
        // While AutoGain is on, Drive or Punish can have changed the audible
        // trim since Live last stored OutputTrim. Leave the trim to Soundtoys.
        if (!autoGainOn && origin < 0) outlet(0,"param",trimSlot,desired[trimSlot]);
        outlet(0,"restoredTrimSource",autoGainOn ? 1 : origin);
    } finally { recalling = false; }
    if (!storedState() || storedState() === "none") outlet(0,"snapshot");
}
function action() {
    if (isLoadFailure(phase)) retry();
    else if (phase === "ready") outlet(0, "openPlugin");
}
function cleanup() {
    cancelRetry();
    if (transportObserver) { transportObserver.property = ""; transportObserver = null; }
    saveSoon.cancel();
    loadTimeout.cancel();
    clear();
}
