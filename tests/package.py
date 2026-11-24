"""Verify frozen Max-host devices against their built Windows and macOS externals."""
import argparse
import hashlib
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


def compatibility_signature(patch):
    # Captured from the public v1.4 devices. Covers automation identities,
    # parameter metadata, initial values, preset storage and Live parameter banks.
    parameters = [row["box"] for row in patch["boxes"]
                  if "valueof" in row["box"].get("saved_attribute_attributes", {})]
    data = json.dumps([patch["parameters"], parameters], sort_keys=True).encode()
    return hashlib.sha256(data).hexdigest()


def verify(candidate, windows, expected):
    files = directory(candidate.read_bytes())
    after = json.loads(files[candidate.name][1].rstrip(b"\0"))["patcher"]
    assert compatibility_signature(after) == expected, "v1.4 parameter contract changed"
    boxes = {r["box"]["id"]: r["box"] for r in after["boxes"]}
    names = {b.get("varname"): b["id"] for b in boxes.values()}
    edges = {(tuple(l["patchline"]["source"]),tuple(l["patchline"]["destination"])) for l in after["lines"]}
    assert all(a in boxes and b in boxes for (a,_),(b,_) in edges)
    assert boxes["maxPlugin"]["text"].startswith("vst~ 2 2 @prefer VST3")
    assert boxes[names["bankState"]]["restore"] == ["none"]
    assert boxes["wrapperOutput"]["text"] == "m4lwrappergainstage~"
    assert boxes["driveRamp"]["text"] == "m4lwrappergainstage~ drive"
    for ch in (0,1):
        for edge in [((names["in"],ch),("wrapperOutput",ch)), ((names["in"],ch),("driveRamp",ch)),
                     (("driveRamp",ch),("maxPlugin",ch)), (("maxPlugin",ch),("wrapperOutput",ch+2)),
                     (("wrapperOutput",ch),(names["out"],ch))]:
            assert edge in edges, edge
    classname = "m4lwrappergainstage~"
    assert files[classname+".mxe64"] == (b"mx64",(windows/(classname+".mxe64")).read_bytes())
    image = files[classname+"/executable"][1]
    assert struct.unpack_from(">II",image) == (0xcafebabe,2)
    assert {struct.unpack_from(">I",image,i)[0] for i in [8,28]} == {0x01000007,0x0100000c}
    with zipfile.ZipFile(io.BytesIO(files[classname+"/zipfile"][1])) as archive:
        assert archive.read(classname+".mxo/Contents/MacOS/"+classname) == image
    assert not any("spectrewrapper2~" in n or "oxfordinflatorpeak2~" in n for n in files)
    for b in boxes.values():
        if b.get("maxclass") in ("jsui","v8ui"): assert b["filename"] in files
        if b.get("jspainterfile"): assert b["jspainterfile"] in files
    print(candidate.name, "verified parameter identities, signal routing, resources and both platform payloads")


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("devices", type=Path)
    parser.add_argument("windows", type=Path)
    args = parser.parse_args()
    signatures = json.loads(Path(__file__).with_name("v1.4-parameters.json").read_text())
    for name, signature in signatures.items():
        verify(args.devices / name, args.windows, signature)
