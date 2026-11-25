// Exercise the actual macOS device processor with the installed licensed VST3.
// No Live session or audio driver is needed. Run after python3 build.py decapitator.
#include "../../../devices/decapitator/native/Engine.h"
#include <cstdio>
#include <stdexcept>
#include <thread>
#include <chrono>

constexpr int frames=64;
using Stereo=std::array<std::array<double,frames>,2>;
static void run(Decapitator& e,Stereo& input,Stereo& output) {
    double* in[]={input[0].data(),input[1].data()};
    double* out[]={output[0].data(),output[1].data()};
    if(!e.process(in,out,frames))throw std::runtime_error("VST3 did not process a block");
}
struct Instance {
    IPtr<Decapitator> engine=owned(new Decapitator([]{}));
    Instance(const char* path,double rate,NSString* state=@"-") {
        std::string error;
        if(!engine->open(path,error))throw std::runtime_error(error);
        if(!engine->recall(state) || !engine->prepare(rate,frames))throw std::runtime_error("Preset or DSP setup failed");
    }
    ~Instance(){engine->shutdown();}
    void edit(int slot,double v) {
        engine->set(slot,v);
        if(!engine->process(nullptr,nullptr,frames))throw std::runtime_error("Cannot deliver an edit");
    }
};
static bool impulse(const char* path,int rate) {
    Instance effect(path,rate);
    effect.edit(6,0);
    Stereo zeros{}, out{};
    const int expected=effect.engine->latency(),pulse=8192;
    double highest=0;int location=-1;
    for(int start=0;start<pulse+expected+256;start+=frames) {
        Stereo in=zeros;
        if(start==pulse){in[0][0]=.25;in[1][0]=-.25;}
        run(*effect.engine,in,out);
        for(int i=0;i<frames;i++)if(std::abs(out[0][i])>highest){
            highest=std::abs(out[0][i]);location=start+i;
        }
    }
    std::printf("rate %d reported %d measured %d peak %.8f\n",rate,expected,location-pulse,highest);
    return highest>.2 && location-pulse==expected;
}
static bool state(const char* path,int mode) {
    constexpr int rate=48000, drive=1, punish=2, tone=4, automatic=7, trim=10;
    Instance original(path,rate);
    original.edit(automatic,0);original.edit(trim,.8);original.edit(drive,.36);original.edit(tone,.5);
    NSString* stale=original.engine->snapshot();
    if(!stale)return false;
    // Reproduce the same ordered edits used by the panel and the recall controller.
    original.edit(automatic,1);original.edit(drive,.81);original.edit(tone,(2.5+12.)/24.);
    if(mode==1){original.edit(automatic,0);original.edit(drive,.23);}
    if(mode==2)original.edit(trim,.72);
    if(mode==3)original.edit(punish,1);
    if(mode==4){original.edit(automatic,0);original.edit(trim,.72);}
    // With AutoGain enabled a manual trim is carried by the vendor preset.
    // Simulate a completed capture for that case, a stale capture for the rest.
    NSString* saved=mode==2 ? original.engine->snapshot() : stale;
    if(!saved)return false;
    Instance reopened(path,rate,saved);
    const auto value=[&](int slot){return original.engine->value(slot);};
    const auto reconcile=[&](int slot,double v){
        if(std::abs(reopened.engine->value(slot)-v)>1e-6)reopened.edit(slot,v);
    };
    if(mode==1){
        reconcile(automatic,0);reconcile(drive,.81);reconcile(punish,0);
        reopened.edit(automatic,1);
    }
    reconcile(automatic,value(automatic));
    for(int i=0;i<11;i++)if(i!=trim && i!=automatic)reconcile(i,value(i));
    if(mode==4)reopened.edit(trim,value(trim));
    Stereo in{},a{},b{};double energyA=0,energyB=0,delta=0;
    for(int start=0;start<3*rate;start+=frames) {
        for(int i=0;i<frames;i++)in[0][i]=in[1][i]=0.017*std::sin(2*M_PI*997*(start+i)/rate);
        run(*original.engine,in,a);run(*reopened.engine,in,b);
        if(start<2*rate)continue;
        for(int i=0;i<frames;i++){energyA+=a[0][i]*a[0][i];energyB+=b[0][i]*b[0][i];delta+=std::pow(a[0][i]-b[0][i],2);}
    }
    double gain=10*std::log10(energyB/energyA),residual=std::sqrt(delta/energyA);
    std::printf("recall case %d gain difference %.7f dB, relative RMS residual %.9f\n",mode,gain,residual);
    return energyA>0.1 && std::isfinite(gain) && std::abs(gain)<.001 && residual<.001;
}
// Give the first instance extra audio time and wall time before constructing
// the second. Discard the first three seconds of their common stimulus so
// initial filter state differences are measured separately from ongoing drift.
static void comparePhases(const char* path,int style,bool settleBoth) {
    constexpr int rate=48000;
    Instance a(path,rate);
    auto settings=[style](Instance& e) {
        e.edit(7,0);e.edit(0,style/4.);e.edit(1,.6);e.edit(10,.75);
    };
    settings(a);
    Stereo in{},left{},right{};
    for(int frame=0;frame<65728;frame+=frames)run(*a.engine,in,left);
    std::this_thread::sleep_for(std::chrono::milliseconds(173));
    Instance b(path,rate);settings(b);
    if(settleBoth) {
        for(int frame=0;frame<3*rate;frame+=frames) {
            run(*a.engine,in,left);
            run(*b.engine,in,right);
        }
    }
    double first=0,peak=0,energy=0,signal=0;
    for(int frame=0;frame<8*rate;frame+=frames) {
        for(int j=0;j<frames;j++) {
            const double t=(frame+j)/double(rate);
            in[0][j]=in[1][j]=.045*(std::sin(2*M_PI*87.31*t)+std::sin(2*M_PI*997.19*t)+std::sin(2*M_PI*4831.73*t));
        }
        run(*a.engine,in,left);run(*b.engine,in,right);
        for(int j=0;j<frames;j++){
            const double diff=left[0][j]-right[0][j];
            if(frame<3*rate)first=std::max(first,std::abs(diff));
            else {peak=std::max(peak,std::abs(diff));energy+=diff*diff;signal+=left[0][j]*left[0][j];}
        }
    }
    std::printf("style %c staggered instances common silence %d s, initial peak %.9g steady peak %.9g steady relative RMS %.9g\n",
        "AENTP"[style],settleBoth?3:0,first,peak,std::sqrt(energy/signal));
}
int main(int argc,char** argv) { @autoreleasepool {
    if(argc!=2 && argc!=3)return 2;
    try {
        if(argc==3){
            if(std::string(argv[2])!="--staggered")return 2;
            for(bool settleBoth:{false,true})
                for(int style=0;style<5;style++)comparePhases(argv[1],style,settleBoth);
            return 0;
        }
        bool passed=true;
        for(int sr:{44100,48000,88200,96000,176400,192000})passed=impulse(argv[1],sr) && passed;
        for(int i=0;i<5;i++)passed=state(argv[1],i) && passed;
        return passed?0:1;
    }catch(const std::exception& e){std::fprintf(stderr,"%s\n",e.what());return 1;}
} }
