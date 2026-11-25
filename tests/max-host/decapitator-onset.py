"""Build the source and two preconditioning effects for the 96 kHz Live onset comparison."""
import argparse
from pathlib import Path
import sys

sys.path.insert(0, str(Path(__file__).resolve().parents[2]))
from build import freeze
from host.portable_audio import _box, _patch, _wire


def source():
    patch = _patch()
    objects = [
        ("low", "cycle~ 87.31"), ("mid", "cycle~ 997.19"), ("high", "cycle~ 4831.73"),
        ("lowMid", "+~"), ("tones", "+~"), ("level", "*~ 0.045"),
        ("count", "count~ 0 32768 1 1"), ("impulse", "==~ 64"), ("pulseLevel", "*~ 0.1"),
        ("mix", "+~"), ("transport", "plugsync~"), ("gate", "*~ 0."),
        ("intro", "delay~ 192001 192000"), ("output", "plugout~"),
    ]
    for i, (name, text) in enumerate(objects):
        _box(patch, name, "newobj", 15 + i % 3 * 180, 20 + i // 3 * 50, text=text)
    for start, end, inlet in [
        ("low", "lowMid", 0), ("mid", "lowMid", 1), ("lowMid", "tones", 0),
        ("high", "tones", 1), ("tones", "level", 0), ("count", "impulse", 0),
        ("impulse", "pulseLevel", 0), ("level", "mix", 0), ("pulseLevel", "mix", 1),
        ("mix", "gate", 0), ("transport", "gate", 1), ("gate", "intro", 0),
        ("intro", "output", 0), ("intro", "output", 1),
    ]:
        _wire(patch, start, 0, end, inlet)
    return patch


def precondition(amplitude):
    gen = _patch("dsp.gen")
    for i in range(3):
        _box(gen, f"in{i}", "newobj", 15 + i*160, 20, text=f"in {i+1}")
        _wire(gen, f"in{i}", 0, "pilot", i)
    code = f"""History started(0);
active = max(started, in1 != 0 || in2 != 0);
started = active;
addition = active ? 0 : in3 * {amplitude};
out1 = in1 + addition;
out2 = in2 + addition;"""
    _box(gen, "pilot", "codebox", 15, 80, code=code, numinlets=3, numoutlets=2, outlettype=["", ""])
    for i in range(2):
        _box(gen, f"out{i}", "newobj", 15 + i*160, 280, text=f"out {i+1}")
        _wire(gen, "pilot", i, f"out{i}", 0)
    patch = _patch()
    _box(patch, "in", "newobj", 15, 20, text="plugin~")
    _box(patch, "osc", "newobj", 175, 20, text="cycle~ 733.")
    _box(patch, "sig", "newobj", 15, 80, text="gen~", patcher=gen, numinlets=3,
         numoutlets=2, outlettype=["signal", "signal"])
    _box(patch, "out", "newobj", 15, 140, text="plugout~")
    _wire(patch, "osc", 0, "sig", 2)
    for i in range(2):
        _wire(patch, "in", i, "sig", i)
        _wire(patch, "sig", i, "out", i)
    return patch


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("output", type=Path)
    directory = parser.parse_args().output
    directory.mkdir(parents=True, exist_ok=True)
    for name, patch in [("Onset source", source()), ("Silent intro", precondition(0)),
                        ("Quiet intro", precondition(0.000001))]:
        freeze(patch, directory / (name + ".amxd"), [])
