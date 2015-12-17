#include <stdexcept>
#include <iostream>

#include "ClientConnection.h"
#include "control_server/ControlServer.h"

#include "Poco/Net/HTTPRequestHandler.h"
#include "Poco/Net/NetException.h"
#include "Poco/Net/HTTPServerRequest.h"
#include "Poco/Net/HTTPServerResponse.h"
#include "Poco/Delegate.h"

class WebSocketRequestHandler : public Poco::Net::HTTPRequestHandler {
private:
    Poco::BasicEvent<ControlArgs> *_controlEvent;

public:
    WebSocketRequestHandler(Poco::BasicEvent<ControlArgs> *controlEvent) : _controlEvent(controlEvent) {
    }

    void onControl(const void *sender, ControlArgs &args) {
        _controlEvent->notifyAsync(this, args);
    }

    void handleRequest(Poco::Net::HTTPServerRequest &request, Poco::Net::HTTPServerResponse &response) {
        try {
            Poco::Net::WebSocket socket(request, response);

            std::cout << "New connection from " << request.clientAddress().toString() << std::endl;
            ClientConnection connection(&socket);
            connection.controlEvent += Poco::delegate(this, &WebSocketRequestHandler::onControl);

            int result;
            do {
                result = connection.processRequest();
            }
            while (result == 0);
            std::cout << "Connection to " << request.clientAddress().toString() << " closed" << std::endl;
            connection.controlEvent -= Poco::delegate(this, &WebSocketRequestHandler::onControl);
        }
        catch (Poco::Net::WebSocketException &exc) {
            std::cout << exc.what() << std::endl;
            switch (exc.code()) {
                case Poco::Net::WebSocket::WS_ERR_HANDSHAKE_UNSUPPORTED_VERSION:
                    response.set("Sec-WebSocket-Version", Poco::Net::WebSocket::WEBSOCKET_VERSION);
                    // fallthrough
                case Poco::Net::WebSocket::WS_ERR_NO_HANDSHAKE:
                case Poco::Net::WebSocket::WS_ERR_HANDSHAKE_NO_VERSION:
                case Poco::Net::WebSocket::WS_ERR_HANDSHAKE_NO_KEY:
                    response.setStatusAndReason(Poco::Net::HTTPResponse::HTTP_BAD_REQUEST);
                    response.setContentLength(0);
                    response.send();
                    break;
            }
        } catch (const std::exception &e) {
            std::cerr << "[ERROR] handleRequest: " << e.what() << std::endl;
        }
    }
};

class WebSocketRequestHandlerFactory : public Poco::Net::HTTPRequestHandlerFactory {
private:
    Poco::BasicEvent<ControlArgs> *_controlEvent;

public:
    WebSocketRequestHandlerFactory(Poco::BasicEvent<ControlArgs> *controlEvent) : _controlEvent(controlEvent) {
    }

    Poco::Net::HTTPRequestHandler *createRequestHandler(const Poco::Net::HTTPServerRequest &request) {
        return new WebSocketRequestHandler(_controlEvent);
    }
};


ControlServer::ControlServer(uint16_t port) {
    Poco::Net::ServerSocket serverSocket(port);
    _server = new Poco::Net::HTTPServer(new WebSocketRequestHandlerFactory(&this->controlEvent), serverSocket,
                                        new Poco::Net::HTTPServerParams);
    _server->start();
}

ControlServer::~ControlServer() {
    _server->stop();
    delete _server;
}

uint16_t ControlServer::getPort() const {
    return _server->port();
}
