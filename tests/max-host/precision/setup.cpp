// Silent inputs are sufficient. Record the stereo output as floating-point audio.
// Left is the setup sample rate / 262144. Right repeats a six-sample frame
// starting at -1, so a capture can begin anywhere in a processing block.
#include "public.sdk/source/main/pluginfactory.h"
#include "public.sdk/source/vst/vstsinglecomponenteffect.h"
#include "pluginterfaces/vst/ivstprocesscontext.h"

using namespace Steinberg;
using namespace Steinberg::Vst;

class SetupProbe final : public SingleComponentEffect {
    unsigned position = 0;
public:
    static FUnknown* create(void*) { return static_cast<IAudioProcessor*>(new SetupProbe); }
    tresult PLUGIN_API initialize(FUnknown* context) override {
        const auto result = SingleComponentEffect::initialize(context);
        if (result == kResultOk) {
            addAudioInput(STR16("Input"), SpeakerArr::kStereo);
            addAudioOutput(STR16("Output"), SpeakerArr::kStereo);
        }
        return result;
    }
    tresult PLUGIN_API canProcessSampleSize(int32 size) override {
        return size == kSample32 || size == kSample64 ? kResultTrue : kResultFalse;
    }
    template <class Sample> void render(Sample** channels, const ProcessData& data) {
        const double frame[] = {-1.0, (processSetup.processMode+1)/4.0, (data.processMode+1)/4.0,
            processSetup.maxSamplesPerBlock/262144.0, data.numSamples/262144.0,
            data.processContext ? data.processContext->sampleRate/262144.0 : 0.0};
        for (int32 i=0; i<data.numSamples; ++i) {
            channels[0][i] = static_cast<Sample>(processSetup.sampleRate/262144.0);
            channels[1][i] = static_cast<Sample>(frame[position]);
            position = (position+1) % 6;
        }
    }
    tresult PLUGIN_API process(ProcessData& data) override {
        if (!data.numSamples || !data.numOutputs || data.outputs[0].numChannels != 2) return kResultOk;
        auto& bus = data.outputs[0];
        if (data.symbolicSampleSize == kSample64) render(bus.channelBuffers64, data);
        else render(bus.channelBuffers32, data);
        bus.silenceFlags = 0;
        return kResultOk;
    }
};

BEGIN_FACTORY_DEF("M4L Wrappers tests", "", "")
    DEF_CLASS2(INLINE_UID(0xBAC80FD7,0x63074995,0xAAD414A4,0x46025E51),
               PClassInfo::kManyInstances,kVstAudioEffectClass,"MaxHostSetup",0,"Fx","1.0",kVstVersionString,SetupProbe::create)
END_FACTORY
