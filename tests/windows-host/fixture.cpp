// Test-only effect. The class/parameter IDs model the vendor API, while the
// audio algorithm multiplies by one control. Never install or distribute this DLL.
#include "public.sdk/source/vst/vstsinglecomponenteffect.h"
#include "public.sdk/source/main/pluginfactory.h"
#include "public.sdk/source/common/pluginview.h"
#include "pluginterfaces/base/ibstream.h"
#include "pluginterfaces/vst/ivstparameterchanges.h"
#include <windows.h>
#include <cstring>

using namespace Steinberg;
using namespace Steinberg::Vst;

#ifdef TEST_SPECTRE
#define TEST_UID INLINE_UID(0x56535453,0x70547273,0x70656374,0x72650000)
constexpr ParamID ids[]={971255197,971255198,971255208,971255210,971255194,971255207,
    730756839,730756840,730756850,730756852,730756836,730756849,
    730757800,730757801,730757811,730757813,730757797,730757810,
    730758761,730758762,730758772,730758774,730758758,730758771,
    84215663,84215664,84215674,84215676,84215660,84215673,
    69820330,195300609,2025248219,2336762,1369197791,1333656829,2372003,907287315,1652125811};
constexpr int precision=kSample32;
#else
#define TEST_UID INLINE_UID(0x5653544F,0x494E546F,0x78666F72,0x6420696E)
constexpr ParamID ids[]={0,1,2,3,4,5,6,13};
constexpr int precision=kSample64;
#endif

class TestView final : public CPluginView {
    HWND child=nullptr;
public:
    TestView(){setRect(ViewRect(0,0,180,100));}
    tresult PLUGIN_API isPlatformTypeSupported(FIDString type) override {
        return type && std::strcmp(type,kPlatformTypeHWND)==0 ? kResultTrue : kResultFalse;
    }
    tresult PLUGIN_API attached(void* parent,FIDString type) override {
        if (!IsWindow(static_cast<HWND>(parent)) || isPlatformTypeSupported(type)!=kResultTrue) return kResultFalse;
        child=CreateWindowExW(0,L"STATIC",L"Test VST3",WS_CHILD,0,0,180,100,
                              static_cast<HWND>(parent),nullptr,GetModuleHandleW(nullptr),nullptr);
        return child ? CPluginView::attached(parent,type) : kResultFalse;
    }
    tresult PLUGIN_API removed() override {
        if(child) DestroyWindow(child);
        child=nullptr;
        return CPluginView::removed();
    }
};

class TestEffect final : public SingleComponentEffect {
    double gain=0.5;
public:
    static FUnknown* create(void*) {return static_cast<IAudioProcessor*>(new TestEffect);}
    tresult PLUGIN_API initialize(FUnknown* ctx) override {
        auto result=SingleComponentEffect::initialize(ctx);
        if(result!=kResultOk)return result;
        addAudioInput(STR16("In"),SpeakerArr::kStereo);
        addAudioOutput(STR16("Out"),SpeakerArr::kStereo);
        for(auto id:ids){
            auto flags=ParameterInfo::kCanAutomate;
            if(id==ids[std::size(ids)-1]) flags=ParameterInfo::kIsBypass;
            parameters.addParameter(STR16("Fixture control"),nullptr,0,0.5,flags,id);
        }
        return kResultOk;
    }
    tresult PLUGIN_API canProcessSampleSize(int32 size) override {return size==precision?kResultTrue:kResultFalse;}
    tresult PLUGIN_API process(ProcessData& d) override {
        if(d.symbolicSampleSize!=precision || d.numInputs!=1 || d.numOutputs!=1)return kResultFalse;
        if(auto changes=d.inputParameterChanges)for(int i=0;i<changes->getParameterCount();++i){
            auto q=changes->getParameterData(i);int32 offset=0;
            if(q && q->getParameterId()==ids[1] && q->getPointCount()>0)
                q->getPoint(q->getPointCount()-1,offset,gain);
        }
        for(int ch=0;ch<2;++ch)for(int i=0;i<d.numSamples;++i){
            if(precision==kSample64)d.outputs->channelBuffers64[ch][i]=d.inputs->channelBuffers64[ch][i]*gain;
            else d.outputs->channelBuffers32[ch][i]=static_cast<float>(d.inputs->channelBuffers32[ch][i]*gain);
        }
        return kResultOk;
    }
    IPlugView* PLUGIN_API createView(FIDString) override {return new TestView;}
    tresult PLUGIN_API getState(IBStream* s) override {return s->write(&gain,sizeof(gain),nullptr);}
    tresult PLUGIN_API setState(IBStream* s) override {
        int32 n=0;
        if(s->read(&gain,sizeof(gain),&n)!=kResultOk || n!=sizeof(gain))return kResultFalse;
        return setParamNormalized(ids[1],gain);
    }
};
BEGIN_FACTORY_DEF("M4L Wrappers tests","","")
    DEF_CLASS2(TEST_UID,PClassInfo::kManyInstances,kVstAudioEffectClass,
               "Wrapper integration fixture",0,"Fx","1.0",kVstVersionString,TestEffect::create)
END_FACTORY
