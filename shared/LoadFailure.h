#pragma once
#include "ext.h"
#include <string>

static void reportLoadFailure(t_object* device, void* events, bool found, const std::string& error) {
    if (!found) {
        object_warn(device, "VST3 plug-in was not found.");
        outlet_anything(events, gensym("missing"), 0, nullptr);
        return;
    }
    const char* reason = error.empty() ? "The VST3 host could not initialize the plug-in." : error.c_str();
    object_warn(device, "%s", reason);
    t_atom detail;
    atom_setsym(&detail, gensym(reason));
    outlet_anything(events, gensym("loaderror"), 1, &detail);
}
