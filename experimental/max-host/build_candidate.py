"""Build an isolated Max-host candidate from a frozen release. Leave the release directory intact."""
import argparse
import json
from pathlib import Path
import plistlib
import re
import subprocess
import sys
import tempfile

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[1]
sys.path.insert(0, str(ROOT))
sys.path.insert(0, str(ROOT / "tests"))
import build
from package import directory

CLASS = "m4lwrappergainstage~"
BETA_VERSION = "1.4-b1"
PRODUCTS = {
    "spectre": ("Spectre", "56535453705472737065637472650000"),
    "oxford-inflator": ("Oxford Inflator", "5653544F494E546F78666F726420696E"),
}
MAX_ONLY = ("decapitator",)


def versioned_panel(panel, work):
    script, count = re.subn(r'"v\d+\.\d+(?:-[\w.]+)?"', f'"v{BETA_VERSION}"', panel.read_text())
    if count != 1:
        raise ValueError(f"Expected one visible version label in {panel.name}")
    path = work / panel.name
    path.write_text(script)
    return path


def native_product(device):
    name, cid = PRODUCTS[device.name]
    controls = (device / "Engine.mm").read_text().split(" controls = {{",1)[1].split("}};",1)[0]
    params = re.findall(r'\{\s*\d+\s*,\s*"([^"]+)"\s*\}', controls)
    product = dict(name=name, cid=cid, parameters=params)
    if device.name == "oxford-inflator":
        product["aliases"] = {"Bypass": ["Bypass", "Sonnox Bypass"]}
    return product


def audio_graph(patch, product):
    boxes, lines = patch["boxes"], patch["lines"]
    ids = {row["box"].get("varname"): row["box"]["id"] for row in boxes}
    boxes[:] = [r for r in boxes if r["box"]["id"] != ids["dsp"]]
    lines[:] = [r for r in lines if all(r["patchline"][key][0] != ids["dsp"] for key in ("source","destination"))]

    def box(name, maxclass, x, y, **args):
        boxes.append({"box": dict(id=name, varname=name, maxclass=maxclass, patching_rect=[x,y,195,22], **args)})
    def wire(a, i, b, j):
        lines.append({"patchline": {"source": [a,i], "destination": [b,j]}})
    box("maxPlugin", "newobj", 320, 1230, text="vst~ 2 2 @prefer VST3 @autosave 0", numinlets=2,numoutlets=8)
    box("driveRamp", "newobj", 65, 1150, text=CLASS+" drive", numinlets=2,numoutlets=3)
    box("wrapperOutput", "newobj", 210, 1280, text=CLASS, numinlets=4,numoutlets=3)
    box("maxHostControl", "v8.codebox", 500, 1230, numinlets=3, numoutlets=4,
        code="const product = "+json.dumps(product)+";\n"+(HERE/"adapter.js").read_text())
    for ch in range(2):
        wire(ids["in"],ch,"driveRamp",ch)
        wire("driveRamp",ch,"maxPlugin",ch)
        wire(ids["in"],ch,"wrapperOutput",ch)
        wire("maxPlugin",ch,"wrapperOutput",ch+2)
        wire("wrapperOutput",ch,ids["out"],ch)
    wire(ids["ctrl"],0,"maxHostControl",0)
    wire("maxHostControl",0,"maxPlugin",0)
    wire("maxHostControl",1,ids["ctrl"],0)
    wire("maxHostControl",2,"driveRamp",0)
    wire("maxHostControl",3,"wrapperOutput",0)
    wire("maxPlugin",2,"maxHostControl",1)
    wire("maxPlugin",3,"maxHostControl",2)
    wire("wrapperOutput",2,ids["ctrl"],0)
    if product.get("restoreFromPlugin"):
        box("audioStatus", "newobj", 90, 1190, text="dspstate~")
        box("latencyRefresh", "message", 90, 1218, text="refreshLatency")
        wire(ids["in"],0,"audioStatus",0)
        wire("audioStatus",1,"latencyRefresh",0)
        wire("latencyRefresh",0,"maxHostControl",0)
    patch["latency"] = 0
    return patch


