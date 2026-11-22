#import <AppKit/AppKit.h>
#include "public.sdk/source/vst/hosting/module.h"
#include "public.sdk/source/vst/hosting/plugprovider.h"
#include "public.sdk/source/vst/hosting/hostclasses.h"
#include "public.sdk/source/vst/hosting/parameterchanges.h"
#include "public.sdk/source/vst/utility/stringconvert.h"
#include "public.sdk/source/common/memorystream.h"
#include "pluginterfaces/vst/ivstaudioprocessor.h"
#include "pluginterfaces/vst/ivsteditcontroller.h"
#include "pluginterfaces/gui/iplugview.h"
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
static constexpr std::array<const char*,8> names={"Input Gain","Effect","Curve","Output Gain","In","Band Split","Clip 0dB","Bypass"};
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
class Oxford final : public U::Implements<U::Directly<IComponentHandler,IPlugFrame>> {
    IPtr<HostApplication> host=owned(new HostApplication);
    Module::Ptr module;
    std::unique_ptr<InstanceProvider> provider;
    IPtr<IComponent> component;
    IPtr<IEditController> controller;
    IPtr<IAudioProcessor> processor;
    IPtr<IPlugView> view;
    NSWindow* window=nil;
    id closeObserver=nil;
    bool active=false,processing=false,mapped=false;
    int block=0;
    double rate=0;
    std::array<ParamID,8> ids{};
    std::array<std::atomic<double>,8> pending{};
    std::atomic<unsigned> dirty{0},editorDirty{0};
    ParameterChanges changes{8};
    std::function<void()> wake;
    std::atomic<bool> refreshAll{false};
    void postEdit(int i,double value){
        pending[i].store(value,std::memory_order_relaxed);
        dirty.fetch_or(1u<<i,std::memory_order_release);
    }
public:
    explicit Oxford(std::function<void()> wake):wake(std::move(wake)){}
    void detachEditor(){
        if(closeObserver){[[NSNotificationCenter defaultCenter] removeObserver:closeObserver];closeObserver=nil;}
        if(view){view->removed();view->setFrame(nullptr);view=nullptr;}
    }
    void closeEditor(){
        NSWindow* old=window;window=nil;detachEditor();
        if(old){[old orderOut:nil];[old close];}
    }
    void shutdown(){
        mapped=false;
        closeEditor();stop();
        if(controller)controller->setComponentHandler(nullptr);
        processor=nullptr;controller=nullptr;component=nullptr;provider.reset();module.reset();
    }
    ~Oxford() override {shutdown();}
    bool open(const std::string& file,std::string& error){
        module=getModule(file,error);if(!module)return false;
        const auto& factory=module->getFactory();
        for(const auto& descriptor:factory.classInfos()){
            if(descriptor.ID().toString()!="5653544F494E546F78666F726420696E")continue;
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
            unsigned found=0;
            for(int j=0;j<controller->getParameterCount();j++){
                ParameterInfo param{};if(controller->getParameterInfo(j,param)!=kResultOk)continue;
                auto title=VST3::StringConvert::convert(param.title);
                for(int i=0;i<8;i++)if(title==names[i]){ids[i]=param.id;pending[i]=controller->getParamNormalized(param.id);found|=1u<<i;}
            }
            if(found!=255){error="Unexpected Oxford parameter list";return false;}
            if(processor->canProcessSampleSize(kSample64)!=kResultOk){error="64-bit audio samples unsupported";return false;}
            SpeakerArrangement arrangement=SpeakerArr::kStereo;
            if(processor->setBusArrangements(&arrangement,1,&arrangement,1)!=kResultOk ||
                component->getBusCount(kAudio,kInput)!=1 || component->getBusCount(kAudio,kOutput)!=1){
                error="Stereo bus layout unavailable";return false;
            }
            component->activateBus(kAudio,kInput,0,true);component->activateBus(kAudio,kOutput,0,true);
            // Preallocate every one-point automation queue before it reaches the audio callback.
            for(auto id:ids){int32 index=0;changes.addParameterData(id,index)->addPoint(0,0,index);}
            changes.clearQueue();mapped=true;return true;
        }
        error="Oxford Inflator class ID not found";return false;
    }
    void stop(){
        if(processing)processor->setProcessing(false);processing=false;
        if(active)component->setActive(false);active=false;
    }
    bool prepare(double sr,int frames){
        if(processing&&sr==rate&&frames==block)return true;
        stop();if(!mapped||sr<=0||frames<=0)return false;
        ProcessSetup setup{kRealtime,kSample64,frames,sr};
        if(processor->setupProcessing(setup)!=kResultOk)return false;
        active=component->setActive(true)==kResultOk;
        if(!active)return false;
        auto result=processor->setProcessing(true);
        processing=result==kResultOk||result==kNotImplemented;
        rate=sr;block=frames;dirty.store(255,std::memory_order_release);
        return processing;
    }
    bool render(double** in,double** out,int count){
        if(!processing||count>block)return false;
        // Max's 64-bit DSP buffers match the VST3 format selected on load.
        AudioBusBuffers input{}, output{};
        input.numChannels = output.numChannels = 2;
        input.channelBuffers64 = in;
        output.channelBuffers64 = out;
        const unsigned send=dirty.exchange(0,std::memory_order_acquire);changes.clearQueue();
        for(int i=0;i<8&&send;i++)if(send&(1u<<i)){
            int32 ix=0;changes.addParameterData(ids[i],ix)->addPoint(0,pending[i].load(std::memory_order_relaxed),ix);
        }
        ProcessData data;data.processMode=kRealtime;data.symbolicSampleSize=kSample64;data.numSamples=count;
        data.numInputs=data.numOutputs=1;data.inputs=&input;data.outputs=&output;data.inputParameterChanges=&changes;
        if(processor->process(data)!=kResultOk)return false;
        return true;
    }
    void set(int i,double raw){if(!mapped||i<0||i>=8)return;raw=std::clamp(raw,0.,1.);controller->setParamNormalized(ids[i],raw);postEdit(i,raw);}
    unsigned consumeEdits(){
        if(refreshAll.exchange(false)&&mapped)for(int i=0;i<8;i++){postEdit(i,controller->getParamNormalized(ids[i]));editorDirty.fetch_or(1u<<i);}
        return editorDirty.exchange(0,std::memory_order_acquire);
    }
    double value(int i)const{return pending[i].load();}
    tresult PLUGIN_API restartComponent(int32 flags) override{
        if(mapped&&(flags&kParamValuesChanged)){refreshAll=true;wake();}return kResultOk;
    }
    tresult PLUGIN_API beginEdit(ParamID) override{return kResultOk;}
    tresult PLUGIN_API endEdit(ParamID) override{return kResultOk;}
    tresult PLUGIN_API performEdit(ParamID id,ParamValue val) override{
        if(mapped)for(int i=0;i<8;i++)if(ids[i]==id){postEdit(i,val);editorDirty.fetch_or(1u<<i,std::memory_order_release);wake();break;}
        return kResultOk;
    }
    bool showEditor(){
        if(window){[window makeKeyAndOrderFront:nil];return true;}
        view=owned(controller->createView(ViewType::kEditor));if(!view)return false;
        ViewRect rect{};if(view->isPlatformTypeSupported(kPlatformTypeNSView)!=kResultOk||view->getSize(&rect)!=kResultOk){view=nullptr;return false;}
        NSRect frame=NSMakeRect(0,0,std::max(100,rect.getWidth()),std::max(100,rect.getHeight()));
        window=[[NSWindow alloc] initWithContentRect:frame styleMask:(NSWindowStyleMaskTitled|NSWindowStyleMaskClosable|NSWindowStyleMaskMiniaturizable) backing:NSBackingStoreBuffered defer:NO];
        [window setReleasedWhenClosed:NO];window.title=@"Sonnox Oxford Inflator";[window center];
        view->setFrame(this);
        if(view->attached((__bridge void*)window.contentView,kPlatformTypeNSView)!=kResultOk){
            view->setFrame(nullptr);view=nullptr;[window close];window=nil;return false;
        }
        closeObserver=[[NSNotificationCenter defaultCenter] addObserverForName:NSWindowWillCloseNotification object:window queue:nil usingBlock:^(NSNotification*){
            this->window=nil;this->detachEditor();
        }];
        [window makeKeyAndOrderFront:nil];
        return true;
    }
    NSData* state(){
        MemoryStream stream;
        if(!component||component->getState(&stream)!=kResultOk||stream.getSize()<=0||stream.getSize()>256*1024)return nil;
        return [NSData dataWithBytes:stream.getData() length:stream.getSize()];
    }
    bool recall(NSData* bytes){
        if(!component||!bytes.length||bytes.length>256*1024)return false;
        MemoryStream stream((void*)bytes.bytes,bytes.length);
        if(component->setState(&stream)!=kResultOk)return false;
        stream.seek(0,IBStream::kIBSeekSet,nullptr);controller->setComponentState(&stream);
        for(int i=0;i<8;i++)postEdit(i,controller->getParamNormalized(ids[i]));
        return true;
    }
    tresult PLUGIN_API resizeView(IPlugView* plug,ViewRect* rect) override{
        if(!rect||!window||plug!=view.get())return kResultFalse;
        [window setContentSize:NSMakeSize(rect->getWidth(),rect->getHeight())];return plug->onSize(rect);
    }
};
