"""Run Max's stock VST3 host against a v1.3 component state, without modifying a Live Set."""
import argparse
import json
from pathlib import Path
import struct
import subprocess
import tempfile
import time

PLUGINS = {
    "oxford": ("Oxford Inflator", "5653544F494E546F78666F726420696E"),
    "spectre": ("Spectre", "56535453705472737065637472650000"),
}


def write_preset(path, cid, state):
    # VST3 preset with a component chunk, as stored by the released native host.
    index = 48 + len(state)
    path.write_bytes(b"VST3" + struct.pack("<I", 1) + cid.encode("ascii")
                     + struct.pack("<Q", index) + state + b"List" + struct.pack("<I", 1)
                     + b"Comp" + struct.pack("<QQ", 48, len(state)))


def make_patch(path, config):
    boxes, lines = [], []

    def box(name, kind, x, y, **attrs):
        boxes.append({"box": dict(id=name, maxclass=kind, patching_rect=[x, y, 250, 22], **attrs)})

    def connect(a, outlet, b, inlet):
        lines.append({"patchline": {"source": [a, outlet], "destination": [b, inlet]}})

    js = Path(__file__).with_name("probe.js").read_text()
    box("runner", "v8.codebox", 10, 15, numinlets=7, numoutlets=4,
        code="var config = " + json.dumps(config) + ";\n" + js)
    box("effect", "newobj", 10, 70, text="vst~ 2 2 @prefer VST3 @autosave 0", varname="effect", numinlets=2, numoutlets=8,
        outlettype=["signal", "signal", "", "list", "int", "", "", ""])
    box("input", "newobj", 280, 70, text="click~")
    box("mute", "newobj", 10, 115, text="*~ 0.")
    box("output", "newobj", 10, 160, text="dac~")
    connect("runner", 0, "effect", 0)
    connect("runner", 1, "output", 0)
    for i in range(2, 8):
        connect("effect", i, "runner", i-1)
    for i in range(2):
        connect("input", 0, "effect", i)
    box("buffer", "newobj", 280, 115, text="buffer~ host-probe-impulse 400 2")
    box("record", "newobj", 280, 150, text="record~ host-probe-impulse 2")
    connect("runner", 2, "record", 0)
    connect("runner", 3, "input", 0)
    connect("input", 0, "record", 0)
    connect("effect", 0, "record", 1)
    connect("effect", 0, "mute", 0)
    connect("mute", 0, "output", 0)
    path.write_text(json.dumps({"patcher": {"fileversion": 1, "classnamespace": "box",
                                            "rect": [100, 100, 600, 250], "boxes": boxes, "lines": lines}}))


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("max_executable", type=Path)
    parser.add_argument("device", choices=PLUGINS)
    parser.add_argument("state", type=Path, help="Raw VST3 component state saved by v1.3")
    parser.add_argument("result", type=Path)
    parser.add_argument("--scan", action="store_true", help="Perform a documented partial Max plug-in rescan before Retry")
    parser.add_argument("--plugin-path", type=Path, help="Load a specific diagnostic plug-in instead of looking up the product")
    parser.add_argument("--precision", action="store_true", help="Exercise a diagnostic plug-in without importing the vendor state")
    parser.add_argument("--export-snapshot", type=Path, help="Copy the locally generated snapshot for inspection")
    args = parser.parse_args()
    result = args.result.resolve()
    plugin, cid = PLUGINS[args.device]
    with tempfile.TemporaryDirectory(dir=result.parent) as folder:
        tmp = Path(folder)
        preset = tmp / "legacy.vstpreset"
        state = args.state.read_bytes()
        write_preset(preset, cid, state)
        events = tmp / "events.jsonl"
        events.touch()
        patch = tmp / "Host probe.maxpat"
        snapshot = tmp / "positive.maxsnap"
        make_patch(patch, dict(plugin=plugin, scan=args.scan, path=str(args.plugin_path.resolve()) if args.plugin_path else "",
                               log=str(events), preset="" if args.precision else str(preset),
                               snapshot=str(snapshot)))
        proc = subprocess.Popen([str(args.max_executable), str(patch)])
        try:
            for _ in range(240):
                if events.exists() and '"end"' in events.read_text():
                    if args.export_snapshot:
                        args.export_snapshot.write_bytes(snapshot.read_bytes())
                    result.write_bytes(events.read_bytes())
                    return
                if proc.poll() is not None:
                    break
                time.sleep(0.5)
            raise RuntimeError("Max did not finish the probe")
        finally:
            if events.exists():
                result.write_bytes(events.read_bytes())
            if proc.poll() is None:
                proc.terminate()
                proc.wait(timeout=15)


if __name__ == "__main__":
    main()
