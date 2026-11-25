const pointerControls = ["preDrive", "postOutput", "driveLink", "input", "amount", "curve", "output", "effectIn", "split", "clip", "editorButton"];
const pluginName = "Sonnox Oxford Inflator";
inlets=1;outlets=2;
const patch=this.patcher,names=["input","amount","curve","output","effectIn","split","clip","hostBypass"];
const low=[-6,0,-50,-12,0,0,0,0],high=[12,100,50,0,1,1,1,1];
let phase="cold",queue=null,key="";
const snapshotTask=new Task(function(){if(phase==="ready")outlet(0,"snapshot");},this);
function snapshotSoon(){snapshotTask.cancel();snapshotTask.schedule(375);}
// Retain the existing storage key so older Live sets can restore VST3 state.
function storedState(){
    const data=patch.getnamed("bankState").getvalueof();
    if(Array.isArray(data))return String(data[data.length-1]||"");
    return String(data||"").replace(/^symbol[, ]/,"");
}
function plugstate(data){
    captureErrorShown = false;
    if(phase!=="ready")return;
    const token=String(data),storage=patch.getnamed("bankState");
    if(storedState()!==token)storage.message("symbol",token);
}
const warningTask=new Task(flush,this);
const loadTimeout=new Task(function(){if(phase==="loading")loaderror("The VST3 host did not respond.");},this);
function panel(){return patch.getnamed("face");}
function update(i,v){panel().message("value",i,v);}
function control(i,value){
    const v=Number(value);update(i,v);
    if(phase==="ready"){
        const normalized=(v-low[i])/(high[i]-low[i]);
        noteParameter(i,normalized);
        outlet(0,"param",i,normalized);
    }
}
function synced(){for(let i=0;i<8;i++)control(i,Number(patch.getnamed(names[i]).getvalueof()));}
function ready(){loadTimeout.cancel();clear();status("ready");synced();if(storedState()==="none"||!storedState())outlet(0,"snapshot");}
function edited(i,v){
    if(phase!=="ready"||i<0||i>=8)return;
    let value=low[i]+Math.max(0,Math.min(1,v))*(high[i]-low[i]);value=Math.round(value*(i<4?100000:1))/(i<4?100000:1);
    const dial=patch.getnamed(names[i]);
    if(editorShowing && Math.abs(Number(dial.getvalueof())-value)>(high[i]-low[i])*1e-6)dial.message("set",value);
    noteParameter(i,v);update(i,value);if(editorShowing)snapshotSoon();
}
function initialized(){syncGains();watchTransport();if(phase==="cold")load();else if(phase==="ready")synced();}
function load(){
    clear();status("loading");loadTimeout.schedule(15000);
    loadSavedPlugin();
}
var pluginEditorMessage = "open";
function action(){if(isLoadFailure(phase))retry();else if(phase==="ready")outlet(0,pluginEditorMessage);}
function cleanup(){cancelRetry();if(transportObserver){transportObserver.property="";transportObserver=null;}snapshotTask.cancel();loadTimeout.cancel();clear();}

