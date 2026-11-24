inlets = 1;
outlets = 2;
const patch = this.patcher;
const pluginName = "Soundtoys Decapitator";
const warningNamespace = "decapitator_missing_";
const pointerControls = ["preDrive", "postOutput", "driveLink"];
let phase = "cold", queue = null, key = "";
let reportedLatency = 0;
const applyLatency = new Task(function () { patch.setattr("latency", reportedLatency); }, this);
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

function latency(samples) {
    reportedLatency = Math.max(0, Math.round(Number(samples)));
    applyLatency.schedule(0);
}
function storedState() {
    const data = patch.getnamed("bankState").getvalueof();
    const value = Array.isArray(data) ? data[data.length - 1] : data;
    const state = String(value ?? "").replace(/^symbol[, ]/, "");
    return state === "0" ? "" : state;
}
function plugstate(data) {
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
function editEnd() {
    if (phase !== "ready") return;
    outlet(0, "snapshot");
    queueSnapshot();
}
function control(index, value) {
    const p = parameters[index];
    if (phase !== "ready" || !p) return;
    values[index] = normalize(p, value);
    outlet(0, "param", index, values[index]);
    render();
    queueSnapshot();
}
function param(index, value) {
    const p = parameters[index];
    if (phase === "ready" && p)
        parameter(index).message(p.choices ? "int" : "float", denormalize(p, clamp01(value)));
}
function edited(index, value) {
    const p = parameters[index];
    if (phase !== "ready" || !p) return;
    values[index] = clamp01(value);
    parameter(index).message("set", denormalize(p, values[index]));
    render();
    queueSnapshot();
}
function initialized() {
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
    // The adapter reads the restored parameters. Replaying Live controls here
    // would overwrite the trim that Decapitator calculated and stored itself.
    status("ready");
    queueSnapshot();
}
function action() {
    if (isLoadFailure(phase)) retry();
    else if (phase === "ready") outlet(0, "openPlugin");
}
function cleanup() {
    cancelRetry();
    if (transportObserver) { transportObserver.property = ""; transportObserver = null; }
    applyLatency.cancel();
    saveSoon.cancel();
    loadTimeout.cancel();
    clear();
}
