// Four MSP signals enter the output stage: original stereo, then processed stereo.
#include "GainAndMeterOutput.h"
#include "z_dsp.h"
#include <limits>

struct OutputState {
    GainRamp trim;
    StereoMeters meters;
    MeterMailbox mailbox;
    std::atomic<long> transport{0};
    std::atomic<bool> enabled{false};
    long epoch = -1;
    int rampFrames = 240;
    int settledFrames = 0;
};
struct Output {
    t_pxobject object;
    OutputState* state;
    void* events;
    void* queue;
};
static t_class* outputClass;

static void flush(Output* output) {
    t_atom reading[9];
    if (output->state->mailbox.receive(reading))
        outlet_anything(output->events, gensym("levels"), 9, reading);
}
static void process(Output* object, t_object*, double** input, long, double** output,
                    long, long frames, long, void*) {
    auto& state = *object->state;
    const bool wet = state.enabled.load(std::memory_order_acquire);
    const double target = state.trim.target.load(std::memory_order_relaxed);
    if (!wet || target != state.trim.previous) state.settledFrames = 0;
    state.trim.update(target, state.rampFrames);
    if (wet && !state.trim.unity()) {
        for (long i = 0; i < frames; ++i) {
            const double gain = state.trim.next();
            output[0][i] = gain * input[2][i];
            output[1][i] = gain * input[3][i];
        }
    } else {
        const int first = wet ? 2 : 0;
        for (int ch = 0; ch < 2; ++ch) std::copy_n(input[first + ch], frames, output[ch]);
    }
    if (wet && !state.trim.remaining)
        state.settledFrames = std::min(state.meters.windowFrames(), state.settledFrames + int(frames));
    const auto transport = state.transport.load(std::memory_order_acquire);
    if (state.epoch != transport >> 1) {
        state.epoch = transport >> 1;
        state.meters.reset();
    }
    MeterReading result;
    if ((transport & 1) && state.meters.append(input, output, int(frames), result)) {
        state.mailbox.publish(state.epoch, result, wet && state.settledFrames >= state.meters.windowFrames());
        qelem_set(object->queue);
    }
}
static void dsp(Output* output, t_object* chain, short*, double rate, long, long) {
    auto& state = *output->state;
    state.rampFrames = std::max(1, int(std::lround(rate * 0.005)));
    state.meters.configure(rate);
    state.settledFrames = 0;
    object_method(chain, gensym("dsp_add64"), output, process, 0, nullptr);
}
static void trim(Output* output, double db) {
    if (std::isfinite(db)) output->state->trim.target.store(std::pow(10., std::clamp(db, -24., 24.) / 20.));
}
static void wet(Output* output, t_atom_long active) { output->state->enabled.store(active != 0); }
static void transport(Output* output, t_atom_long token) { output->state->transport.store(long(token)); }
static void* create() {
    auto* output = static_cast<Output*>(object_alloc(outputClass));
    if (!output) return nullptr;
    output->state = new OutputState;
    output->queue = qelem_new(output, (method)flush);
    dsp_setup(&output->object, 4);
    output->object.z_misc |= Z_NO_INPLACE;
    output->events = outlet_new(output, nullptr);
    outlet_new(output, "signal");
    outlet_new(output, "signal");
    return output;
}
static void destroy(Output* output) {
    dsp_free(&output->object);
    qelem_free(output->queue);
    delete output->state;
}
extern "C" void C74_EXPORT ext_main(void*) {
    outputClass = class_new("m4lwrapperoutput~", (method)create, (method)destroy, sizeof(Output), nullptr, 0);
    class_addmethod(outputClass, (method)dsp, "dsp64", A_CANT, 0);
    class_addmethod(outputClass, (method)trim, "output", A_FLOAT, 0);
    class_addmethod(outputClass, (method)wet, "wet", A_LONG, 0);
    class_addmethod(outputClass, (method)transport, "metering", A_LONG, 0);
    class_dspinit(outputClass);
    class_register(CLASS_BOX, outputClass);
}
