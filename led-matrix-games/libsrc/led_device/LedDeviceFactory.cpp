#include "led_device/LedDeviceFactory.h"

#include "LedDeviceTpm2Serial.h"
#include "LedDeviceTpm2TcpSocket.h"

LedDevice * LedDeviceFactory::construct(const Poco::DynamicStruct & deviceConfig)
{
    std::cout << "Device configuration: " << ((Poco::DynamicStruct)deviceConfig).toString() << std::endl;

    std::string type = deviceConfig["type"];
    std::transform(type.begin(), type.end(), type.begin(), ::tolower);

    LedDevice* device = nullptr;
	
	if (type == "tpm2ser")
    {
        const std::string output = deviceConfig["output"];
        const unsigned baudrate = deviceConfig["baudrate"];

        LedDeviceTpm2Serial * deviceTpm2 = new LedDeviceTpm2Serial(output, baudrate);
        deviceTpm2->open();
		device = deviceTpm2;
    }

    else if (type == "tpm2tcp")
    {
        const std::string output = deviceConfig["output"];

        LedDeviceTpm2TcpSocket * deviceTpm2 = new LedDeviceTpm2TcpSocket(output);
        deviceTpm2->open();
        device = deviceTpm2;
    }

    else
    {
        std::cout << "Unable to create device " << type << std::endl;
    }

    return device;
}
