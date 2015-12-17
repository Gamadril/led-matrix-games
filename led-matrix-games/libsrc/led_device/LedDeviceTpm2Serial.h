#pragma once

#include <string>

#include "LedRs232Device.h"

class LedDeviceTpm2Serial : public LedRs232Device {
public:
    LedDeviceTpm2Serial(const std::string &outputDevice, const uint32_t baudrate);

    virtual int write(const Screen &screen);

    virtual int switchOff();

private:
    std::vector<uint8_t> _ledBuffer;
};
