"""Build a local Live device that passes stereo audio through the Decapitator latency probe."""
import argparse
import io
import json
from pathlib import Path
import sys
import zipfile

sys.path.insert(0, str(Path(__file__).resolve().parents[3]))
from build import freeze


def resources(bundle):
    name = bundle.stem
    packed = io.BytesIO()
    with zipfile.ZipFile(packed, "w", zipfile.ZIP_DEFLATED) as archive:
        for entry in sorted(bundle.rglob("*")):
            archive.write(entry, entry.relative_to(bundle.parent))
    contents = bundle / "Contents"
    return [
        (bundle.name, b"iLaX", bytes(4)),
        (name + "/zipfile", bytes(4), packed.getvalue()),
        (name + "/executable", bytes(4), (contents / "MacOS" / name).read_bytes()),
        (name + "/plist", bytes(4), (contents / "Info.plist").read_bytes()),
    ]


def export_device(bundle, plugin, mode, output):
    if not plugin.is_dir() or bundle.name != "m4ldecaplatency~.mxo":
        raise ValueError("Select the installed Decapitator VST3 and the compiled test external.")
    script = """
let started = false;
const poll = new Task(function () { outlet(0, "getlatency"); }, this);
function bang() {
    if (started) return;
    started = true;
    poll.interval = 80;
    poll.repeat(-1);
}
function latency(n) {
    if (n <= 0) return;
    this.patcher.setattr("latency", n);
    if (holdStartupValue) poll.cancel();
}
function notifydeleted() { poll.cancel(); }
"""
    boxes = {
        "input": "plugin~", "processor": bundle.stem + " " + json.dumps(str(plugin.resolve())),
        "output": "plugout~", "init": "live.thisdevice", "prefix": "prepend latency",
        "control": {"maxclass": "v8.codebox", "code": "const holdStartupValue = " +
                    json.dumps(mode == "startup") + ";\n" + script, "numinlets": 1, "numoutlets": 1},
    }
    edges = [("input", 0, "processor", 0), ("input", 1, "processor", 1),
             ("processor", 0, "output", 0), ("processor", 1, "output", 1),
             ("init", 0, "control", 0), ("processor", 2, "prefix", 0),
             ("prefix", 0, "control", 0), ("control", 0, "processor", 0)]
    patch = {"fileversion": 1, "rect": [0, 0, 660, 220], "boxes": [], "lines": []}
    for i, (key, desc) in enumerate(boxes.items()):
        attrs = {"maxclass": "newobj", "text": desc} if isinstance(desc, str) else desc
        patch["boxes"].append({"box": {"id": key, "patching_rect": [15 + i % 3 * 175, 20 + i // 3 * 50, 160, 22], **attrs}})
    for src, n, dst, k in edges:
        patch["lines"].append({"patchline": {"source": [src, n], "destination": [dst, k]}})
    freeze(patch, output, resources(bundle))


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("external", type=Path)
    parser.add_argument("plugin", type=Path)
    parser.add_argument("report", choices=("startup", "follow"))
    parser.add_argument("output", type=Path)
    args = parser.parse_args()
    export_device(args.external, args.plugin, args.report, args.output)
