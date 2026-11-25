"""Embed the shared stereo gain stages and output meter into each Max device."""
from .meter import meter_box


def _patch(namespace="box"):
    return {"fileversion": 1, "classnamespace": namespace, "rect": [0, 0, 670, 430],
            "boxes": [], "lines": []}


def _box(patch, name, kind, x, y, **attrs):
    box = dict(id=name, maxclass=kind, patching_rect=[x, y, 135, 22], **attrs)
    patch["boxes"].append({"box": box})
    return box


def _wire(patch, src, out, dst, inlet):
    patch["lines"].append({"patchline": {"source": [src, out], "destination": [dst, inlet]}})


def _stereo_gain(post):
    """The release ramp advances on the first wet sample and pauses while dry."""
    gen = _patch("dsp.gen")
    audio_inputs = 4 if post else 2
    for i in range(audio_inputs):
        _box(gen, f"input{i}", "newobj", 15 + 150*i, 20, text=f"in {i+1}")
        _wire(gen, f"input{i}", 0, "gain", i)
    for i in range(2):
        _box(gen, f"output{i}", "newobj", 15 + 150*i, 320, text=f"out {i+1}")
        _wire(gen, "gain", i, f"output{i}", 0)

    code = """Param targetDb(0);
History previousDb(0);
History target(1);
History current(1);
History stepSize(0);
History remaining(0);
"""
    if post:
        code += "Param wet(0);\n"
    code += """
desired = target;
step = stepSize;
left = remaining;
value = current;
if (targetDb != previousDb) {
    desired = pow(10, clamp(targetDb, -24, 24) / 20);
    left = max(1, floor(samplerate * 0.005 + 0.5));
    step = (desired - value) / left;
}
"""
    advance = "left > 0 && wet != 0" if post else "left > 0"
    code += f"""if ({advance}) {{
    left -= 1;
    value = left == 0 ? desired : value + step;
}}
previousDb = targetDb;
target = desired;
stepSize = step;
remaining = left;
current = value;
"""
    if post:
        code += "out1 = wet ? in3 * value : in1;\nout2 = wet ? in4 * value : in2;"
    else:
        code += "out1 = in1 * value;\nout2 = in2 * value;"
    codebox = _box(gen, "gain", "codebox", 15, 65, code=code, numinlets=audio_inputs,
                   numoutlets=2, outlettype=["", ""])
    codebox["patching_rect"] = [15, 65, 595, 220]
    return gen


def gain_stage(post=False):
    patch = _patch()
    audio_inputs = 4 if post else 2
    for i in range(audio_inputs):
        _box(patch, f"input{i}", "inlet", 15 + 130*i, 15, index=i+1)
        _wire(patch, f"input{i}", 0, "trim", i)
    _box(patch, "control", "inlet", 550, 15, index=audio_inputs+1)
    _box(patch, "commands", "newobj", 500, 65, text="route output wet")
    _box(patch, "target", "newobj", 420, 110, text="prepend targetDb")
    _wire(patch, "control", 0, "commands", 0)
    _wire(patch, "commands", 0, "target", 0)
    _wire(patch, "target", 0, "trim", 0)
    _box(patch, "trim", "newobj", 10, 165, text="gen~", patcher=_stereo_gain(post),
         numinlets=audio_inputs, numoutlets=2, outlettype=["signal"]*2)
    for i in range(2):
        _box(patch, f"out{i}", "outlet", 15 + 130*i, 315, index=i+1)
        _wire(patch, "trim", i, f"out{i}", 0)
    if post:
        _box(patch, "wet", "newobj", 540, 110, text="prepend wet")
        _wire(patch, "commands", 1, "wet", 0)
        _wire(patch, "wet", 0, "trim", 0)
        meter = meter_box()
        meter["patching_rect"] = [295, 240, 125, 22]
        patch["boxes"].append({"box": meter})
        for i in range(2):
            _wire(patch, f"input{i}", 0, meter["id"], i)
            _wire(patch, "trim", i, meter["id"], i+2)
        _wire(patch, "control", 0, meter["id"], 4)
        _box(patch, "levels", "outlet", 275, 315, index=3)
        _wire(patch, meter["id"], 0, "levels", 0)
    return patch


def install_audio(patch):
    boxes = {entry["box"]["id"]: entry["box"] for entry in patch["boxes"]}
    for name, post in (("driveRamp", False), ("wrapperOutput", True)):
        inputs = 4 if post else 2
        boxes[name].update(text="p postGainAndMeter" if post else "p preGain",
                           patcher=gain_stage(post), numinlets=inputs + 1,
                           numoutlets=3 if post else 2,
                           outlettype=["signal", "signal"] + ([""] if post else []))
