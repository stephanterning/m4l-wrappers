#pragma once
#include "public.sdk/source/common/memorystream.h"
#include "pluginterfaces/vst/ivstcomponent.h"
#include "pluginterfaces/vst/ivsteditcontroller.h"
#include <cstdint>
#include <string>
#include <string_view>
#include <vector>

using PluginState = std::vector<uint8_t>;
constexpr size_t maxPluginStateBytes = 256 * 1024;

inline PluginState readPluginState(Steinberg::Vst::IComponent* component) {
    Steinberg::MemoryStream stream;
    if (!component || component->getState(&stream) != Steinberg::kResultOk ||
        stream.getSize() <= 0 || stream.getSize() > maxPluginStateBytes) return {};
    const auto* data = reinterpret_cast<const uint8_t*>(stream.getData());
    return {data, data + stream.getSize()};
}

inline bool restorePluginState(Steinberg::Vst::IComponent* component,
                               Steinberg::Vst::IEditController* controller, const PluginState& state) {
    if (!component || !controller || state.empty() || state.size() > maxPluginStateBytes) return false;
    // MemoryStream wraps a non-const buffer. Give the plug-in its own mutable copy.
    auto data = state;
    Steinberg::MemoryStream stream(data.data(), data.size());
    if (component->setState(&stream) != Steinberg::kResultOk) return false;
    stream.seek(0, Steinberg::IBStream::kIBSeekSet, nullptr);
    controller->setComponentState(&stream);
    return true;
}

// This is the RFC 4648 representation used by the existing pattr state on macOS.
constexpr std::string_view stateAlphabet = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";

inline std::string encodePluginState(const PluginState& state) {
    std::string text;
    text.reserve((state.size()+2)/3*4);
    for (size_t i=0; i<state.size(); i+=3) {
        uint32_t bits = uint32_t(state[i]) << 16;
        if (i+1 < state.size()) bits |= uint32_t(state[i+1]) << 8;
        if (i+2 < state.size()) bits |= state[i+2];
        text.push_back(stateAlphabet[bits >> 18]);
        text.push_back(stateAlphabet[(bits >> 12) & 63]);
        text.push_back(i+1 < state.size() ? stateAlphabet[(bits >> 6) & 63] : '=');
        text.push_back(i+2 < state.size() ? stateAlphabet[bits & 63] : '=');
    }
    return text;
}

inline PluginState decodePluginState(std::string_view text) {
    if (text.empty() || text.size()%4 || text.size() > (maxPluginStateBytes+2)/3*4) return {};
    const size_t padding = text.back()=='=' ? (text[text.size()-2]=='=' ? 2 : 1) : 0;
    const size_t bytes = text.size()/4*3-padding;
    if (bytes > maxPluginStateBytes) return {};
    PluginState state;
    state.reserve(bytes);
    uint32_t bits=0;
    int count=0;
    for (char c : text.substr(0,text.size()-padding)) {
        auto digit = stateAlphabet.find(c);
        if (digit==std::string_view::npos) return {};
        bits = (bits << 6) | uint32_t(digit);
        count += 6;
        if (count>=8) {
            count -= 8;
            state.push_back(static_cast<uint8_t>(bits >> count));
        }
    }
    return state;
}
