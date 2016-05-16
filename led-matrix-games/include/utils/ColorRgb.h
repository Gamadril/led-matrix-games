#pragma once

#include <cstdint>
#include <iostream>

struct ColorRgb
{
    uint8_t red = 0;
    uint8_t green = 0;
    uint8_t blue = 0;

    void applyBrightness(uint8_t value) {
        red = red * value / 100;
        green = green * value / 100;
        blue = blue * value / 100;
    }
};

inline std::ostream& operator<<(std::ostream& os, const ColorRgb& color)
{
    os << "{" << unsigned(color.red) << "," << unsigned(color.green) << "," << unsigned(color.blue) << "}";
    return os;
}
