"""Build the shared macOS host sources and freeze each Max for Live device."""
import concurrent.futures
import io
import json
import os
from pathlib import Path
import shutil
import struct
import subprocess
import sys
import time
import zipfile

ROOT = Path(__file__).resolve().parent
BUILD = ROOT / "build"
sdk = Path(os.environ.get("VST3_SDK", ROOT / "deps/vst3sdk")).resolve()
headers = Path(os.environ.get("MAX_SDK_BASE", ROOT / "deps/max-sdk-base")).resolve() / "c74support"
AMXD_HEADER = bytes.fromhex("616d706604000000616161616d657461040000000700000070746368")

sdk_sources = [
    'pluginterfaces/base/coreiids.cpp', 'pluginterfaces/base/funknown.cpp',
    'pluginterfaces/base/ustring.cpp', 'public.sdk/source/common/commoniids.cpp',
    'public.sdk/source/common/commonstringconvert.cpp','public.sdk/source/common/memorystream.cpp',
    'public.sdk/source/common/threadchecker_mac.mm', 'public.sdk/source/vst/vstinitiids.cpp',
    'public.sdk/source/vst/utility/stringconvert.cpp'
]
sdk_sources += ['public.sdk/source/vst/hosting/' + s for s in ['module.cpp', 'module_mac.mm',
    'plugprovider.cpp', 'hostclasses.cpp', 'pluginterfacesupport.cpp', 'parameterchanges.cpp',
    'connectionproxy.cpp']]

def compile_external(device, name, arch):
    out = BUILD / device.name / arch
    out.mkdir(parents=True, exist_ok=True)
    flags = ['clang++', '-std=c++17', '-O2', '-fvisibility=hidden', '-DNDEBUG', '-DRELEASE=1',
             '-arch', arch, '-mmacosx-version-min=12.0', '-Wno-deprecated-declarations',
             '-I' + str(ROOT / 'shared'), '-I' + str(sdk), '-I' + str(headers / 'max-includes'), '-I' + str(headers / 'msp-includes')]
    def compile_source(src):
        obj = out / (src.stem + '.o')
        deps = [src]
        if src.parent == device:
            deps += [device / 'Engine.mm', device / 'Discovery.h', *sorted((ROOT / 'shared').glob('*.h'))]
        if not obj.exists() or any(f.stat().st_mtime > obj.stat().st_mtime for f in deps):
            subprocess.run(flags + (['-fobjc-arc'] if src.suffix == '.mm' else []) +
                           ['-c', str(src), '-o', str(obj)], check=True)
        return str(obj)
    with concurrent.futures.ThreadPoolExecutor(6) as pool:
        objects = list(pool.map(compile_source, [sdk / s for s in sdk_sources] + [device / 'external.mm']))
    result = out / name
    subprocess.run(flags + objects + ['-framework', 'AppKit', '-framework', 'CoreFoundation', '-framework',
            'Foundation', '-framework', 'CoreServices'] +
            ['-bundle','-undefined','dynamic_lookup'] + ['-o',str(result)],check=True)
    return result

def be(number):
    return struct.pack(">I",number)
def record(tag, data):
    return tag+be(len(data)+8)+data

