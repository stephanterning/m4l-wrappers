// This patch runs in a separate Max process. Its only hardware output is silence.
inlets = 2;
outlets = 6;
let phase = "boot", sequence = 0, validTicks = 0, allTicks = 0;
let started = false, rate = 0, tasks = [];

function later(ms, action) {
    const task = new Task(action, this);
    tasks.push(task);
    task.schedule(ms);
}
function log() {
    const file = new File(eventsPath, "readwrite");
    file.position = file.eof;
    file.writeline(JSON.stringify(arrayfromargs(arguments)));
    file.close();
}
function enter(name) {
    phase = name;
    allTicks = validTicks = 0;
    log("phase", phase);
}
function sampleRate(hz) {
    if (hz > 0) { rate = hz; log("rate", hz); }
}
function vectorSize(frames) { if (frames > 0) log("vector", frames); }
function loadbang() {
    if (started) return;
    started = true;
    later(1500, function () {
        outlet(1, 1);
        later(500, function () {
            outlet(0, "wet", 1);
            outlet(2, 1);
            enter("tones");
            outlet(0, "metering", ++sequence * 2 + 1);
        });
    });
}
function levels(epoch, valid, settled, il, ir, ip, ol, orms, op) {
    if (epoch !== sequence) return;
    allTicks++;
    if (valid) validTicks++;
    log("levels", phase, valid, settled, il, ir, ip, ol, orms, op);
    if (phase === "tones" && validTicks === 3) {
        enter("dry");
        outlet(0, "wet", 0);
    } else if (phase === "dry" && !settled) {
        enter("settling");
        outlet(0, "wet", 1);
        outlet(0, "output", -3);
    } else if (phase === "settling" && settled && allTicks > 1) {
        enter("downward-ramp");
        outlet(5, [0.25, 5]);
        outlet(0, "output", -12.041199826559248);
        outlet(0, "metering", ++sequence * 2 + 1);
    } else if (phase === "downward-ramp" && validTicks === 4) {
        outlet(2, 1e-11);
        outlet(5, [1, 5]);
        outlet(0, "output", 0);
        enter("near-silence");
        outlet(0, "metering", ++sequence * 2 + 1);
    } else if (phase === "near-silence" && validTicks === 2) {
        outlet(2, 0);
        enter("silence");
        outlet(0, "metering", ++sequence * 2 + 1);
    } else if (phase === "silence" && validTicks === 2) {
        enter("pulse");
        outlet(3, -0.8);
        outlet(4, -0.7);
    } else if (phase === "pulse" && allTicks > 6 && ip <= -239 && op <= -239) {
        outlet(0, "metering", sequence * 2);
        enter("stopped");
        later(500, function () {
            // Clear while the transport is stopped; then resume this epoch.
            outlet(0, "metering", ++sequence * 2);
            later(100, function () {
                outlet(2, 1);
                enter("after-stop");
                outlet(0, "metering", sequence * 2 + 1);
            });
        });
    } else if (phase === "after-stop" && validTicks === 3) {
        enter("dsp-off");
        outlet(1, 0);
        later(500, function () {
            enter("after-dsp-restart");
            outlet(1, 1);
        });
    } else if (phase === "after-dsp-restart" && validTicks === 3) {
        enter("done");
        outlet(1, 0);
        log("end", rate);
    }
}
