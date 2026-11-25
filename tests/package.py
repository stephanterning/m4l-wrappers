"""Verify frozen Max-host devices and their portable embedded DSP."""
import argparse
from copy import deepcopy
import hashlib
import json
from pathlib import Path
import struct

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


def check_embedded_graph(patch):
    boxes = {row["box"]["id"]: row["box"] for row in patch["boxes"]}
    assert len(boxes) == len(patch["boxes"])
    for row in patch["lines"]:
        edge = row["patchline"]
        for side, ports in (("source", "numoutlets"), ("destination", "numinlets")):
            name, port = edge[side]
            box = boxes[name]
            assert port >= 0 and (ports not in box or port < box[ports]), (side, name, port)
    for box in boxes.values():
        if box.get("text") == "gen~":
            assert box["patcher"]["classnamespace"] == "dsp.gen"
            assert any(child["box"].get("code") for child in box["patcher"]["boxes"])
        if "patcher" in box:
            check_embedded_graph(box["patcher"])


def verify(candidate, expected):
    files = directory(candidate.read_bytes())
    after = json.loads(files[candidate.name][1].rstrip(b"\0"))["patcher"]
    # Check v2 additions first, then verify the remaining control contract against
    # the independently captured v1.4 fixtures.
    is_native = "m4ldecapitator~.mxo" in files
    prior = deepcopy(after)
    product = candidate.name.split(" Wrapper V2.")[0]
    old_product_name = "Oxford" if product == "Oxford Inflator" else product
    old_hints = {
        "preDrive": f"Gain before {old_product_name}",
        "postOutput": f"Gain after {old_product_name}",
        "driveLink": "Offset Drive changes with the opposite change to Output.",
        "input": "Input Gain", "amount": "Effect", "curve": "Curve", "output": "Output Gain",
        "effectIn": "Effect In", "split": "Band Split", "clip": "Clip 0 dB",
    }
    presentation_shifts = {
        "preDrive": 20, "postOutput": 60,
        "input": 40, "amount": 40, "curve": 40, "output": 40,
        "effectIn": 40, "split": 40, "clip": 40,
    }
    for row in list(prior["boxes"]):
        box = row["box"]
        name = box.get("varname")
        # Info View metadata is separate from the historical parameter identity.
        box.pop("annotation", None)
        box.pop("annotation_name", None)
        if name in old_hints:
            box["hint"] = old_hints[name]
        if name in presentation_shifts and "presentation_rect" in box:
            box["presentation_rect"][0] -= presentation_shifts[name]
        decap_dial = "Decapitator" in candidate.name and name in ("param1", "param3", "param4", "param5", "param6", "param10")
        spectre_dial = ("Spectre" in candidate.name and name and name.startswith("param") and
                        name[5:].isdigit() and int(name[5:]) <= 32 and int(name[5:]) % 6 < 3)
        if decap_dial or spectre_dial:
            assert next(i for i, r in enumerate(after["boxes"]) if r["box"]["id"] == box["id"]) < next(
                i for i, r in enumerate(after["boxes"]) if r["box"].get("varname") == "face"
            )
            # Restore the original box ordering before comparing the historical signature.
            prior["boxes"].remove(row)
            destination = next(edge["patchline"]["destination"][0] for edge in prior["lines"]
                               if edge["patchline"]["source"] == [box["id"], 0])
            at = next(i for i, r in enumerate(prior["boxes"]) if r["box"]["id"] == destination)
            prior["boxes"].insert(at, row)
            if spectre_dial:
                assert box.pop("hidden") == 1
            # Transparent dials above the painted face expose the existing parameters in Live's Map Mode.
            assert box["maxclass"] == "live.dial" and box["parameter_enable"] == 1
            assert box.pop("showname") == box.pop("shownumber") == 0
            box["maxclass"] = "live.numbox"
            assert box.pop("presentation") == 1
            assert box.pop("jspainterfile") in files
            x, y, width, height = box.pop("presentation_rect")
            assert 163 <= x < x + width <= (773 if spectre_dial else 669) and 0 <= y < y + height <= 169
        if name == "trimOrigin":
            source = box["saved_attribute_attributes"]["valueof"]
            assert source["parameter_type"] == 0 and source["parameter_invisible"] == 3 and not source["parameter_visible_undoable"]
            prior["boxes"].remove(row)
            del prior["parameters"][box["id"]]
        if name == "maxLookup" or (name == "maxPlugin" and not is_native):
            private = box["saved_attribute_attributes"].pop("valueof")
            assert private["parameter_type"] == 3 and private["parameter_invisible"] == 2
        if name == "driveLink":
            new_label = "Compensate output"
            attr = box["saved_attribute_attributes"]["valueof"]
            assert attr["parameter_longname"] == "Drive Link"
            assert box["text"] == box["texton"] == ""
            assert attr["parameter_shortname"] == new_label
            assert prior["parameters"][box["id"]][:2] == ["Drive Link", new_label]
            # Only these known panel and parameter changes differ from the v1.4 fixture.
            attr.update(parameter_longname="Drive Link", parameter_shortname="Link")
            box.update(text="Link", texton="Link", fontsize=10.0, presentation_rect=[71.0,126.0,40.0,14.0])
            prior["parameters"][box["id"]][:2] = ["Drive Link", "Link"]
        if "Oxford" in candidate.name and name in ("effectIn", "split", "clip"):
            assert box["maxclass"] == "live.toggle" and box["outlettype"] == ["int"]
            box.update(maxclass="live.text", numoutlets=2, outlettype=["", ""], text=box["hint"], texton=box["hint"])
        if name == "driveLink" or ("Oxford" in candidate.name and name in ("effectIn","split","clip")):
            attr = box["saved_attribute_attributes"]["valueof"]
            assert attr["parameter_enum"] == ["Off", "On"]
            attr["parameter_enum"] = ["val1", "val2"]
    if "Decapitator" in candidate.name:
        assert "trimOrigin" in after["parameters"]
    assert compatibility_signature(prior) == expected, "Unexpected change to the Live parameter contract"
    boxes = {r["box"]["id"]: r["box"] for r in after["boxes"]}
    names = {b.get("varname"): b["id"] for b in boxes.values()}
    assert not any(box.get("hint") for box in boxes.values())
    for box in boxes.values():
        if box.get("presentation") and not box.get("ignoreclick"):
            assert box.get("annotation_name") and box.get("annotation"), box["id"]
    help_titles = {
        "preDrive": "Pre Gain", "postOutput": "Post Gain", "driveLink": "Compensate output",
        "compensateOutputLabel": "Compensate output", "compensationReadout": "Output compensation",
        "compensationLabel": "Output compensation", "inputMeter": "Input meter", "outputMeter": "Output meter",
    }
    for name, title in help_titles.items():
        control = boxes[names[name]]
        assert control["annotation_name"] == title and control["annotation"], name
    edges = {(tuple(l["patchline"]["source"]),tuple(l["patchline"]["destination"])) for l in after["lines"]}
    assert all(a in boxes and b in boxes for (a,_),(b,_) in edges)
    assert boxes["audioStatus"]["text"] == "dspstate~"
    assert boxes["latencyRefresh"]["text"] == "refreshLatency"
    assert {
        ((names["in"], 0), ("audioStatus", 0)),
        (("audioStatus", 1), ("latencyRefresh", 0)),
        (("latencyRefresh", 0), ("maxHostControl", 0)),
    } <= edges
    pre_rect = boxes[names["preDrive"]]["presentation_rect"]
    post_rect = boxes[names["postOutput"]]["presentation_rect"]
    toggle = boxes[names["driveLink"]]
    left_title = boxes[names["compensateOutputLabel"]]
    right_title = boxes[names["compensationLabel"]]
    value = boxes[names["compensationReadout"]]
    for control, title, dial in ((toggle, left_title, pre_rect), (value, right_title, post_rect)):
        x, y, width, height = control["presentation_rect"]
        tx, ty, tw, th = title["presentation_rect"]
        assert x + width / 2 == tx + tw / 2 == dial[0] + dial[2] / 2
        assert dial[1] + dial[3] <= y < y + height <= ty
        assert 6 <= after["openrect"][3] - (ty + th) <= 12
        assert control["annotation"] == title["annotation"]
    assert left_title["presentation_rect"][1] == right_title["presentation_rect"][1]
    assert left_title["jsarguments"] == ["Compensate output"]
    assert right_title["jsarguments"] == ["Output compensation"]
    assert value["jsarguments"] == ["0.0 dB"] and "parameter_enable" not in value
    lookup = boxes["maxLookup" if is_native else "maxPlugin"]
    assert lookup["text"].startswith("vst~ 2 2 @prefer VST3") and "@parameter_enable 1" in lookup["text"]
    if is_native:
        assert "Decapitator" in candidate.name and boxes["maxPlugin"]["text"] == "m4ldecapitator~"
        assert (("maxPlugin",2),("maxHostControl",1)) in edges
        assert not any("maxLookup" in (a[0],b[0]) for a,b in edges)
        from io import BytesIO
        import zipfile
        with zipfile.ZipFile(BytesIO(files["m4ldecapitator~/zipfile"][1])) as bundle:
            body = bundle.read("m4ldecapitator~.mxo/Contents/MacOS/m4ldecapitator~")
            assert body[:4] == bytes.fromhex("cafebabe") and body == files["m4ldecapitator~/executable"][1]
            assert "m4ldecapitator~.mxo/Contents/Resources/Steinberg License.txt" in bundle.namelist()
    assert boxes[names["bankState"]]["restore"] == ["none"]
    for stage in ("driveRamp", "wrapperOutput"):
        check_embedded_graph(boxes[stage]["patcher"])
    assert (("maxHostControl", 2), ("driveRamp", 2)) in edges
    assert (("maxHostControl", 3), ("wrapperOutput", 4)) in edges
    assert (("wrapperOutput", 2), (names["ctrl"], 0)) in edges
    for ch in (0,1):
        for edge in [((names["in"],ch),("wrapperOutput",ch)), ((names["in"],ch),("driveRamp",ch)),
                     (("driveRamp",ch),("maxPlugin",ch)), (("maxPlugin",ch),("wrapperOutput",ch+2)),
                     (("wrapperOutput",ch),(names["out"],ch))]:
            assert edge in edges, edge
    allowed = {b"JSON", b"TEXT", b"PNG "}
    if is_native: allowed.update([b"iLaX", bytes(4)])
    assert {kind for kind, _ in files.values()} <= allowed
    assert b"m4lwrappergainstage~" not in files[candidate.name][1]
    for b in boxes.values():
        if b.get("maxclass") in ("jsui","v8ui"): assert b["filename"] in files
        if b.get("jspainterfile"): assert b["jspainterfile"] in files
    print(candidate.name, "verified parameter identities, signal routing, resources and embedded audio stages")


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("devices", type=Path)
    args = parser.parse_args()
    signatures = json.loads(Path(__file__).with_name("v1.4-parameters.json").read_text())
    for name, signature in signatures.items():
        verify(args.devices / name.replace(" Wrapper.", " Wrapper V2."), signature)
