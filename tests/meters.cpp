#include "../shared/Meter.h"
#include <cstdlib>
#include <cstdio>

// A negative-only impulse on each side exercises the four SIMD lanes and peak magnitude.
// The subsequent steady tones verify the stereo power sum and K-weighting filters.
int main() {
    StereoMeters meters;
    meters.configure(48000);
    constexpr int n=128;
    double left[n],right[n],outL[n],outR[n];
    double* in[]={left,right};
    double* out[]={outL,outR};
    MeterReading reading;
    for (int i=0;i<144000;i+=n) {
        for(int j=0;j<n;j++) {
            const double phase=(i+j)*2.*3.14159265358979323846/48000.;
            left[j]=.1*std::sin(100*phase);
            right[j]=.2*std::sin(1000*phase);
            outL[j]=.3*std::sin(2000*phase);
            outR[j]=.4*std::sin(3000*phase);
        }
        if(i==0){left[0]=-.6;outR[0]=-.9;}
        meters.append(in,out,n,reading);
    }
    if(!reading.valid)return EXIT_FAILURE;
    // Captured with the original Apple SIMD implementation.
    const double expected[]={-16.3230671687,-19.0304655972,-4.4369749923,
                             -6.1650106720,-12.0410043984,-.9151498112};
    for(size_t i=0;i<reading.db.size();++i){
        if(!std::isfinite(reading.db[i]) || std::abs(reading.db[i]-expected[i])>1e-7){
            std::fprintf(stderr,"Meter %zu: expected %.10f, got %.10f\n",i,expected[i],reading.db[i]);
            return EXIT_FAILURE;
        }
    }
    meters.reset();
    if(meters.reading().valid)return EXIT_FAILURE;
    return EXIT_SUCCESS;
}
