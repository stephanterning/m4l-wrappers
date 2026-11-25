"""Compare the samples from both gain stages in Max against the release ramp law."""
import argparse
import json
import math
import subprocess
import sys
import tempfile
import time
import uuid
from pathlib import Path

HERE = Path(__file__).resolve().parent
sys.path.insert(0, str(HERE.parents[1]))
from host.portable_audio import _box, _patch, _wire, gain_stage

INPUT = (0.125, -0.75)
PROCESSED = (0.625, -0.375)


def make_probe(folder):
    patch = _patch()
    name = "gain_test_" + uuid.uuid4().hex
    result = folder / "samples.jsonl"
    controller = "const bufferName = " + json.dumps(name) + ";\n"
    controller += "const resultFile = " + json.dumps(result.as_posix()) + ";\n"
    controller += (HERE / "gain-probe.js").read_text()
    _box(patch, "control", "v8.codebox", 450, 15, numinlets=1, numoutlets=3, code=controller)
    for stage, post in (("pre", False), ("post", True)):
        _box(patch, stage, "newobj", 25 if not post else 200, 105,
             text="p " + stage, patcher=gain_stage(post))
        _wire(patch, "control", int(post), stage, 4 if post else 2)
    for i, value in enumerate(INPUT + PROCESSED):
        source = f"input{i}"
        _box(patch, source, "newobj", 10 + i * 100, 55, text=f"sig~ {value}")
        _wire(patch, source, 0, "post", i)
        if i < 2:
            _wire(patch, source, 0, "pre", i)
    _box(patch, "record", "newobj", 25, 195, varname="recorder", text=f"record~ {name} 4")
    _box(patch, "buffer", "newobj", 220, 195, varname="samples", text=f"buffer~ {name} 1000 4")
    for i in range(2):
        _wire(patch, "pre", i, "record", i)
        _wire(patch, "post", i, "record", i + 2)
    _box(patch, "silent", "newobj", 15, 240, text="*~ 0.")
    _box(patch, "dac", "newobj", 15, 280, text="dac~")
    _wire(patch, "post", 0, "silent", 0)
    _wire(patch, "silent", 0, "dac", 0)
    _wire(patch, "control", 2, "dac", 0)
    path = folder / "Stereo gain probe.maxpat"
    path.write_text(json.dumps({"patcher": patch}))
    return path, result


def run(max_executable, folder):
    patch, result = make_probe(folder)
    process = subprocess.Popen([str(max_executable), str(patch)])
    try:
        for _ in range(160):
            if result.exists():
                lines = result.read_text().splitlines()
                if lines and lines[-1] == '["done"]':
                    return [json.loads(line) for line in lines[:-1]]
                if lines and lines[-1].startswith('["error"'):
                    raise RuntimeError(lines[-1])
            if process.poll() is not None:
                break
            time.sleep(0.25)
        raise RuntimeError("Max did not finish the muted stereo gain probe")
    finally:
        if process.poll() is None:
            process.terminate()
            process.wait(timeout=15)


def gain(db):
    return 10 ** (db / 20)


def check_channel(values, start, end, duration, first_wet=None):
    """The control tick is asynchronous. Locate its edge, then check every sample."""
    if len(values) < 2 * duration or not math.isclose(values[0], start, rel_tol=1e-7):
        raise ValueError("Missing or unexpected initial signal")
    edge = next((i for i, sample in enumerate(values) if sample != values[0]), len(values))
    if end != start and (edge == len(values) or edge + duration >= len(values)):
        raise ValueError("Transition was missing or incomplete")
    for i, actual in enumerate(values):
        if i < edge:
            expected = start
        elif duration and i < edge + duration:
            base = start if first_wet is None else first_wet
            expected = base + (end - base) * (i - edge + 1) / duration
        else:
            expected = end
        # record~/buffer~ store 32-bit floats. MSP runs the gain calculation at 64 bits.
        if not math.isclose(actual, expected, rel_tol=1e-7, abs_tol=1e-9):
            raise ValueError(f"Sample {i} measured {actual}, expected {expected}")


def verify(rows):
    expected_stages = ["unity-dry", "trim-while-dry", "wet", "wet-retarget",
                       "missing", "new-trim-while-missing", "recovered"]
    if [row[0] for row in rows] != expected_stages:
        raise ValueError("Incomplete sequence of gain measurements")
    for name, rate, channels in rows:
        if rate <= 0 or len(channels) != 4:
            raise ValueError("Invalid measurement format")
        ramp = math.floor(rate * 0.005 + 0.5)
        for i, runs in enumerate(channels):
            values = [value for value, frames in runs for _ in range(frames)]
            if len(values) < rate * 0.04:
                raise ValueError(f"No active audio in {name}, channel {i + 1}")
            ch = i % 2
            dry, processed = INPUT[ch], PROCESSED[ch]
            if i < 2:
                # Pre Gain always processes input, including when Post Gain passes dry audio.
                start, end = {
                    "unity-dry": (0, 0), "trim-while-dry": (0, 12), "wet": (12, 12),
                    "wet-retarget": (12, -6), "missing": (-6, -6),
                    "new-trim-while-missing": (-6, -6), "recovered": (-6, -6),
                }[name]
                expected = dry * gain(start), dry * gain(end), ramp
            else:
                # On recovery the wet ramp resumes from its previous gain. The first
                # sample uses the processed input, even when the dry signal differs.
                expected = {
                    "unity-dry": (dry, dry, 0),
                    "trim-while-dry": (dry, dry, 0),
                    "wet": (dry, processed * gain(-18), ramp, processed),
                    "wet-retarget": (processed * gain(-18), processed * gain(18), ramp),
                    "missing": (processed * gain(18), dry, 0),
                    "new-trim-while-missing": (dry, dry, 0),
                    "recovered": (dry, processed * gain(-12), ramp, processed * gain(18)),
                }[name]
            try:
                check_channel(values, *expected)
            except ValueError as exc:
                raise ValueError(f"{name}, channel {i + 1} at {rate} Hz: {exc}") from exc
        print(f"PASS {name} at {rate} Hz")


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("max_executable", type=Path, help="Executable for a separate Max 9 instance")
    args = parser.parse_args()
    with tempfile.TemporaryDirectory(prefix="m4l-gain-") as work:
        verify(run(args.max_executable.resolve(), Path(work)))
