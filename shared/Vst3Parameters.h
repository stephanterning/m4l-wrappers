#pragma once

#include "pluginterfaces/vst/ivsteditcontroller.h"
#include "public.sdk/source/vst/utility/stringconvert.h"
#include <algorithm>
#include <array>
#include <string>
#include <vector>

struct Vst3Control {
    Steinberg::Vst::ParamID id;
    const char* name;
};

struct Vst3Parameter {
    Steinberg::Vst::ParamID id;
    std::string name;
    bool bypass;
};

template<size_t N>
static bool matchParameters(const std::array<Vst3Control,N>& controls, size_t bypassIndex,
                            const std::vector<Vst3Parameter>& available,
                            std::array<Steinberg::Vst::ParamID,N>& ids, std::string& error) {
    for (size_t i=0; i<N; ++i) {
        const auto& control=controls[i];
        auto match=available.end();
        if (i==bypassIndex)
            match=std::find_if(available.begin(),available.end(),[](const auto& p){return p.bypass;});
        if (match==available.end())
            match=std::find_if(available.begin(),available.end(),[&](const auto& p){return !p.bypass && p.id==control.id;});
        if (match==available.end()) {
            // Only accept a unique original name on an ID not reserved by another control.
            for (auto it=available.begin(); it!=available.end(); ++it) {
                if (it->bypass || it->name!=control.name) continue;
                if (std::any_of(controls.begin(),controls.end(),[&](const auto& c){return c.id==it->id;})) continue;
                if (match!=available.end()) {match=available.end();break;}
                match=it;
            }
        }
        if (match==available.end()) {
            error=std::string("Cannot map the required VST3 parameter: ")+control.name+
                  " (expected ID "+std::to_string(control.id)+").";
            return false;
        }
        ids[i]=match->id;
    }
    return true;
}

template<size_t N>
static bool resolveParameters(Steinberg::Vst::IEditController& controller,
                              const std::array<Vst3Control,N>& controls, size_t bypassIndex,
                              std::array<Steinberg::Vst::ParamID,N>& ids, std::string& error) {
    std::vector<Vst3Parameter> available;
    for (int j=0; j<controller.getParameterCount(); ++j) {
        Steinberg::Vst::ParameterInfo p{};
        if (controller.getParameterInfo(j,p)==Steinberg::kResultOk)
            available.push_back({p.id,Steinberg::Vst::StringConvert::convert(p.title),(p.flags & Steinberg::Vst::ParameterInfo::kIsBypass)!=0});
    }
    return matchParameters(controls,bypassIndex,available,ids,error);
}
