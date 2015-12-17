#pragma once

#include "Poco/Dynamic/Struct.h"

#include "LedDevice.h"

class LedDeviceFactory {
public:
    static LedDevice *construct(const Poco::DynamicStruct &deviceConfig);
};
