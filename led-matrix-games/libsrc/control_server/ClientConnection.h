#pragma once

#include <string>

#include "Poco/BasicEvent.h"
#include "Poco/Net/WebSocket.h"
#include "utils/DelegateArgs.h"

class ClientConnection {
public:
    ClientConnection(Poco::Net::WebSocket *socket);

    ~ClientConnection();

    int processRequest();

    Poco::BasicEvent<ControlArgs> controlEvent;

private:
    void handleMessage(const std::string &message);

private:
    Poco::Net::WebSocket *_socket;
    char _receiveBuffer[10];
};
