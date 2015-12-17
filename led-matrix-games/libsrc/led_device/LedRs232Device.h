#pragma once

#include <serial/serial.h>

#include <led_device/LedDevice.h>

class LedRs232Device : public LedDevice {
public:
    LedRs232Device(const std::string &outputDevice, const uint32_t baudrate);

    virtual ~LedRs232Device();

    int open();

protected:
    int writeBytes(const uint32_t size, const uint8_t *data);

private:
    const std::string _deviceName;
    const uint32_t _baudRate;
    serial::Serial _rs232Port;
};
