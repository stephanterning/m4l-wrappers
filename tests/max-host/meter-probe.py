"""Exercise the shipping Gen meter with Max and verify readings against analytic signals.

Usage: python3 tests/max-host/meter-probe.py /path/to/Max [--upsample 2]
Uses the current audio driver rate or its double, without changing audio preferences.
No vendor plug-ins, SDK or platform-specific Max externals are required.
"""
import argparse
import cmath
import json
import math
from pathlib import Path
import subprocess
import sys
import tempfile
import time

sys.path.insert(0, str(Path(__file__).resolve().parents[2]))
from host.meter import meter_box

TONES = [(100, .1), (1000, .2), (2000, .3), (3000, .4)]


def write_patches(folder, events, upsample, vector, delay_ms=0):
    boxes, lines = [], []
    dsp_bus = "acoustic-test-" + folder.name

    def add(name, text=None, x=0, y=0, **attrs):
        obj = dict(id=name, maxclass="newobj", patching_rect=[x, y, 120, 22])
        if text:
            obj["text"] = text
        boxes.append({"box": {**obj, **attrs}})

    def wire(src, port, dest, inlet):
        lines.append({"patchline": {"source": [src, port], "destination": [dest, inlet]}})

    def write(name):
        path = folder / name
        path.write_text(json.dumps({"patcher": dict(fileversion=1, classnamespace="box",
                            rect=[60, 60, 800, 550], boxes=boxes, lines=lines)}), encoding="utf-8")
        boxes.clear()
        lines.clear()
        return path

    code = Path(__file__).with_suffix(".js").read_text(encoding="utf-8")
    add("test", x=10, y=180, maxclass="v8.codebox", numinlets=2, numoutlets=6,
        code="var eventsPath = " + json.dumps(events.as_posix()) + ";\n" + code)
    meter = meter_box()
    if delay_ms:
        # Reproduce a busy UI thread servicing the meter clock late in the interval.
        subpatch = meter["patcher"]
        tick_to_sample = next(row["patchline"] for row in subpatch["lines"]
                              if row["patchline"]["source"] == ["tick", 0])
        tick_to_sample["destination"] = ["probeDelay", 0]
        subpatch["boxes"].append({"box": dict(id="probeDelay", maxclass="newobj",
                                 text=f"delay {delay_ms}", patching_rect=[180, 190, 80, 22])})
        subpatch["lines"].append({"patchline": {"source": ["probeDelay", 0],
                                                "destination": ["sample", 0]}})
    boxes.append({"box": meter})
    add("postGain", "line~ 1.", 520, 355)
    wire("test", 5, "postGain", 0)
    add("zero", "sig~ 0.", 10, 260)
    add("signalOut", "out~ 1", 10, 300)
    add("audioSwitch", "s " + dsp_bus, 150, 300)
    wire("zero", 0, "signalOut", 0)
    wire("test", 1, "audioSwitch", 0)
    add("state", "dspstate~", 350, 250)
    add("rate", "prepend sampleRate", 350, 300)
    add("vector", "prepend vectorSize", 520, 300)
    wire("state", 2, "vector", 0)
    wire("vector", 0, "test", 1)
    wire("zero", 0, "state", 0)
    wire("state", 1, "rate", 0)
    wire("rate", 0, "test", 1)
    for i, (freq, amp) in enumerate(TONES):
        osc, scale, gate = f"tone{i}", f"amp{i}", f"gate{i}"
        x = i * 160
        add(osc, f"cycle~ {freq}", x, 10)
        add(scale, f"*~ {amp}", x, 45)
        add(gate, "*~ 0.", x, 75)
        wire(osc, 0, scale, 0)
        wire(scale, 0, gate, 0)
        wire("test", 2, gate, 1)
        if i < 2:
            wire(gate, 0, "portableMeter", i)
        else:
            trim = f"post{i}"
            add(trim, "*~", x, 105)
            wire(gate, 0, trim, 0)
            wire("postGain", 0, trim, 1)
            wire(trim, 0, "portableMeter", i)
    for i, channel in enumerate((0, 3)):
        pulse = f"pulse{i}"
        add(pulse, "click~", 580, 120 + 35*i)
        wire("test", 3+i, pulse, 0)
        wire(pulse, 0, "portableMeter", channel)
    wire("test", 0, "portableMeter", 4)
    wire("portableMeter", 0, "test", 0)
    write("MeterSignals.maxpat")

    add("voice", f"poly~ MeterSignals 1 up {upsample} @vs {vector}", 10, 20)
    add("silentOutput", "dac~", 10, 80)
    wire("voice", 0, "silentOutput", 0)
    add("switch", "r " + dsp_bus, 180, 20)
    wire("switch", 0, "silentOutput", 0)
    return write("Acoustic meter probe.maxpat")


