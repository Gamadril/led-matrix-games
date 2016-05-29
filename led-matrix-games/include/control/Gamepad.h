#pragma once

#include "Poco/Runnable.h"
#include "Poco/BasicEvent.h"
#include "utils/DelegateArgs.h"

class Gamepad : public Poco::Runnable {
public:
    Gamepad(const std::string &inputDevice);

    ~Gamepad();

    virtual void run();

    Poco::BasicEvent<ControlArgs> controlEvent;

private:
    const std::string _device;
    int _fd;
    bool _abort;
};