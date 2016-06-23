#include <stdio.h>
#include <fcntl.h>
#include <unistd.h>
#include <sys/ioctl.h>
#include <linux/joystick.h>
#include <utils/DelegateArgs.h>

#include "control/Gamepad.h"

Gamepad::Gamepad(const std::string &inputDevice) :
        _device(inputDevice),
        _fd(-1),
        _abort(false) {
}

void Gamepad::run() {
    struct js_event jse;
    std::cout << "Gamepad thread started" << std::endl;

    while (!_abort) {
        if (_fd == -1) {
            _fd = open(_device.c_str(), O_RDONLY | O_NONBLOCK);

            if (_fd >= 0) {
                int32_t naxis = 0;
                int32_t nbuttons = 0;
                char name[128];

                ioctl(_fd, JSIOCGAXES, &naxis);
                ioctl(_fd, JSIOCGBUTTONS, &nbuttons);
                ioctl(_fd, JSIOCGNAME(sizeof(name)), &name);

                std::cout << "Gamepad detected: " << name << std::endl;
                std::cout << "Number of axis: " << naxis << std::endl;
                std::cout << "Number of buttons: " << nbuttons << std::endl;
            } else {
                Poco::Thread::sleep(2000);
                continue;
            }
        }


        // TODO tested and works probably only with the USB XBOX 360 controller
        while (read(_fd, &jse, sizeof(jse)) > 0) {
            switch (jse.type & ~JS_EVENT_INIT) {
                case JS_EVENT_AXIS:
                    if (jse.number == 6) {
                        ControlArgs args;
                        if (jse.value < 0) {
                            args.key = "left";
                            controlEvent.notifyAsync(this, args);
                        } else if (jse.value > 0) {
                            args.key = "right";
                            controlEvent.notifyAsync(this, args);
                        }
                    } else if (jse.number == 7) {
                        ControlArgs args;
                        if (jse.value < 0) {
                            args.key = "up";
                            controlEvent.notifyAsync(this, args);
                        } else if (jse.value > 0) {
                            args.key = "down";
                            controlEvent.notifyAsync(this, args);
                        }
                    }
                    break;
                case JS_EVENT_BUTTON:
                    if (jse.value == 1) {
                        ControlArgs args;
                        if (jse.number == 4) {
                            args.key = "bright_minus";
                        } else if (jse.number == 5) {
                            args.key = "bright_plus";
                        } else if (jse.number == 6) {
                            args.key = "select";
                        } else {
                            if (jse.number % 2 == 0) {
                                args.key = "a";
                            } else {
                                args.key = "b";
                            }
                        }
                        controlEvent.notifyAsync(this, args);
                    }
                    break;
                default:
                    break;
            }
        }
    }
}

Gamepad::~Gamepad() {
    if (_fd != -1) {
        close(_fd);
    }
}