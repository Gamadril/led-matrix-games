#pragma once

#include <vector>
#include "ColorRgb.h"

class Screen {
public:
    Screen(const int &width, const int &height) {
        this->width = width;
        this->height = height;

        _data.resize(height);
        for (int i = 0; i < height; i++) {
            _data[i].resize(width);
            for (int j = 0; j < width; j++) {
                _data[i][j] = {};
            }
        }
    }

    ~Screen() {
    }

    ColorRgb get(const int &x, const int &y) const {
        return _data[y][x];
    }

    void set(const int &x, const int &y, const ColorRgb &color) {
        _data[y][x].red = color.red;
        _data[y][x].green = color.green;
        _data[y][x].blue = color.blue;
    }

    std::string toString() {
        std::string result = "";
        for (int i = 0; i < height; i++) {
            for (int j = 0; j < width; j++) {
                if (_data[i][j].red > 0 || _data[i][j].green > 0 || _data[i][j].blue > 0) {
                    result.append("+");
                } else {
                    result.append(" ");
                }
            }
            result.append("\n");
        }
        return result;
    }

    uint8_t width;
    uint8_t height;

private:
    std::vector<std::vector<ColorRgb>> _data;
};