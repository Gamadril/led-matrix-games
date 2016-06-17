#pragma once

#include <string>

#include "Poco/Dynamic/Struct.h"
#include "Poco/BasicEvent.h"
#include "Poco/Runnable.h"

#include "utils/DelegateArgs.h"

#include <time.h>

extern "C"
{
#include "lua.h"
#include "lauxlib.h"
#include "lualib.h"
}

class Game : public Poco::Runnable {
public:
    Game(const std::string &script, Screen *screen);

    virtual ~Game();

    virtual void run();

    bool isAbortRequested() const;

    void abort();

    void setPoint(lua_State *state);

    void setScreen(lua_State *state);

    bool shouldFinish();

    std::string getKey();

    void setPressedKey(std::string &key);

    long timeElapsed();

    Poco::BasicEvent<void> finishedEvent;
    Poco::BasicEvent<void> updateScreenEvent;

private:
    void setArgumentsToLua(const Poco::Dynamic::Var &obj, lua_State *state);

private:
    const std::string _script;

    bool _abortRequested;

    Screen *_screen;

    std::string _key;

    struct timespec _start;
};
