const assert = require("node:assert/strict");
const vm = require("node:vm");
const fs = require("node:fs");
const path = require("node:path");

const events = [];
const jobs = [];
class Task {
    constructor(run) { this.run = run; }
    schedule() { this.cancel(); jobs.push(this); }
    cancel() { const i = jobs.indexOf(this); if (i >= 0) jobs.splice(i, 1); }
}
const files = new Map();
class File {
    constructor(key, mode) { this.key = key; this.isopen = mode === "write" || files.has(key); this.position = 0; }
    get eof() { return (files.get(this.key) || []).length; }
    set eof(n) { files.set(this.key, (files.get(this.key) || []).slice(0,n)); }
    writebytes(bytes) { files.set(this.key, (files.get(this.key) || []).concat(Array.from(bytes))); this.position += bytes.length; }
    readbytes(n) { return files.get(this.key).slice(0,n); }
    close() {}
}
const product = {id: 17, cid:"0123456789ABCDEF0123456789ABCDEF", name:"Fixture", parameters:["Gain","Quality"],
    latencyParameters:["Quality"]};
let pluginLatency = 60;
let storedValue = 0.7, readParameter = 0;
let windowVisible = false;
let installed = true, wrong = false, missingParameter = false, corruptRead = false;
const globals = {Task, File, product, post(){}, patcher:{getnamed(){return {getattr(){return installed ? ["C74_VST3:/Fixture",17]:null;}};}},
    outlet(out, op, ...args) {
        events.push([out,op,...args]);
        if (out !== 0) return;
        if (Array.isArray(op)) readParameter = op[1];
        if (op === "open") windowVisible = true;
        if (op === "wclose") windowVisible = false;
        if (op === "get" && args[0] === -9) {
            context.inlet = 2;
            context.list(-9, ...(windowVisible ? [-200,100,550,600] : [0,0,500,200]));
            context.inlet = 0;
        } else if (op === "get") context.parameterChanged(args[0], args[0] === -8 ? (wrong ? 99 : 17) : args[0] === -10 ? pluginLatency : readParameter);
        if (op === "params") {
            context.inlet = 1;
            for (const name of missingParameter ? ["Gain"] : ["Quality","Gain"]) { context.messagename=name;context.anything(); }
            context.inlet = 0;
        }
        if (op === "read" && !corruptRead) readParameter = storedValue;
        if (op === "write") {
            const preset = Array.from(context.legacyPreset([50,60,70]));
            if (wrong) preset[8] = 88;
            files.set(args[0],preset);
        }
    }};
const source = fs.readFileSync(path.join(__dirname, "../../host/adapter.js"), "utf8");
function instantiate(overrides = {}) {
    const instance = vm.createContext({...globals,...overrides});
    vm.runInContext(source, instance);
    return instance;
}
let context = instantiate();
function drain(){ while(jobs.length) jobs.shift().run(); }
function reset(){events.length=0;}
function was(out,op,...args) {return events.some(e=>JSON.stringify(e)===JSON.stringify([out,op,...args]));}
for(const n of [1,2,3,256,4000,300000]){
    const raw=Array.from({length:n},(_,i)=>(i*13)%256);
    const encoded=context.encode(raw);assert.equal(encoded,Buffer.from(raw).toString("base64"));
    assert.deepEqual(Array.from(context.parsePreset(context.legacyPreset(context.decode(encoded))).component),raw);
}
const largeBank=context.legacyPreset(Array.from({length:300000},(_,i)=>i % 251));
context.writeFile("big",largeBank);
assert.equal(context.parsePreset(context.readFile("big")).component.length,300000);
const invalid=Array.from(context.legacyPreset([1]));invalid[40]=255;
assert.throws(()=>context.parsePreset(invalid));
context.load("AQID");drain();assert.ok(was(1,"ready") && was(3,"wet",1));assert.ok(was(1,"latency",60));
reset();context.param(0,.4);assert.ok(was(0,[2,.4]));
assert.ok(!was(0, "get", -10));
context.param(0, .5);
context.param(0, .6);
assert.equal(jobs.length, 1);
pluginLatency = 48; // A future plug-in version adds lookahead to an existing control.
drain();
assert.ok(was(1, "latency", 48));
pluginLatency = 60;
context.refreshLatency();
drain();
reset();
context.param(1, 1);
assert.ok(was(0, "get", -10) && !was(1, "latency", 60));
pluginLatency = 64; // The processor applies Quality on the next audio block.
drain();
assert.ok(was(1, "latency", 64));
reset();
pluginLatency = 0;
context.parameterChanged(1, 0); // A mode change from the vendor editor.
assert.ok(was(1, "latency", 0), "Publish the new delay before deferred work runs");
drain();
assert.equal(events.filter(e => e[1] === "latency").length, 1);
reset();
pluginLatency = 60;
context.refreshLatency(); // DSP rate change.
assert.ok(was(1, "latency", 60));
drain();
storedValue=.25;context.load("AQID");drain();assert.ok(was(1,"ready"));
context.snapshot();assert.ok(was(1,"plugstate","preset1_"+context.encode(context.legacyPreset([50,60,70]))));
wrong=true;reset();context.snapshot();
assert.ok(events.some(e=>e[1]==="stateerror") && !events.some(e=>e[1]==="plugstate"));
wrong=false;
for(const failure of ["absent","wrong","missing parameter","corrupt preset","unconfirmed restore"]){
    reset();installed=failure!=="absent";wrong=failure==="wrong";missingParameter=failure==="missing parameter";corruptRead=failure==="unconfirmed restore";
    context.load(failure==="corrupt preset"?"bad!":"AQID");drain();context.snapshot();
    assert.ok(!events.some(e => e[1] === "scan"), "Retry must not open a Max scan dialog");
    assert.ok(was(3,"wet",0) && events.some(e=>e[1]==="loaderror") && !events.some(e=>["ready","plugstate"].includes(e[1])),failure);
}
reset();installed=true;wrong=false;missingParameter=false;corruptRead=false;context.load("AQID");drain();assert.ok(was(1,"ready"));
reset();context.openPlugin();assert.ok(was(0, "open") && was(1, "editorWindow", 1));
windowVisible = false;
drain();
assert.ok(was(1, "editorWindow", 0) && !was(0, "wclose"));
reset();context.openPlugin();context.closePlugin();drain();
assert.ok(was(0, "wclose") && was(1, "editorWindow", 0));
context.load("AQID");reset();context.openPlugin();assert.deepEqual(events, []);
drain();


