"""Run the production macOS Decapitator processor at six rates and compare stale-preset recall."""
import argparse
import os
from pathlib import Path
import platform
import subprocess
import sys

root = Path(__file__).resolve().parents[3]
sys.path.insert(0, str(root))
from devices.decapitator.native.package import native_bundle, SDK_SOURCES


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("plugin", type=Path, help="Installed Soundtoys Decapitator VST3 bundle")
    parser.add_argument("--staggered", action="store_true", help="Compare two instances with different start times in all five styles")
    args = parser.parse_args()
    if sys.platform != "darwin" or not args.plugin.is_dir():
        parser.error("Run on macOS with the path to the installed VST3 bundle.")
    native_bundle()
    build = root / "build/decapitator-v2"
    sdk = Path(os.environ.get("VST3_SDK", root / "deps/vst3sdk"))
    objects = [build / platform.machine() / (Path(source).stem + ".o") for source in SDK_SOURCES]
    check = build / "audio-state-check"
    subprocess.run(["clang++", "-std=c++17", "-O2", "-fobjc-arc", "-DNDEBUG", "-DRELEASE=1",
                    "-Wno-deprecated-declarations", "-I", sdk, Path(__file__).with_suffix(".mm"),
                    *objects, "-Wl,-dead_strip", "-framework", "CoreFoundation", "-framework", "Foundation",
                    "-framework", "AppKit", "-framework", "CoreServices", "-o", check], check=True)
    subprocess.run([check, args.plugin.resolve()] + (["--staggered"] if args.staggered else []), check=True)
