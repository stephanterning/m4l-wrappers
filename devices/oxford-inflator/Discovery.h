#import <Foundation/Foundation.h>

static bool isOxfordBundle(NSString* path) {
    NSString* name = path.lastPathComponent.stringByDeletingPathExtension;
    if ([name caseInsensitiveCompare:@"Oxford Inflator Native"] == NSOrderedSame ||
        [name caseInsensitiveCompare:@"Oxford Inflator"] == NSOrderedSame) {
        return true;
    }
    NSURL* bundle = [NSURL fileURLWithPath:path isDirectory:YES];
    NSURL* info = [bundle URLByAppendingPathComponent:@"Contents/Info.plist"];
    NSDictionary* properties = [NSDictionary dictionaryWithContentsOfURL:info error:nullptr];
    return [properties[@"CFBundleIdentifier"] isEqualToString:@"com.sonnox.OxfordInflator"];
}

#include "ModulePaths.h"

static NSArray<NSString*>* oxfordPaths() {
    return matchingModulePaths(isOxfordBundle);
}