def output_bundle(work):
    bundle = work / (CLASS+".mxo")
    exe = bundle/"Contents/MacOS"/CLASS
    exe.parent.mkdir(parents=True, exist_ok=True)
    info = dict(CFBundleExecutable=CLASS, CFBundleName=CLASS, CFBundlePackageType="iLaX",
                CFBundleIdentifier="org.m4lwrappers.output", CFBundleVersion="1", CFBundleShortVersionString="1")
    (bundle/"Contents/Info.plist").write_bytes(plistlib.dumps(info))
    subprocess.run(["clang++","-std=c++17","-O2","-arch","arm64","-arch","x86_64","-mmacosx-version-min=12.0",
                    "-bundle","-undefined","dynamic_lookup","-Wno-deprecated-declarations",
                    "-I"+str(build.headers/"max-includes"),"-I"+str(build.headers/"msp-includes"),
                    "-I"+str(ROOT/"shared"),str(HERE/"output.cpp"),"-o",str(exe)],check=True)
    subprocess.run(["codesign","--force","--sign","-",str(bundle)],check=True)
    return bundle


def make(device, source, output, windows):
    config = json.loads((device/"device.json").read_text())
    if source.name != config["name"] + ".amxd":
        raise ValueError("The supplied device does not match the selected product.")
    files = directory(source.read_bytes())
    patch = json.loads(files[source.name][1].rstrip(b"\0"))["patcher"]
    controller = next(row["box"] for row in patch["boxes"] if row["box"].get("varname") == "ctrl")
    controller["code"] = "\n".join((
        (device / "controller.js").read_text(),
        # v8.codebox intercepts "open" and opens its source editor.
        'pluginEditorMessage = "openPlugin";',
        (ROOT / "shared/missing-plugin.js").read_text(),
        (ROOT / "shared/meter-controls.js").read_text(),
    ))
    output.mkdir(parents=True, exist_ok=True)
    with tempfile.TemporaryDirectory() as tmp:
        work = Path(tmp)
        bundle = output_bundle(work)
        assets = {}
        for name,(kind,data) in files.items():
            if kind in (b"TEXT",b"PNG "):
                path = work/name
                path.write_bytes(data)
                assets[name] = path
        panel = "spectre-bands-v1.js" if device.name == "spectre" else "oxford-panel-v1.js"
        assets[panel] = versioned_panel(device / panel, work)
        assets["wrapper-warning-overlay.js"] = ROOT / "shared/warning-overlay.js"
        result = output/source.name
        build.freeze(bundle,audio_graph(patch,native_product(device)),result,assets,
                     build.windows_external(windows,CLASS) if windows else None)
        print(result)


