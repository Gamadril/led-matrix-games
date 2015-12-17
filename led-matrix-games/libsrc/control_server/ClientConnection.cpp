// system includes
#include <stdexcept>

#include <iostream>
#include <sstream>
#include <Poco/Net/NetException.h>
#include <utils/DelegateArgs.h>

#include "Poco/Base64Decoder.h"
#include "Poco/Net/DNS.h"

#include "ClientConnection.h"

ClientConnection::ClientConnection(Poco::Net::WebSocket *socket) :
        _socket(socket) {
}

ClientConnection::~ClientConnection() {
    _socket->close();
}

int ClientConnection::processRequest() {
    int flags, size = 0;

    try {
        size = _socket->receiveFrame(_receiveBuffer, sizeof(_receiveBuffer), flags);
    } catch (Poco::Net::NetException ex) {
        std::cerr << "[ERROR] Could not receive WebSocket frame: " << ex.displayText() << std::endl;
        return -1;
    } catch (Poco::TimeoutException ex) {
        std::cerr << "[ERROR] WebSocket read timeout" << std::endl;
        return -1;
    }

    if ((flags & Poco::Net::WebSocket::FRAME_OP_BITMASK) == Poco::Net::WebSocket::FRAME_OP_CLOSE) {
        return -1;
    }

    if (size > 0) {
        if ((flags & Poco::Net::WebSocket::FRAME_OP_BITMASK) == Poco::Net::WebSocket::FRAME_OP_PING) {
            _socket->sendFrame(_receiveBuffer, size, Poco::Net::WebSocket::FRAME_OP_PONG);
        } else {
            handleMessage(std::string(_receiveBuffer, size));
        }
    }

    return 0;
}

void ClientConnection::handleMessage(const std::string &messageString) {
    ControlArgs args;
    args.key = messageString;
    controlEvent.notifyAsync(this, args);
}