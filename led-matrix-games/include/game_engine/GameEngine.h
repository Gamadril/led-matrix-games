#pragma once

#include "Poco/BasicEvent.h"
#include "Poco/Dynamic/Struct.h"
#include "Poco/Path.h"

#include "utils/DelegateArgs.h"

class Game;

class GameEngine {
public:
    GameEngine(const uint32_t screenWidth, const uint32_t screenHeight);

    virtual ~GameEngine();

    int runGame(const std::string &gamePath);

    void stopGame();

    void setPressedKey(std::string &key);

    Poco::BasicEvent<ScreenArgs> setScreenEvent;

protected:
    void onGameExit(const void *sender);
    void onUpdateScreen(const void *sender);
    void onClearScreen(const void *sender);

private:
    Game *_game;
    Screen _screen;
};
