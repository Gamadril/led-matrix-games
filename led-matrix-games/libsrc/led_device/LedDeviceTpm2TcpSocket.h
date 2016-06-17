#pragma once

#include <string>
#include <vector>

#include "TcpSocketDevice.h"

class LedDeviceTpm2TcpSocket : public TcpSocketDevice {
public:
    LedDeviceTpm2TcpSocket(const std::string &address);

    virtual ~LedDeviceTpm2TcpSocket();

    virtual int write(const Screen &ledValues);

    virtual int switchOff();

private:
    /// The buffer containing the packed RGB values
    std::vector<uint8_t> _ledBuffer;
};
