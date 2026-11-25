"""Build and embed Decapitator's macOS VST3 processor using the Max and Steinberg SDKs."""
from concurrent.futures import ThreadPoolExecutor
import io
import os
from pathlib import Path
import plistlib
import shlex
import subprocess
import zipfile

NAME = "m4ldecapitator~"
SOURCE = Path(__file__).resolve().parent
ROOT = SOURCE.parents[2]
SDK_SOURCES = [
    "base/source/fbuffer.cpp", "pluginterfaces/base/coreiids.cpp", "pluginterfaces/base/funknown.cpp", "pluginterfaces/base/ustring.cpp",
    "public.sdk/source/common/commoniids.cpp", "public.sdk/source/common/commonstringconvert.cpp",
    "public.sdk/source/common/memorystream.cpp", "public.sdk/source/common/threadchecker_mac.mm",
    "public.sdk/source/vst/vstinitiids.cpp", "public.sdk/source/vst/vstpresetfile.cpp",
    "public.sdk/source/vst/utility/stringconvert.cpp",
    *["public.sdk/source/vst/hosting/" + name for name in
      ("module.cpp","module_mac.mm","plugprovider.cpp","hostclasses.cpp","pluginterfacesupport.cpp",
       "parameterchanges.cpp","connectionproxy.cpp")],
]


def native_bundle():
    sdk = Path(os.environ.get("VST3_SDK", ROOT / "deps/vst3sdk")).resolve()
    includes = Path(os.environ.get("MAX_SDK_BASE", ROOT / "deps/max-sdk-base")).resolve() / "c74support"
    if not (sdk / SDK_SOURCES[0]).is_file() or not (includes / "max-includes/ext.h").is_file():
        raise ValueError("Building the macOS Decapitator requires VST3_SDK and MAX_SDK_BASE.")
    work = ROOT / "build/decapitator-v2"
    bundle = work / (NAME + ".mxo")
    contents = bundle / "Contents"
    executable = contents / "MacOS" / NAME
    executable.parent.mkdir(parents=True, exist_ok=True)
    (contents / "Resources").mkdir(exist_ok=True)
    (contents / "Resources/Steinberg License.txt").write_bytes((sdk / "pluginterfaces/LICENSE.txt").read_bytes())
    (contents / "Info.plist").write_bytes(plistlib.dumps({
        "CFBundleExecutable": NAME, "CFBundleIdentifier": "org.m4lwrappers.decapitator.host",
        "CFBundleName": NAME, "CFBundlePackageType": "BNDL", "CFBundleVersion": "2",
    }))
    binaries = []
    for arch in ("arm64", "x86_64"):
        output = work / arch
        output.mkdir(exist_ok=True)
        flags = ["clang++", "-std=c++17", "-O2", "-fvisibility=hidden", "-DNDEBUG", "-DRELEASE=1",
                 "-arch", arch, "-mmacosx-version-min=12.0", "-Wno-deprecated-declarations",
                 "-I", str(sdk), "-I", str(includes / "max-includes"), "-I", str(includes / "msp-includes")]
        def compile_source(src):
            obj = output / (src.stem + ".o")
            depfile = obj.with_suffix(".d")
            # -MMD also tracks transitive SDK headers. The output path is relative
            # to the compilation directory and paths in the depfile may contain spaces.
            deps = []
            if depfile.exists():
                payload = depfile.read_text().replace(chr(92)+"\n", " ").split(": ", 1)
                if len(payload) == 2:
                    deps = [Path(file) for file in shlex.split(payload[1])]
            if not deps or not obj.exists() or any(not p.is_file() or p.stat().st_mtime_ns > obj.stat().st_mtime_ns for p in deps):
                subprocess.run(flags + (["-fobjc-arc"] if src.suffix == ".mm" else []) +
                               ["-MMD", "-MF", str(depfile), "-c", str(src), "-o", str(obj)], check=True)
            return obj
        with ThreadPoolExecutor(5) as pool:
            objects = list(pool.map(compile_source, [sdk / name for name in SDK_SOURCES] + [SOURCE / "external.mm"]))
        binary = output / NAME
        subprocess.run(flags + objects + ["-bundle","-undefined","dynamic_lookup","-Wl,-dead_strip","-Wl,-exported_symbol,_ext_main","-framework","AppKit",
                       "-framework","Foundation","-framework","CoreFoundation",
                       "-framework","CoreServices","-o",binary], check=True)
        unresolved = subprocess.check_output(["nm","-u",binary],text=True)
        if any("9Steinberg" in symbol or "4VST3" in symbol for symbol in unresolved.splitlines()):
            raise RuntimeError("The Max bundle has unresolved VST3 SDK symbols.")
        binaries.append(binary)
    subprocess.run(["lipo","-create",*binaries,"-output",executable],check=True)
    subprocess.run(["codesign","--force","--sign","-",bundle],check=True)
    subprocess.run(["codesign","--verify","--strict",bundle],check=True)
    return bundle


def resources(bundle):
    contents = bundle / "Contents"
    packed = io.BytesIO()
    with zipfile.ZipFile(packed,"w",zipfile.ZIP_DEFLATED) as archive:
        for entry in sorted(bundle.rglob("*")):
            archive.write(entry,entry.relative_to(bundle.parent))
    return [(bundle.name,b"iLaX",bytes(4)), (NAME+"/zipfile",bytes(4),packed.getvalue()),
            (NAME+"/executable",bytes(4),(contents/"MacOS"/NAME).read_bytes()),
            (NAME+"/plist",bytes(4),(contents/"Info.plist").read_bytes()),
            (NAME+"/resfile/Steinberg License.txt",bytes(4),(contents/"Resources/Steinberg License.txt").read_bytes())]


def install(patch):
    # Max resolves the installed plug-in in a disabled, unconnected vst~.
    # Only the SDK processor participates in the audio graph.
    processor = next(row["box"] for row in patch["boxes"] if row["box"].get("varname") == "maxPlugin")
    lookup = dict(processor,id="maxLookup",varname="maxLookup",patching_rect=[580,1230,285,22])
    patch["boxes"].append({"box":lookup})
    processor.update(text=NAME,numoutlets=3)
    for key in ("saved_attribute_attributes","saved_object_attributes"):
        processor.pop(key,None)
    patch["lines"] = [row for row in patch["lines"] if row["patchline"]["source"] not in (["maxPlugin",2],["maxPlugin",3])]
    patch["lines"].append({"patchline":{"source":["maxPlugin",2],"destination":["maxHostControl",1]}})
    return resources(native_bundle())