// A saved Live Set contains the last good token even if the device stays missing
// through a save and relaunch. A fresh adapter can subsequently load that token.
const lastGood = Buffer.from([50,60,70]).toString("base64");
const savedFile = JSON.stringify({bank:lastGood});
for (let reopen = 0; reopen < 2; ++reopen) {
    context = instantiate();
    installed = false;
    reset();
    context.load(JSON.parse(savedFile).bank);
    drain();
    context.snapshot();
    assert.ok(!events.some(e => e[1] === "plugstate") && was(3,"wet",0));
}
installed = true;
reset();
context.load(JSON.parse(savedFile).bank);
drain();
assert.ok(was(1,"ready") && was(3,"wet",1));

const decapitator = {
    ...product,
    name: "Decapitator",
    parameters: ["Style","Drive","Punish","LowCut","Tone","HighCut","Mix","AutoGain","LowThump","HighSlope","OutputTrim"],
    restoreFromPlugin: true,
    restoreProbe: 6,
    autoGain: {drive: 1, punish: 2, enabled: 7, trim: 10}
};
let storedTrimSource = 0;
const pluginNames = ["Bypass", ...decapitator.parameters];
const saved = [0, 0.25, 0.5, 0, 0, 0, 1, 0.9, 1, 0, 0, 0.67];
const working = [...saved];
const ordinal = slot => pluginNames.indexOf(decapitator.parameters[slot]) + 1;
const drive = ordinal(decapitator.autoGain.drive);
const punish = ordinal(decapitator.autoGain.punish);
const enabled = ordinal(decapitator.autoGain.enabled);
const trim = ordinal(decapitator.autoGain.trim);
context = instantiate({
    product: decapitator,
    outlet(out, op, ...args) {
        events.push([out, op, ...args]);
        if (out === 1 && op === "ready") context.restoredTrimSource(storedTrimSource);
        if (out !== 0) return;
        if (Array.isArray(op)) {
            const [index, value] = op;
            working[index - 1] = value;
            context.parameterChanged(index, value); // vst~ echoes the parameter as it is written.
        }
        if (op === "get") context.parameterChanged(args[0], args[0] === -10 ? 62 : working[args[0] - 1]);
        if (op === "params") {
            context.inlet = 1;
            for (const name of pluginNames) {
                context.messagename = name;
                context.anything();
            }
            context.inlet = 0;
        }
        if (op === "read") working.splice(0, working.length, ...saved);
        if (op === "write") files.set(args[0], Array.from(context.legacyPreset([50, 60, 70])));
    }
});
reset();
const preset = "preset1_" + context.encode(context.legacyPreset([50, 60, 70]));
context.load(preset);
drain();
assert.ok(was(1, "ready") && was(1, "latency", 62) && was(1, "autoTrim", 0));
assert.ok(was(1, "edited", decapitator.autoGain.trim, 0.67), "Display the imported OutputTrim");
assert.deepEqual(events.filter(([out, op]) => out === 0 && Array.isArray(op)).map(e => Array.from(e[1])),
                 [[ordinal(decapitator.restoreProbe), 0.25]], "Only the muted, unrelated recall probe may write during load");
