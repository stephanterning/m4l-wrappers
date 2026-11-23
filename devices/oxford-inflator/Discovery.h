#pragma once
#include "ModulePaths.h"

static std::vector<std::string> oxfordPaths() {
    return matchingModulePaths({"oxford inflator native","oxford inflator","sonnox oxford inflator"},
                               "com.sonnox.OxfordInflator");
}
