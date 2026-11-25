"""Build the macOS test external from the local Max and Steinberg SDKs."""
import argparse
from pathlib import Path
import plistlib
import subprocess

NAME = "m4ldecaplatency~"
SDK_SOURCES = {
    "pluginterfaces/base": ("coreiids.cpp", "funknown.cpp", "ustring.cpp"),
    "public.sdk/source/common": ("commoniids.cpp", "commonstringconvert.cpp", "memorystream.cpp", "threadchecker_mac.mm"),
    "public.sdk/source/vst": ("vstinitiids.cpp",),
    "public.sdk/source/vst/utility": ("stringconvert.cpp",),
    "public.sdk/source/vst/hosting": ("module.cpp", "module_mac.mm", "plugprovider.cpp", "hostclasses.cpp",
                                      "pluginterfacesupport.cpp", "parameterchanges.cpp", "connectionproxy.cpp"),
}


def build(vst3_sdk, max_sdk, output):
    bundle = output / (NAME + ".mxo")
    contents = bundle / "Contents"
    binaries = contents / "MacOS"
    binaries.mkdir(parents=True, exist_ok=True)
    info = {"CFBundleExecutable": NAME, "CFBundleName": NAME, "CFBundleIdentifier": "org.m4lwrappers.test.decaplatency",
            "CFBundlePackageType": "BNDL", "CFBundleVersion": "1"}
    (contents / "Info.plist").write_bytes(plistlib.dumps(info))
    includes = max_sdk / "c74support"
    sources = [vst3_sdk / folder / file for folder, files in SDK_SOURCES.items() for file in files]
    subprocess.run(["clang++", "-std=c++17", "-O2", "-fobjc-arc", "-DNDEBUG", "-DRELEASE=1",
                    "-Wno-deprecated-declarations", "-fvisibility=hidden", "-I", vst3_sdk,
                    "-I", includes / "max-includes", "-I", includes / "msp-includes",
                    Path(__file__).with_name("probe.cpp"), *sources, "-bundle", "-undefined", "dynamic_lookup",
                    "-framework", "AppKit", "-framework", "Foundation", "-framework", "CoreFoundation",
                    "-framework", "CoreServices", "-o", binaries / NAME], check=True)
    subprocess.run(["codesign", "--force", "--sign", "-", bundle], check=True)
    return bundle


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("vst3_sdk", type=Path)
    parser.add_argument("max_sdk", type=Path)
    parser.add_argument("output", type=Path)
    args = parser.parse_args()
    print(build(args.vst3_sdk, args.max_sdk, args.output))
