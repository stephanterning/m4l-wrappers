"""Build standalone Max-host wrappers on macOS."""
import argparse
import io
import json
import os
from pathlib import Path
import plistlib
import re
import struct
import subprocess
import tempfile
import time
import zipfile

ROOT = Path(__file__).resolve().parent
CLASS = "m4lwrappergainstage~"
WRAPPER_VERSION = "1.4"
headers = Path(os.environ.get("MAX_SDK_BASE", ROOT / "deps/max-sdk-base")).resolve() / "c74support"
AMXD_HEADER = bytes.fromhex("616d706604000000616161616d657461040000000700000070746368")

def be(number):
    return struct.pack(">I",number)
def record(tag, data):
    return tag+be(len(data)+8)+data

def windows_external(directory, name):
    path = directory / (name + ".mxe64")
    data = path.read_bytes()
    # Reject a wrong architecture or an ordinary EXE before producing a release.
    pe = int.from_bytes(data[60:64], "little")
    if (data[:2] != b"MZ" or data[pe:pe+6] != b"PE\0\0\x64\x86"
            or data[pe+24:pe+26] != b"\x0b\x02"
            or not int.from_bytes(data[pe+22:pe+24], "little") & 0x2000):
        raise ValueError(f"Expected a Windows x64 DLL at {path}")
    return data


def freeze(bundle, patch, path, assets, windows_binary=None):
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
    if windows_binary is not None:
        # Max stores Windows externals as raw DLL bytes in a top-level mx64 entry.
        resources.append((EXTERNAL + ".mxe64", b"mx64", windows_binary))
    data=bytearray();index=bytearray();now=int(time.time())+2082844800
    for ix,(name,kind,contents) in enumerate(resources):
        offset=16+len(data);data.extend(contents);name=name.encode()+b'\0';name+=b'\0'*(-len(name)%4)
        props=b''.join(record(k,be(v)) for k,v in [(b'sz32',len(contents)),(b'of32',offset),(b'vers',0),(b'flag',17 if ix==0 else 0),(b'mdat',now)])
        index.extend(record(b'dire',record(b'type',kind)+record(b'fnam',name)+props))
    blob=b'mx@c'+be(16)+be(0)+be(len(data)+16)+data+record(b'dlst',index)
    tmp=path.with_suffix('.tmp')
    tmp.write_bytes(AMXD_HEADER+struct.pack('<I',len(blob))+blob)
    tmp.replace(path)


def versioned_panel(panel, work):
    script, count = re.subn(r'"v\d+\.\d+(?:-[\w.]+)?"', f'"v{WRAPPER_VERSION}"', panel.read_text())
    if count != 1:
        raise ValueError(f"Expected one visible version label in {panel.name}")
    path = work / panel.name
    path.write_text(script)
    return path


def output_bundle(work):
    bundle = work / (CLASS+".mxo")
    exe = bundle/"Contents/MacOS"/CLASS
    exe.parent.mkdir(parents=True, exist_ok=True)
    info = dict(CFBundleExecutable=CLASS, CFBundleName=CLASS, CFBundlePackageType="iLaX",
                CFBundleIdentifier="org.m4lwrappers.output", CFBundleVersion="1", CFBundleShortVersionString="1")
    (bundle/"Contents/Info.plist").write_bytes(plistlib.dumps(info))
    subprocess.run(["clang++","-std=c++17","-O2","-arch","arm64","-arch","x86_64","-mmacosx-version-min=12.0",
                    "-bundle","-undefined","dynamic_lookup","-Wno-deprecated-declarations",
                    "-I"+str(headers/"max-includes"),"-I"+str(headers/"msp-includes"),
                    "-I"+str(ROOT/"shared"),str(ROOT/"host/output.cpp"),"-o",str(exe)],check=True)
    subprocess.run(["codesign","--force","--sign","-",str(bundle)],check=True)
    return bundle


def build_device(device, output, work, bundle, windows):
    config = json.loads((device / "device.json").read_text())
    patch = json.loads((device / "device.maxpat").read_text())["patcher"]
    boxes = {row["box"].get("varname"): row["box"] for row in patch["boxes"]}
    product = config["product"]
    controller = (device / "controller.js").read_text()
    definitions = device / "parameters.json"
    if definitions.exists():
        parameters = json.loads(definitions.read_text())
        product["parameters"] = [p["vst"] for p in parameters]
        controller = "const parameters = " + json.dumps(parameters) + ";\n" + controller
    else:
        controller += '\npluginEditorMessage = "openPlugin";'
    boxes["ctrl"]["code"] = "\n".join((controller, (ROOT / "shared/missing-plugin.js").read_text(),
                                      (ROOT / "shared/meter-controls.js").read_text()))
    boxes["maxHostControl"]["code"] = ("const product = " + json.dumps(product) + ";\n"
                                        + (ROOT / "host/adapter.js").read_text())
    assets = config["resources"]
    panel = config["panel"]
    assets[panel] = versioned_panel(device / panel, work)
    path = output / (config["name"] + ".amxd")
    freeze(bundle, patch, path, assets, windows)
    print(path)


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("devices", nargs="*", help="Device directory names (default: all)")
    parser.add_argument("--output", type=Path, default=ROOT / "dist")
    parser.add_argument("--windows-externals", type=Path)
    args = parser.parse_args()
    devices = {p.parent.name: p.parent for p in sorted((ROOT / "devices").glob("*/device.json"))}
    selected = args.devices or list(devices)
    if set(selected) - devices.keys():
        parser.error("Available devices: " + ", ".join(devices))
    windows = windows_external(args.windows_externals, CLASS) if args.windows_externals else None
    args.output.mkdir(parents=True, exist_ok=True)
    with tempfile.TemporaryDirectory() as tmp:
        work = Path(tmp)
        bundle = output_bundle(work)
        for name in selected:
            build_device(devices[name], args.output, work, bundle, windows)
