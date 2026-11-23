#pragma once
#if defined(_WIN32)
#include <emmintrin.h>
#else
#include <simd/simd.h>
#endif
#include <array>
#include <algorithm>
#include <cmath>

struct MeterReading {
    std::array<double,6> db{};
    bool valid=false;
};

class StereoMeters {
#if defined(_WIN32)
    // Two SSE2 stereo pairs fit the baseline Windows x64 instruction set.
    struct Signal {
        __m128d in{}, out{};
        Signal() = default;
        Signal(__m128d a,__m128d b):in(a),out(b){}
        Signal(double l,double r,double ol,double or_):in(_mm_set_pd(r,l)),out(_mm_set_pd(or_,ol)){}
        friend Signal operator+(Signal a,Signal b){return {_mm_add_pd(a.in,b.in),_mm_add_pd(a.out,b.out)};}
        friend Signal operator-(Signal a,Signal b){return {_mm_sub_pd(a.in,b.in),_mm_sub_pd(a.out,b.out)};}
        friend Signal operator*(Signal a,Signal b){return {_mm_mul_pd(a.in,b.in),_mm_mul_pd(a.out,b.out)};}
        friend Signal operator*(double a,Signal b){const auto g=_mm_set1_pd(a);return {_mm_mul_pd(g,b.in),_mm_mul_pd(g,b.out)};}
        Signal& operator+=(Signal b){*this=*this+b;return *this;}
        double operator[](int index)const{
            const __m128d pair=index<2?in:out;
            return _mm_cvtsd_f64((index&1)?_mm_unpackhi_pd(pair,pair):pair);
        }
    };
    static Signal maximum(Signal a,Signal b){return {_mm_max_pd(a.in,b.in),_mm_max_pd(a.out,b.out)};}
    static Signal magnitude(Signal a){
        const auto sign=_mm_set1_pd(-0.);
        return {_mm_andnot_pd(sign,a.in),_mm_andnot_pd(sign,a.out)};
    }
#else
    using Signal=simd_double4;
    static Signal maximum(Signal a,Signal b){return simd::max(a,b);}
    static Signal magnitude(Signal a){return simd::abs(a);}
#endif
    static constexpr int segments=300;
    static constexpr double pi=3.14159265358979323846;
    struct Biquad {
        double b0=1,b1=0,b2=0,a1=0,a2=0;
        Signal z1{},z2{};
        Signal process(Signal in) {
            Signal y=b0*in+z1;
            z1=b1*in-a1*y+z2;
            z2=b2*in-a2*y;
            return y;
        }
        void reset(){z1={};z2={};}
    };
    struct Slice {
        Signal power{},weighted{},peak{};
    };
    std::array<Slice,segments> history{};
    int chunkFrames=480, frames=0, head=0, filled=0;
    int refresh=0;
    Biquad shelf,highpass;
    Slice partial;
    Signal power{},weighted{};

    static double energyDb(double power){
        return power>1.e-24 ? 10*std::log10(power) : -240.;
    }

public:
    void configure(double rate){
        chunkFrames=std::max(1,(int)std::lround(rate/100.));
        // BS.1770 K weighting. Bilinear coefficients for this device's sample rate.
        const double k=std::tan(pi*1681.974450955533/rate);
        const double q=.7071752369554196;
        const double vh=std::pow(10.,3.999843853973347/20.);
        const double vb=std::pow(vh,.4996667741545416);
        const double a0=1+k/q+k*k;
        shelf={(vh+vb*k/q+k*k)/a0,2*(k*k-vh)/a0,(vh-vb*k/q+k*k)/a0,
               2*(k*k-1)/a0,(1-k/q+k*k)/a0};
        const double h=std::tan(pi*38.13547087602444/rate);
        const double hq=.5003270373238773;
        const double ha=1+h/hq+h*h;
        highpass={1,-2,1,2*(h*h-1)/ha,(1-h/hq+h*h)/ha};
        reset();
    }
    void reset(){
        history={};partial={};power={};weighted={};
        frames=head=filled=refresh=0;
        shelf.reset();highpass.reset();
    }
    // Returns true at the 10 Hz display cadence, with or without a full window.
    bool append(double** in,double** out,int count,MeterReading& result) {
        bool updated=false;
        for(int i=0;i<count;i++){
            const Signal frame={in[0][i],in[1][i],out[0][i],out[1][i]};
            const auto k=highpass.process(shelf.process(frame));
            partial.power+=frame*frame;
            partial.weighted+=k*k;
            partial.peak=maximum(partial.peak,magnitude(frame));
            if(++frames!=chunkFrames)continue;
            frames=0;
            power+=partial.power-history[head].power;
            weighted+=partial.weighted-history[head].weighted;
            history[head]=partial;
            partial={};
            head=(head+1)%segments;
            filled=std::min(filled+1,segments);
            if(++refresh==10){refresh=0;updated=true;}
        }
        if(updated)result=reading();
        return updated;
    }
    int windowFrames() const {return segments*chunkFrames;}
    MeterReading reading() const {
        MeterReading result;
        result.valid=filled==segments;
        if(!result.valid)return result;
        Signal peak{};
        for(const auto& slice:history)peak=maximum(peak,slice.peak);
        const double samples=windowFrames();
        for(int side=0;side<2;side++){
            const int i=2*side;
            result.db[3*side]=-0.691+energyDb((weighted[i]+weighted[i+1])/samples);
            result.db[3*side+1]=energyDb((power[i]+power[i+1])/(2*samples));
            const double maximum=std::max(peak[i],peak[i+1]);
            result.db[3*side+2]=maximum>1.e-12?20*std::log10(maximum):-240.;
        }
        return result;
    }
};
