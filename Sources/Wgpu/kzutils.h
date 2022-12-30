#ifndef KZUTILS_H_
#define KZUTILS_H_

#include "webgpu.h"

// This is basically a testing ground to make sure my swift code works

WGPURequiredLimits getReq() {
    return (WGPURequiredLimits) {
        .nextInChain = NULL,
        .limits = (WGPULimits) {
            .maxBindGroups = 1,
        },
    };
}

#endif
