"""Check the actual frozen candidate, including the Windows payload and released Live parameter definitions."""
import argparse
import io
import json
from pathlib import Path
import struct
import sys
import zipfile

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))
from package import directory


def patch_and_files(path):
    files = directory(path.read_bytes())
    return json.loads(files[path.name][1].rstrip(b"\0"))["patcher"], files


def parameters(patch):
    return {entry["box"]["id"]: entry["box"] for entry in patch["boxes"]
            if "valueof" in entry["box"].get("saved_attribute_attributes", {})}


def verify(release, candidate, windows):
    before, _ = patch_and_files(release)
    after, files = patch_and_files(candidate)
    assert parameters(after) == parameters(before), "Live parameter IDs or saved defaults changed"
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
    for arg in ("release_dir","candidate_dir","windows_dir"):
        parser.add_argument(arg, type=Path)
    args = parser.parse_args()
    for name in ("Oxford Inflator Wrapper.amxd","Spectre Wrapper.amxd"):
        verify(args.release_dir/name,args.candidate_dir/name,args.windows_dir)
