#include "ext.h"
#include "z_dsp.h"
#include "Engine.h"
#include "ext_systhread.h"
#include "decapitator_path.h"
#include <mutex>

struct Core {
    std::mutex lifecycle, configuration;
    IPtr<Decapitator> engine;
    double rate=0;
    long vector=0, advertised=-1;
    bool ready=false, setupFailed=false;
};
struct Device {t_pxobject obj; Core* core; void* events; void* queue;};
static t_class* type;
static void event(Device* d,const char* name,long argc=0,t_atom* argv=nullptr) {
    outlet_anything(d->events,gensym(name),argc,argv);
}
static void detail(Device* d,const char* name,const char* message) {
    t_atom arg;atom_setsym(&arg,gensym(message));event(d,name,1,&arg);
}
static void number(Device* d,const char* name,long v) {
    t_atom arg;atom_setlong(&arg,v);event(d,name,1,&arg);
}
static void reply(Device* d,long ordinal,double v) {
    t_atom args[2];atom_setlong(args,ordinal);atom_setfloat(args+1,v);event(d,"nativeValue",2,args);
}
static void release(Device* d) {
    IPtr<Decapitator> old;
    {
        std::lock_guard lock(d->core->lifecycle);
        old=d->core->engine; d->core->engine=nullptr; d->core->ready=false;
        d->core->advertised=-1;d->core->setupFailed=false;
    }
    if(old)old->shutdown();
}
static void flush(Device* d) {
    auto& c=*d->core;
    long latency=-1;
    double rate=0;
    bool failed=false;
    IPtr<Decapitator> engine;
    {
        // Editor messages and latency queries must not contend with the audio
        // callback. Only a DSP reconfiguration also takes this lock.
        std::lock_guard lock(c.configuration);
        engine=c.engine;
        if(!engine)return;
        failed=c.setupFailed;c.setupFailed=false;
        rate=c.rate;latency=engine->latency();
    }
    if(failed){detail(d,"nativeFailure","Decapitator could not start at the selected audio settings.");return;}
    if(rate>0 && latency!=c.advertised) {
        c.advertised=latency;reply(d,-10,latency);
    }
    const unsigned edits=engine->takeEdits();
    for(unsigned i=0;i<11;i++)if(edits&(1u<<i))reply(d,i+1,engine->editedValue(i));
    if(engine->takeStateChange() && c.ready && engine->editorOpen())event(d,"nativeBankChanged");
}
static void loadState(Device* d,t_symbol* token) {
    release(d);
    std::string error;
    const auto path=loadedDecapitatorPath(error);
    auto fresh=owned(new Decapitator([d]{qelem_set(d->queue);}));
    if(path.empty() || !fresh->open(path,error)){
        fresh->shutdown();detail(d,"nativeFailure",error.c_str());return;
    }
    if(!fresh->recall([NSString stringWithUTF8String:token->s_name])){
        fresh->shutdown();detail(d,"nativeFailure","Decapitator could not restore the saved VST3 preset.");return;
    }
    auto& c=*d->core;
    {
        std::lock_guard lock(c.lifecycle);
        if(c.rate>0 && c.vector>0 && !fresh->prepare(c.rate,c.vector))
            error="Decapitator could not start at the selected audio settings.";
        else c.engine=fresh;
    }
    if(!error.empty()){fresh->shutdown();detail(d,"nativeFailure",error.c_str());return;}
    event(d,"nativeReady");
    {std::lock_guard lock(c.lifecycle);c.ready=true;}
    flush(d);
}
static void set(Device* d,t_symbol*,long argc,t_atom* argv) {
    if(argc!=2)return;
    const long i=atom_getlong(argv)-1;
    if(i<0 || i>=11)return;
    auto& c=*d->core;
    if(!c.engine)return;
    c.engine->set(i,atom_getfloat(argv+1));
    // Reconcile controller-dependent parameters in order before enabling wet audio.
    if(!c.ready) {
        std::lock_guard lock(c.lifecycle);
        if(c.vector>0)c.engine->process(nullptr,nullptr,c.vector);
    }
}
static void get(Device* d,long ordinal) {
    auto& c=*d->core;
    if(!c.engine)return;
    if(ordinal==-10){if(c.advertised>=0)reply(d,-10,c.advertised);return;}
    if(ordinal>=1 && ordinal<=11)reply(d,ordinal,c.engine->value(ordinal-1));
}
static void capture(Device* d) {
    auto& c=*d->core;if(!c.engine)return;
    // VST3 component state is obtained on the UI thread, as specified by the SDK.
    NSString* token=c.engine->snapshot();
    if(token)detail(d,"plugstate",token.UTF8String);
    else detail(d,"stateerror","Decapitator could not capture its current VST3 preset.");
}
static void show(Device* d){if(d->core->engine)number(d,"nativeEditor",d->core->engine->openEditor());}
static void editorState(Device* d) {
    const bool open=d->core->engine && d->core->engine->editorOpen();
    // The wrapper accepts vendor edits until it receives the close notification.
    if(!open)flush(d);
    number(d,"nativeEditor",open);
}
static void hide(Device* d) {
    if(d->core->engine)d->core->engine->closeEditor();
    editorState(d);
}
static void perform(Device* d,t_object*,double** in,long,double** out,long,long n,long,void*) {
    auto& c=*d->core;
    std::unique_lock lock(c.lifecycle,std::try_to_lock);
    if(lock && c.ready && c.engine && c.engine->process(in,out,n))return;
    for(int ch=0;ch<2;ch++)std::copy_n(in[ch],n,out[ch]);
}
static void dsp(Device* d,t_object* chain,short*,double rate,long n,long) {
    auto& c=*d->core;
    long latency=-1;
    {
        std::scoped_lock lock(c.lifecycle,c.configuration);
        c.rate=rate;
        c.vector=n;
        if(c.engine) {
            c.setupFailed=!c.engine->prepare(rate,n);
            if(c.ready && systhread_ismainthread())
                latency=c.setupFailed ? 0 : c.engine->latency();
        }
    }
    // Live can start rendering before the next low-priority Max callback.
    // Supply the active processor's latency while Live is building this graph.
    if(latency>=0) {
        t_object* patch=nullptr;
        if(object_obex_lookup(d,gensym("#P"),&patch)==MAX_ERR_NONE && patch &&
           object_attr_getlong(patch,gensym("latency"))!=latency)
            object_attr_setlong(patch,gensym("latency"),latency);
    }
    object_method(chain,gensym("dsp_add64"),d,perform,0,nullptr);
    qelem_set(d->queue);
}
static void destroy(Device* d){dsp_free(&d->obj);release(d);qelem_free(d->queue);delete d->core;}
static void* create(){
    auto* d=static_cast<Device*>(object_alloc(type));if(!d)return nullptr;
    d->core=new Core;d->queue=qelem_new(d,(method)flush);
    dsp_setup(&d->obj,2);d->obj.z_misc|=Z_NO_INPLACE;
    d->events=outlet_new(d,nullptr);outlet_new(d,"signal");outlet_new(d,"signal");return d;
}
extern "C" void C74_EXPORT ext_main(void*) {
    type=class_new("m4ldecapitator~",(method)create,(method)destroy,sizeof(Device),nullptr,0);
    class_addmethod(type,(method)loadState,"loadstate",A_SYM,0);
    class_addmethod(type,(method)release,"release",0);
    class_addmethod(type,(method)set,"list",A_GIMME,0);
    class_addmethod(type,(method)get,"get",A_LONG,0);
    class_addmethod(type,(method)capture,"snapshot",0);
    class_addmethod(type,(method)show,"showeditor",0);
    class_addmethod(type,(method)hide,"hideeditor",0);
    class_addmethod(type,(method)editorState,"editorstate",0);
    class_addmethod(type,(method)dsp,"dsp64",A_CANT,0);
    class_dspinit(type);class_register(CLASS_BOX,type);
}