reset();
context.param(decapitator.autoGain.drive, 0.7);
assert.ok(was(0, [drive, 0.7]) && was(1, "autoTrim", 1));
assert.ok(!was(0, "get", trim) && !was(1, "autoTrim", 0), "Drive's echo is not an updated trim");
context.snapshot();
assert.ok(was(1, "plugstate", preset), "Decapitator saves the complete preset");
assert.ok(!was(1, "autoTrim", 0), "Exporting the preset does not verify the live display");
reset();
context.param(decapitator.autoGain.enabled, 0);
assert.ok(was(0, [enabled, 0]) && was(1, "autoTrim", 2) && !was(1, "autoTrim", 0));
reset();
context.param(decapitator.autoGain.enabled, 1);
assert.ok(was(0, [enabled, 1]) && was(1, "autoTrim", 1));
reset();
context.param(decapitator.autoGain.trim, 0.75);
assert.ok(was(0, [trim, 0.75]) && was(1, "autoTrim", 0));
reset();
context.param(decapitator.autoGain.drive, 0.7);
assert.deepEqual(events, [], "An identical Drive echo must preserve manual trim");
context.param(decapitator.autoGain.drive, 0.4);
assert.ok(was(1, "autoTrim", 1));
reset();
context.parameterChanged(trim, 0.3);
context.parameterChanged(drive, 0.6);
assert.ok(was(1, "autoTrim", 0) && !was(1, "autoTrim", 1), "Editor event order preserves an actual trim update");
reset();
context.param(decapitator.autoGain.punish, 1);
assert.ok(was(0, [punish, 1]) && was(1, "autoTrim", 1));
context.parameterChanged(trim, 0.3);
context.param(decapitator.autoGain.enabled, 0);
reset();
context.param(decapitator.autoGain.enabled, 1);
assert.ok(was(0, [enabled, 1]) && was(1, "autoTrim", 1), "Turning AutoGain on can change a known trim");
for (const enabledAtSave of [0,1]) {
    saved[enabled-1] = enabledAtSave;
    storedTrimSource = 1.8;
    reset(); context.load(preset); drain();
    assert.equal(events.filter(e=>e[1]==="autoTrim").at(-1)[2],enabledAtSave ? 1 : 2);
}
let located = false, available = true;
const discovery = [];
const nativeFixture = {
    product:{...decapitator, sdkHost:true},
    patcher:{getnamed(name) {
        assert.equal(name,"maxLookup");
        return {
            getattr:()=>located ? ["C74_VST3:/Decapitator",17] : [],
            message(op,...args) {
                discovery.push([op,...args]);
                if(op==="plug_vst3")located=available;
                if(op==="drop")located=false;
            }
        };
    }},
    outlet(out, op, ...args) {
        events.push([out,op,...args]);
        if(out===0 && op==="loadstate"){
            assert.equal(located,true,"Keep Max's module loaded until the SDK has claimed it");
            context.nativeReady();
        }
        if(out===0 && op==="get")context.nativeValue(args[0],args[0]===-10 ? 110 : .5);
    }
};
context = instantiate(nativeFixture);
reset();context.load(preset);drain();
assert.ok(was(1,"ready") && was(3,"wet",1) && was(1,"latency",110));
assert.equal(located,true);
assert.deepEqual(discovery,[["plug_vst3","Decapitator"],["disable",1]]);
discovery.length=0;
context=instantiate(nativeFixture);
reset();context.load(preset);drain();
assert.ok(was(1,"ready"));
assert.deepEqual(discovery,[["disable",1]],"Reuse the matching Max lookup when a device opens");
reset();available=false;context.load(preset);drain();
assert.ok(was(3,"wet",0) && !was(0,"loadstate",preset));
reset();available=true;context.load(preset);drain();
assert.ok(was(0,"loadstate",preset),"Retry hands the original preset to the rediscovered processor");
console.log("Max host adapter, SDK hand-off, Retry and saved-state checks passed");
