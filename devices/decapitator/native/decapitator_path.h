#pragma once
#import <Foundation/Foundation.h>
#import <CoreFoundation/CoreFoundation.h>
#include <set>
#include <string>

// Call only after the per-instance Max vst~ lookup has confirmed Decapitator.
// Core Foundation exposes the bundles already open in this process, including
// plug-ins Max loaded from a custom folder. A duplicate needs explicit resolution.
inline std::string loadedDecapitatorPath(std::string& error) {
    const CFArrayRef bundles = CFBundleGetAllBundles();
    std::set<std::string> paths;
    for (CFIndex i = 0; bundles && i < CFArrayGetCount(bundles); ++i) {
        auto bundle = static_cast<CFBundleRef>(const_cast<void*>(CFArrayGetValueAtIndex(bundles, i)));
        const auto id = CFBundleGetIdentifier(bundle);
        if (!id || !CFEqual(id, CFSTR("com.soundtoys.vst3.Decapitator")) ||
            !CFBundleIsExecutableLoaded(bundle)) continue;
        NSURL* url = CFBridgingRelease(CFBundleCopyBundleURL(bundle));
        NSURL* resolved = url.URLByResolvingSymlinksInPath;
        if ([resolved.pathExtension.lowercaseString isEqualToString:@"vst3"] && resolved.fileSystemRepresentation)
            paths.emplace(resolved.fileSystemRepresentation);
    }
    if (paths.size() == 1) return *paths.begin();
    error = paths.empty() ? "Max found Decapitator, but its loaded VST3 bundle could not be identified."
                          : "Multiple Decapitator VST3 bundles are loaded. Keep one version active and click Retry.";
    return {};
}
