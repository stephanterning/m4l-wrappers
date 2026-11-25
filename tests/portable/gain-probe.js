// Record the two gain stages exactly as embedded in the device. Output is muted.
inlets = 1;
outlets = 3;
const tasks = [];
let started = false;
let index = 0;

const stages = [
    ["unity-dry", () => {}],
    ["trim-while-dry", () => { outlet(0, "output", 12); outlet(1, "output", -18); }],
    ["wet", () => outlet(1, "wet", 1)],
    ["wet-retarget", () => { outlet(0, "output", -6); outlet(1, "output", 18); }],
    ["missing", () => outlet(1, "wet", 0)],
    ["new-trim-while-missing", () => outlet(1, "output", -12)],
    ["recovered", () => outlet(1, "wet", 1)]
];

function log(value) {
    const f = new File(resultFile, "readwrite");
    f.position = f.eof;
    f.writeline(JSON.stringify(value));
    f.close();
}

function later(delay, action) {
    const job = new Task(() => {
        try { action(); }
        catch (err) { log(["error", String(err)]); }
    }, this);
    tasks.push(job);
    job.schedule(delay);
}

function readSignal(buffer, channel) {
    const runs = [];
    for (const value of buffer.peek(channel, 0, buffer.framecount())) {
        const last = runs[runs.length - 1];
        if (last && last[0] === value) last[1]++;
        else runs.push([value, 1]);
    }
    // All test signals have a nonzero floor. Drop unused zeroes after record~ stops.
    if (runs.length && runs[runs.length - 1][0] === 0) runs.pop();
    return runs;
}

function recordStage() {
    const [name, command] = stages[index++];
    const recorder = this.patcher.getnamed("recorder");
    this.patcher.getnamed("samples").message("clear");
    recorder.message(1);
    later(60, command);
    later(180, () => {
        recorder.message(0);
        const buffer = new Buffer(bufferName);
        const channels = [];
        for (let i = 1; i <= 4; ++i) channels.push(readSignal(buffer, i));
        log([name, buffer.framecount(), channels]);
        if (index < stages.length) later(60, recordStage);
        else { outlet(2, 0); log(["done"]); }
    });
}

function loadbang() {
    if (started) return;
    started = true;
    later(1000, () => outlet(2, 1));
    later(2500, recordStage);
}
