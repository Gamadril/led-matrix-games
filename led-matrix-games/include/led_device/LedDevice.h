#pragma once

#include "utils/Screen.h"

class LedDevice {
public:
    virtual ~LedDevice() {
        // empty
    }

    virtual int write(const Screen &ledValues) = 0;
    virtual int switchOff() = 0;
};
