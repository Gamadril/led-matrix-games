#pragma once

#include <cstring>

#include "Screen.h"

typedef struct {
    Screen *screen;
} ScreenArgs;

typedef struct {
    std::string key;
} ControlArgs;