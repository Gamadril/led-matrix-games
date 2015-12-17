#pragma once

#include "Poco/BasicEvent.h"
#include "Poco/Net/HTTPServer.h"
#include "utils/DelegateArgs.h"

class ControlServer {
public:
    ControlServer(uint16_t port);

    ~ControlServer();

    uint16_t getPort() const;

    Poco::BasicEvent<ControlArgs> controlEvent;

private:
    /// The TCP server object
    Poco::Net::HTTPServer *_server;
};
