#include <fstream>
#include <utils/DelegateArgs.h>

#include "Poco/Dynamic/Var.h"
#include "Poco/File.h"
#include "Poco/Delegate.h"
#include "Poco/Thread.h"

#include "game_engine/GameEngine.h"
#include "Game.h"

GameEngine::GameEngine(const uint32_t screenWidth, const uint32_t screenHeight) :
        _screen(screenWidth, screenHeight) {
}

GameEngine::~GameEngine() {
    _game->abort();
    _game->updateScreenEvent -= Poco::delegate(this, &GameEngine::onUpdateScreen);
    _game->clearScreenEvent -= Poco::delegate(this, &GameEngine::onClearScreen);
    _game->finishedEvent -= Poco::delegate(this, &GameEngine::onGameExit);

    delete _game;
}


int GameEngine::runGame(const std::string &gamePath) {
    _game = new Game(gamePath, _screen);
    _game->updateScreenEvent += Poco::delegate(this, &GameEngine::onUpdateScreen);
    _game->clearScreenEvent += Poco::delegate(this, &GameEngine::onClearScreen);
    _game->finishedEvent += Poco::delegate(this, &GameEngine::onGameExit);

	Poco::ThreadPool::defaultPool().start(*_game);

    return 0;
}

void GameEngine::setPressedKey(std::string &key) {
    _game->setPressedKey(key);
}

void GameEngine::stopGame() {
    _game->abort();
}

void GameEngine::onUpdateScreen(const void *sender) {
    ScreenArgs args;
    args.screen = &_screen;
    setScreenEvent.notifyAsync(this, args);
}

void GameEngine::onClearScreen(const void *sender) {
    _screen.clear();
    ScreenArgs args;
    args.screen = &_screen;
    setScreenEvent.notifyAsync(this, args);
}

void GameEngine::onGameExit(const void *sender) {
    _game->updateScreenEvent -= Poco::delegate(this, &GameEngine::onUpdateScreen);
    _game->clearScreenEvent -= Poco::delegate(this, &GameEngine::onClearScreen);
    _game->finishedEvent -= Poco::delegate(this, &GameEngine::onGameExit);

    delete _game;
}