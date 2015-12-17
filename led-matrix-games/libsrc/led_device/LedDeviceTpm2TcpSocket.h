#pragma once

#include <string>

#include "TcpSocketDevice.h"

class LedDeviceTpm2TcpSocket : public TcpSocketDevice {
public:
    LedDeviceTpm2TcpSocket(const std::string &address);

    virtual int write(const Screen &ledValues);

    virtual int switchOff();

private:
    /// The buffer containing the packed RGB values
    std::vector<uint8_t> _ledBuffer;
};
