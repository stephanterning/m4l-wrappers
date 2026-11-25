"""Build the sample-clocked Max meter as an embedded patch with no external resources."""
from pathlib import Path


def meter_box():
    code = Path(__file__).with_suffix(".genexpr").read_text(encoding="utf-8")
    patch = dict(fileversion=1, rect=[0, 0, 840, 560], boxes=[], lines=[])
    gen = dict(fileversion=1, classnamespace="dsp.gen", rect=[0, 0, 840, 560],
               boxes=[], lines=[])

    def add(p, ident, x, y, **attrs):
        p["boxes"].append({"box": dict(id=ident, patching_rect=[x, y, 72, 22],
                                       **attrs)})

    def connect(p, src, so, dest, di):
        p["lines"].append({"patchline": {"source": [src, so], "destination": [dest, di]}})

    for i in range(4):
        key = f"in{i+1}"
        add(patch, key, 20 + i*90, 20, maxclass="inlet", index=i+1, outlettype=["signal"])
        add(gen, key, 20 + i*90, 20, maxclass="newobj", text=f"in {i+1}")
        connect(gen, key, 0, "dsp", i)
        connect(patch, key, 0, "gen", i)
    add(gen, "dsp", 20, 90, maxclass="codebox", code=code, numinlets=4, numoutlets=10)
    for i in range(10):
        add(gen, f"out{i+1}", 10 + i*80, 170, maxclass="newobj", text=f"out {i+1}")
        connect(gen, "dsp", i, f"out{i+1}", 0)
    add(patch, "gen", 30, 110, maxclass="newobj", text="gen~", patcher=gen,
        numinlets=4, numoutlets=10, outlettype=["signal"]*10)
    add(patch, "commands", 425, 20, maxclass="inlet", index=5)
    connect(patch, "commands", 0, "gen", 0)
    add(patch, "dspState", 540, 20, maxclass="newobj", text="dspstate~")
    add(patch, "started", 540, 55, maxclass="newobj", text="sel 1")
    add(patch, "runs", 605, 55, maxclass="newobj", text="counter")
    add(patch, "generation", 605, 90, maxclass="newobj", text="prepend dsprun")
    connect(patch, "in1", 0, "dspState", 0)
    connect(patch, "dspState", 0, "started", 0)
    connect(patch, "started", 0, "runs", 0)
    connect(patch, "runs", 0, "generation", 0)
    connect(patch, "generation", 0, "gen", 0)
    add(patch, "tick", 20, 175, maxclass="newobj", text="edge~")
    add(patch, "sample", 20, 220, maxclass="newobj", text="t " + " ".join(["b"]*9))
    connect(patch, "gen", 0, "tick", 0)
    connect(patch, "tick", 0, "sample", 0)
    add(patch, "reading", 20, 325, maxclass="newobj", text="pack i i i f f f f f f")
    for i in range(9):
        key = f"sample{i}"
        add(patch, key, 10 + i*90, 275, maxclass="newobj", text="snapshot~")
        connect(patch, "gen", i+1, key, 0)
        connect(patch, "sample", i, key, 0)
        connect(patch, key, 0, "reading", i)
    add(patch, "levels", 20, 375, maxclass="newobj", text="prepend levels")
    add(patch, "out", 20, 425, maxclass="outlet", index=1)
    connect(patch, "reading", 0, "levels", 0)
    connect(patch, "levels", 0, "out", 0)
    return dict(id="portableMeter", varname="portableMeter", maxclass="newobj",
                text="p wrapperMeter", numinlets=5, numoutlets=1, outlettype=[""],
                patching_rect=[420, 1310, 115, 22], patcher=patch)
