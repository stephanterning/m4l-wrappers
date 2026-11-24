// Run against the released host to independently read a component state extracted from a private Live Set.
#include "Engine.mm"
#include "Discovery.h"
#include <iomanip>
#include <fstream>
#include <iostream>

#ifdef TEST_OXFORD
using Engine = Oxford;
const auto discover = oxfordPaths;
#else
using Engine = Spectre;
const auto discover = spectrePaths;
#endif

int main(int argc, char** argv) {
    if (argc != 2) return 1;
    @autoreleasepool {
        [NSApplication sharedApplication];
        [NSApp finishLaunching];
        auto paths = discover();
        if (paths.empty()) return 2;
        std::string error;
        auto host = owned(new Engine([]{}));
        if (!host->open(paths.front(), error) || !host->prepare(48000, 128)) return 3;
        std::ifstream file(argv[1], std::ios::binary);
        if (!file) return 4;
        PluginState state((std::istreambuf_iterator<char>(file)), {});
        if (!host->recall(state)) return 5;
        std::cout << std::setprecision(17);
        for (size_t i = 0; i < controls.size(); ++i) std::cout << i + 1 << " " << host->value(i) << "\n";
        host->shutdown();
        return 0;
    }
}
