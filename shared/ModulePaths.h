static NSArray<NSString*>* matchingModulePaths(bool (*matches)(NSString*)) {
    NSMutableOrderedSet<NSString*>* candidates = [NSMutableOrderedSet orderedSet];
    for (const std::string& path : VST3::Hosting::Module::getModulePaths()) {
        NSString* bundlePath = [NSString stringWithUTF8String:path.c_str()];
        if (bundlePath && matches(bundlePath)) {
            [candidates addObject:bundlePath.stringByResolvingSymlinksInPath];
        }
    }
    return candidates.array;
}
