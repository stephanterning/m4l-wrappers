#import <Foundation/Foundation.h>

static bool isSpectreBundle(NSString* path) {
    NSString* name = path.lastPathComponent.stringByDeletingPathExtension;
    if ([name caseInsensitiveCompare:@"Spectre"] == NSOrderedSame) return true;
    NSURL* bundle = [NSURL fileURLWithPath:path isDirectory:YES];
    NSURL* info = [bundle URLByAppendingPathComponent:@"Contents/Info.plist"];
    NSDictionary* properties = [NSDictionary dictionaryWithContentsOfURL:info error:nullptr];
    return [properties[@"CFBundleIdentifier"] isEqualToString:@"com.wavesfactory.Spectre"];
}

#include "ModulePaths.h"

static NSArray<NSString*>* spectrePaths() {
    return matchingModulePaths(isSpectreBundle);
}
