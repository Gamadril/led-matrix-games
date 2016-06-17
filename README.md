# led-matrix-games
=======================

led-matrix-games is a RPi based system running simple games using a led matrix as display. See for details: [Tetris display](http://www.ledswork.de/wp/2015/09/27/tetris-display-mit-handy-steuerung/)(in German)

The repository contains a build script which will download buildroot and compile the linux system for the Raspberry Pi including the toolchain for crosscompiling the sofware (led-matrix-games folder). The "engine" includes the runtime for the games written in LUA and LED controlling interface. Currently it uses tpm2 protocol and serial device for driving ws2812 based led matrix (16x32). There is also a tpm2net device support which was used for development.
After the start the RPi acts as a WiFi access point providing the open "GAMES" network. After connecting to the network open 192.168.0.1 in the browser to get a "virtual gamepad" to play the game.
Currently the build script compiles an own hostapd version to support rtl8188eu based cards (tested with TL-WN725N). For other cards the build script and hostapd configuration have to be modified. Gamepad/Joystick support was added, but tested only with the XBox 360 USB controller.

The output of the build.sh script is a sdcard image (sdcard.img) which can be flashed to sd card using the usual ways.
For linux use `dd if=./sdcard.img of=/dev/sdX` - replace sdX with the sd card reader device recognized by the system.


3rd party components
--------------------
Poco library: https://github.com/pocoproject/poco

Serial library: https://github.com/wjwwood/serial

Lua: http://www.lua.org/

License
-------
MIT license, see [LICENSE](./LICENSE)
