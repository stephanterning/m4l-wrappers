#pragma once
#include "ModulePaths.h"

static std::vector<std::string> spectrePaths() {
    return matchingModulePaths({"spectre","wavesfactory spectre"}, "com.wavesfactory.Spectre");
}
