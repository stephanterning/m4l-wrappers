const pointerControls = ["preDrive", "postOutput", "driveLink"];
const pluginName = "Wavesfactory Spectre";
inlets = 1;
outlets = 2;
const patch = this.patcher;
const parameters = [{"name":"Band 1 Frequency","low":20.0,"high":20000.0,"choices":null,"log":true,"unit":3,"initial":42.08000096992389},{"name":"Band 1 Gain","low":0.0,"high":12.0,"choices":null,"log":false,"unit":4,"initial":0.0},{"name":"Band 1 Q","low":0.1,"high":10.0,"choices":null,"log":false,"unit":1,"initial":0.7070000234991312},{"name":"Band 1 On","low":0,"high":1,"choices":["Off","On"],"log":false,"unit":0,"initial":1},{"name":"Band 1 Color","low":0,"high":10,"choices":["Solid","Warm","Tube","Tape","Class B","Diode","Digital","Bit","Rectify","Half Rectify","Clean"],"log":false,"unit":0,"initial":0},{"name":"Band 1 Processing","low":0,"high":4,"choices":["Stereo","Left","Right","Mid","Side"],"log":false,"unit":0,"initial":0},{"name":"Band 2 Frequency","low":20.0,"high":20000.0,"choices":null,"log":true,"unit":3,"initial":164.0000025831755},{"name":"Band 2 Gain","low":0.0,"high":12.0,"choices":null,"log":false,"unit":4,"initial":0.0},{"name":"Band 2 Q","low":0.1,"high":10.0,"choices":null,"log":false,"unit":1,"initial":0.7070000234991312},{"name":"Band 2 On","low":0,"high":1,"choices":["Off","On"],"log":false,"unit":0,"initial":1},{"name":"Band 2 Color","low":0,"high":10,"choices":["Solid","Warm","Tube","Tape","Class B","Diode","Digital","Bit","Rectify","Half Rectify","Clean"],"log":false,"unit":0,"initial":0},{"name":"Band 2 Processing","low":0,"high":4,"choices":["Stereo","Left","Right","Mid","Side"],"log":false,"unit":0,"initial":0},{"name":"Band 3 Frequency","low":20.0,"high":20000.0,"choices":null,"log":true,"unit":3,"initial":632.5000626229526},{"name":"Band 3 Gain","low":0.0,"high":12.0,"choices":null,"log":false,"unit":4,"initial":0.0},{"name":"Band 3 Q","low":0.1,"high":10.0,"choices":null,"log":false,"unit":1,"initial":0.7070000234991312},{"name":"Band 3 On","low":0,"high":1,"choices":["Off","On"],"log":false,"unit":0,"initial":1},{"name":"Band 3 Color","low":0,"high":10,"choices":["Solid","Warm","Tube","Tape","Class B","Diode","Digital","Bit","Rectify","Half Rectify","Clean"],"log":false,"unit":0,"initial":0},{"name":"Band 3 Processing","low":0,"high":4,"choices":["Stereo","Left","Right","Mid","Side"],"log":false,"unit":0,"initial":0},{"name":"Band 4 Frequency","low":20.0,"high":20000.0,"choices":null,"log":true,"unit":3,"initial":2459.9995023035603},{"name":"Band 4 Gain","low":0.0,"high":12.0,"choices":null,"log":false,"unit":4,"initial":0.0},{"name":"Band 4 Q","low":0.1,"high":10.0,"choices":null,"log":false,"unit":1,"initial":0.7070000234991312},{"name":"Band 4 On","low":0,"high":1,"choices":["Off","On"],"log":false,"unit":0,"initial":1},{"name":"Band 4 Color","low":0,"high":10,"choices":["Solid","Warm","Tube","Tape","Class B","Diode","Digital","Bit","Rectify","Half Rectify","Clean"],"log":false,"unit":0,"initial":0},{"name":"Band 4 Processing","low":0,"high":4,"choices":["Stereo","Left","Right","Mid","Side"],"log":false,"unit":0,"initial":0},{"name":"Band 5 Frequency","low":20.0,"high":20000.0,"choices":null,"log":true,"unit":3,"initial":9600.000806923503},{"name":"Band 5 Gain","low":0.0,"high":12.0,"choices":null,"log":false,"unit":4,"initial":0.0},{"name":"Band 5 Q","low":0.1,"high":10.0,"choices":null,"log":false,"unit":1,"initial":0.7070000234991312},{"name":"Band 5 On","low":0,"high":1,"choices":["Off","On"],"log":false,"unit":0,"initial":1},{"name":"Band 5 Color","low":0,"high":10,"choices":["Solid","Warm","Tube","Tape","Class B","Diode","Digital","Bit","Rectify","Half Rectify","Clean"],"log":false,"unit":0,"initial":0},{"name":"Band 5 Processing","low":0,"high":4,"choices":["Stereo","Left","Right","Mid","Side"],"log":false,"unit":0,"initial":0},{"name":"Spectre Input","low":-12.0,"high":12.0,"choices":null,"log":false,"unit":4,"initial":0.0},{"name":"Spectre Output","low":-12.0,"high":12.0,"choices":null,"log":false,"unit":4,"initial":0.0},{"name":"Mix","low":0.0,"high":100.0,"choices":null,"log":false,"unit":5,"initial":50.0},{"name":"Input Compensation","low":0,"high":1,"choices":["Off","On"],"log":false,"unit":0,"initial":0},{"name":"Quality","low":0,"high":2,"choices":["Normal","Good","Best"],"log":false,"unit":0,"initial":1},{"name":"De-Emphasis","low":0,"high":1,"choices":["Disabled","Enabled"],"log":false,"unit":0,"initial":1},{"name":"Mode","low":0,"high":2,"choices":["Subtle","Medium","Aggressive"],"log":false,"unit":0,"initial":0},{"name":"Processing","low":0,"high":4,"choices":["Stereo","Left","Right","Mid","Side"],"log":false,"unit":0,"initial":0},{"name":"Spectre Bypass","low":0,"high":1,"choices":["Off","On"],"log":false,"unit":0,"initial":0}];
let phase = "cold", queue = null, key = "";
function toLive(index, raw) {
    const p = parameters[index];
    const n = Math.max(0, Math.min(1, Number(raw)));
    if (p.log) return p.low * Math.pow(p.high / p.low, n);
    const scaled = p.low + n * (p.high - p.low);
    return p.choices ? Math.round(scaled) : scaled;
}
function toPlugin(index, value) {
    const p = parameters[index];
    const v = Math.max(p.low, Math.min(p.high, Number(value)));
    return p.log ? Math.log(v / p.low) / Math.log(p.high / p.low) : (v - p.low) / (p.high - p.low);
}
function panel() { return patch.getnamed("face"); }
// Show only the three native dials belonging to the current inspector.
let visibleMappingBase = -1;
function mappingTargets(base) {
    if (base === visibleMappingBase) return;
    for (let column = 0; column < 3; column++) {
        if (visibleMappingBase >= 0) patch.getnamed("param" + (visibleMappingBase + column)).hidden = true;
        if (base >= 0) {
            const dial = patch.getnamed("param" + (base + column));
            dial.hidden = false;
            patch.bringtofront(dial);
        }
    }
    visibleMappingBase = base;
}
function storedState() {
    const data = patch.getnamed("bankState").getvalueof();
    return String(Array.isArray(data) ? data[data.length - 1] : data || "").replace(/^symbol[, ]/, "");
}
function plugstate(data) {
    captureErrorShown = false;
    if (phase !== "ready") return;
    if (storedState() !== String(data)) patch.getnamed("bankState").message("symbol", String(data));
}
const snapshotTask = new Task(function () { if (phase === "ready") outlet(0, "snapshot"); }, this);
function snapshotSoon() {
    snapshotTask.cancel();
    snapshotTask.schedule(375);
}
function control(index, value) {
    if (!parameters[index]) return;
    const normalized = toPlugin(index, value);
    panel().message("param", index, normalized);
    if (phase === "ready") {
        noteParameter(index,normalized);
        outlet(0, "param", index, normalized);
    }
}
function param(index, normalized) {
    // Edits from the embedded panel pass through the Live parameter for automation and recall.
    if (phase === "ready" && parameters[index]) patch.getnamed("param"+index).message(parameters[index].choices ? "int" : "float", toLive(index, normalized));
}
function edited(index, normalized) {
    if (phase !== "ready" || !parameters[index]) return;
    const dial = patch.getnamed("param"+index);
    if (editorShowing && Math.abs(toPlugin(index, dial.getvalueof()) - normalized) > 1e-6)
        dial.message("set", toLive(index, normalized));
    noteParameter(index, normalized);
    panel().message("param", index, normalized);
    if (editorShowing) snapshotSoon();
}
function syncPlugin() {
    const values = parameters.map((p, i) => toPlugin(i, patch.getnamed("param"+i).getvalueof()));
    panel().message("params", ...values);
    if (phase === "ready") values.forEach((v, i) => outlet(0, "param", i, v));
}
const loadTimeout = new Task(function () { if (phase === "loading") loaderror("The VST3 host did not respond."); }, this);
const warningTask = new Task(flush, this);
function initialized() {
    syncGains();
    watchTransport();
    if (phase === "cold") { syncPlugin(); load(); }
    else if (phase === "ready") syncPlugin();
}
function load() {
    clear(); status("loading"); loadTimeout.schedule(15000);
    loadSavedPlugin();
}
function ready() {
    loadTimeout.cancel(); clear(); status("ready"); syncPlugin();
    if (!storedState() || storedState() === "none") outlet(0,"snapshot");
}
var pluginEditorMessage = "open";
function action() {
    if (isLoadFailure(phase)) retry();
    else if (phase === "ready") outlet(0, pluginEditorMessage);
}
function cleanup() {
    cancelRetry();
    if (transportObserver) { transportObserver.property = ""; transportObserver = null; }
    snapshotTask.cancel(); loadTimeout.cancel(); clear();
}

