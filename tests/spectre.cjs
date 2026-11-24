const fs = require('node:fs');
const vm = require('node:vm');
const assert = require('node:assert/strict');
const path = require('node:path');
const base = path.join(__dirname,'../dist/Spectre Wrapper.amxd');
const b = fs.readFileSync(base), archive = b.subarray(32);
assert.equal(b.readUInt32LE(28),archive.length);
const entries = new Map();
function chunks(buf) {
    const result = [];
    for(let i=0;i<buf.length;) {
        const size=buf.readUInt32BE(i+4);
        assert(size>=8 && size<=buf.length-i);
        result.push([buf.toString('ascii',i,i+4),buf.subarray(i+8,i+size)]); i+=size;
    }
    return result;
}
const table=chunks(archive.subarray(archive.readUInt32BE(12)))[0];
assert.equal(table[0],'dlst');
for(const [type,entry] of chunks(table[1])) {
    const tags=Object.fromEntries(chunks(entry));
    const name=tags.fnam.toString().replace(/\0+$/,'');
    const offset=tags.of32.readUInt32BE(), size=tags.sz32.readUInt32BE();
    entries.set(name,archive.subarray(offset,offset+size));
}
const patch=JSON.parse(entries.get(path.basename(base)).toString().replace(/\0+$/,'')).patcher;
const boxes=Object.fromEntries(patch.boxes.map(({box:b})=>[b.varname,b]));
const ids=new Set(Object.values(boxes).map(b=>b.id));
for(const {patchline:l} of patch.lines) assert(ids.has(l.source[0]) && ids.has(l.destination[0]));
const assets=[...entries.keys()];
assert(assets.includes('spectrewrapper2~/zipfile'));
assert.deepEqual(entries.get('spectrewrapper2~/executable'),fs.readFileSync(path.join(__dirname,'../build/spectre/spectrewrapper2~.mxo/Contents/MacOS/spectrewrapper2~')));
for(const box of Object.values(boxes)) {
    if(['jsui','v8ui'].includes(box.maxclass)) assert(assets.includes(box.filename));
    if(box.jspainterfile) assert(assets.includes(box.jspainterfile));
}
const values={}, ui=[],commands=[];
let latency;
let ctx;
const objects = new Map();
for(const [key,b] of Object.entries(boxes)) {
    values[key]=b.saved_attribute_attributes?.valueof?.parameter_initial?.[0]??0;
    objects.set(key,{
        getvalueof:()=>values[key],message:(msg,...args)=>{
            if(key==='face'||key.endsWith('Meter')) {ui.push([key,msg,...args]);return;}
            if(msg==='set'||msg==='int'||msg==='float') values[key]=args[0];
            if((msg==='int'||msg==='float')&&/^param\d+$/.test(key)) ctx.control(Number(key.slice(5)),args[0]);
            if(msg==='float' && key==='postOutput')ctx.outputTrim(args[0]);
        }
    });
}
const patcher={bringtofront:o=>assert.equal(o,objects.get("warningOverlay")),getnamed:n=>objects.get(n),setattr:(k,v)=>latency=v};
let clock=0;
const timers=new Map();
class Task {
    constructor(fn){this.fn=fn;}
    schedule(ms){if(ms===0)this.fn();else timers.set(this,clock+ms);}
    cancel(){timers.delete(this);}
}
function advance(ms){
    const end=clock+ms;
    while(true){
        const next=[...timers].sort((a,b)=>a[1]-b[1])[0];
        if(!next || next[1]>end)break;
        clock=next[1];timers.delete(next[0]);next[0].fn();
    }
    clock=end;
}
class LiveAPI {constructor(){this.id=1;}get(){return 0;}}
ctx=vm.createContext({patcher,Task,LiveAPI,outlet:(n,...args)=>commands.push(args),Date,Math});
vm.runInContext(boxes.ctrl.code,ctx);
values.bankState=['none'];
ctx.load();
assert.deepEqual(commands.at(-1),['load','-']);
values.bankState=['symbol','AQI='];
ctx.load();
assert.deepEqual(commands.at(-1),['load','AQI=']);
values.bankState=['none'];
ctx.initialized();ctx.ready();
const initial=commands.filter(c=>c[0]==='param').slice(-39);
assert.equal(initial.length,39);
assert.deepEqual(initial[34],['param',34,.5]);assert.deepEqual(initial[35],['param',35,1]);
for(let i=0;i<39;i++) {
    const d=boxes['param'+i].saved_attribute_attributes.valueof;
    const raw=d.parameter_enum?1:.72;
    ctx.param(i,raw);
    const last=commands.filter(c=>c[0]==='param').at(-1);
    assert.equal(last[1],i);assert(Math.abs(last[2]-raw)<1e-12);
    ctx.edited(i,0);assert.equal(values['param'+i],d.parameter_mmin);
}
ctx.outputTrim(-12);ctx.driveLinkChanged(1);ctx.drive(24);ctx.drive(6);
assert.equal(values.postOutput,-18);
ctx.setPlaying(true);vm.runInContext('matchAfter=0',ctx);
ctx.levels(1,1,1,-13,-8,-1,-12.95,-8.1,-.75);
assert.deepEqual(ui.at(-1),['outputMeter','available',0,0,1]);
ctx.gainmatch(2);assert.equal(values.postOutput,-18.25);assert.deepEqual(commands.at(-1),['metering',5]);
ctx.latency(64);assert.equal(latency,64);
console.log('Frozen archive, native binary, outer panel, all 39 parameter round trips, menu, relative Link, Gain Match threshold/reset and latency notification passed.');
// Exercise the same warning queue used by multiple devices in one Live Set.
class Dictionary {
    constructor(){this.values=new Map();}
    set(k,v){this.values.set(k,v);} contains(k){return this.values.has(k);}
    get(k){return this.values.get(k);} remove(k){this.values.delete(k);}
    getkeys(){return Array.from(this.values.keys());} clear(){this.values.clear();}
}
const trackAPI=class {constructor(){this.type='Track';this.id=777;}get(){return 'Bass';}};

