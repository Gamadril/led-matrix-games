#include "LedDeviceTpm2Serial.h"

LedDeviceTpm2Serial::LedDeviceTpm2Serial(const std::string &outputDevice, const unsigned baudrate) :
        LedRs232Device(outputDevice, baudrate),
        _ledBuffer(0) {
}

LedDeviceTpm2Serial::~LedDeviceTpm2Serial(){
    switchOff();
}

int LedDeviceTpm2Serial::write(const Screen &screen) {
    if (_leds == NULL) {
        initLeds(screen.width, screen.height);
    }

    uint8_t rOffset = 0, gOffset = 1, bOffset = 2;
    if (_colorOrder == GRB) {
        gOffset = 0;
        rOffset = 1;
    }
    if (_ledBuffer.size() == 0) {
        uint32_t count = (uint32_t) (screen.width * screen.height * 3);
        _ledBuffer.resize(5 + count);
        _ledBuffer[0] = 0xC9; // block-start byte
        _ledBuffer[1] = 0xDA; // DATA frame
        _ledBuffer[2] = (uint8_t) ((count >> 8) & 0xFF); // frame size high byte
        _ledBuffer[3] = (uint8_t) (count & 0xFF); // frame size low byte
        _ledBuffer.back() = 0x36; // block-end byte
    }

    // write data
    ColorRgb color;
    uint32_t index = 0;
    Pixel pos;
    for (int y = 0; y < screen.height; y++) {
        for (int x = 0; x < screen.width; x++) {
            pos = _leds[y * screen.width + x];
            color = screen.get(pos.X, pos.Y);
            color.applyBrightness(_brightness);

            _ledBuffer[4 + index + rOffset] = color.red;
            _ledBuffer[4 + index + gOffset] = color.green;
            _ledBuffer[4 + index + bOffset] = color.blue;
            index += 3;
        }
    }
    return writeBytes((const uint32_t) _ledBuffer.size(), _ledBuffer.data());
}

int LedDeviceTpm2Serial::switchOff() {
    memset(4 + _ledBuffer.data(), 0, _ledBuffer.size() - 5);
    return writeBytes((const uint32_t) _ledBuffer.size(), _ledBuffer.data());
}
