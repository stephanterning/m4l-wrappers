#pragma once
#include "public.sdk/source/vst/hosting/module.h"
#include <algorithm>
#include <filesystem>
#include <initializer_list>
#include <string>
#include <vector>
#ifdef __APPLE__
#import <Foundation/Foundation.h>
#endif

inline bool moduleNameMatches(std::string name, std::initializer_list<const char*> names) {
    for (char& c : name) if (c>='A' && c<='Z') c += 'a'-'A';
    return std::find(names.begin(),names.end(),name)!=names.end();
}

inline std::vector<std::string> matchingModulePaths(std::initializer_list<const char*> names,
                                                     const char* macBundleIdentifier) {
    namespace fs = std::filesystem;
    std::vector<std::string> candidates;
    for (const auto& path : VST3::Hosting::Module::getModulePaths()) {
        const auto file=fs::u8path(path);
        bool match=moduleNameMatches(file.stem().u8string(),names);
#ifdef __APPLE__
        if (!match) {
            NSURL* bundle = [NSURL fileURLWithPath:[NSString stringWithUTF8String:path.c_str()] isDirectory:YES];
            NSURL* info = [bundle URLByAppendingPathComponent:@"Contents/Info.plist"];
            NSDictionary* properties = [NSDictionary dictionaryWithContentsOfURL:info error:nullptr];
            match=[properties[@"CFBundleIdentifier"] isEqualToString:[NSString stringWithUTF8String:macBundleIdentifier]];
        }
#endif
        if (!match) continue;
        std::error_code error;
        const auto resolved=fs::canonical(file,error);
        if (error) continue;
        const std::string location=resolved.generic_u8string();
        if (std::find(candidates.begin(),candidates.end(),location)==candidates.end()) candidates.push_back(location);
    }
    return candidates;
}
