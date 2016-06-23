#pragma once

#include "utils/Screen.h"

struct Pixel {
    uint16_t X;
    uint16_t Y;
};

enum DeviceColorOrder {
    RGB,
    GRB
};

enum DeviceLedOrigin {
    TopLeft,
    TopRight,
    BottomLeft,
    BottomRight
};

enum DeviceLedDirection {
    Right,
    Left,
    Up,
    Down
};

enum DeviceLedFlow {
    SNAKE,
    LINE
};

class LedDevice {
public:
    LedDevice();

    virtual ~LedDevice();

    virtual int write(const Screen &ledValues) = 0;

    virtual int switchOff() = 0;

    void setBrightness(uint8_t brightness);

    uint8_t getBrightness();

    void setColorOrder(DeviceColorOrder colorOrder);

    void setLedOrigin(DeviceLedOrigin origin);

    void setLedDirection(DeviceLedDirection direction);

    void setLedFlow(DeviceLedFlow flow);

    void setSegmentWidth(uint8_t width);

protected:
    void initLeds(uint8_t width, uint8_t height);

private:
    void flip(bool vertical, bool horizontal, const uint16_t &width, const uint16_t &height);

protected:
    uint8_t _brightness;
    DeviceColorOrder _colorOrder;
    DeviceLedOrigin _origin;
    DeviceLedDirection _direction;
    DeviceLedFlow _flow;

    uint8_t _segmentWidth;
    Pixel *_leds;

};
