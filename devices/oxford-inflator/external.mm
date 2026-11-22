#include "Engine.mm"
#include "Discovery.h"
#include "Meter.h"
#include "ext.h"
#include "ext_systhread.h"
#include "z_dsp.h"
struct GainRamp {
    std::atomic<double> target{1};
    double gain=1, previous=1, step=0;
    int remaining=0;
    void update(double desired,int frames){
        if(desired==previous)return;
        previous=desired;remaining=frames;step=(desired-gain)/frames;
    }
    double next(){
        if(remaining){gain=--remaining?gain+step:previous;}
        return gain;
    }
    bool unity() const {return gain==1&&previous==1;}
};

struct MeterMailbox {
    std::atomic<unsigned> serial{0};
    std::atomic<long> epoch{0};
    std::atomic<bool> valid{false}, settled{false};
    std::array<std::atomic<double>,6> value{};
    unsigned reported=0;

    void publish(long token,const MeterReading& reading,bool matchReady){
        serial.fetch_add(1,std::memory_order_acq_rel);
        epoch.store(token,std::memory_order_relaxed);
        valid.store(reading.valid,std::memory_order_relaxed);
        settled.store(matchReady,std::memory_order_relaxed);
        for(int i=0;i<6;i++)value[i].store(reading.db[i],std::memory_order_relaxed);
        serial.fetch_add(1,std::memory_order_release);
    }
    bool receive(t_atom* values){
        const auto version=serial.load(std::memory_order_acquire);
        if((version&1)||version==reported)return false;
        atom_setlong(values,epoch.load(std::memory_order_relaxed));
        atom_setlong(values+1,valid.load(std::memory_order_relaxed));
        atom_setlong(values+2,settled.load(std::memory_order_relaxed));
        for(int i=0;i<6;i++)atom_setfloat(values+3+i,value[i].load(std::memory_order_relaxed));
        if(serial.fetch_add(0,std::memory_order_acq_rel)!=version)return false;
        reported=version;return true;
    }
};

struct Core {
    std::mutex swap;
    IPtr<Oxford> instance;
    double rate=48000;
    int vector=64,rampFrames=240,settledFrames=0;
    GainRamp drive, output;
    std::array<std::vector<double>,2> driven;
    StereoMeters meters;
    MeterMailbox meterMailbox;
    std::atomic<long> meterCommand{0};
    long meterEpoch=-1;
    Core(){meters.configure(rate);for(auto& channel:driven)channel.resize(vector);}
};
struct Device {t_pxobject obj;Core* core;void* events;void* queue;};
static t_class* type;
static void announce(Device* d,const char* message){outlet_anything(d->events,gensym(message),0,nullptr);}
static void flush(Device* d){
    t_atom meter[9];
    if(d->core->meterMailbox.receive(meter))
        outlet_anything(d->events,gensym("levels"),9,meter);
    auto engine=d->core->instance;if(!engine)return;
    auto changed=engine->consumeEdits();
    for(int i=0;i<8;i++)if(changed&(1u<<i)){
        t_atom a[2];atom_setlong(a,i);atom_setfloat(a+1,engine->value(i));outlet_anything(d->events,gensym("edited"),2,a);
    }
}
static void releasePlugin(Device* d){
    IPtr<Oxford> old;
    {std::lock_guard lock(d->core->swap);old=d->core->instance;d->core->instance=nullptr;}
    if(old)old->shutdown();
}
static void loadOnMain(Device* d,t_symbol*,long argc,t_atom* args){
    @autoreleasepool {
        if(argc!=1||atom_gettype(args)!=A_SYM)return;
        NSString* encoded=[NSString stringWithUTF8String:atom_getsym(args)->s_name];
        NSData* state=[[NSData alloc] initWithBase64EncodedString:encoded options:0];
        releasePlugin(d);
        NSArray<NSString*>* candidates=oxfordPaths();
        std::string error="Oxford Inflator VST3 is not installed";
        for(NSString* path in candidates){
            if(![[NSFileManager defaultManager] fileExistsAtPath:path])continue;
            auto fresh=owned(new Oxford([d]{qelem_set(d->queue);}));
            if(!fresh->open([path fileSystemRepresentation],error)){fresh->shutdown();continue;}
            if(state.length)fresh->recall(state);
            bool ok=false;
            {std::lock_guard lock(d->core->swap);ok=fresh->prepare(d->core->rate,d->core->vector);if(ok)d->core->instance=fresh;}
            if(!ok){fresh->shutdown();error="Oxford did not enter stereo processing mode";continue;}
            announce(d,"ready");return;
        }
        object_warn((t_object*)d,"%s",error.c_str());announce(d,"missing");
    }
}
static void load(Device* d,t_symbol* msg,long argc,t_atom* a){defer_low(d,(method)loadOnMain,msg,argc,a);}
static void setParam(Device* d,t_symbol* msg,long argc,t_atom* a){
    if(argc!=2)return;
    if(!systhread_ismainthread()){defer_low(d,(method)setParam,msg,argc,a);return;}
    if(auto e=d->core->instance)e->set((int)atom_getlong(a),atom_getfloat(a+1));
}
static void show(Device* d){
    if(!systhread_ismainthread()){defer_low(d,(method)show,nullptr,0,nullptr);return;}
    if(auto e=d->core->instance)if(!e->showEditor())object_warn((t_object*)d,"Sonnox editor could not be opened");
}
static void snapshot(Device* d){
    if(!systhread_ismainthread()){defer_low(d,(method)snapshot,nullptr,0,nullptr);return;}
    if(auto e=d->core->instance){
        NSData* bytes=e->state();if(!bytes||bytes.length>8192)return;
        NSString* encoded=[bytes base64EncodedStringWithOptions:0];
        t_atom out;atom_setsym(&out,gensym(encoded.UTF8String));
        outlet_anything(d->events,gensym("plugstate"),1,&out);
    }
}
static void trim(Device* d,t_symbol* name,long argc,t_atom* args){
    if(argc!=1)return;
    const double db=atom_getfloat(args);
    if(!std::isfinite(db))return;
    auto& gain=name==gensym("drive")?d->core->drive:d->core->output;
    gain.target.store(std::pow(10.,std::clamp(db,-24.,24.)/20.),std::memory_order_relaxed);
}

