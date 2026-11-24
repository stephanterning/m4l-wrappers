# M4L Wrappers

Control Soundtoys Decapitator, Wavesfactory Spectre and Sonnox Oxford Inflator from Ableton Live’s Device View. Each wrapper adds linked Pre Gain and Post Gain controls, input and output meters, and one-click gain matching by short-term LUFS, RMS or sample peak.

Each v1.4 download contains a single `.amxd`. Install the corresponding licensed VST3 plug-in and open the wrapper in Live with Max for Live. The devices support macOS (Apple Silicon and Intel), with beta support for Windows x64.

## Spectre Wrapper

Drag five colour-coded bands to shape saturation by frequency. Each band has its own saturation type and channel selection.

[Download on Gumroad](https://stephanterning.gumroad.com/l/m4l-spectre-wrapper) · [View on maxforlive.com](https://maxforlive.com/library/device/17391/spectre-wrapper)

![Spectre Wrapper v1.4 with five saturation curves and the controls for band 3](docs/images/spectre.png)

## Oxford Inflator Wrapper

Adjust Input, Effect, Curve and Output, and switch Clip 0 dB, Band Split and Effect In directly from the device panel.

[Download on Gumroad](https://stephanterning.gumroad.com/l/m4l-oxfird-inflator-wrapper) · [View on maxforlive.com](https://maxforlive.com/library/device/17392/oxford-inflator-wrapper)

![Oxford Inflator Wrapper v1.4 with its four faders between the input and output meters](docs/images/oxford-inflator.png)

## Decapitator Wrapper

Choose among five saturation styles, push Drive or engage Punish, then shape the sound with the filters and Tone control. Use Mix to blend the processed signal with the dry input.

[Download on Gumroad](https://stephanterning.gumroad.com/l/m4l-decapitator-wrapper) · [View on maxforlive.com](https://maxforlive.com/library/device.php?id=17424)

![Decapitator Wrapper v1.4 with style E selected, Punish engaged and automatic output trim](docs/images/decapitator.png)

## How v1.4 works

All three wrappers load their VST3 by name through Max’s `vst~` on both macOS and Windows. The shared adapter handles parameter mapping, plug-in state and latency reporting. A separate Max external, `m4lwrappergainstage~`, handles pre/post gain, metering and dry routing. Its C++ source is shared across platforms. Each cross-platform device embeds a universal macOS binary and a Windows x64 binary of this external.

If a plug-in is missing, the wrapper lists the affected tracks and passes audio through dry. After restoring the VST3 installation, restart Live and reopen the Set to recall the saved plug-in state.

## Build v1.4 from source

To use a release, download the wrapper from Gumroad, unzip it and open the .amxd in Live. The tools below are for building from source.

On macOS, Python 3 runs the packaging script. The Xcode Command Line Tools provide the C++ compiler for the shared gain and meter external, which uses Cycling ’74’s Max SDK headers. If you use Git to fetch the headers, run these commands from the repository root:

```sh
git clone https://github.com/Cycling74/max-sdk-base.git deps/max-sdk-base
git -C deps/max-sdk-base checkout c03a2922a2a8ff149165a1e2ea134e9321d6e202
```

You can also point `MAX_SDK_BASE` at an existing checkout. With the Max SDK in place, build Decapitator directly from the repository:

```sh
python3 experimental/max-host/build_candidate.py decapitator dist/v1.4
```

The Spectre and Oxford builders take their patch layout, Live parameter definitions and some bundled resources from the matching v1.3 device. Place those two released files in a separate directory, for example `build/v1.3/`, then run:

```sh
python3 experimental/max-host/build_candidate.py spectre "build/v1.3/Spectre Wrapper.amxd" dist/v1.4
python3 experimental/max-host/build_candidate.py oxford-inflator "build/v1.3/Oxford Inflator Wrapper.amxd" dist/v1.4
```

These commands produce macOS devices in `dist/v1.4/`. With the v1.3 inputs available, all three builds work without Steinberg’s VST3 SDK. If you need to generate the two input devices from a fresh clone, the legacy `build.py` still uses the Steinberg SDK. The optional precision-test plug-in also uses it.

### Include Windows x64 support

Build the shared gain and meter external once on Windows using the same Max SDK checkout, Visual Studio 2022 with Desktop development with C++, and CMake 3.25 or later:

```powershell
cmake -S experimental/max-host -B build/output -G "Visual Studio 17 2022" -A x64
cmake --build build/output --config Release
```

Copy `m4lwrappergainstage~.mxe64` from `build/output/externals/` to the same directory on the Mac. Append `--windows-externals build/output/externals` to each of the three Python build commands above. Each resulting `.amxd` then contains both platform binaries.

## Development and verification

The Max host adapter and shared audio code live in `experimental/max-host/`. Each wrapper’s controls, panel and configuration live under `devices/`. The common meter UI, gain linking, gain matching and missing-plug-in warnings live in `shared/`.

When adding or updating a wrapper, preserve its Live parameter identifiers and per-instance plug-in state. Test recall by saving two differently configured instances in the previous version and reopening the Set after replacing the device at the same path. Also check automation, missing-plug-in recovery, CPU time and sample alignment against the VST3 loaded directly in Live. Include modes that change latency.

Run the adapter and controller checks from the repository root:

```sh
node tests/max-host/adapter.cjs
node tests/oxford.cjs
node tests/spectre.cjs "dist/v1.4/Spectre Wrapper.amxd"
```