def build_decapitator_patch(patch, config):
    # Reuse Oxford's surrounding Live controls and Spectre's hidden automation objects.
    removed = {"editorButton", "edit", "panelResource", "ctl7", "hostBypass",
               "input", "amount", "curve", "output", "effectIn", "split", "clip"}
    removed.update("ctl" + str(i) for i in range(7))
    boxes, lines = patch["boxes"], patch["lines"]
    boxes[:] = [row for row in boxes if row["box"]["varname"] not in removed]
    ids = {row["box"]["id"] for row in boxes}
    lines[:] = [row for row in lines if all(row["patchline"][port][0] in ids
                                           for port in ("source", "destination"))]
    by_name = {row["box"]["varname"]: row["box"] for row in boxes}
    panel = by_name["face"]
    original_width = panel["presentation_rect"][2]
    width = 506
    delta = width - original_width
    panel.update(maxclass="v8ui", filename="decapitator-panel.js", numoutlets=1, outlettype=[""])
    panel["presentation_rect"][2] = panel["patching_rect"][2] = width
    panel.pop("jsarguments", None)
    panel.pop("ignoreclick", None)
    patch["devicewidth"] += delta
    for key in ("rect", "openrect"):
        patch[key][2] += delta
    patch.update(description="Soundtoys Decapitator VST3 stereo wrapper",
                 digest=config["name"], tags="VST3 Soundtoys Decapitator", dependency_cache=[])
    for name in ("postOutput", "outputMeter", "match0", "match1", "match2"):
        by_name[name]["presentation_rect"][0] += delta
    by_name["alert"]["text"] = 'dialog "Decapitator · VST3" @mode 1'
    params = patch["parameters"]
    for name in list(params):
        if name not in ids and name not in ("parameterbanks", "inherited_shortname"):
            del params[name]
    for obj, long_name, short_name in (("preDrive", "Pre Gain", "Pre Gain"),
                                       ("postOutput", "Post Gain", "Post Gain"),
                                       ("bankState", "Decapitator state", "Decapitator state")):
        box = by_name[obj]
        for key in ("hint", "annotation"):
            if key in box:
                box[key] = box[key].replace("Oxford", config["plugin"])
        attrs = box["saved_attribute_attributes"]["valueof"]
        attrs.update(parameter_longname=long_name, parameter_shortname=short_name)
        params[box["id"]] = [long_name, short_name, 0]
    controls = config["parameters"]
    template = json.loads((ROOT/"devices/spectre/device.maxpat").read_text())["patcher"]
    templates = {row["box"]["varname"]: row["box"] for row in template["boxes"]}
    controller = by_name["ctrl"]
    lines.append({"patchline": {"source": [panel["id"], 0], "destination": [controller["id"], 0]}})
    for index, param in enumerate(controls):
        is_enum = "choices" in param
        box = templates["param3" if is_enum else "param0"].copy()
        name = param["name"]
        box.update(id=f"decap-param{index}", varname=f"param{index}",
                   patching_rect=[20+190*(index//6), 510+36*(index%6), 100, 18])
        value = dict(parameter_longname=name, parameter_shortname=name, parameter_mmin=param["low"],
                     parameter_mmax=param["high"], parameter_initial_enable=1,
                     parameter_initial=[param["initial"]], parameter_type=2 if is_enum else 0,
                     parameter_modmode=0, parameter_unitstyle=param.get("unit", 0))
        if is_enum:
            box["items"] = param["choices"]
            value["parameter_enum"] = param["choices"]
        box["saved_attribute_attributes"] = {"valueof": value}
        prepend = dict(id=box["id"]+"ctl", varname=box["varname"]+"ctl",
                       maxclass="newobj", text=f"prepend control {index}",
                       patching_rect=[125+190*(index//6), 510+36*(index%6), 80, 18])
        boxes.extend({"box": b} for b in (box, prepend))
        params[box["id"]] = [name, name, 0]
        for src, dst in ((box, prepend), (prepend, controller)):
            lines.append({"patchline": {"source": [src["id"], 0], "destination": [dst["id"], 0]}})
    for i in range(2):
        params["parameterbanks"][str(i)] = dict(index=i, name=config["plugin"] if not i else "Trim and filters",
                                                parameters=([p["name"] for p in controls][i*8:i*8+8]+["-"]*8)[:8],
                                                buttons=["-"]*8)
    return controller


def make_max_device(device, output, windows):
    config = json.loads((device/"device.json").read_text())
    patch = json.loads((ROOT/"devices/oxford-inflator/device.maxpat").read_text())["patcher"]
    controller = build_decapitator_patch(patch, config)
    controller["code"] = "const parameters = " + json.dumps(config["parameters"]) + ";\n" + "\n".join(
        path.read_text() for path in (device/"controller.js", ROOT/"shared/missing-plugin.js", ROOT/"shared/meter-controls.js"))
    assets = config["resources"]
    build.add_warning_overlay(patch, assets, controller)
    product = dict(name=config["plugin"], cid=config["cid"], parameters=[p["vst"] for p in config["parameters"]],
                   restoreFromPlugin=True, restoreProbe=6, autoGain=dict(drive=1, punish=2, enabled=7, trim=10))
    output.mkdir(parents=True, exist_ok=True)
    result = output / (config["name"] + ".amxd")
    with tempfile.TemporaryDirectory() as tmp:
        work = Path(tmp)
        panel = "decapitator-panel.js"
        assets[panel] = versioned_panel(device / panel, work)
        bundle = output_bundle(work)
        binary = build.windows_external(windows, CLASS) if windows else None
        build.freeze(bundle, audio_graph(patch, product), result, assets, binary)
    print(result)


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("device",choices=(*PRODUCTS, *MAX_ONLY))
    parser.add_argument("released_device",type=Path,nargs="?")
    parser.add_argument("output_directory",type=Path)
    parser.add_argument("--windows-externals",type=Path)
    args = parser.parse_args()
    device = ROOT/"devices"/args.device
    if args.device in MAX_ONLY:
        if args.released_device is not None:
            parser.error("This device is built from source and needs no released file.")
        make_max_device(device, args.output_directory, args.windows_externals)
        sys.exit(0)
    if args.released_device is None:
        parser.error("Provide the released device.")
    if args.released_device.resolve().parent == args.output_directory.resolve():
        parser.error("Use a separate directory for the candidate.")
    make(device,args.released_device,args.output_directory,args.windows_externals)
