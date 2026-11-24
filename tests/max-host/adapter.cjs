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
const product = {id: 17, cid:"0123456789ABCDEF0123456789ABCDEF", name:"Fixture", parameters:["Gain","Quality"]};
let storedValue = 0.7, readParameter = 0;
let installed = true, wrong = false, missingParameter = false, corruptRead = false;
const context = {Task, File, product, post(){}, patcher:{getnamed(){return {getattr(){return installed ? ["C74_VST3:/Fixture",17]:null;}};}},
    outlet(out, op, ...args) {
        events.push([out,op,...args]);
        if (out !== 0) return;
        if (Array.isArray(op)) readParameter = op[1];
        if (op === "get") context.parameterChanged(args[0], args[0] === -8 ? (wrong ? 99 : 17) : args[0] === -10 ? 60 : readParameter);
        if (op === "params") {
            context.inlet = 1;
            for (const name of missingParameter ? ["Gain"] : ["Quality","Gain"]) { context.messagename=name;context.anything(); }
            context.inlet = 0;
        }
        if (op === "read" && !corruptRead) readParameter = storedValue;
        if (op === "write") files.set(args[0],Array.from(context.legacyPreset([50,60,70])));
    }};
vm.createContext(context);
vm.runInContext(fs.readFileSync(path.join(__dirname,"../../experimental/max-host/adapter.js"),"utf8"),context);
function drain(){ while(jobs.length) jobs.shift().run(); }
function reset(){events.length=0;}
function was(out,op,...args) {return events.some(e=>JSON.stringify(e)===JSON.stringify([out,op,...args]));}
for(const n of [1,2,3,256,4000]){
    const raw=Array.from({length:n},(_,i)=>(i*13)%256);
    const encoded=context.encode(raw);assert.equal(encoded,Buffer.from(raw).toString("base64"));
    assert.deepEqual(Array.from(context.parsePreset(context.legacyPreset(context.decode(encoded))).component),raw);
}
const invalid=Array.from(context.legacyPreset([1]));invalid[40]=255;
assert.throws(()=>context.parsePreset(invalid));
context.load("AQID");drain();assert.ok(was(1,"ready") && was(3,"wet",1));assert.ok(was(1,"latency",60));
reset();context.param(0,.4);assert.ok(was(0,[2,.4]));
storedValue=.25;context.load("AQID");drain();assert.ok(was(1,"ready"));
context.snapshot();assert.ok(was(1,"plugstate",Buffer.from([50,60,70]).toString("base64")));
for(const failure of ["absent","wrong","missing parameter","corrupt preset","unconfirmed restore"]){
    reset();installed=failure!=="absent";wrong=failure==="wrong";missingParameter=failure==="missing parameter";corruptRead=failure==="unconfirmed restore";
    context.load(failure==="corrupt preset"?"bad!":"AQID");drain();context.snapshot();
    assert.ok(was(3,"wet",0) && events.some(e=>e[1]==="loaderror") && !events.some(e=>["ready","plugstate"].includes(e[1])),failure);
}
reset();installed=true;wrong=false;missingParameter=false;corruptRead=false;context.load("AQID");drain();assert.ok(was(1,"ready"));
console.log("Max host adapter checks passed");
