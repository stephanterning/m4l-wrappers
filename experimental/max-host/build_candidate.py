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

CLASS = "m4lwrapperoutput~"
PRODUCTS = {
    "spectre": ("Spectre", -142919238, "56535453705472737065637472650000"),
    "oxford-inflator": ("Oxford Inflator", 714868650, "5653544F494E546F78666F726420696E"),
}


def audio_graph(patch, device):
    name, uid, cid = PRODUCTS[device.name]
    controls = (device / "Engine.mm").read_text().split(" controls = {{",1)[1].split("}};",1)[0]
    params = re.findall(r'\{\s*\d+\s*,\s*"([^"]+)"\s*\}', controls)
    if device.name == "oxford-inflator":
        params[-1] = "Sonnox Bypass"
    product = dict(name=name, id=uid, cid=cid, parameters=params)
    boxes, lines = patch["boxes"], patch["lines"]
    ids = {row["box"].get("varname"): row["box"]["id"] for row in boxes}
    boxes[:] = [r for r in boxes if r["box"]["id"] != ids["dsp"]]
    lines[:] = [r for r in lines if all(r["patchline"][key][0] != ids["dsp"] for key in ("source","destination"))]

    def box(name, maxclass, x, y, **args):
        boxes.append({"box": dict(id=name, varname=name, maxclass=maxclass, patching_rect=[x,y,195,22], **args)})
    def wire(a, i, b, j):
        lines.append({"patchline": {"source": [a,i], "destination": [b,j]}})
    box("maxPlugin", "newobj", 320, 1230, text="vst~ 2 2 @prefer VST3 @autosave 0", numinlets=2,numoutlets=8)
    box("driveRamp", "newobj", 65, 1150, text="line~ 1.")
    box("wrapperOutput", "newobj", 210, 1280, text=CLASS, numinlets=4,numoutlets=3)
    box("maxHostControl", "v8.codebox", 500, 1230, numinlets=3, numoutlets=4,
        code="const product = "+json.dumps(product)+";\n"+(HERE/"adapter.js").read_text())
    for ch in range(2):
        gain = "driveMultiply"+str(ch)
        box(gain, "newobj", 65+110*ch, 1190, text="*~ 1.")
        wire(ids["in"],ch,gain,0)
        wire("driveRamp",0,gain,1)
        wire(gain,0,"maxPlugin",ch)
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
    files = directory(source.read_bytes())
    patch = json.loads(files[source.name][1].rstrip(b"\0"))["patcher"]
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
        result = output/source.name
        build.freeze(bundle,audio_graph(patch,device),result,assets,
                     build.windows_external(windows,CLASS) if windows else None)
        print(result)


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("device",choices=PRODUCTS)
    parser.add_argument("released_device",type=Path)
    parser.add_argument("output_directory",type=Path)
    parser.add_argument("--windows-externals",type=Path)
    args = parser.parse_args()
    if args.released_device.resolve().parent == args.output_directory.resolve():
        parser.error("Use a separate directory for the candidate.")
    make(ROOT/"devices"/args.device,args.released_device,args.output_directory,args.windows_externals)
