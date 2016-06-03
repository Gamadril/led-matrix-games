#include <led_device/LedDevice.h>

LedDevice::LedDevice() :
        _origin(TopLeft),
        _flow(SNAKE),
        _direction(Right),
        _brightness(30),
        _colorOrder(RGB),
        _leds(NULL) {
}

void LedDevice::setBrightness(uint8_t brightness) {
    _brightness = brightness;
}

uint8_t LedDevice::getBrightness() {
    return _brightness;
}

void LedDevice::setColorOrder(DeviceColorOrder colorOrder) {
    _colorOrder = colorOrder;
}

void LedDevice::setLedDirection(DeviceLedDirection direction) {
    _direction = direction;
}

void LedDevice::setLedFlow(DeviceLedFlow flow) {
    _flow = flow;
}

void LedDevice::setLedOrigin(DeviceLedOrigin origin) {
    _origin = origin;
}

void LedDevice::setSegmentWidth(uint8_t width) {
    _segmentWidth = width;
}

void LedDevice::initLeds(uint8_t width, uint8_t height) {
    uint16_t ledCount = width * height;
    _leds = new Pixel[ledCount];

    for (uint8_t y = 0; y < height; y++) {
        for (uint8_t x = 0; x < width; x++) {
            if (_origin == TopLeft) {
                if (_direction == Right) {
                    if (x >= _segmentWidth) {

                    } else {
                        if (_flow == LINE) {
                            _leds[y * width + x] = {X: x, Y: y};
                        } else if (_flow == SNAKE) {
                            if (y % 2 == 1) {
                                _leds[y * width + x] = {X: (uint8_t) (width - 1 - x), Y: y};
                            } else {
                                _leds[y * width + x] = {X: x, Y: y};
                            }
                        }
                    }
                }
            }
        }
    }
}
