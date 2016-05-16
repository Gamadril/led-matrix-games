add_library(led_device
        LedDeviceFactory.cpp
        LedDeviceTpm2TcpSocket.cpp
        LedDeviceTpm2Serial.cpp
        LedRs232Device.cpp
        TcpSocketDevice.cpp
        LedDevice.cpp)

target_link_libraries(led_device
        utils
        serial
        PocoNet
        )

if (UNIX)
    target_link_libraries(led_device pthread)
endif ()
