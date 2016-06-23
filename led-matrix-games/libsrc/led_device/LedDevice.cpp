#include <led_device/LedDevice.h>

LedDevice::LedDevice() :
        _origin(TopLeft),
        _flow(SNAKE),
        _direction(Right),
        _brightness(30),
        _colorOrder(RGB),
        _leds(NULL) {
}

LedDevice::~LedDevice() {
    if (_leds != NULL) {
        delete[] _leds;
    }
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

// TODO works for even width?
void LedDevice::flip(bool vertical, bool horizontal, const uint16_t &width, const uint16_t &height) {
    Pixel temp;
    for (uint16_t i = 0; i < height * width; i++) {
        temp = _leds[i];
        if (vertical) {
            temp.X = (uint16_t) (width - 1 - temp.X);
        }
        if (horizontal) {
            temp.Y = (uint16_t) (height - 1 - temp.Y);
        }
        _leds[i] = temp;
    }
}

void LedDevice::initLeds(uint8_t width, uint8_t height) {
    _leds = new Pixel[width * height];
    uint8_t segment = 0;
    int index = 0;
    uint16_t ledsPerSegment = _segmentWidth * height;

    for (uint8_t y = 0; y < height; y++) {
        for (uint8_t x = 0; x < width; x++) {
            Pixel point = {X: x, Y: y};
            if (_direction == Right || _direction == Left) {
                segment = x / _segmentWidth;
                if (_flow == LINE) {
                    index = ledsPerSegment * segment + y * _segmentWidth + x % _segmentWidth;
                } else if (_flow == SNAKE) {
                    if (y % 2 == 0) {
                        index = ledsPerSegment * segment + y * _segmentWidth + x % _segmentWidth;
                    } else {
                        index = ledsPerSegment * segment + y * _segmentWidth + _segmentWidth - 1 - (x % _segmentWidth);
                    }
                }
            } else if (_direction == Down || _direction == Up) { // TODO the height of the segment to take into account
                if (_flow == LINE) {
                    index = x * height + y;
                } else if (_flow == SNAKE) {
                    if (x % 2 == 1) {
                        index = x * height + height - 1 - y;
                    } else {
                        index = x * height + y;
                    }
                }
            }
            _leds[index] = point;
        }
    }

    bool flipVertical = _origin == TopRight || _origin == BottomRight;
    bool flipHorizontal = _origin == BottomLeft || _origin == BottomRight;
    flip(flipVertical, flipHorizontal, width, height);
}
