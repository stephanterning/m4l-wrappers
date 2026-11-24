// Diagnostic only. A positive pulse reports float64, a negative pulse float32.
// The marker also requires the declared setup precision to agree with process().
#include "public.sdk/source/vst/vstsinglecomponenteffect.h"
#include "public.sdk/source/main/pluginfactory.h"
#include <algorithm>

using namespace Steinberg;
using namespace Steinberg::Vst;

class Precision final : public SingleComponentEffect {
public:
    static FUnknown* create(void*) { return static_cast<IAudioProcessor*>(new Precision); }
    tresult PLUGIN_API initialize(FUnknown* context) override {
        auto result = SingleComponentEffect::initialize(context);
        if (result == kResultOk) {
            addAudioInput(STR16("Input"), SpeakerArr::kStereo);
            addAudioOutput(STR16("Output"), SpeakerArr::kStereo);
        }
        return result;
    }
    tresult PLUGIN_API canProcessSampleSize(int32 size) override {
        return size == kSample32 || size == kSample64 ? kResultTrue : kResultFalse;
    }
    tresult PLUGIN_API process(ProcessData& data) override {
        if (!data.numSamples || !data.numInputs || !data.numOutputs) return kResultOk;
        if (data.symbolicSampleSize != processSetup.symbolicSampleSize) return kResultFalse;
        for (int c = 0; c < data.outputs[0].numChannels; ++c) {
            if (data.symbolicSampleSize == kSample64)
                std::transform(data.inputs[0].channelBuffers64[c], data.inputs[0].channelBuffers64[c] + data.numSamples,
                               data.outputs[0].channelBuffers64[c], [](double sample) { return 0.5 * sample; });
            else
                std::transform(data.inputs[0].channelBuffers32[c], data.inputs[0].channelBuffers32[c] + data.numSamples,
                               data.outputs[0].channelBuffers32[c], [](float sample) { return -0.5f * sample; });
        }
        data.outputs[0].silenceFlags = data.inputs[0].silenceFlags;
        return kResultOk;
    }
};

BEGIN_FACTORY_DEF("M4L Wrappers tests", "", "")
    DEF_CLASS2(INLINE_UID(0x3A79EE42,0xB79E473C,0x8F6BE2FE,0x79559E23),
               PClassInfo::kManyInstances,kVstAudioEffectClass,"MaxHostPrecision",0,"Fx","1.0",kVstVersionString,Precision::create)
END_FACTORY
