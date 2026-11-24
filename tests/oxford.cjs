const vm=require('node:vm'), fs=require('node:fs'), assert=require('node:assert/strict');
const seen=[], objects=new Map();let currentDate=9000,transportValue=0,callback;
const patcher={getnamed(name){
    if(!objects.has(name)){
        objects.set(name,{value:0,getvalueof(){return this.value;},message(type,...values){
            seen.push([name,type,...values]);
            if(type==='set')this.value=values[0];
            if(type==='float'||type==='int'){
                this.value=values[0];
                if(name==='postOutput')vm.runInContext('outputTrim('+this.value+')',context);
                if(name==='preDrive')vm.runInContext('drive('+this.value+')',context);
                if(name==='driveLink')vm.runInContext('driveLinkChanged('+this.value+')',context);
            }
        }});
    }
    return objects.get(name);
}};
class LiveAPI{
    constructor(onUpdate){callback=onUpdate;}
    get(){return [transportValue];}
}
const context=vm.createContext({patcher,Task:class{cancel(){} schedule(){}},LiveAPI,Date:{now:()=>currentDate},outlet:(...msg)=>seen.push(msg)});
vm.runInContext(['devices/oxford-inflator/controller.js','shared/missing-plugin.js','shared/meter-controls.js'].map(file=>fs.readFileSync(__dirname+'/../'+file,'utf8')).join('\n'),context);
function run(s){vm.runInContext(s,context);}
function play(state){transportValue=state;callback(['is_playing',state]);}
run('syncGains();watchTransport();phase="ready"');
assert.deepEqual(seen.slice(-2),[[0,'drive',0],[0,'output',0]]);
play(1);
assert.deepEqual(seen.at(-1),[0,'metering',3]);
run('levels(1,1,1,-18,-21,-3,-12,-14,-2)');
assert.deepEqual(seen.find(r=>r[0]==='inputMeter'&&r[1]==='levels'),['inputMeter','levels',-18,-19.6,-3]);
run('levels(1,1,1,-16,-20,-3,-12,-14,-2);levels(1,1,1,-17,-20,-3,-12,-14,-2)');
assert.equal(seen.filter(r=>r[0]==='inputMeter'&&r[1]==='levels').length,1);
run('levels(1,1,1,-18,-21,-3,-12,-14,-2)');
const smoothed=seen.filter(r=>r[0]==='inputMeter'&&r[1]==='levels').at(-1);
assert.ok(smoothed[2]>-18&&smoothed[2]<-17.5);
run('gainmatch(0);gainmatch(0)');
assert.equal(patcher.getnamed('postOutput').value,-6);
assert.deepEqual(seen.at(-1),[0,'metering',5]);
assert.equal(seen.filter(r=>r[1]==='clear').length,4);
assert.equal(seen.filter(r=>r[0]==='postOutput'&&r[1]==='float').length,1);
currentDate+=3500;
run('levels(1,1,1,-3,-3,-3,-4,-4,-4)');
assert.equal(vm.runInContext('latestLevels',context),null);
run('levels(2,1,1,-18,-21,-3,-18,-19,-2)');
play(0);
const before=seen.filter(r=>r[0]==='inputMeter'&&r[1]==='levels').length;
run('levels(2,1,1,-3,-3,-3,-4,-4,-4)');
assert.equal(seen.filter(r=>r[0]==='inputMeter'&&r[1]==='levels').length,before);
run('gainmatch(1)');assert.equal(patcher.getnamed('postOutput').value,-8);
assert.deepEqual(seen.at(-1),[0,'metering',6]);
play(1);
assert.deepEqual(seen.at(-1),[0,'metering',9]);
run('meter_reset()');assert.deepEqual(seen.at(-1),[0,'metering',11]);
currentDate+=3500;
run('levels(5,1,1,-2,-4,-6,-9,-9,-100);gainmatch(2)');
assert.equal(patcher.getnamed('postOutput').value,24);
assert.deepEqual(seen.at(-1),[0,'metering',13]);
patcher.getnamed('postOutput').message('float',-1);
patcher.getnamed('driveLink').message('int',1);
patcher.getnamed('preDrive').message('float',1);
assert.equal(patcher.getnamed('postOutput').value,-2);
patcher.getnamed('postOutput').message('float',-5.5);
assert.equal(patcher.getnamed('preDrive').value,1);
patcher.getnamed('preDrive').message('float',0.75);
assert.equal(patcher.getnamed('postOutput').value,-5.25);
run('syncGains()');
assert.equal(patcher.getnamed('postOutput').value,-5.25);
patcher.getnamed('postOutput').message('float',-23.75);
patcher.getnamed('preDrive').message('float',1.75);
assert.equal(patcher.getnamed('postOutput').value,-24);
patcher.getnamed('driveLink').message('int',0);
patcher.getnamed('preDrive').message('float',0);
assert.equal(patcher.getnamed('postOutput').value,-24);
currentDate+=3500;
run('levels(6,1,1,-18,-21,-3,-17.9,-20.899,-3.099)');
assert.deepEqual(Array.from(vm.runInContext('canMatch',context)),[false,true,false]);
run('gainmatch(0);gainmatch(2)');
assert.deepEqual(Array.from(vm.runInContext('canMatch',context)),[false,true,false]);
assert.equal(patcher.getnamed('postOutput').value,-24);
const driveDial=patcher.getnamed('preDrive');
const outputDial=patcher.getnamed('postOutput');
const linkControl=patcher.getnamed('driveLink');
outputDial.message('float',-12);
linkControl.message('int',1);
for(let v=1;v<=24;v++)driveDial.message('float',v);
assert.equal(outputDial.value,-24);
for(let v=23;v>=6;v--)driveDial.message('float',v);
assert.equal(outputDial.value,-18);
assert.deepEqual(seen.at(-1),[0,'output',-18]);
outputDial.message('float',12);
assert.equal(driveDial.value,6);
driveDial.message('float',-24);
assert.equal(outputDial.value,24);
driveDial.message('float',0);
assert.equal(outputDial.value,18);
linkControl.message('int',0);
driveDial.message('float',-6);
linkControl.message('int',1);
driveDial.message('float',-3);
assert.equal(outputDial.value,15);
console.log('Meter behavior, Gain Match and Drive Link through both Output limits passed');

// An edit from the wrapper UI also refreshes the instance's native state.
let snapshots=0;
context.onSnapshot=()=>++snapshots;
run('snapshotTask.schedule=onSnapshot; phase="ready"; control(1,26);');
assert.deepEqual(seen.at(-1),[0,'param',1,.26]);
assert.equal(snapshots,1);
run('phase="missing"; control(1,81);');
assert.equal(snapshots,1);

// A delayed host reply must not replace the last working bank while unavailable.
const bank = patcher.getnamed('bankState');
bank.value = 'previous-instance-state';
const beforeLateReply = seen.length;
run('plugstate("unavailable-state");');
assert.equal(seen.length, beforeLateReply);
assert.equal(bank.value, 'previous-instance-state');
