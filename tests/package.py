"""Verify both frozen devices against their built Windows and macOS externals."""
import argparse
import io
import json
from pathlib import Path
import struct
import zipfile

ROOT = Path(__file__).resolve().parents[1]


def chunks(data):
    offset = 0
    while offset < len(data):
        tag, length = struct.unpack_from(">4sI", data, offset)
        assert 8 <= length <= len(data) - offset, "Invalid Max chunk length"
        yield tag, data[offset + 8:offset + length]
        offset += length


def directory(data):
    assert data[:4] == b"ampf" and data[24:28] == b"ptch"
    archive = data[32:]
    assert struct.unpack_from("<I", data, 28)[0] == len(archive)
    magic, header_size, _, index = struct.unpack_from(">4sIII", archive)
    assert magic == b"mx@c" and header_size == 16 and index < len(archive)
    [(tag, listing)] = chunks(archive[index:])
    assert tag == b"dlst"
    entries = {}
    for tag, entry in chunks(listing):
        assert tag == b"dire"
        fields = dict(chunks(entry))
        name = fields[b"fnam"].rstrip(b"\0").decode("utf-8")
        offset = int.from_bytes(fields[b"of32"], "big")
        size = int.from_bytes(fields[b"sz32"], "big")
        assert name not in entries and header_size <= offset <= offset + size <= index
        entries[name] = (fields[b"type"], archive[offset:offset+size])
    return entries


def check_device(device, windows_dir):
    config = json.loads((device / "device.json").read_text())
    name = config["external"]
    filename = config["name"] + ".amxd"
    files = directory((ROOT / "dist" / filename).read_bytes())
    assert files[name + ".mxe64"] == (b"mx64", (windows_dir / (name + ".mxe64")).read_bytes())
    assert files[name + ".mxo"] == (b"iLaX", bytes(4))
    mac_name = name + ".mxo/Contents/MacOS/" + name
    mac = (ROOT / "build" / device.name / mac_name).read_bytes()
    assert files[name + "/executable"][1] == mac
    # CPU types in the universal Mach-O header (x86_64 and arm64).
    magic, arch_count = struct.unpack_from(">II", mac)
    assert magic == 0xcafebabe
    assert {struct.unpack_from(">I", mac, 8 + 20*i)[0] for i in range(arch_count)} == {0x01000007, 0x0100000c}
    with zipfile.ZipFile(io.BytesIO(files[name + "/zipfile"][1])) as bundle:
        assert bundle.read(mac_name) == mac
        assert bundle.read(name + ".mxo/Contents/Info.plist") == files[name + "/plist"][1]
    kind, data = files[filename]
    assert kind == b"JSON"
    patch = json.loads(data.rstrip(b"\0"))["patcher"]
    boxes = {entry["box"].get("varname"): entry["box"] for entry in patch["boxes"]}
    assert boxes["dsp"]["text"] == name
    assert boxes["bankState"]["restore"] == ["none"]
    print(f"{filename}: verified Mac universal and Windows x64 external payloads")


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--windows-externals", type=Path, required=True)
    args = parser.parse_args()
    for device in sorted((ROOT / "devices").iterdir()):
        check_device(device, args.windows_externals)
