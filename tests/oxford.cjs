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
    constructor(onUpdate){if(onUpdate)callback=onUpdate;}
    get(field){
        return [transportValue];
    }
}
const context=vm.createContext({patcher,Task:class{cancel(){} schedule(){}},LiveAPI,Date:{now:()=>currentDate},outlet:(...msg)=>seen.push(msg)});
vm.runInContext(['devices/oxford-inflator/controller.js','shared/missing-plugin.js','shared/meter-controls.js'].map(file=>fs.readFileSync(__dirname+'/../'+file,'utf8')).join('\n'),context);
function run(s){vm.runInContext(s,context);}
function play(state){transportValue=state;callback(['is_playing',state]);}
run('syncGains();watchTransport();phase="ready"');
assert.deepEqual(seen.filter(r=>r[0]===0).slice(-2),[[0,'drive',0],[0,'output',0]]);
play(1);
assert.deepEqual(seen.at(-1),[0,'metering',3]);
run('levels(1,1,1,-18,-21,-3,-12,-14,-2,matchRevision)');
assert.deepEqual(seen.find(r=>r[0]==='inputMeter'&&r[1]==='levels'),['inputMeter','levels',-18,-19.6,-3]);
run('levels(1,1,1,-16,-20,-3,-12,-14,-2,matchRevision);levels(1,1,1,-17,-20,-3,-12,-14,-2,matchRevision)');
assert.equal(seen.filter(r=>r[0]==='inputMeter'&&r[1]==='levels').length,1);
run('levels(1,1,1,-18,-21,-3,-12,-14,-2,matchRevision)');
const smoothed=seen.filter(r=>r[0]==='inputMeter'&&r[1]==='levels').at(-1);
assert.ok(smoothed[2]>-18&&smoothed[2]<-17.5);
run('gainmatch(0);gainmatch(0)');
assert.equal(patcher.getnamed('postOutput').value,-6);
assert.deepEqual(seen.at(-1),[0,'metering',5]);
assert.equal(seen.filter(r=>r[1]==='clear').length,4);
assert.equal(seen.filter(r=>r[0]==='postOutput'&&r[1]==='float').length,1);
currentDate+=3500;
run('levels(1,1,1,-3,-3,-3,-4,-4,-4,matchRevision)');
assert.equal(vm.runInContext('latestLevels',context),null);
run('levels(2,1,1,-18,-21,-3,-18,-19,-2,matchRevision)');
play(0);
const before=seen.filter(r=>r[0]==='inputMeter'&&r[1]==='levels').length;
run('levels(2,1,1,-3,-3,-3,-4,-4,-4,matchRevision)');
assert.equal(seen.filter(r=>r[0]==='inputMeter'&&r[1]==='levels').length,before);
run('gainmatch(1)');assert.equal(patcher.getnamed('postOutput').value,-8);
assert.deepEqual(seen.at(-1),[0,'metering',6]);
play(1);
assert.deepEqual(seen.at(-1),[0,'metering',9]);
run('meter_reset()');assert.deepEqual(seen.at(-1),[0,'metering',11]);
currentDate+=3500;
run('levels(5,1,1,-2,-4,-6,-9,-9,-100,matchRevision);gainmatch(2)');
assert.equal(patcher.getnamed('postOutput').value,24);
assert.deepEqual(seen.at(-1),[0,'metering',13]);
const driveDial=patcher.getnamed('preDrive');
const outputDial=patcher.getnamed('postOutput');
const linkControl=patcher.getnamed('driveLink');
const readout=patcher.getnamed('compensationReadout');
const audioOutput=()=>seen.filter(r=>r[0]===0 && r[1]==='output').at(-1)[2];
outputDial.message('float',2);driveDial.message('float',6);
assert.equal(audioOutput(),2);
const writesBefore=()=>seen.filter(r=>r[0]==='postOutput').length;
const manualWrites=writesBefore();
linkControl.message('int',1);
assert.equal(readout.value,'-6.0 dB');assert.equal(audioOutput(),-4);
driveDial.message('float',-6);
assert.equal(readout.value,'+6.0 dB');assert.equal(audioOutput(),8);
linkControl.message('int',0);
assert.equal(readout.value,'0.0 dB');assert.equal(audioOutput(),2);
assert.equal(writesBefore(),manualWrites,'Derived changes must never edit Post Gain');
linkControl.message('int',1);
for(const [pre,post,combined] of [[-24,24,48],[24,-24,-48],[6,2,-4]]){
    for(const preFirst of [true,false]){
        driveDial.message('float',0);outputDial.message('float',0);
        if(preFirst){driveDial.message('float',pre);outputDial.message('float',post);}
        else{outputDial.message('float',post);driveDial.message('float',pre);}
        assert.equal(audioOutput(),combined);assert.equal(outputDial.value,post);
    }
}
run('syncGains()');assert.equal(audioOutput(),-4);assert.equal(outputDial.value,2);
run('levels(epoch,1,1,-2,-4,-6,-3,-5,-8,matchRevision);gainmatch(2)');
assert.equal(outputDial.value,4);assert.equal(audioOutput(),-2);
run('levels(epoch,1,1,-18,-21,-3,-17.9,-20.899,-3.099,matchRevision)');
assert.deepEqual(Array.from(vm.runInContext('canMatch',context)),[false,true,false]);
run('gainmatch(0);gainmatch(2)');assert.equal(outputDial.value,4);
console.log('Pre compensation, independent Post automation, Gain Match and trim limits passed');

// A panel edit changes only its Live parameter and the processor.
let snapshots=0;
context.onSnapshot=()=>++snapshots;
run('snapshotTask.schedule=onSnapshot; phase="ready"; control(1,26);');
assert.deepEqual(seen.at(-1),[0,'param',1,.26]);
assert.equal(snapshots,0);
run('phase="missing"; control(1,81);');
assert.equal(snapshots,0);

// A delayed host reply must not replace the last working bank while unavailable.
const bank = patcher.getnamed('bankState');
bank.value = 'previous-instance-state';
const beforeLateReply = seen.length;
run('plugstate("unavailable-state");');
assert.equal(seen.length, beforeLateReply);
assert.equal(bank.value, 'previous-instance-state');

run('phase="ready"; editorShowing=false; driveLinkChanged(0);');
// Replay a queued high-level report after an audible plug-in change.
run('meter_reset(); levels(epoch,1,1,-18,-18,-18,-12,-12,-12,matchRevision)');
const priorRevision=vm.runInContext('matchRevision',context);
run('control(1,56); edited(1,.56)');
assert.equal(vm.runInContext('matchRevision',context),priorRevision+1);
const previousOutput=outputDial.value;
for(let metric=0;metric<3;metric++){
    run('levels(epoch,1,1,-18,-18,-18,-12,-12,-12,'+priorRevision+'); gainmatch('+metric+')');
    assert.equal(outputDial.value,previousOutput);
}
run('levels(epoch,1,0,-18,-18,-18,-12,-12,-12,matchRevision)');
assert.deepEqual(Array.from(vm.runInContext('canMatch',context)),[false,false,false]);
run('levels(epoch,1,1,-18,-18,-18,-12,-12,-12,matchRevision)');
assert.deepEqual(Array.from(vm.runInContext('canMatch',context)),[true,true,true]);
