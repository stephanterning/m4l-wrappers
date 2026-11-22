# M4L Wrappers

Standalone Max for Live audio effects for controlling installed plug-ins from Ableton Live’s Device View. The first two devices host the VST3 editions of Wavesfactory Spectre and Sonnox Oxford Inflator. Both macOS externals build for Apple Silicon and Intel.

## Spectre Wrapper

![Spectre Wrapper in Ableton Live with five saturation bands and band 4 selected](docs/images/spectre.png)

## Oxford Inflator Wrapper

![Oxford Inflator Wrapper in Ableton Live with Drive Link and Band Split enabled](docs/images/oxford-inflator.png)

Shown with the optional Oxford skin. The default build uses a drawn panel with the same controls.

## Build on macOS

Install Xcode Command Line Tools, Python 3.9 or later and Git. From the repository root:

```sh
mkdir -p deps
git clone https://github.com/steinbergmedia/vst3sdk.git deps/vst3sdk
git -C deps/vst3sdk checkout 3cdf9ca5d1f5b1b21e0a86832aa4abe55607bd96
git -C deps/vst3sdk submodule update --init pluginterfaces base public.sdk
git clone https://github.com/Cycling74/max-sdk-base.git deps/max-sdk-base
git -C deps/max-sdk-base checkout c03a2922a2a8ff149165a1e2ea134e9321d6e202
python3 build.py
```

Existing SDK checkouts can be selected with `VST3_SDK` and `MAX_SDK_BASE`. Run `python3 build.py spectre` or `python3 build.py oxford-inflator` for a single device. Open the resulting file from `dist/` in Live with Max for Live and the corresponding licensed VST3 installed. The Oxford panel draws its own controls by default. A local copy of the original wrapper’s skin can be placed at `devices/oxford-inflator/oxford-surface.png` before building.

## Project layout

Each directory under `devices/` owns its editable Max patch, controller, panel, native host and parameter mapping. The build embeds the controller scripts, UI resources and signed universal Max external in one .amxd per device.

`shared/` contains VST3 module discovery, audio metering, the meter UI, Drive/Output linking, Gain Match and the missing-plugin warning. The warning groups affected tracks by device type and Live Set. Missing instances pass dry audio. Retry repeats discovery and restores the instance when the plug-in is available.

## Adding a wrapper

Start with the device closest to the new plug-in. Give its external and saved state distinct identifiers. Identify the plug-in by VST3 class ID, map its published parameter IDs, and negotiate its supported sample format and bus layout. Preserve the identifiers used by released devices so existing Live Sets can recall them.

Run the controller and package checks after building (Node.js required):

```sh
node tests/oxford.cjs
node tests/spectre.cjs
```

Before releasing a wrapper, check save/reload, missing-plugin recovery and parameter automation in Live. Compare CPU and sample alignment with the native plug-in using identical audio, settings and buffer size, including modes that change latency.
