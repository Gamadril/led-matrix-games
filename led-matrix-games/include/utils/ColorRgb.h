#pragma once

#include <cstdint>
#include <iostream>

struct ColorRgb
{
    uint8_t red = 0;
    uint8_t green = 0;
    uint8_t blue = 0;
};

inline std::ostream& operator<<(std::ostream& os, const ColorRgb& color)
{
    os << "{" << unsigned(color.red) << "," << unsigned(color.green) << "," << unsigned(color.blue) << "}";
    return os;
}
