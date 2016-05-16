#include "led_device/LedDeviceFactory.h"

#include "LedDeviceTpm2Serial.h"
#include "LedDeviceTpm2TcpSocket.h"

LedDevice * LedDeviceFactory::construct(const Poco::DynamicStruct & deviceConfig)
{
    std::cout << "Device configuration: " << ((Poco::DynamicStruct)deviceConfig).toString() << std::endl;

    std::string type = deviceConfig["type"];
    std::transform(type.begin(), type.end(), type.begin(), ::tolower);
    std::string colorOrder = deviceConfig["color_order"];
    std::transform(colorOrder.begin(), colorOrder.end(), colorOrder.begin(), ::tolower);
    std::string ledOrigin = deviceConfig["origin"];
    std::transform(ledOrigin.begin(), ledOrigin.end(), ledOrigin.begin(), ::tolower);
    std::string ledDirection = deviceConfig["direction"];
    std::transform(ledDirection.begin(), ledDirection.end(), ledDirection.begin(), ::tolower);
    std::string ledFlow = deviceConfig["flow"];
    std::transform(ledFlow.begin(), ledFlow.end(), ledFlow.begin(), ::tolower);
    uint8_t ledSegmentWidth = (uint8_t) deviceConfig["segment_width"];

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

    if (device) {
        if (colorOrder == "grb") {
            device->setColorOrder(GRB);
        }

        if (ledOrigin == "topleft") {
            device->setLedOrigin(TopLeft);
        } else if (ledOrigin == "topright") {
            device->setLedOrigin(TopRight);
        } else if (ledOrigin == "bottomleft") {
            device->setLedOrigin(BottomLeft);
        } else if (ledOrigin == "bottomright") {
            device->setLedOrigin(BottomRight);
        }

        if (ledDirection == "left") {
            device->setLedDirection(Left);
        } else if (ledDirection == "right") {
            device->setLedDirection(Right);
        } else if (ledDirection == "up") {
            device->setLedDirection(Up);
        } else if (ledDirection == "down") {
            device->setLedDirection(Down);
        }

        if (ledFlow == "snake") {
            device->setLedFlow(SNAKE);
        } else if (ledFlow == "line") {
            device->setLedFlow(LINE);
        }

        device->setSegmentWidth(ledSegmentWidth);
    }

    return device;
}