def k_magnitude(frequency, rate):
    # Independent frequency-domain response of the two BS.1770 K-weighting stages.
    z = cmath.exp(-2j * math.pi * frequency / rate)
    k = math.tan(math.pi * 1681.974450955533 / rate)
    t = k / .7071752369554196
    high = 10 ** (3.999843853973347 / 20)
    mid = high ** .4996667741545416
    shelf = ((high + mid*t + k*k) + 2*(k*k - high)*z + (high - mid*t + k*k)*z*z)
    shelf /= (1 + t + k*k) + 2*(k*k - 1)*z + (1 - t + k*k)*z*z
    h = math.tan(math.pi * 38.13547087602444 / rate)
    u = h / .5003270373238773
    denominator = (1 + u + h*h)
    low_cut = (1-z)**2 / (1 + (2*(h*h-1)*z + (1-u+h*h)*z*z)/denominator)
    return abs(shelf * low_cut)


def check(events, requested_vector):
    rate = next(e[1] for e in events if e[0] == "end")
    vector = next(e[1] for e in events if e[0] == "vector")
    assert not requested_vector or vector == requested_vector, ("Max vector size", vector, requested_vector)
    assert rate > 0, "No DSP sample rate"
    expected = []
    for channels in (TONES[:2], TONES[2:]):
        power = sum(a*a/2 for _, a in channels)
        weighted = sum((a*k_magnitude(f, rate))**2/2 for f, a in channels)
        expected.extend([10*math.log10(weighted)-.691, 10*math.log10(power/2),
                         20*math.log10(max(a for _, a in channels))])
    readings = [e for e in events if e[0] == "levels"]
    errors = []
    for phase in ("tones", "after-stop", "after-dsp-restart", "near-silence", "silence"):
        rows = [e for e in readings if e[1] == phase]
        first = next(i for i, e in enumerate(rows) if e[2])
        assert 20 <= first <= 31, (phase, "fresh three-second window", first)
        reference = [-240.691, -240., -240.] * 2 if phase == "silence" else expected
        if phase == "near-silence":
            reference = [db - 220 for db in expected]
        errors.extend(abs(a-b) for a, b in zip(rows[-1][4:], reference))
    assert max(errors) < .005, ("level mismatch (dB)", max(errors), rate)
    assert any(e[1] == "dry" and not e[3] for e in readings)
    settling = [e for e in readings if e[1] == "settling" and not e[3]]
    assert 20 <= len(settling) <= 31, ("gain settlement", len(settling))
    ramp = [e for e in readings if e[1] == "downward-ramp" and e[2]]
    expected_peak = expected[-1] + 20 * math.log10(.25)
    assert ramp[0][9] > expected_peak + .1, ("initial ramp peak not captured", ramp[0])
    assert any(e[3] for e in ramp), "gain never settled"
    assert all(abs(e[9] - expected_peak) < .005 for e in ramp if e[3]), (
        "offered Gain Match from a window that still contained the louder pre-ramp samples", ramp)
    assert sum(e[1] == "stopped" for e in readings) <= 1, "meter ran while stopped"
    pulses = [e for e in readings if e[1] == "pulse" and e[6] > -200]
    assert 25 <= len(pulses) <= 31, ("peak did not expire after three seconds", len(pulses))
    frames = 300 * int(rate/100 + .5)
    for gain, rms, peak in ((.8, 5, 6), (.7, 8, 9)):
        assert abs(pulses[1][peak] - 20*math.log10(gain)) < .00001
        assert abs(pulses[1][rms] - 10*math.log10(gain*gain/(2*frames))) < .00001
    print(f"PASS at {rate:g} Hz, {vector} samples/vector. Maximum steady-state error {max(errors):.6g} dB.")


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("max_executable", type=Path)
    parser.add_argument("--upsample", type=int, choices=[1, 2, 4], default=1)
    parser.add_argument("--vector", type=int, choices=[0, 64, 128, 256, 512, 1024, 2048], default=0,
                        help="Local poly~ signal vector size supported by the active audio engine (0 inherits)")
    parser.add_argument("--readback-delay", type=int, choices=range(0, 51), default=0,
                        metavar="0..50", help="Delay clock readback in ms to simulate a busy UI")
    parser.add_argument("--events", type=Path, help="Optional JSON Lines recording")
    args = parser.parse_args()
    with tempfile.TemporaryDirectory() as tmp:
        folder = Path(tmp)
        events = folder / "events.jsonl"
        patch = write_patches(folder, events, args.upsample, args.vector, args.readback_delay)
        arguments = [str(args.max_executable.resolve())]
        if sys.platform == "darwin":
            arguments.extend(["-ApplePersistenceIgnoreState", "YES"])
        proc = subprocess.Popen([*arguments, str(patch)])
        try:
            for _ in range(150):
                time.sleep(.5)
                if events.exists() and '"end"' in events.read_text(encoding="utf-8"):
                    break
                if proc.poll() is not None:
                    break
            data = events.read_text(encoding="utf-8").splitlines() if events.exists() else []
            if args.events:
                args.events.write_text("\n".join(data) + "\n", encoding="utf-8")
            rows = [json.loads(line) for line in data]
            assert any(e[0] == "end" for e in rows), ("Max did not finish", rows[-2:])
            check(rows, args.vector)
        finally:
            if proc.poll() is None:
                proc.terminate()
                proc.wait(timeout=15)


if __name__ == "__main__":
    main()
