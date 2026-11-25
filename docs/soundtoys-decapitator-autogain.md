# Decapitator VST3 AutoGain and OutputTrim notifications

**Support request draft**

When AutoGain changes OutputTrim in response to a host-driven Drive edit, how should a VST3 host learn the new trim value? This affects a Max for Live wrapper that exposes Decapitator's controls and restores them when a Live Set opens.

We tested Decapitator 5.5.5.19885 on macOS using Steinberg's VST3 SDK, stereo 32-bit floating point, 48 kHz and 64 frames per block. The processor received an output parameter changes queue. We logged its OutputTrim points, component-handler edit callbacks and component restart requests. The test used a restored instance and host-driven parameter edits.

1. With AutoGain on and Drive at 7.8, set OutputTrim manually to −10.5 dB and allow processing to settle.
2. Raise Drive to 8.8 through the controller and deliver the change to the processor at sample offset zero. Read OutputTrim through `IEditController::getParamNormalized` immediately after the controller write and again after one processing block.
3. The immediate read returned 0.5625 (−10.5 dB). The read after one block returned 0.416666667 (−14 dB). Across this Drive change we observed no OutputTrim edit callback, output parameter point for OutputTrim, or parameter-values-changed restart request. Writing the old value back then raised the measured output by 3.50 dB.

Is this the intended notification behavior for a dependent parameter? Is there a supported notification or synchronization point for hosts that need the effective OutputTrim, including for a save immediately following a Drive edit? Our current host can query the new value after processing in this example. We would appreciate guidance for automation and editor-driven changes as well.
