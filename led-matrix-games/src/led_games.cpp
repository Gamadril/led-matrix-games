#include <cassert>
#include <iostream>
#include <utils/DelegateArgs.h>

#include "Poco/Dynamic/Struct.h"
#include "Poco/FileStream.h"
#include "Poco/Path.h"
#include "Poco/File.h"
#include "Poco/Util/ServerApplication.h"
#include "Poco/Util/HelpFormatter.h"
#include "Poco/Util/IniFileConfiguration.h"
#include "Poco/Delegate.h"

#include "control_server/ControlServer.h"
#include "game_engine/GameEngine.h"
#include "led_device/LedDeviceFactory.h"
#include "Display.h"

class LedGamesService : public Poco::Util::ServerApplication {
public:
    LedGamesService()
            : _helpRequested(false) {
    }

    ~LedGamesService() {
    }

protected:
    void initialize(Poco::Util::Application &self) {
        loadConfiguration(); // load default configuration files, if present
        Poco::Util::ServerApplication::initialize(self);
    }

    void defineOptions(Poco::Util::OptionSet &options) {
        Poco::Util::ServerApplication::defineOptions(options);

        options.addOption(Poco::Util::Option("help", "h", "display help information on command line arguments")
                                  .required(false)
                                  .repeatable(false));
    }

    void handleOption(const std::string &name, const std::string &value) {
        Poco::Util::ServerApplication::handleOption(name, value);

        if (name == "help")
            _helpRequested = true;
    }

    void displayHelp() {
        Poco::Util::HelpFormatter helpFormatter(options());
        helpFormatter.setCommand(commandName());
        helpFormatter.setHeader("Led Matrix Games");
        helpFormatter.format(std::cout);
    }

    int main(const std::vector<std::string> &args) {
        if (_helpRequested) {
            displayHelp();
        }
        else {
            Poco::Util::AbstractConfiguration *view;
            Poco::Util::AbstractConfiguration::Keys keys;

            // create LED output device
            view = config().createView("device");
            view->keys(keys);
            Poco::DynamicStruct ledConfig;
            for (auto key : keys) {
                ledConfig[key] = view->getRawString(key);
            }
            _ledDevice = LedDeviceFactory::construct(ledConfig);
            if (_ledDevice == nullptr) {
                std::cerr << "Unable to create Led device: " << view->getString("type") << std::endl;
                return ExitCode::EXIT_SOFTWARE;
            }
            std::cout << "Led device " << view->getString("type") << " created" << std::endl;

            // get generic settings
            view = config().createView("settings");
            uint8_t brightness = (uint8_t) view->getUInt("brightness", 60);
            if (brightness > 100) {
                brightness = 100;
            }
            _ledDevice->setBrightness(brightness);

            // Create game engine
            view = config().createView("games");
            _engine = new GameEngine(DISPLAY_WIDTH, DISPLAY_HEIGHT);
            _engine->setScreenEvent += Poco::delegate(this, &LedGamesService::onNewScreen);
            std::string gamePath = view->getString("path", "games") + Poco::Path::separator() + view->getString("start", "demo") + ".lua";
            Poco::File gameFile(gamePath);
            if (!gameFile.exists()) {
                std::cerr << "Unable to find game file: " << gamePath << std::endl;
                return ExitCode::EXIT_SOFTWARE;
            }
            _engine->runGame(gamePath);
            std::cout << "Game engine created and started with " << gamePath << std::endl;

            // Create control server
            view = config().createView("server");
            uint16_t port = (uint16_t) view->getUInt("port", 37890);
            _controlServer = new ControlServer(port);
            _controlServer->controlEvent += Poco::delegate(this, &LedGamesService::onControl);
            std::cout << "Control server created and started on port " << _controlServer->getPort() << std::endl;

            // wait for CTRL-C or kill
            waitForTerminationRequest();

            _engine->setScreenEvent -= Poco::delegate(this, &LedGamesService::onNewScreen);
            _controlServer->controlEvent -= Poco::delegate(this, &LedGamesService::onControl);
            delete _engine;
            delete _controlServer;
            delete _ledDevice;
        }
        return ExitCode::EXIT_OK;
    }

    void onNewScreen(const void *sender, ScreenArgs &args) {
        _ledDevice->write(*args.screen);
    }

    void onControl(const void *sender, ControlArgs &args) {
        _engine->setPressedKey(args.key);
    }

private:
    bool _helpRequested;
    ControlServer *_controlServer;
    GameEngine *_engine;
    LedDevice *_ledDevice;
};

POCO_SERVER_MAIN(LedGamesService)