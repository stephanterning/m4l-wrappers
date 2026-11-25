# Stereo gain regression probe

Run this from the repository root with Python 3 and a local Max 9 audio engine. Supply the path to the Max executable, including the executable inside the application bundle on macOS.

```sh
python3 tests/portable/gain.py "/Applications/Max.app/Contents/MacOS/Max"
```

On Windows, pass the installed Max executable to the same probe.

```powershell
py -3 tests/portable/gain.py "C:\Program Files\Cycling '74\Max 9\Max.exe"
```

The probe opens a temporary patch, starts a muted output and closes its own Max process on completion. It uses the sample rate of the selected Max audio device. An active audio driver is required. The test embeds the production gain patchers and supplies two different stereo signals for the dry and processed paths. It exercises both gain stages, including changing gain while dry and reconnecting a wet signal at a previously applied nonzero trim.

Each result compares every recorded sample against the expected amplitude, including the first sample of a gain ramp and its exact 5 ms length rounded to the nearest sample. The tolerance accounts for the single-precision storage used by Max’s recording buffer. The command exits unsuccessfully for missing audio, incomplete measurements or a signal mismatch.
