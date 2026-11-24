let startupWarningPending = true;
let holdingRetryPanel = false;
let editorShowing = false;
let failureDetail = "";
const retrySearch = new Task(load, this);
const releaseRetryPanel = new Task(function () {
    holdingRetryPanel = false;
    showPanelStatus(phase);
}, this);

function status(value) {
    phase = value;
    if (value !== "ready") editorShowing = false;
    const enabled = value === "ready" ? 1 : 0;
    for (const name of pointerControls) patch.getnamed(name).message("active", enabled && !editorShowing ? 1 : 0);
    if (!enabled) setMatchAvailability([false,false,false]);
    if (value !== "loaderror") failureDetail = "";
    if (value === "ready") startupWarningPending = false;
    if (!holdingRetryPanel || value === "loading") showPanelStatus(value);
}

function loadSavedPlugin() {
    const state = storedState();
    // pattr stores "none" in a fresh device. Only a new instance gets the plug-in defaults.
    outlet(0, "load", !state || state === "none" ? "-" : state);
}

function isLoadFailure(value) { return value === "missing" || value === "loaderror"; }

function showPanelStatus(value) {
    if (value === "ready" && editorShowing) value = "editor";
    panel().message("status", value);
    const overlay = patch.getnamed("warningOverlay");
    const visible = isLoadFailure(value) || value === "loading" || value === "editor";
    overlay.hidden = !visible;
    overlay.ignoreclick = !visible;
    if (visible) patch.bringtofront(overlay);
    overlay.message("status", value, failureDetail);
}
function editorWindow(value) {
    const open = phase === "ready" && Number(value) === 1;
    if (editorShowing === open) return;
    editorShowing = open;
    for (const name of pointerControls) patch.getnamed(name).message("active", open ? 0 : 1);
    for (let i = 0; i < canMatch.length; i++)
        patch.getnamed("match" + i).message("active", !open && canMatch[i] ? 1 : 0);
    if (!holdingRetryPanel) showPanelStatus(phase);
}
function closeEditor() {
    if (editorShowing) outlet(0, "closePlugin");
}
function retry() {
    if (holdingRetryPanel || !isLoadFailure(phase)) return;
    startupWarningPending = false;
    holdingRetryPanel = true;
    clear();
    status("loading");
    releaseRetryPanel.schedule(1000);
    // Give Max a redraw opportunity before VST3 discovery runs on the main thread.
    retrySearch.schedule(50);
}
function cancelRetry() {
    retrySearch.cancel();
    releaseRetryPanel.cancel();
    holdingRetryPanel = false;
}
function missing() {
    recordFailure("missing", "");
}
function loaderror(reason) {
    recordFailure("loaderror", String(reason || "The VST3 host could not initialize the plug-in."));
}
function recordFailure(value, detail) {
    loadTimeout.cancel(); failureDetail = detail; status(value);
    if (!startupWarningPending) return;
    startupWarningPending = false;
    let track = "Unknown track", set = "local";
    try {
        const device = new LiveAPI(null, "this_device");
        key = "d" + device.id; set = String(new LiveAPI(null, "live_set").id);
        for (let i = 0; Number(device.id) && i < 64; i++) {
            if (device.type === "Track") { track = String(device.get("name")); break; }
            device.goto("canonical_parent");
        }
    } catch(e) { key = "d" + Date.now() + "_" + Math.random(); }
    queue = new Dict(warningNamespace + "v2_" + set);
    queue.set(key, JSON.stringify([track, detail])); queue.set("last", String(Date.now())); warningTask.schedule(650);
}
function clear() {
    warningTask.cancel();
    if (queue && key && queue.contains(key)) queue.remove(key);
    key = "";
}
function flush() {
    if (!queue || !queue.contains("last")) return;
    const elapsed = Date.now() - Number(queue.get("last"));
    if (elapsed < 600) { warningTask.schedule(650 - elapsed); return; }
    const keys = [].concat(queue.getkeys() || []).filter(k => k !== "last");
    const groups = new Map();
    for (const k of keys) {
        const [track, detail] = JSON.parse(String(queue.get(k)));
        if (!groups.has(detail)) groups.set(detail, new Set());
        groups.get(detail).add(track);
    }
    queue.clear();
    if (!groups.size) return;
    const paragraphs = [];
    for (const [detail, tracks] of groups) {
        paragraphs.push(detail ? "An error occurred while loading " + pluginName + " (VST3).\n" + detail
                               : pluginName + " (VST3) was not found.");
        paragraphs.push("Tracks:\n" + Array.from(tracks).join("\n"));
    }
    paragraphs.push(groups.size === 1 && groups.has("")
        ? "Audio passes through dry. Restore the VST3 installation, then click Retry in the device."
        : "Audio passes through dry. Click Retry in the device to try again.");
    outlet(1, "symbol", paragraphs.join("\n\n"));
}
