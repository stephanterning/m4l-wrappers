let playing=false,epoch=0,transportObserver=null;
let latestLevels=null,canMatch=[false,false,false],driveDb=0,outputDb=0;
let driveLinked=false,lastCompensationText="";
let matchRevision=0;
const meterParameters=[];
let displayLevels=null,displayTicks=0;
const rmsReferenceOffset=1.4; // Match the RMS calibration of Swiss Army Meter 5.2.
const displaySmoothing=0.15; // About 0.6 s of visual damping for 10 Hz readings.
const matchThreshold=0.1;
function syncGains(){
    driveDb=Number(patch.getnamed("preDrive").getvalueof());
    outputDb=Number(patch.getnamed("postOutput").getvalueof());
    driveLinked=Number(patch.getnamed("driveLink").getvalueof())!==0;
    outlet(0,"drive",driveDb);
    applyOutputGain();
}
function driveLinkChanged(value){
    const linked=Number(value)!==0;
    if(driveLinked===linked)return;
    driveLinked=linked;
    if(driveDb!==0)gainChanged();
    applyOutputGain();
}
function watchTransport(){
    if(transportObserver)return;
    transportObserver=new LiveAPI(transportChanged,"live_set");
    transportObserver.property="is_playing";
    setPlaying(Number(transportObserver.get("is_playing"))!==0);
}
function transportChanged(args){
    if(args[0]==="is_playing")setPlaying(Number(args[1])!==0);
}
function setPlaying(active){
    if(playing===active)return;
    playing=active;
    if(playing)meter_reset();
    else outlet(0,"metering",2*epoch);
}
function gainChanged(){
    outlet(0,"matchrevision",++matchRevision);
    setMatchAvailability([false,false,false]);
}
function noteParameter(slot,value){
    if(Math.abs(meterParameters[slot]-value)<=1e-6)return;
    meterParameters[slot]=value;
    gainChanged();
}
function clampTrim(db){return Math.max(-24,Math.min(24,db));}
function drive(db){
    db=Number(db);
    if(db===driveDb)return;
    driveDb=db;
    outlet(0,"drive",db);
    gainChanged();
    if(driveLinked)applyOutputGain();
}
function outputTrim(db){
    db=Number(db);
    if(db===outputDb)return;
    outputDb=db;
    gainChanged();
    applyOutputGain();
}
function applyOutputGain(){
    const compensation=driveLinked ? -driveDb : 0;
    outlet(0,"output",outputDb+compensation);
    const rounded=Number(compensation.toFixed(1));
    const text=(rounded>0 ? "+" : "")+rounded.toFixed(1)+" dB";
    if(text!==lastCompensationText){
        patch.getnamed("compensationReadout").message("set",text);
        lastCompensationText=text;
    }
}
function setMatchAvailability(ready){
    if(ready.every((value,i)=>value===canMatch[i]))return;
    for(let i=0;i<3;i++){
        if(canMatch[i]!==ready[i])patch.getnamed("match"+i).message("active",ready[i]&&!editorShowing?1:0);
    }
    canMatch=ready;
    patch.getnamed("outputMeter").message("available",...ready.map(Number));
}
function meter_reset(){
    epoch++;
    latestLevels=null;
    displayLevels=null;
    displayTicks=0;
    setMatchAvailability([false,false,false]);
    patch.getnamed("inputMeter").message("clear");
    patch.getnamed("outputMeter").message("clear");
    outlet(0,"metering",2*epoch+(playing?1:0));
}
function renderLevels(input,output){
    const first=displayLevels===null;
    displayLevels=[input,output].map((side,index)=>side.map((db,metric)=>{
        if(db<=-200)return db;
        const calibrated=db+(metric===1?rmsReferenceOffset:0);
        if(first||metric===2||displayLevels[index][metric]<=-200)return calibrated;
        return displayLevels[index][metric]+displaySmoothing*(calibrated-displayLevels[index][metric]);
    }));
    if(!first&&++displayTicks<3)return;
    displayTicks=0;
    patch.getnamed("inputMeter").message("levels",...displayLevels[0]);
    patch.getnamed("outputMeter").message("levels",...displayLevels[1]);
}
function levels(token,valid,settled,il,ir,ip,ol,or,op,revision){
    if(!playing||token!==epoch)return;
    if(!valid){setMatchAvailability([false,false,false]);return;}
    const input=[il,ir,ip],output=[ol,or,op];
    latestLevels=[input,output];
    renderLevels(input,output);
    const ready=phase==="ready"&&settled&&revision===matchRevision;
    setMatchAvailability(input.map((value,i)=>!!(
        ready&&value>-200&&output[i]>-200&&Math.abs(value-output[i])>matchThreshold+1e-9
    )));
}
function gainmatch(row){
    if(phase!=="ready"||editorShowing||!canMatch[row]||!latestLevels)return;
    const newGain=outputDb+latestLevels[0][row]-latestLevels[1][row];
    const limited=clampTrim(newGain);
    patch.getnamed("postOutput").message("float",Math.round(limited*100)/100);
    meter_reset();
}
