function missing() {
    loadTimeout.cancel(); status("missing");
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
    if (tracks.length) outlet(1, "symbol", pluginName + " (VST3) could not be loaded. Tracks: " + tracks.join(", ") +
        ". Audio passes through dry. Restore the VST3 installation, then click Retry in the device.");
}
