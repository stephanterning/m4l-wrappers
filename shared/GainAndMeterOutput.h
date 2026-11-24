#pragma once
#include "ext.h"
#include "Meter.h"
#include <atomic>

struct GainRamp {
    std::atomic<double> target{1};
    double gain=1, previous=1, step=0;
    int remaining=0;
    void update(double desired,int frames){
        if(desired==previous)return;
        previous=desired;remaining=frames;step=(desired-gain)/frames;
    }
    double next(){
        if(remaining){gain=--remaining?gain+step:previous;}
        return gain;
    }
    bool unity() const {return gain==1&&previous==1;}
};

struct MeterMailbox {
    std::atomic<unsigned> serial{0};
    std::atomic<long> epoch{0};
    std::atomic<bool> valid{false}, settled{false};
    std::array<std::atomic<double>,6> value{};
    unsigned reported=0;

    void publish(long token,const MeterReading& reading,bool matchReady){
        serial.fetch_add(1,std::memory_order_acq_rel);
        epoch.store(token,std::memory_order_relaxed);
        valid.store(reading.valid,std::memory_order_relaxed);
        settled.store(matchReady,std::memory_order_relaxed);
        for(int i=0;i<6;i++)value[i].store(reading.db[i],std::memory_order_relaxed);
        serial.fetch_add(1,std::memory_order_release);
    }
    bool receive(t_atom* values){
        const auto version=serial.load(std::memory_order_acquire);
        if((version&1)||version==reported)return false;
        atom_setlong(values,epoch.load(std::memory_order_relaxed));
        atom_setlong(values+1,valid.load(std::memory_order_relaxed));
        atom_setlong(values+2,settled.load(std::memory_order_relaxed));
        for(int i=0;i<6;i++)atom_setfloat(values+3+i,value[i].load(std::memory_order_relaxed));
        if(serial.fetch_add(0,std::memory_order_acq_rel)!=version)return false;
        reported=version;return true;
    }
};