def freeze(bundle, patch, path, assets):
    EXTERNAL = bundle.stem
    contents=bundle/"Contents"
    zipdata=io.BytesIO()
    with zipfile.ZipFile(zipdata,"w",compression=zipfile.ZIP_DEFLATED) as archive:
        for f in [bundle,*sorted(bundle.rglob("*"))]:
            archive.write(f,f.relative_to(bundle.parent))
    resources=[
        (path.name,b"JSON",(json.dumps({"patcher":patch},ensure_ascii=False,indent=2)+'\n\0').encode()),
        *((name, b"PNG " if name.endswith(".png") else b"TEXT", (ROOT / src).read_bytes())
          for name, src in assets.items()),
        (EXTERNAL+".mxo",b"iLaX",bytes(4)),(EXTERNAL+"/zipfile",bytes(4),zipdata.getvalue()),
        (EXTERNAL+"/executable",bytes(4),(contents/"MacOS"/EXTERNAL).read_bytes()),
        (EXTERNAL+"/plist",bytes(4),(contents/"Info.plist").read_bytes())]
    for f in sorted((contents/"Resources").glob("*")):
        if f.is_file():resources.append((EXTERNAL+"/resfile/"+f.name,bytes(4),f.read_bytes()))
    data=bytearray();index=bytearray();now=int(time.time())+2082844800
    for ix,(name,kind,contents) in enumerate(resources):
        offset=16+len(data);data.extend(contents);name=name.encode()+b'\0';name+=b'\0'*(-len(name)%4)
        props=b''.join(record(k,be(v)) for k,v in [(b'sz32',len(contents)),(b'of32',offset),(b'vers',0),(b'flag',17 if ix==0 else 0),(b'mdat',now)])
        index.extend(record(b'dire',record(b'type',kind)+record(b'fnam',name)+props))
    blob=b'mx@c'+be(16)+be(0)+be(len(data)+16)+data+record(b'dlst',index)
    tmp=path.with_suffix('.tmp')
    tmp.write_bytes(AMXD_HEADER+struct.pack('<I',len(blob))+blob)
    tmp.replace(path)


def build_device(device):
    config = json.loads((device / "device.json").read_text())
    name = config["external"]
    bundle = BUILD / device.name / (name + ".mxo")
    contents = bundle / "Contents"
    for directory in ("MacOS", "Resources"):
        (contents / directory).mkdir(parents=True, exist_ok=True)
    shutil.copyfile(device / "Info.plist", contents / "Info.plist")
    shutil.copyfile(sdk / "pluginterfaces/LICENSE.txt", contents / "Resources/Steinberg License.txt")
    bins = [compile_external(device, name, arch) for arch in ("arm64", "x86_64")]
    subprocess.run(["lipo", "-create", *bins, "-output", contents / "MacOS" / name], check=True)
    subprocess.run(["codesign", "--force", "--sign", "-", bundle], check=True)
    subprocess.run(["codesign", "--verify", "--strict", bundle], check=True)
    patch = json.loads((device / "device.maxpat").read_text())["patcher"]
    controller = next(row["box"] for row in patch["boxes"] if row["box"]["varname"] == "ctrl")
    scripts = [device / "controller.js", ROOT / "shared/missing-plugin.js", ROOT / "shared/meter-controls.js"]
    controller["code"] = "\n".join(script.read_text() for script in scripts)
    output = ROOT / "dist" / (config["name"] + ".amxd")
    output.parent.mkdir(exist_ok=True)
    assets = config["resources"].copy()
    panel = next(row["box"] for row in patch["boxes"] if row["box"]["varname"] == "face")
    panel_x, _, panel_width, height = panel["presentation_rect"]
    width = patch["devicewidth"]
    overlay = dict(id="warning-overlay", varname="warningOverlay", maxclass="v8ui",
                   filename="wrapper-warning-overlay.js", numinlets=1, numoutlets=1, outlettype=[""],
                   jsarguments=[panel_x / width, panel_width / width], presentation=1,
                   presentation_rect=[0, 0, width, height],
                   patching_rect=[10, 1100, width, height])
    patch["boxes"].insert(0, {"box": overlay})
    patch["lines"].append({"patchline": {"source": [overlay["id"], 0], "destination": [controller["id"], 0]}})
    assets[overlay["filename"]] = "shared/warning-overlay.js"
    if device.name == "oxford-inflator":
        skin = ROOT / assets["oxford-surface.png"]
        if skin.is_file():
            panel = device / "oxford-panel-v1.js"
            generated = BUILD / device.name / panel.name
            generated.write_text(panel.read_text().replace("var skin=null;", 'var skin=new Image("oxford-surface.png");', 1))
            assets[panel.name] = generated
        else:
            del assets["oxford-surface.png"]
            patch["boxes"] = [row for row in patch["boxes"] if row["box"].get("varname") != "panelResource"]
    freeze(bundle, patch, output, assets)
    print(output)

if __name__ == "__main__":
    devices = ROOT / "devices"
    for device in ([devices / arg for arg in sys.argv[1:]] or sorted(devices.iterdir())):
        build_device(device)
