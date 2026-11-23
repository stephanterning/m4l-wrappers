#include "public.sdk/source/vst/hosting/module.h"
#include "public.sdk/source/vst/hosting/plugprovider.h"
#include "public.sdk/source/vst/hosting/hostclasses.h"
#include "public.sdk/source/vst/hosting/parameterchanges.h"
#include "public.sdk/source/vst/utility/stringconvert.h"
#include "public.sdk/source/common/memorystream.h"
#include "pluginterfaces/vst/ivstaudioprocessor.h"
#include "pluginterfaces/vst/ivsteditcontroller.h"
#include "pluginterfaces/gui/iplugview.h"
#include "Vst3Parameters.h"
#include "PluginEditor.h"
#include "PluginState.h"
#include <array>
#include <atomic>
#include <algorithm>
#include <vector>
#include <functional>
#include <map>
#include <mutex>
using namespace Steinberg;
using namespace Steinberg::Vst;
using VST3::Hosting::Module;
// VST3 ParamIDs are stable across releases and independent of the controller's display order.
static constexpr std::array<Vst3Control,39> controls = {{
    {971255197, "LowShelf Frequency"},
    {971255198, "LowShelf Gain"},
    {971255208, "LowShelf Q"},
    {971255210, "LowShelf Switch"},
    {971255194, "LowShelf Color"},
    {971255207, "LowShelf Processing"},
    {730756839, "Peak 01 Frequency"},
    {730756840, "Peak 01 Gain"},
    {730756850, "Peak 01 Q"},
    {730756852, "Peak 01 Switch"},
    {730756836, "Peak 01 Color"},
    {730756849, "Peak 01 Processing"},
    {730757800, "Peak 02 Frequency"},
    {730757801, "Peak 02 Gain"},
    {730757811, "Peak 02 Q"},
    {730757813, "Peak 02 Switch"},
    {730757797, "Peak 02 Color"},
    {730757810, "Peak 02 Processing"},
    {730758761, "Peak 03 Frequency"},
    {730758762, "Peak 03 Gain"},
    {730758772, "Peak 03 Q"},
    {730758774, "Peak 03 Switch"},
    {730758758, "Peak 03 Color"},
    {730758771, "Peak 03 Processing"},
    {84215663, "HighShelf Frequency"},
    {84215664, "HighShelf Gain"},
    {84215674, "HighShelf Q"},
    {84215676, "HighShelf Switch"},
    {84215660, "HighShelf Color"},
    {84215673, "HighShelf Processing"},
    {69820330, "Input"},
    {195300609, "Output"},
    {2025248219, "Dry Wet"},
    {2336762, "Input Compensation"},
    {1369197791, "Quality"},
    {1333656829, "De-Emphasis"},
    {2372003, "Mode"},
    {907287315, "Processing"},
    {1652125811, "Bypass"},
}};
static constexpr size_t parameterCount = controls.size();
static constexpr uint64_t allParameters = (uint64_t(1) << parameterCount) - 1;
static constexpr size_t qualityIndex = 34;
static constexpr size_t deEmphasisIndex = 35;
class InstanceProvider : public PlugProvider {
public:
    using PlugProvider::PlugProvider;
    bool start(FUnknown* host){return setupPlugin(host);}
};
static Module::Ptr getModule(const std::string& file,std::string& error){
    static std::map<std::string,std::weak_ptr<Module>> cache;
    auto instance=cache[file].lock();
    if(!instance){instance=Module::create(file,error);cache[file]=instance;}
    return instance;
}
class Spectre final : public U::Implements<U::Directly<IComponentHandler,IPlugFrame>> {
    IPtr<HostApplication> host=owned(new HostApplication);
    Module::Ptr module;
    std::unique_ptr<InstanceProvider> provider;
    IPtr<IComponent> component;
    IPtr<IEditController> controller;
    IPtr<IAudioProcessor> processor;
    PluginEditor editor;
    bool active=false,processing=false;
    std::atomic<bool> mapped{false};
    std::array<std::vector<float>,2> input32, output32;
    int block=0;
    double rate=0;
    std::array<ParamID,parameterCount> ids{};
    std::array<std::atomic<double>,parameterCount> pending{};
    std::atomic<uint64_t> dirty{0},editorDirty{0};
    ParameterChanges changes{int32(parameterCount)};
    std::function<void()> wake;
    std::atomic<bool> refreshAll{false};
    std::atomic<bool> latencyChanged{true};
    void postEdit(int i,double value){
        pending[i].store(value,std::memory_order_relaxed);
        dirty.fetch_or((uint64_t(1)<<i),std::memory_order_release);
    }
public:
    explicit Spectre(std::function<void()> wake):wake(std::move(wake)){}
    void closeEditor(){editor.close();}
    void shutdown(){
        mapped=false;
        closeEditor();stop();
        if(controller)controller->setComponentHandler(nullptr);
        processor=nullptr;controller=nullptr;component=nullptr;provider.reset();module.reset();
    }
    ~Spectre() override {shutdown();}
    bool open(const std::string& file,std::string& error){
        module=getModule(file,error);
        if(!module){
            // The SDK may return a localized macOS error. Keep the device message in English.
            error="The VST3 bundle was found, but its executable or plug-in factory could not be loaded.";
            return false;
        }
        const auto& factory=module->getFactory();
        for(const auto& descriptor:factory.classInfos()){
            if(descriptor.ID().toString()!="56535453705472737065637472650000")continue;
            provider=std::make_unique<InstanceProvider>(factory,descriptor);
            if(!provider->start(host)){error="VST3 initialization failed";return false;}
            component=provider->getComponentPtr();controller=provider->getControllerPtr();
            processor=U::cast<IAudioProcessor>(component);
            if(!processor||!controller){error="Processor or controller unavailable";return false;}
            controller->setComponentHandler(this);
            MemoryStream state;
            if(component->getState(&state)==kResultOk){
                state.seek(0,IBStream::kIBSeekSet,nullptr);controller->setComponentState(&state);
            }
            if(!resolveParameters(*controller.get(),controls,38,ids,error))return false;
            for(size_t i=0;i<ids.size();++i)pending[i]=controller->getParamNormalized(ids[i]);
            if(processor->canProcessSampleSize(kSample32)!=kResultOk){error="32-bit float audio samples unsupported";return false;}
            SpeakerArrangement arrangement=SpeakerArr::kStereo;
            if(processor->setBusArrangements(&arrangement,1,&arrangement,1)!=kResultOk ||
                component->getBusCount(kAudio,kInput)!=1 || component->getBusCount(kAudio,kOutput)!=1){
                error="Stereo bus layout unavailable";return false;
            }
            component->activateBus(kAudio,kInput,0,true);component->activateBus(kAudio,kOutput,0,true);
            // Preallocate every one-point automation queue before it reaches the audio callback.
            for(auto id:ids){int32 index=0;changes.addParameterData(id,index)->addPoint(0,0,index);}
            changes.clearQueue();
            mapped=true;
            set(qualityIndex,0.5);
            set(deEmphasisIndex,1.0);
            return true;
        }
        error="Spectre class ID not found";return false;
    }
    void stop(){
        if(processing)processor->setProcessing(false);processing=false;
        if(active)component->setActive(false);active=false;
    }
    bool prepare(double sr,int frames){
        if(processing&&sr==rate&&frames==block)return true;
        stop();if(!mapped||sr<=0||frames<=0)return false;
        for(size_t ch=0;ch<2;++ch){
            input32[ch].resize(frames);
            output32[ch].resize(frames);
        }
        ProcessSetup setup{kRealtime,kSample32,frames,sr};
        if(processor->setupProcessing(setup)!=kResultOk)return false;
        active=component->setActive(true)==kResultOk;
        if(!active)return false;
        auto result=processor->setProcessing(true);
        processing=result==kResultOk||result==kNotImplemented;
        rate=sr;block=frames;dirty.store(allParameters,std::memory_order_release);
        latencyChanged=true;
        wake();
        return processing;
    }
    bool render(double** in,double** out,int count){
        if(!processing||count>block)return false;
        // The Max signal chain uses doubles. Spectre 1.5.x accepts float buffers.
        float* inputs[] = {input32[0].data(),input32[1].data()};
        float* outputs[] = {output32[0].data(),output32[1].data()};
        for(size_t ch=0;ch<2;++ch)std::copy_n(in[ch],count,inputs[ch]);
        AudioBusBuffers input{}, output{};
        input.numChannels = output.numChannels = 2;
        input.channelBuffers32 = inputs;
        output.channelBuffers32 = outputs;
        const uint64_t send=dirty.exchange(0,std::memory_order_acquire);changes.clearQueue();
        for(int i=0;i<parameterCount&&send;i++)if(send&((uint64_t(1)<<i))){
            int32 ix=0;changes.addParameterData(ids[i],ix)->addPoint(0,pending[i].load(std::memory_order_relaxed),ix);
        }
        ProcessData data;data.processMode=kRealtime;data.symbolicSampleSize=kSample32;data.numSamples=count;
        data.numInputs=data.numOutputs=1;data.inputs=&input;data.outputs=&output;data.inputParameterChanges=&changes;
        if(processor->process(data)!=kResultOk)return false;
        for(size_t ch=0;ch<2;++ch)std::copy_n(outputs[ch],count,out[ch]);
        return true;
    }
    void set(int i,double raw){
        if(!mapped||i<0||i>=parameterCount||!std::isfinite(raw))return;
        raw=std::clamp(raw,0.,1.);
        if(controller->setParamNormalized(ids[i],raw)==kResultOk)postEdit(i,raw);
    }
    uint64_t consumeEdits(){
        if(refreshAll.exchange(false)&&mapped)for(int i=0;i<parameterCount;i++){postEdit(i,controller->getParamNormalized(ids[i]));editorDirty.fetch_or((uint64_t(1)<<i));}
        return editorDirty.exchange(0,std::memory_order_acquire);
    }
    double value(int i)const{return pending[i].load();}
    tresult PLUGIN_API restartComponent(int32 flags) override{
        if(mapped){
            if(flags&kParamValuesChanged)refreshAll=true;
            if(flags&kLatencyChanged)latencyChanged=true;
            if(flags&(kParamValuesChanged|kLatencyChanged))wake();
        }
        return kResultOk;
    }
    tresult PLUGIN_API beginEdit(ParamID) override{return kResultOk;}
    tresult PLUGIN_API endEdit(ParamID) override{return kResultOk;}
    tresult PLUGIN_API performEdit(ParamID id,ParamValue val) override{
        if(mapped)for(int i=0;i<parameterCount;i++)if(ids[i]==id){postEdit(i,val);editorDirty.fetch_or((uint64_t(1)<<i),std::memory_order_release);wake();break;}
        return kResultOk;
    }
    uint32_t latencySamples() const {return processor ? processor->getLatencySamples() : 0;}
    bool takeLatencyChange(){return latencyChanged.exchange(false);}
    bool showEditor(){return editor.show(controller.get(),this,"Wavesfactory Spectre");}
    PluginState state(){return readPluginState(component.get());}
    bool recall(const PluginState& bytes){
        if(!restorePluginState(component.get(),controller.get(),bytes))return false;
        for(int i=0;i<parameterCount;i++)postEdit(i,controller->getParamNormalized(ids[i]));
        return true;
    }
    tresult PLUGIN_API resizeView(IPlugView* plug,ViewRect* rect) override{
        return editor.resize(plug,rect);
    }
};
