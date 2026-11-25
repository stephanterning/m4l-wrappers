// Test external for an isolated stereo comparison. Mix stays at zero so the
// measured pulse reveals Decapitator's physical delay without distortion.
#include "ext.h"
#include "z_dsp.h"
#include "pluginterfaces/vst/ivstaudioprocessor.h"
#include "public.sdk/source/vst/hosting/hostclasses.h"
#include "public.sdk/source/vst/hosting/module.h"
#include "public.sdk/source/vst/hosting/parameterchanges.h"
#include "public.sdk/source/vst/hosting/plugprovider.h"
#include "public.sdk/source/vst/utility/stringconvert.h"
#include <algorithm>
#include <array>
#include <memory>
#include <vector>

using namespace Steinberg;
using namespace Steinberg::Vst;
using VST3::Hosting::Module;

struct Provider : PlugProvider {
    using PlugProvider::PlugProvider;
    using PlugProvider::setupPlugin;
};

struct Probe {
    IPtr<HostApplication> host = owned(new HostApplication);
    Module::Ptr module;
    std::unique_ptr<Provider> provider;
    IPtr<IComponent> component;
    IPtr<IEditController> controller;
    IPtr<IAudioProcessor> processor;
    ParamID mix = kNoParamId;
    ParameterChanges changes{1};
    std::array<std::vector<float>, 4> buffers;
    bool active = false;
    bool running = false;

    bool load(const char* path) {
        std::string error;
        module = Module::create(path, error);
        if (!module) return false;
        auto factory = module->getFactory();
        for (const auto& info : factory.classInfos()) {
            if (info.ID().toString() != "56535453744463646563617069746174") continue;
            provider = std::make_unique<Provider>(factory,info);
            if (!provider->setupPlugin(host)) return false;
            component = provider->getComponentPtr();
            controller = provider->getControllerPtr();
            processor = U::cast<IAudioProcessor>(component);
            if (!processor || !controller || processor->canProcessSampleSize(kSample32) != kResultTrue) return false;
            for (int i=0; i<controller->getParameterCount(); ++i) {
                ParameterInfo p{};
                if (controller->getParameterInfo(i,p)==kResultOk && VST3::StringConvert::convert(p.title)=="Mix") mix=p.id;
            }
            SpeakerArrangement stereo = SpeakerArr::kStereo;
            if (mix==kNoParamId || processor->setBusArrangements(&stereo,1,&stereo,1)!=kResultOk) return false;
            return component->activateBus(kAudio,kInput,0,true)==kResultOk &&
                   component->activateBus(kAudio,kOutput,0,true)==kResultOk;
        }
        return false;
    }
    void stop() {
        if (running) processor->setProcessing(false);
        if (active) component->setActive(false);
        running = active = false;
    }
    ~Probe() { stop(); }
    bool prepare(double rate, long vector) {
        stop();
        if (!processor || mix==kNoParamId || vector<=0) return false;
        for (auto& b:buffers) b.resize(vector);
        ProcessSetup setup{kRealtime,kSample32,static_cast<int32>(vector),rate};
        if (processor->setupProcessing(setup)!=kResultOk || component->setActive(true)!=kResultOk) return false;
        active=true;
        const auto result=processor->setProcessing(true);
        running = result==kResultOk || result==kNotImplemented;
        changes.clearQueue();
        int32 index=0;
        controller->setParamNormalized(mix,0);
        changes.addParameterData(mix,index)->addPoint(0,0,index);
        return running;
    }
    bool process(double** in,double** out,long frames) {
        if (!running || size_t(frames)>buffers[0].size()) return false;
        for (int i=0;i<2;++i) std::copy_n(in[i],frames,buffers[i].data());
        float* inputs[]{buffers[0].data(),buffers[1].data()};
        float* outputs[]{buffers[2].data(),buffers[3].data()};
        AudioBusBuffers input{},output{};
        input.numChannels=output.numChannels=2;
        input.channelBuffers32=inputs; output.channelBuffers32=outputs;
        ProcessData data{};
        data.processMode=kRealtime;data.symbolicSampleSize=kSample32;data.numSamples=static_cast<int32>(frames);
        data.numInputs=data.numOutputs=1;data.inputs=&input;data.outputs=&output;data.inputParameterChanges=&changes;
        const auto result=processor->process(data);
        changes.clearQueue();
        if (result!=kResultOk) return false;
        for (int i=0;i<2;++i) std::copy_n(outputs[i],frames,out[i]);
        return true;
    }
};

struct Device { t_pxobject obj; Probe* probe; void* latency; bool loaded; };
static t_class* type;
static void perform(Device* d,t_object*,double** in,long,double** out,long,long frames,long,void*) {
    if (!d->loaded || !d->probe->process(in,out,frames))
        for (int i=0;i<2;++i) std::fill_n(out[i],frames,0.);
}
static void dsp64(Device* d,t_object* chain,short*,double rate,long vector,long) {
    if (d->loaded && !d->probe->prepare(rate,vector))
        object_error(reinterpret_cast<t_object*>(d),"Could not configure the diagnostic VST3 processor.");
    object_method(chain,gensym("dsp_add64"),d,perform,0,nullptr);
}
static void report(Device* d) {
    if (d->loaded && d->probe->running) outlet_int(d->latency,d->probe->processor->getLatencySamples());
}
static void destroy(Device* d) { dsp_free(&d->obj);delete d->probe; }
static void* create(t_symbol* path) {
    auto* d=static_cast<Device*>(object_alloc(type));
    if (!d) return nullptr;
    dsp_setup(&d->obj,2);d->obj.z_misc|=Z_NO_INPLACE;
    d->latency=intout(d);outlet_new(d,"signal");outlet_new(d,"signal");
    d->probe=new Probe;
    d->loaded=path && d->probe->load(path->s_name);
    if (!d->loaded) object_error(reinterpret_cast<t_object*>(d),"Expected the Soundtoys Decapitator VST3 bundle path.");
    return d;
}
extern "C" void C74_EXPORT ext_main(void*) {
    type=class_new("m4ldecaplatency~",(method)create,(method)destroy,sizeof(Device),nullptr,A_DEFSYM,0);
    class_addmethod(type,(method)dsp64,"dsp64",A_CANT,0);
    class_addmethod(type,(method)report,"getlatency",0);
    class_dspinit(type);class_register(CLASS_BOX,type);
}
