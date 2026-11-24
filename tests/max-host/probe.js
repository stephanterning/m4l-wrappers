// Embedded in an isolated Max patch by probe.py. All paths are supplied by the runner.
inlets = 7;
outlets = 4;
var stage = "startup";
var tasks = [];
var params = [];
var host;
function record(event, args) {
    var file = new File(config.log, "readwrite");
    if (file.isopen) {
        file.position = file.eof;
        file.writeline(JSON.stringify([stage, event, args]));
        file.close();
    }
}
function later(ms, callback) {
    var task = new Task(callback, this);
    tasks.push(task);
    task.schedule(ms);
}
function query(all) {
    record("currentplug", [host.getattr("currentplug")]);
    [-4, -8, -10].forEach(function (p) { outlet(0, "get", p); });
    if (all) {
        for (var i = 1; i <= params.length; ++i) outlet(0, "get", i);
    } else if (params.length > 1) outlet(0, "get", 2);
}
function anything() {
    if (inlet === 1 && stage === "installed") params.push(messagename);
    record(inlet + ":" + messagename, arrayfromargs(arguments));
}
function list() { record(inlet + ":list", arrayfromargs(arguments)); }
function msg_int(v) { record(inlet + ":int", [v]); }
function msg_float(v) { record(inlet + ":float", [v]); }
function bang() { record(inlet + ":bang", []); }

function capturePulse(start, label) {
    later(start, function () {
        stage = label;
        query(false);
        outlet(2, 1);
    });
    later(start + 100, function () { outlet(3, "bang"); });
    later(start + 250, function () {
        outlet(2, 0);
        var buffer = new Buffer("host-probe-impulse");
        var peaks = [1, 2].map(function (channel) {
            var samples = buffer.peek(channel, 0, buffer.framecount());
            var index = 0;
            for (var j = 1; j < samples.length; ++j) {
                if (Math.abs(samples[j]) > Math.abs(samples[index])) index = j;
            }
            return [index, samples[index]];
        });
        record("peaks", peaks);
    });
}
function loadbang() {
    host = this.patcher.getnamed("effect");
    outlet(1, 1);
    later(700, function () {
        stage = "unavailable";
        outlet(0, "plug_vst3", "M4L Wrappers Unavailable QA Fixture");
    });
    capturePulse(1800, "unavailable");
    later(2300, function () { if (config.scan) outlet(0, "scan", 1); });
    later(3300, function () {
        stage = "retry";
        if (config.path) outlet(0, "plug", config.path);
        else outlet(0, "plug_vst3", config.plugin);
    });
    later(6800, function () {
        stage = "installed";
        outlet(0, "params");
        query(true);
        outlet(1, 1);
    });
    // Measure quality before loading any legacy state. Non-flat filters can move an impulse peak.
    [0, 0.5, 1, 0.5].forEach(function (value, i) {
        var start = 7800 + 1150 * i;
        later(start, function () {
            stage = "quality-" + i;
            var index = params.indexOf("Quality") + 1;
            if (index) outlet(0, [index, value]);
        });
        capturePulse(start + 500, "quality-" + i);
    });
    later(13000, function () {
        stage = "edited";
        if (params.length > 1) outlet(0, [2, 0.75]);
        query(false);
    });
    later(14000, function () {
        stage = "read-v13";
        if (config.preset) outlet(0, "read", config.preset);
    });
    later(15500, function () { query(true); });
    later(16300, function () {
        stage = "max-snapshot";
        if (params.length > 1) outlet(0, [2, 0.625]);
    });
    later(17400, function () { outlet(0, "snapshot", config.snapshot); });
    later(18600, function () { if (params.length > 1) outlet(0, [2, 0.25]); query(false); });
    later(19600, function () { stage = "max-restore"; outlet(0, "restore", config.snapshot); });
    later(20800, function () { query(true); });
    later(21600, function () {
        stage = "done";
        outlet(1, 0);
        record("end", []);
    });
}
