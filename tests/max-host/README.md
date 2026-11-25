# Max VST3 host evaluation

The following measurements were collected during the transition from the v1.3 native host to Max. For current build and test instructions see the [project README](../../README.md).

## Release decision

Use Max’s named VST3 lookup as the target for both wrappers. The measured overhead versus v1.3 is acceptable in exchange for using the same discovery code on macOS and Windows. At the tested block size Oxford added about 7–10 microseconds per block and Spectre about 0.5–3.2. The candidates remain QA builds pending verification of state recovery after saving and reopening a set with a missing plug-in. Custom plug-in folders and playback in Live on Windows still need real-host coverage.

| Device and mode | Direct VST3 | v1.3 | Max-host candidate |
| --- | ---: | ---: | ---: |
| Oxford, Band Split off | 39.0 | 46.4 | 56.8 |
| Oxford, Band Split on | 38.9 | 48.4 | 55.3 |
| Spectre, Normal | 40.3 | 46.9 | 48.5 |
| Spectre, Good | 93.3 | 96.0 | 99.2 |
| Spectre, Best | 151.1 | 156.6 | 157.1 |

Values are median audio-thread microseconds between test devices before and after one serial effect in Live 13.0b26 on Apple Silicon, at 44.1 kHz with 64-sample MSP vectors. Each mode has four timed windows with counterbalanced effect order, transport running and wrapper metering active. The measurement includes the Live track path between the timing devices. Direct Oxford had the same plug-in processing, and both Oxford wrappers had an additional +24 dB post gain. The recorded levels differ by exactly that gain. Use the two wrapper columns for the Oxford regression check. The three Spectre signal paths had matched levels. This table does not give Live’s global CPU percentage.

## Audio, state and failure behavior

- **Oxford 4.04.0**. The licensed VST3 processed three steady input levels through Max with exactly the same double-precision values as the SDK host explicitly configured for 64-bit audio. An explicit 32-bit run produced different values for all three. At inputs 0.1 and 0.100000001 the 64-bit outputs were 0.13615477002105617 and 0.13615477136493795. The 32-bit path returned 0.13615477085113525 for both. A separate dual-precision diagnostic VST3 also returned the 64-bit marker. The test does not cover Oxford 4.01.
- **Spectre 1.5.6**. A neutral standalone patch measured impulse offsets of 0, 60, 64 and 60 samples through Normal, Good, Best and back to Good. Live also reported the same 0/60/64 values as the directly loaded VST3. With two older saved instances, all 39 normalized parameters independently read back through Max matched the released host within 0.000001.
- **Upgrade audio**. Separate parallel chains in Live loaded the released v1.3 device and the candidate from copies of two distinct saved instances per product. A different output channel was compared for each instance. Oxford nulled exactly in the recorded blocks. Spectre’s initial restored audio also nulled exactly for both instances. Across subsequent Quality switches the largest sample difference was below 0.0000001. The comparisons shared a time base and did not shift the recorded audio to obtain these nulls.
- **Storage**. The adapter uses standard VST3 preset files in Max’s temporary directory for interoperation with `vst~`. The Live Set contains the per-instance state. With both tested VST3s, the exported controller chunk was empty, so the candidate can keep writing the same opaque component representation as v1.3. If a plug-in supplies additional nonempty state chunks, the adapter preserves the complete preset in a tagged value. An unavailable device cannot replace the last successful bank. After loading an older bank, a muted parameter readback checks that the import actually took effect before the device enables its wet path.
- **Unavailable VST3**. A missing-plug-in simulation in a Live Set with two Spectre tracks showed both track names in one English startup warning. With nonzero input and stored non-unity trims, each output channel matched its input exactly. The panel and trim controls were inactive and both banks stayed distinct after simulated UI input. A global Max rescan triggered an additional confirmation dialog in Live, so Retry now makes a fresh named VST3 lookup without issuing `scan`. The adapter checks the exported preset’s 128-bit VST3 class ID before enabling controls. These last changes have automated coverage. A complete commercial-plug-in save/close/reopen/Retry cycle after that change, custom folders shared only with Live, and Windows Live playback remain unverified.
- **Platforms**. The v1.3-to-v1.4 evaluation built the Windows x64 Max external and precision diagnostic, then froze both macOS architectures and the Windows DLL into each candidate. Archive tests compare Live parameter definitions, signal connections and platform binaries. These checks do not exercise the commercial plug-ins in Live on Windows.

## Reproduce the probes

Run the following from the repository root. Use a temporary working area, a scratch Max instance and a copy of the Live Set. Keep commercial plug-ins, personal presets, recordings and absolute machine paths outside Git.

1. To collect Max discovery, parameter, snapshot and impulse events, pass the executable of a dedicated Max instance, a product, a locally extracted v1.3 component state and a result file. The runner briefly enables DSP and mutes its output. The result file and exported native snapshot can contain local information.

   ```sh
   python3 tests/max-host/probe.py "/path/to/Max" spectre "/path/to/component.bin" "/tmp/host-events.jsonl"
   ```

2. To test precision negotiation independently of a commercial VST3, configure `tests/max-host/precision` with `-DVST3_SDK=/path/to/full/vst3sdk`, and build the `MaxHostPrecision` target. Run the probe with `--precision --plugin-path /path/to/MaxHostPrecision.vst3`. A unit impulse becomes +0.5 for 64-bit processing and -0.5 for 32-bit. A dry +1 pulse is a failed test.
3. Run adapter checks with `node tests/max-host/adapter.cjs`. Run `python3 tests/package.py dist` after building the current devices to check their frozen resources and v1.4 parameter identities.

The Max interfaces used here are documented in [Cycling ’74’s vst~ reference](https://docs.cycling74.com/reference/vst~/). The binary preset layout follows [Steinberg’s VST3 preset format](https://steinbergmedia.github.io/vst3_dev_portal/pages/Technical+Documentation/Locations+Format/Preset+Format.html).
