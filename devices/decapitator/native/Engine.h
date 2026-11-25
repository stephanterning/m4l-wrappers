#pragma once
#include "PluginEditor.h"
#include "pluginterfaces/vst/ivstaudioprocessor.h"
#include "public.sdk/source/vst/hosting/hostclasses.h"
#include "public.sdk/source/vst/hosting/module.h"
#include "public.sdk/source/vst/hosting/parameterchanges.h"
#include "public.sdk/source/vst/hosting/plugprovider.h"
#include "public.sdk/source/vst/utility/stringconvert.h"
#include "public.sdk/source/common/memorystream.h"
#include "public.sdk/source/vst/vstpresetfile.h"
#include <algorithm>
#include <array>
#include <atomic>
#include <functional>
#include <cmath>
#include <vector>

using namespace Steinberg;
using namespace Steinberg::Vst;
struct Provider : PlugProvider {
    using PlugProvider::PlugProvider;
    using PlugProvider::setupPlugin;
};

class Decapitator final : public U::Implements<U::Directly<IComponentHandler,IComponentHandler2,IPlugFrame>> {
    // Slots follow the controls exported by the Max panel. IDs and titles are
    // independently verified, so a different mapping fails before audio is enabled.
    static constexpr std::array<const char*,11> names = {"Style","Drive","Punish","LowCut","Tone",
        "HighCut","Mix","AutoGain","LowThump","HighSlope","OutputTrim"};
    IPtr<HostApplication> host = owned(new HostApplication);
    VST3::Hosting::Module::Ptr module;
    std::unique_ptr<Provider> provider;
    IPtr<IComponent> component;
    IPtr<IEditController> controller;
    IPtr<IAudioProcessor> processor;
    FUID cid;
    std::array<std::atomic<double>,11> values{};
    std::array<std::vector<float>,4> buffers;
    std::atomic<unsigned> dirty{0}, edited{0};
    std::atomic<bool> refresh{false}, stateDirty{false};
    ParameterChanges changes{11};
    std::function<void()> notify;
    bool active=false, running=false;
    PluginEditor editor;
    void queue(int slot,double v) {
        values[slot].store(v,std::memory_order_relaxed);
        dirty.fetch_or(1u<<slot,std::memory_order_release);
    }
    void stop() {
        if (running) processor->setProcessing(false);
        if (active) component->setActive(false);
        running=false; active=false;
    }
public:
    explicit Decapitator(std::function<void()> wake):notify(std::move(wake)) {}
    void shutdown() {
        editor.close(); stop();
        if(controller)controller->setComponentHandler(nullptr);
        processor=nullptr; controller=nullptr; component=nullptr; provider.reset(); module.reset();
    }
    bool open(const std::string& path,std::string& error) {
        module = VST3::Hosting::Module::create(path,error);
        if(!module){error="The VST3 bundle Max found could not be loaded.";return false;}
        const auto factory=module->getFactory();
        for(const auto& entry:factory.classInfos()) {
            if(entry.ID().toString()!="56535453744463646563617069746174")continue;
            cid.fromString(entry.ID().toString().c_str());
            provider=std::make_unique<Provider>(factory,entry);
            if(!provider->setupPlugin(host))break;
            component=provider->getComponentPtr();controller=provider->getControllerPtr();
            processor=U::cast<IAudioProcessor>(component);
            if(!controller || !processor || processor->canProcessSampleSize(kSample32)!=kResultTrue)break;
            std::array<int,11> found{};
            for(int i=0;i<controller->getParameterCount();i++) {
                ParameterInfo parameter{};
                if(controller->getParameterInfo(i,parameter)!=kResultOk)continue;
                auto name=VST3::StringConvert::convert(parameter.title);
                for(size_t k=0;k<names.size();k++) if(name==names[k]) {
                    if(parameter.id!=k+1){error="Unexpected VST3 parameter ID for "+name+".";return false;}
                    ++found[k];
                }
            }
            for(size_t i=0;i<names.size();i++) {
                if(found[i]!=1){error=std::string("Missing or ambiguous VST3 parameter: ")+names[i]+".";return false;}
                int32 index=0;
                changes.addParameterData(i+1,index)->addPoint(0,0,index);
            }
            changes.clearQueue();
            SpeakerArrangement stereo=SpeakerArr::kStereo;
            if(processor->setBusArrangements(&stereo,1,&stereo,1)!=kResultOk ||
               component->activateBus(kAudio,kInput,0,true)!=kResultOk ||
               component->activateBus(kAudio,kOutput,0,true)!=kResultOk)break;
            controller->setComponentHandler(this);
            return true;
        }
        error="The expected stereo Decapitator VST3 processor could not be initialized.";
        return false;
    }
    bool prepare(double rate,long frames) {
        stop();
        if(!processor || rate<=0 || frames<=0)return false;
        for(auto& buffer:buffers)buffer.resize(frames);
        ProcessSetup setup{kRealtime,kSample32,static_cast<int32>(frames),rate};
        if(processor->setupProcessing(setup)!=kResultOk || component->setActive(true)!=kResultOk)return false;
        active=true;
        const auto result=processor->setProcessing(true);
        running=result==kResultTrue || result==kNotImplemented;
        return running;
    }
    long latency() const {return running ? processor->getLatencySamples() : 0;}
    bool process(double** in,double** out,int frames) {
        if(!running || frames<=0 || size_t(frames)>buffers[0].size())return false;
        for(int i=0;i<2;i++) {
            if(in)std::copy_n(in[i],frames,buffers[i].data());
            else std::fill_n(buffers[i].data(),frames,0.f);
        }
        float* inputs[]={buffers[0].data(),buffers[1].data()};
        float* outputs[]={buffers[2].data(),buffers[3].data()};
        AudioBusBuffers input{}, output{};
        input.numChannels=output.numChannels=2;
        input.channelBuffers32=inputs;output.channelBuffers32=outputs;
        // The processor consumes leading silent blocks to prime its latency.
        // Leave silence flags clear so the first transient is processed in full.
        changes.clearQueue();
        const unsigned mask=dirty.exchange(0,std::memory_order_acquire);
        for(unsigned i=0;i<names.size();i++)if(mask&(1u<<i)) {
            int32 ix=0;changes.addParameterData(i+1,ix)->addPoint(0,values[i].load(std::memory_order_relaxed),ix);
        }
        ProcessData data{};
        data.processMode=kRealtime;data.symbolicSampleSize=kSample32;data.numSamples=frames;
        data.numInputs=data.numOutputs=1;data.inputs=&input;data.outputs=&output;data.inputParameterChanges=&changes;
        if(processor->process(data)!=kResultOk)return false;
        if(out)for(int i=0;i<2;i++)std::copy_n(outputs[i],frames,out[i]);
        return true;
    }
    double value(unsigned slot) const {return controller->getParamNormalized(slot+1);}
    void set(unsigned slot,double v) {
        if(slot>=names.size() || !std::isfinite(v))return;
        v=std::clamp(v,0.,1.);controller->setParamNormalized(slot+1,v);queue(slot,v);
    }
    bool recall(NSString* token) {
        if([token isEqualToString:@"-"])return true;
        if(![token hasPrefix:@"preset1_"])return false;
        NSData* bytes=[[NSData alloc] initWithBase64EncodedString:[token substringFromIndex:8] options:0];
        if(!bytes.length || bytes.length>INT32_MAX)return false;
        NSMutableData* mutableBytes=[bytes mutableCopy];
        MemoryStream stream(mutableBytes.mutableBytes,mutableBytes.length);
        return PresetFile::loadPreset(&stream,cid,component,controller);
    }
    NSString* snapshot() {
        MemoryStream proc,ctrl,bank;
        if(component->getState(&proc)!=kResultOk || proc.getSize()<=0)return nil;
        const auto result=controller->getState(&ctrl);
        if(result!=kResultOk && result!=kNotImplemented && result!=kResultFalse)return nil;
        proc.seek(0,IBStream::kIBSeekSet,nullptr);ctrl.seek(0,IBStream::kIBSeekSet,nullptr);
        if(!PresetFile::savePreset(&bank,cid,&proc,result==kResultOk && ctrl.getSize()>0 ? &ctrl : nullptr))return nil;
        NSData* data=[NSData dataWithBytes:bank.getData() length:bank.getSize()];
        return [@"preset1_" stringByAppendingString:[data base64EncodedStringWithOptions:0]];
    }
    tresult PLUGIN_API beginEdit(ParamID) override{return kResultOk;}
    tresult PLUGIN_API endEdit(ParamID) override {return setDirty(true);}
    tresult PLUGIN_API setDirty(TBool changed) override {
        if(changed){stateDirty.store(true,std::memory_order_release);notify();}
        return kResultOk;
    }
    tresult PLUGIN_API requestOpenEditor(FIDString) override{return kNotImplemented;}
    tresult PLUGIN_API startGroupEdit() override{return kResultOk;}
    tresult PLUGIN_API finishGroupEdit() override{return setDirty(true);}
    bool takeStateChange(){return stateDirty.exchange(false,std::memory_order_acquire);}
    tresult PLUGIN_API performEdit(ParamID id,ParamValue v) override {
        if(id>=1 && id<=names.size()){queue(id-1,v);edited.fetch_or(1u<<(id-1),std::memory_order_release);notify();}
        return kResultOk;
    }
    tresult PLUGIN_API restartComponent(int32 flags) override {
        if(flags&kParamValuesChanged)refresh=true;
        if(flags&(kParamValuesChanged|kLatencyChanged))notify();
        return kResultOk;
    }
    unsigned takeEdits() {
        if(refresh.exchange(false)){
            for(unsigned i=0;i<names.size();i++)values[i].store(value(i));
            edited.fetch_or((1u<<names.size())-1);
        }
        return edited.exchange(0,std::memory_order_acquire);
    }
    double editedValue(unsigned i) const {return values[i].load();}
    bool openEditor(){return editor.show(controller,this,"Soundtoys Decapitator");}
    void closeEditor(){editor.close();}
    bool editorOpen() const{return editor.isOpen();}
    tresult PLUGIN_API resizeView(IPlugView* view,ViewRect* rect) override{return editor.resize(view,rect);}
};
