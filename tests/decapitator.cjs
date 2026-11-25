const assert = require('node:assert/strict');
const fs = require('node:fs');
const path = require('node:path');
const vm = require('node:vm');
const root = path.join(__dirname, '..');
const parameters = require('../devices/decapitator/parameters.json');
const source = ['devices/decapitator/controller.js','shared/device-latency.js','shared/missing-plugin.js','shared/meter-controls.js']
    .map(f => fs.readFileSync(path.join(root,f),'utf8')).join('\n');

function instance(trimSource, auto, drive, trim) {
    const values = {bankState:'saved preset',trimOrigin:trimSource};
    parameters.forEach((p,i) => { values['param'+i] = p.initial; });
    Object.assign(values,{param1:drive,param7:auto,param10:trim});
    const emitted=[],messages=[],scheduled=new Map();
    const ctx=vm.createContext({
        parameters,Task:class {
            constructor(callback){this.callback=callback;}
            cancel(){scheduled.delete(this);}
            schedule(ms){scheduled.set(this,ms);}
        },
        outlet:(...args)=>emitted.push(args),
        patcher:{
            bringtofront(){},
            getattr(name){return values[name];},
            setattr(name,value){values[name]=value;messages.push([name,'setattr',value]);},
            getnamed(name){return {
                getvalueof:()=>values[name],
                message(op,...args){
                    messages.push([name,op,...args]);
                    if (op==='float'||op==='set')values[name]=args[0];
                }
            };}
        }
    });
    vm.runInContext(source,ctx);
    ctx.ready();
    return {ctx,values,emitted,messages,scheduled};
}

// A bank can be older than changes to the visible controls. Only a manual
// trim is replayed directly. An automatic trim can survive disabling AutoGain.
for(const origin of [0,-1,1.81,3.81]){
    const automatic=instance(origin,1,8.8,-10.5);
    const writes=automatic.emitted.filter(e=>e[1]==='param'||e[1]==='reconcile');
    assert.ok(writes.every(e=>e[2]!==10));
    assert.deepEqual(writes.filter(e=>e[2]===7),[[0,'reconcile',7,1]]);
    assert.ok(writes.some(e=>e[1]==='reconcile' && e[2]===1 && Math.abs(e[3]-.88)<1e-6));
    const {emitted}=instance(origin,0,3.6,-7);
    const edits=emitted.filter(e=>e[1]==='param'||e[1]==='reconcile');
    const trims=edits.filter(e=>e[2]===10);
    assert.equal(trims.length,origin<0?1:0);
    if(origin<0)assert.equal(edits.at(-1)[2],10);
    if(origin>=1){
        assert.deepEqual(edits.slice(0,5).map(e=>[e[1],e[2]]),
            [['reconcile',7],['reconcile',1],['reconcile',2],['param',7],['reconcile',7]]);
        assert.ok(Math.abs(edits[1][3]-.81)<1e-6);
        assert.equal(edits[2][3],origin>=3?1:0);
        assert.equal(edits[3][3],1);
        assert.equal(edits[4][3],0);
    }
}

for (const enabled of [0,1]) {
    const {ctx,emitted,scheduled}=instance(-1,enabled,2.3,-5);
    ctx.edited(7,enabled);
    ctx.control(10,-7.5);
    ctx.control(10,-7.25);
    for (const task of Array.from(scheduled.keys())) task.callback();
    assert.equal(emitted.filter(e=>e[1]==='snapshot').length,enabled);
}

const {ctx,values,messages}=instance(0,1,2.3,-5);
ctx.latency(62); ctx.latency(110); ctx.latency(110); ctx.latency(62);
for (const invalid of [NaN, Infinity, -1, 62.5]) ctx.latency(invalid);
assert.deepEqual(messages.filter(m=>m[0]==='latency').map(m=>m[2]),[62,110,62]);
ctx.edited(7,1);ctx.edited(1,.23);
ctx.control(1,8.1);
assert.ok(Math.abs(values.trimOrigin-1.81)<1e-6);
ctx.control(10,-4);assert.equal(values.trimOrigin,-1);
ctx.control(1,8.1);assert.equal(values.trimOrigin,-1);
ctx.control(2,1);assert.ok(Math.abs(values.trimOrigin-3.81)<1e-6);
ctx.control(7,0);ctx.control(1,2);
assert.ok(Math.abs(values.trimOrigin-3.81)<1e-6);
assert.ok(messages.filter(m=>m[0]==='trimOrigin').every(m=>m[1]==='float'));
console.log('Decapitator restore ordering, manual trim and automatic compensation provenance passed.');