for (const extraTracks of [false, true]) {
    timers.clear();
    ctx=vm.createContext({patcher,Task,LiveAPI:trackAPI,Dict:Dictionary,Date:{now:()=>clock},Math,
        outlet:(n,...args)=>commands.push(args)});
    vm.runInContext(boxes.ctrl.code,ctx);
    ctx.load();ctx.missing();
    const before = values.param1;
    ctx.param(1, .99);
    assert.equal(values.param1, before, 'An unavailable panel cannot edit a Live parameter');
    const stored = values.bankState;
    ctx.plugstate('late-host-snapshot');
    assert.equal(values.bankState, stored);
    if (extraTracks) vm.runInContext('queue.set("d778",JSON.stringify(["MIX PRE-MASTER",""])); queue.set("d779",JSON.stringify(["Bass",""]))',ctx);
    vm.runInContext('queue.set("last",String(Date.now()-1500))',ctx);
    ctx.flush();
    const names = extraTracks ? 'Bass\nMIX PRE-MASTER' : 'Bass';
    assert.deepEqual(commands.at(-1), ['symbol',
        'Wavesfactory Spectre (VST3) was not found.\n\nTracks:\n' + names +
        '\n\nAudio passes through dry. Restore the VST3 installation, then click Retry in the device.']);
}
// A timeout gives no evidence that the plug-in is missing. Group distinct causes by track.
timers.clear();
ctx=vm.createContext({patcher,Task,LiveAPI:trackAPI,Dict:Dictionary,Date:{now:()=>clock},Math,
    outlet:(n,...args)=>commands.push(args)});
vm.runInContext(boxes.ctrl.code,ctx);
ctx.load(); advance(15000);
vm.runInContext('queue.set("d778",JSON.stringify(["Lead","Cannot map the required VST3 parameter: Effect (expected ID 1)."]))',ctx);
advance(650);
const loadWarning=commands.at(-1)[1];
assert(loadWarning.includes('An error occurred while loading Wavesfactory Spectre (VST3).'));
assert(loadWarning.includes('The VST3 host did not respond.\n\nTracks:\nBass'));
assert(loadWarning.includes('Effect (expected ID 1).\n\nTracks:\nLead'));
assert(!loadWarning.includes('was not found'));
const overlay=objects.get('warningOverlay');
assert.equal(overlay.hidden,false);
const modalCount=()=>commands.filter(msg=>msg[0]==='symbol').length;
const lastStatus=()=>ui.filter(msg=>msg[0]==='face' && msg[1]==='status').at(-1)[2];
const initialModals=modalCount();
for(const [outcome,duration] of [['missing',50],['missing',1400],['loaderror',50],['ready',50]]){
    const loads=commands.filter(msg=>msg[0]==='load').length;
    ctx.retry();ctx.retry();
    assert.equal(lastStatus(),'loading');
    advance(50);
    assert.equal(commands.filter(msg=>msg[0]==='load').length,loads+1);
    advance(duration-50);
    assert.equal(lastStatus(),'loading');
    ctx[outcome]();
    if(duration<1000){
        advance(999-duration);
        assert.equal(lastStatus(),'loading');
        ctx.retry();
        advance(1);
    }
    assert.equal(lastStatus(),outcome);
    advance(700);
    assert.equal(modalCount(),initialModals);
}
assert.equal(overlay.hidden,true);assert.equal(overlay.ignoreclick,true);
assert(ui.some(e=>e[0]==='face' && e[1]==='status' && e[2]==='ready'));
console.log('Track-named English missing warning, Retry reload, and restored state routing passed.');
