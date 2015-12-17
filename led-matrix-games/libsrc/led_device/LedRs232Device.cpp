#include <cstring>
#include <iostream>

#include <serial/serial.h>

#include "LedRs232Device.h"

LedRs232Device::LedRs232Device(const std::string &outputDevice, const uint32_t baudrate) :
        _deviceName(outputDevice),
        _baudRate(baudrate),
        _rs232Port() {
}

LedRs232Device::~LedRs232Device() {
    if (_rs232Port.isOpen()) {
        _rs232Port.close();
    }
}

int LedRs232Device::open() {
    try {
        std::cout << "Opening UART: " << _deviceName << std::endl;
        _rs232Port.setPort(_deviceName);
        _rs232Port.setBaudrate(_baudRate);
        _rs232Port.open();
    }
    catch (const std::exception &e) {
        std::cerr << "Unable to open RS232 device (" << e.what() << ")" << std::endl;
        return -1;
    }

    return 0;
}

int LedRs232Device::writeBytes(const uint32_t size, const uint8_t *data) {
    static int errorCounter = 0;

    if (!_rs232Port.isOpen()) {
        return -1;
    }

    try {
        _rs232Port.flushOutput();
        _rs232Port.write(data, size);
        _rs232Port.flush();
    }
    catch (const serial::SerialException &serialExc) {
        if (errorCounter < 3) {
            std::cerr << "Serial exception caught while writing to device: " << serialExc.what() << std::endl;
            std::cout << "Attempting to re-open the device." << std::endl;
            errorCounter++;
        }

        // First make sure the device is properly closed
        try {
            _rs232Port.close();
        }
        catch (const std::exception &e) { }

        // Attempt to open the device and write the data
        try {
            _rs232Port.open();
            _rs232Port.write(data, size);
            _rs232Port.flush();
            errorCounter = 0;
        }
        catch (const std::exception &e) {
            // We failed again, this not good, do nothing maybe in the next loop we have more success
        }
    }
    catch (const std::exception &e) {
        std::cerr << "Unable to write to RS232 device (" << e.what() << ")" << std::endl;
        return -1;
    }

    return 0;
}
