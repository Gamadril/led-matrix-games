#pragma once

#include <vector>
#include <iostream>

#include "ColorRgb.h"

class Screen {
public:
    Screen(const int &width, const int &height) {
        this->width = width;
        this->height = height;

        _data = new ColorRgb *[height];
        for (int i = 0; i < height; i++) {
            _data[i] = new ColorRgb[width];
        }
    }

    ~Screen() {
        for (int i = 0; i < height; i++) {
            delete[] _data[i];
        }
        delete[] _data;

        width = 0;
        height = 0;
        _data = NULL;
    }

    ColorRgb get(const int &x, const int &y) const {
        return _data[y][x];
    }

    void set(const int &x, const int &y, const ColorRgb &color) {
        _data[y][x] = color;
    }

    void clear() {
        for (int i = 0; i < height; ++i) {
            for (int j = 0; j < width; ++j) {
                _data[i][j].blue = 0;
                _data[i][j].red = 0;
                _data[i][j].green = 0;
            }
        }
    }

    int width;
    int height;

private:
    ColorRgb **_data;
};