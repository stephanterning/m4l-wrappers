# Portable audio verification

The reference devices were the three published v1.4 downloads. The unpacked reference files matched the devices inside their distribution archives. All comparisons used local copies of Live Sets, plug-in installations and test signals.

## Gain, sound and saved Sets

- The two embedded gain stages were compared sample by sample with v1.4 at 44.1 kHz. The test included both channels, unity, positive and negative gain changes, falling back to dry audio, changing trim while dry, and resuming the processed path. The largest absolute sample difference was 7.11 × 10⁻¹⁵. A reference built with a 5 ms `line~` ramp produced a maximum difference of 0.00713 during the same transitions. The embedded Gen version advances on the first wet sample and pauses the output ramp while dry, as v1.4 does. With Pre Gain at +12 dB and Post Gain at −6 dB, both channels returned at their previous gains on the first sample after a DSP restart.
- Oxford Inflator 4.04.0 between the portable gain stages produced 0.13615477002105617 and 0.13615477136493795 from steady inputs of 0.1 and 0.100000001. Both outputs and a third higher-level sample matched the archived explicit 64-bit VST3 reference exactly. The 32-bit reference produced the same output for the first two inputs.
- Live reopened two different v1.4 instances of each product with their saved values. The upgrade test loaded the published devices, closed the Set, replaced the three devices at exactly the same paths and reopened the same Set. Its file checksum stayed identical. Six arrangement envelopes still addressed the original controls. Oxford Effect restored to 23% and 74%, Spectre Mix to 26% and 69%, and Decapitator Drive to 2.3 and 7.4. The automation test read back Oxford Curve at 12 and 24, Spectre Band 1 Gain at 2 and 4 dB and Decapitator Tone at 1 and 2 dB. The test allows 0.000001 for floating-point Live API automation readback.
- For the audio comparison, each side of a parallel rack used a copy of the same saved instance and received the same stereo signal. We captured one output channel per instance, 8,192 samples in each of four windows, using a different channel for the second instance. Oxford and Spectre matched v1.4 on every captured sample, including Oxford Band Split and Spectre Quality changes. This comparison used single-precision recordings. The Oxford precision test above read the double-precision DSP output directly.
- Peak, RMS and LUFS Gain Match were each triggered in two running Oxford devices fed the same continuous stereo tones, one using v1.4 and one using the portable meter. Each press changed Post Gain to −6.48 dB, reset the display and disabled all three buttons. The final input/output differences were below 0.003 dB. A single measurement packet carries its epoch, validity, settled state and six readings together. In particular, a downward trim can leave an old, louder sample in the first three-second peak window. That window keeps Gain Match disabled until the ramp has left it.
- A two-track Oxford fixture simulated an unavailable VST3 by asking Max to load a nonexistent name. One English startup alert listed both tracks. With stored non-unity trims, both channels passed the nonzero test tones through exactly, controls were disabled, and a failed Retry raised no second alert. Once the lookup returned the installed Oxford, Retry recovered both distinct saved banks byte for byte. The simulation left the vendor installation intact; discovery after physically reinstalling a VST3 still depends on Max and Live.
- Decapitator reported 62 samples on both parallel paths. The two restored, steady v1.4 instances matched their portable counterparts within 7 × 10⁻¹⁰ full scale. When toggling Punish between windows, the largest residual was 9.4 × 10⁻⁶ (about −101 dBFS). A control using **two copies of published v1.4** also produced a residual, up to 6.9 × 10⁻⁶. Independent Decapitator instances can differ slightly during this test.

In a separate parallel comparison the other rack chain hosted the VST3 directly in Live. Oxford and Spectre nulled at the captured sample precision with matched settings. Spectre’s Normal, Good and Best paths aligned without a sample shift. Across two runs, the largest Decapitator residual including Punish switches was 1.65 × 10⁻⁵ full scale (about −96 dBFS). Live reported 62 samples for both paths.

## Audio-thread timings in Live

A serial track in Live 13.0b26 on an Apple M3 Max played the same periodic stereo signal through each path in turn. A timing device before the effect and another after it measured thread CPU time. The figures are microseconds per 64-sample block at 44.1 kHz, including the track path between the probes. Each cell is the median of four window medians with counterbalanced device order. The empty track path took approximately 16–18 µs. These are processing times, not Live’s total CPU percentage.

| Mode | Direct VST3 | Published v1.4 | Portable | Live latency for all three paths |
| --- | ---: | ---: | ---: | ---: |
| Oxford, Band Split off | 38.4 | 69.8 | 70.9 | 0 samples |
| Oxford, Band Split on | 38.4 | 68.5 | 63.9 | 0 samples |
| Spectre, Normal | 41.2 | 49.4 | 53.4 | 0 samples |
| Spectre, Good | 93.4 | 97.5 | 102.1 | 60 samples |
| Spectre, Best | 152.5 | 157.6 | 160.3 | 64 samples |
| Decapitator, AutoGain off | 123.4 | 132.9 | 134.5 | 62 samples |
| Decapitator, AutoGain on | 123.1 | 130.8 | 136.1 | 62 samples |

The Oxford and Spectre timing builds used the validated K-weighting and shared window; the final meter also clears its window when the audio engine restarts. DSP stayed on throughout these timing windows. The Decapitator timing run used the restart-aware meter. The final four-instance Max comparison also includes the fix that keeps readiness flags synchronized with the measurement. Window-to-window variation was greatest for Oxford. For example, the published Oxford with Band Split off ranged from 60.8 to 75.7 µs; the portable version ranged from 67.5 to 84.4 µs.

## Meter accuracy

At 44.1 and 88.2 kHz the largest steady-state difference from an analytical reference was 0.00000011 dB. At 48 kHz/1,024 samples and 96 kHz/2,048 samples, readings from Max’s NonRealTime driver were within 0.0001 dB. These offline runs verified numerical accuracy. Forwarding events while rendering faster than real time is unsuitable for measuring the display cadence. The real-time probe also tested silence, attenuation of 220 dB, a negative impulse aging out of the three-second window, a transport stop and a DSP restart. A 15 ms delayed readback confirmed that a loud sample from the gain ramp cannot enable a stale Peak match.

All six values use the same 30 complete 100 ms intervals. The release accumulated 10 ms slices and returned the latest complete slice at the end of a reporting vector. With vectors longer than 10 ms, the two meters can therefore sample a changing signal at slightly different instants. When returning to the wet signal, the portable meter waits for the 5 ms gain ramp and the full window. A button can become available one 100 ms update later than v1.4.

## Repeating the checks

Build the devices and run `python3 tests/package.py dist` to check the parameter identities captured from v1.4 and the embedded signal graph. The stereo gain probe verifies the stepped and ramped output of the production stages. [Stereo gain probe](gain.md)

With an installed Max executable, the acoustic probe checks the six readings against analytical frequency responses, sums of squares and sample amplitudes. It exercises warm-up, a single negative pulse and its expiry, gain settlement, pause, reset and an audio-engine restart. Run `python3 tests/max-host/meter-probe.py /path/to/Max`. Add `--upsample 2` to repeat the test at twice the active sample rate, or `--readback-delay 15` to exercise delayed reporting after a gain change.

The four-instance Oxford timing experiment compares the released external, a single shared Gen meter and two stock loudness objects under matched conditions. [CPU measurements and method](performance.md)
