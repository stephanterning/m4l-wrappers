let startupWarningPending = true;
let holdingRetryPanel = false;
const retrySearch = new Task(load, this);
const releaseRetryPanel = new Task(function () {
    holdingRetryPanel = false;
    showPanelStatus(phase);
}, this);

function status(value) {
    phase = value;
    if (value === "ready") startupWarningPending = false;
    if (!holdingRetryPanel || value === "loading") showPanelStatus(value);
}

function showPanelStatus(value) {
    panel().message("status", value);
    const overlay = patch.getnamed("warningOverlay");
    const visible = value === "missing" || value === "loading";
    overlay.hidden = !visible;
    overlay.ignoreclick = !visible;
    if (visible) patch.bringtofront(overlay);
    overlay.message("status", value);
}
function retry() {
    if (holdingRetryPanel || phase !== "missing") return;
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
    loadTimeout.cancel(); status("missing");
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
    queue = new Dict(warningNamespace + set);
    queue.set(key, track); queue.set("last", String(Date.now())); warningTask.schedule(650);
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
    const tracks = Array.from(new Set(keys.map(k => String(queue.get(k)))));
    queue.clear();
    if (tracks.length) {
        const message = [
            pluginName + " (VST3) could not be loaded.",
            "Tracks:\n" + tracks.join("\n"),
            "Audio passes through dry. Restore the VST3 installation, then click Retry in the device."
        ].join("\n\n");
        outlet(1, "symbol", message);
    }
}