static void transport(Device* d,t_atom_long packed){
    d->core->meterCommand.store(packed,std::memory_order_release);
}

static bool process(Core& c,double** in,double** out,int count){
    if(!c.instance||count>c.vector)return false;
    c.drive.update(c.drive.target.load(std::memory_order_relaxed),c.rampFrames);
    const double output=c.output.target.load(std::memory_order_relaxed);
    if(output!=c.output.previous)c.settledFrames=0;
    c.output.update(output,c.rampFrames);

    double* driven[]={c.driven[0].data(),c.driven[1].data()};
    if(!c.drive.unity()){
        for(int i=0;i<count;i++){
            const double g=c.drive.next();
            driven[0][i]=g*in[0][i];driven[1][i]=g*in[1][i];
        }
    }else{driven[0]=in[0];driven[1]=in[1];}

    if(!c.instance->render(driven,out,count))return false;
    if(!c.output.unity()){
        for(int i=0;i<count;i++){
            const double g=c.output.next();
            out[0][i]*=g;out[1][i]*=g;
        }
    }
    if(c.output.remaining==0)
        c.settledFrames=std::min(c.meters.windowFrames(),c.settledFrames+count);
    return true;
}

static void run(Device* d,t_object*,double** in,long,double** out,long,long n,long,void*){
    auto& c=*d->core;
    std::unique_lock lock(c.swap,std::try_to_lock);
    const bool wet=lock&&process(c,in,out,(int)n);
    if(!wet)for(int ch=0;ch<2;ch++)std::copy_n(in[ch],n,out[ch]);
    if(!lock)return;

    const auto command=c.meterCommand.load(std::memory_order_acquire);
    const long epoch=command>>1;
    if(epoch!=c.meterEpoch){c.meterEpoch=epoch;c.meters.reset();}
    if((command&1)==0)return;
    MeterReading reading;
    if(c.meters.append(in,out,(int)n,reading)){
        const bool settled=wet&&c.settledFrames>=c.meters.windowFrames();
        c.meterMailbox.publish(epoch,reading,settled);
        qelem_set(d->queue);
    }
}
static void dsp(Device* d,t_object* chain,short*,double rate,long n,long){
    auto& c=*d->core;
    {
        std::lock_guard lock(c.swap);
        if(c.rate!=rate&&rate>0)c.meters.configure(rate);
        c.rampFrames=std::max(1,(int)std::lround(rate*.005));
        c.rate=rate;c.vector=(int)n;
        for(auto& channel:c.driven)channel.resize(n);
        if(c.instance&&!c.instance->prepare(rate,(int)n))object_warn((t_object*)d,"DSP setup failed");
    }
    object_method(chain,gensym("dsp_add64"),d,run,0,nullptr);
}
static void destroy(Device* d){dsp_free((t_pxobject*)d);releasePlugin(d);qelem_free(d->queue);delete d->core;}
static void* create(){
    Device* d=(Device*)object_alloc(type);if(!d)return nullptr;d->core=new Core;d->queue=qelem_new(d,(method)flush);
    dsp_setup((t_pxobject*)d,2);d->obj.z_misc|=Z_NO_INPLACE;
    d->events=outlet_new(d,nullptr);outlet_new(d,"signal");outlet_new(d,"signal");return d;
}
extern "C" __attribute__((visibility("default"))) void ext_main(void*){
    type=class_new("oxfordinflatorpeak~",(method)create,(method)destroy,sizeof(Device),nullptr,0);
    class_addmethod(type,(method)load,"load",A_GIMME,0);class_addmethod(type,(method)setParam,"param",A_GIMME,0);
    class_addmethod(type,(method)show,"open",0);class_addmethod(type,(method)dsp,"dsp64",A_CANT,0);
    class_addmethod(type,(method)snapshot,"snapshot",0);
    class_addmethod(type,(method)trim,"drive",A_GIMME,0);
    class_addmethod(type,(method)trim,"output",A_GIMME,0);
    class_addmethod(type,(method)transport,"metering",A_LONG,0);
    class_dspinit(type);class_register(CLASS_BOX,type);
}
