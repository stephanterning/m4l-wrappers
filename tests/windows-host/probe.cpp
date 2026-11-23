#include "Engine.mm"
#include "Discovery.h"
#include <windows.h>
#include <filesystem>
#include <iostream>
#include <stdexcept>

namespace fs=std::filesystem;
#ifdef TEST_SPECTRE
using Engine=Spectre;
const auto discover=spectrePaths;
constexpr auto pluginFile=L"Spectre.vst3";
#else
using Engine=Oxford;
const auto discover=oxfordPaths;
constexpr auto pluginFile=L"Oxford Inflator.vst3";
#endif

static void check(bool condition,const std::string& message) {
    if(!condition)throw std::runtime_error(message);
}

static void audio(Engine& engine,double gain) {
    double l[64],r[64],ol[64]{},orr[64]{};
    std::fill_n(l,64,0.5);std::fill_n(r,64,-0.25);
    double* input[]={l,r};double* output[]={ol,orr};
    check(engine.render(input,output,64),"stereo process failed");
    for(int i=0;i<64;++i)check(ol[i]==l[i]*gain && orr[i]==r[i]*gain,"unexpected audio");
}

int wmain(int argc,wchar_t** argv) {
    if(argc!=2)return 1;
    const auto fixture=fs::absolute(argv[1]);
    const auto parent=fs::absolute(argv[0]).parent_path()/L"VST3"/L"Test \u00e5"/fixture.stem();
    const auto plugin=parent/pluginFile;
    const auto locate=[&](){
        for(const auto& path:discover()){
            std::error_code ec;
            if(fs::equivalent(fs::u8path(path),plugin,ec))return path;
        }
        return std::string{};
    };
    const auto init=CoInitializeEx(nullptr,COINIT_APARTMENTTHREADED);
    if(FAILED(init))return 2;
    int status=0;
    try{
        // Each executable owns its fixture directory; no system plug-ins are touched.
        fs::remove_all(parent);
        check(locate().empty(),"unexpected test plug-in before install");
#ifdef TEST_SPECTRE
        const auto binary=plugin/L"Contents"/L"x86_64-win"/pluginFile;
#else
        const auto binary=plugin;
#endif
        fs::create_directories(binary.parent_path());
        fs::copy_file(fixture,binary);
        auto path=locate();
        check(!path.empty(),"retry did not discover newly installed test plug-in");
        std::string error;
        auto engine=owned(new Engine([]{}));
        if(!engine->open(path,error))throw std::runtime_error("open: "+error);
        check(engine->prepare(48000,64),"prepare failed");
        engine->set(1,0.25); audio(*engine.get(),0.25);
        auto state=engine->state();
        check(!state.empty(),"empty state");
        check(engine->showEditor(),"attach HWND failed");engine->closeEditor();
        check(engine->showEditor(),"reopen HWND failed");engine->closeEditor();
        engine->shutdown();
        auto recalled=owned(new Engine([]{}));
        if(!recalled->open(path,error))throw std::runtime_error("reopen: "+error);
        check(recalled->recall(state),"state restore failed");
        check(recalled->prepare(44100,64),"second prepare failed");
        audio(*recalled.get(),0.25);
        recalled->shutdown();
        fs::remove_all(parent);
        check(locate().empty(),"removed file still discovered");
    }catch(const std::exception& e){
        std::cerr<<e.what()<<'\n';status=1;
    }
    CoUninitialize();
    return status;
}
