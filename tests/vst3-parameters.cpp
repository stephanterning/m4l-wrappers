#include "../shared/Vst3Parameters.h"
#include <cassert>

int main() {
    const std::array<Vst3Control,3> controls={{{11,"Gain"},{22,"Frequency"},{33,"Bypass"}}};
    std::array<Steinberg::Vst::ParamID,3> ids{};
    std::string error;
    std::vector<Vst3Parameter> available={{44,"New bypass name",true},{55,"Frequency",false},{11,"Level",false}};
    assert(matchParameters(controls,2,available,ids,error));
    assert(ids[0]==11 && ids[1]==55 && ids[2]==44);

    available.push_back({66,"Frequency",false});
    assert(!matchParameters(controls,2,available,ids,error));
    assert(error=="Cannot map the required VST3 parameter: Frequency (expected ID 22).");
    available={{11,"Frequency",false},{33,"Bypass",false}};
    assert(!matchParameters(controls,2,available,ids,error));
    available.push_back({22,"Changed name",false});
    assert(matchParameters(controls,2,available,ids,error));
    assert(ids[0]==11 && ids[1]==22 && ids[2]==33);
}
