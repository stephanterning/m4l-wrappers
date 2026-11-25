"""Package the portable Max patches and scripts into standalone Live devices."""
import argparse
import json
from pathlib import Path
import re
import struct
import tempfile
import time

from host.portable_audio import install_audio

ROOT = Path(__file__).resolve().parent
WRAPPER_VERSION = "1.4"
AMXD_HEADER = bytes.fromhex("616d706604000000616161616d657461040000000700000070746368")


def integer(value):
    return struct.pack(">I", value)


def record(tag, data):
    return tag + integer(len(data) + 8) + data


def freeze(patch, path, resources):
    patch_json = json.dumps({"patcher": patch}, ensure_ascii=False, indent=2)
    entries = [(path.name, b"JSON", (patch_json + "\n\0").encode("utf-8")), *resources]
    data = bytearray()
    index = bytearray()
    timestamp = int(time.time()) + 2082844800  # Max archive dates count from 1904.
    for i, (name, kind, content) in enumerate(entries):
        offset = 16 + len(data)
        data.extend(content)
        filename = name.encode("utf-8") + b"\0"
        filename += b"\0" * (-len(filename) % 4)
        fields = [(b"sz32", len(content)), (b"of32", offset), (b"vers", 0),
                  (b"flag", 17 if i == 0 else 0), (b"mdat", timestamp)]
        metadata = b"".join(record(key, integer(value)) for key, value in fields)
        index.extend(record(b"dire", record(b"type", kind) + record(b"fnam", filename) + metadata))
    archive = b"mx@c" + integer(16) + integer(0) + integer(len(data) + 16) + data + record(b"dlst", index)
    with tempfile.TemporaryDirectory(dir=path.parent) as work:
        tmp = Path(work) / path.name
        tmp.write_bytes(AMXD_HEADER + struct.pack("<I", len(archive)) + archive)
        tmp.replace(path)


def resources_for(config):
    for name, source in config["resources"].items():
        path = ROOT / source
        if name.endswith(".png"):
            yield name, b"PNG ", path.read_bytes()
            continue
        text = path.read_text(encoding="utf-8")
        if name == config["panel"]:
            text, count = re.subn(r'"v\d+\.\d+(?:-[\w.]+)?"', f'"v{WRAPPER_VERSION}"', text)
            if count != 1:
                raise ValueError(f"Expected one visible version label in {name}")
        yield name, b"TEXT", text.encode("utf-8")


def build_device(device, output):
    config = json.loads((device / "device.json").read_text(encoding="utf-8"))
    patch = json.loads((device / "device.maxpat").read_text(encoding="utf-8"))["patcher"]
    boxes = {row["box"].get("varname"): row["box"] for row in patch["boxes"]}
    product = config["product"]
    controller = (device / "controller.js").read_text(encoding="utf-8")
    definitions = device / "parameters.json"
    if definitions.exists():
        parameters = json.loads(definitions.read_text(encoding="utf-8"))
        product["parameters"] = [p["vst"] for p in parameters]
        controller = "const parameters = " + json.dumps(parameters) + ";\n" + controller
    else:
        controller += '\npluginEditorMessage = "openPlugin";'
    boxes["ctrl"]["code"] = "\n".join((controller, (ROOT / "shared/missing-plugin.js").read_text(encoding="utf-8"),
                                      (ROOT / "shared/meter-controls.js").read_text(encoding="utf-8")))
    boxes["maxHostControl"]["code"] = ("const product = " + json.dumps(product) + ";\n"
                                        + (ROOT / "host/adapter.js").read_text(encoding="utf-8"))
    path = output / (config["name"] + ".amxd")
    install_audio(patch)
    freeze(patch, path, resources_for(config))
    print(path)


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("devices", nargs="*", help="Device directory names (default: all)")
    parser.add_argument("--output", type=Path, default=ROOT / "dist")
    args = parser.parse_args()
    devices = {p.parent.name: p.parent for p in sorted((ROOT / "devices").glob("*/device.json"))}
    selected = args.devices or list(devices)
    if set(selected) - devices.keys():
        parser.error("Available devices: " + ", ".join(devices))
    args.output.mkdir(parents=True, exist_ok=True)
    for name in selected:
        build_device(devices[name], args.output)
