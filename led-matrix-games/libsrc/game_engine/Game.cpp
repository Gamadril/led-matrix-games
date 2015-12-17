#include <iostream>
#include <sstream>
#include <thread>

#include "Poco/Timestamp.h"

#include "Game.h"
#include "utils/HsvTransform.h"

namespace {

    static int lua_setPoint(lua_State *state) {
        Game **game = static_cast<Game **>(luaL_checkudata(state, 1, "GameMT"));
        (*game)->setPoint(state);
        return 0;
    }

    static int lua_setScreen(lua_State *state) {
        Game **game = static_cast<Game **>(luaL_checkudata(state, 1, "GameMT"));
        (*game)->setScreen(state);
        return 0;
    }

    static int lua_clearScreen(lua_State *state) {
        Game **game = static_cast<Game **>(luaL_checkudata(state, 1, "GameMT"));
        (*game)->clearScreen();
        return 0;
    }

    static int lua_abort(lua_State *state) {
        Game **game = static_cast<Game **>(luaL_checkudata(state, 1, "GameMT"));
        bool toAbort = (*game)->shouldFinish();
        lua_pushboolean(state, toAbort);
        return 1;
    }

    static int lua_getKey(lua_State *state) {
        Game **game = static_cast<Game **>(luaL_checkudata(state, 1, "GameMT"));
        std::string key = (*game)->getKey();
        lua_pushstring(state, key.c_str());
        return 1;
    }

    static int lua_sleep(lua_State *state) {
        int ms = static_cast<int> (luaL_checknumber(state, 2));
        std::this_thread::sleep_for(std::chrono::milliseconds{ms});
        return 0;
    }

    static int lua_rgb_to_hsv(lua_State *state) {
        uint16_t h;
        uint8_t s, v,
                r = static_cast<uint8_t> (luaL_checknumber(state, 1)),
                g = static_cast<uint8_t> (luaL_checknumber(state, 2)),
                b = static_cast<uint8_t> (luaL_checknumber(state, 3));

        HsvTransform::rgb2hsv(r, g, b, h, s, v);

        lua_newtable(state);

        lua_pushinteger(state, 1);
        lua_pushinteger(state, h);
        lua_settable(state, -3);

        lua_pushinteger(state, 2);
        lua_pushinteger(state, s);
        lua_settable(state, -3);

        lua_pushinteger(state, 3);
        lua_pushinteger(state, v);
        lua_settable(state, -3);

        return 1;
    }


    /**
     * Convert HSV value to RGB
     * H [0..359]
     * S [0..255]
     * V [0..255]
     */
    static int lua_hsv_to_rgb(lua_State *state) {
        uint16_t h = static_cast<uint16_t> (luaL_checknumber(state, 1));
        uint8_t r, g, b,
                s = static_cast<uint8_t> (luaL_checknumber(state, 2)),
                v = static_cast<uint8_t> (luaL_checknumber(state, 3));

        HsvTransform::hsv2rgb(h, s, v, r, g, b);

        lua_newtable(state);

        lua_pushinteger(state, 1);
        lua_pushinteger(state, r);
        lua_settable(state, -3);

        lua_pushinteger(state, 2);
        lua_pushinteger(state, g);
        lua_settable(state, -3);

        lua_pushinteger(state, 3);
        lua_pushinteger(state, b);
        lua_settable(state, -3);

        return 1;
    }




void stackdump_g(lua_State* l)
{
    int i;
    int top = lua_gettop(l);

    printf("total in stack %d\n",top);

    for (i = 1; i <= top; i++)
    {
        int t = lua_type(l, i);
        switch (t) {
            case LUA_TSTRING:  
                printf("string: '%s'\n", lua_tostring(l, i));
                break;
            case LUA_TBOOLEAN:  
                printf("boolean %s\n",lua_toboolean(l, i) ? "true" : "false");
                break;
            case LUA_TNUMBER:  
                printf("number: %g\n", lua_tonumber(l, i));
                break;
            default:  
                printf("%s\n", lua_typename(l, t));
                break;
        }
        printf("  "); 
    }
    printf("\n"); 
}

}

Game::Game(const std::string &script, Screen &screen) :
        _script(script),
        _abortRequested(false),
        _screen(screen),
        _key("") {
}

Game::~Game() {
}

void Game::setPressedKey(std::string &key) {
    _key = key;
}

void Game::setPoint(lua_State *state) {
    // check if we have aborted already
    if (shouldFinish()) {
        return;
    }

    // check the number of arguments
    if (lua_gettop(state) == 4 && lua_istable(state, -1)) {
        // x, y + 3 seperate arguments for red, green, and blue
        uint32_t x = (uint32_t) luaL_checkinteger(state, 2);
        uint32_t y = (uint32_t) luaL_checkinteger(state, 3);
        ColorRgb color;

        lua_rawgeti(state, -1, 1);
        color.red = (uint8_t) luaL_checkinteger(state, -1);
        lua_pop(state, 1);

        lua_rawgeti(state, -1, 2);
        color.green = (uint8_t) luaL_checkinteger(state, -1);
        lua_pop(state, 1);

        lua_rawgeti(state, -1, 3);
        color.blue = (uint8_t) luaL_checkinteger(state, -1);
        lua_pop(state, 1);

        //lua_pop(state, 1);
        //lua_pop(state, 1);

        _screen.set(x, y, color);
        updateScreenEvent.notify(this);
    }
}

void Game::setScreen(lua_State *state) {
    // check if we have aborted already
    if (shouldFinish()) {
        return;
    }

    if (lua_istable(state, 2)) {

        lua_len(state, -1);
        unsigned count = (unsigned) luaL_checkinteger(state, -1);
        lua_pop(state, 1);

        if (count == unsigned(_screen.height)) {
            uint32_t x, y;
            ColorRgb color;
            for (unsigned i = 0; i < _screen.height; i++) {
                lua_rawgeti(state, -1, i + 1);

                lua_len(state, -1);
                count = (unsigned) luaL_checkinteger(state, -1);
                lua_pop(state, 1);

                if (count == unsigned(_screen.width)) {
                    for(unsigned j = 0; j < _screen.width; j++) {
                        lua_rawgeti(state, -1, j + 1);

                        if (!lua_istable(state, -1))
                        {
                            std::cerr << "[Game] screen dots does not contain color information" << std::endl;
                            break;
                        }
                        lua_rawgeti(state, -1, 1);
                        color.red = (uint8_t) luaL_checkinteger(state, -1);
                        lua_pop(state, 1);

                        lua_rawgeti(state, -1, 2);
                        color.green = (uint8_t) luaL_checkinteger(state, -1);
                        lua_pop(state, 1);

                        lua_rawgeti(state, -1, 3);
                        color.blue = (uint8_t) luaL_checkinteger(state, -1);
                        lua_pop(state, 1);

                        lua_pop(state, 1);
                        _screen.set(j, i, color);
                    }
                }
                else {
                    std::cerr << "[Effect] screen size does not match size of received table" << std::endl;
                }
                lua_pop(state, 1);
            }

            updateScreenEvent.notifyAsync(this);
        }
        else {
            std::cerr << "[Effect] screen size does not match size of received table" << std::endl;
        }
    }
}

void Game::run() {
    // create new Lua state
    lua_State *L = luaL_newstate();
    luaL_openlibs(L);

    luaL_newmetatable(L, "GameMT");
    lua_pushvalue(L, -1);
    lua_setfield(L, -2, "__index");
    lua_pushcfunction(L, lua_setPoint);
    lua_setfield(L, -2, "setPoint");
    lua_pushcfunction(L, lua_setScreen);
    lua_setfield(L, -2, "setScreen");
    lua_pushcfunction(L, lua_clearScreen);
    lua_setfield(L, -2, "clearScreen");
    lua_pushcfunction(L, lua_abort);
    lua_setfield(L, -2, "abort");
    lua_pushcfunction(L, lua_sleep);
    lua_setfield(L, -2, "sleep");
    lua_pushcfunction(L, lua_getKey);
    lua_setfield(L, -2, "getKey");

    // screen dimensions
    lua_pushinteger(L, _screen.width);
    lua_setfield(L, -2, "screenWidth");
    lua_pushinteger(L, _screen.height);
    lua_setfield(L, -2, "screenHeight");

    Game **ud = static_cast<Game **>(lua_newuserdata(L, sizeof(Game *)));
    *(ud) = this;
    luaL_setmetatable(L, "GameMT");
    lua_setglobal(L, "engine");

    luaL_newmetatable(L, "GameMT");
    lua_pushcfunction(L, lua_rgb_to_hsv);
    lua_setfield(L, -2, "rgb2hsv");
    lua_pushcfunction(L, lua_hsv_to_rgb);
    lua_setfield(L, -2, "hsv2rgb");
    luaL_setmetatable(L, "GameMT");
    lua_setglobal(L, "colors");

    lua_settop(L, 0); //empty the lua stack
    if (luaL_dofile(L, _script.c_str())) {
        fprintf(stderr, "error: %s\n", lua_tostring(L, -1));
        lua_pop(L, 1);
    }

    // close the Lua state
    lua_close(L);

    finishedEvent.notifyAsync(this);
}

void Game::clearScreen() {
    clearScreenEvent.notifyAsync(this);
}

bool Game::isAbortRequested() const {
    return _abortRequested;
}

bool Game::shouldFinish() {
    return _abortRequested;
}

std::string Game::getKey() {
    if (_key != "") {
        std::string key = _key;
        _key = "";
        return key;
    }
    return "";
}


void Game::abort() {
    _abortRequested = true;
}

void Game::setArgumentsToLua(const Poco::Dynamic::Var &obj, lua_State *state) {
    //std::cout << obj.toString() << std::endl;

    if (obj.isEmpty())
        return;

    if (obj.isNumeric()) {
        lua_pushnumber(state, obj.convert<double>());
    }
    else if (obj.isInteger()) {
        lua_pushinteger(state, obj.convert<int>());
    }
    else if (obj.isBoolean()) {
        lua_pushboolean(state, obj.convert<bool>());
    }
    else if (obj.isString()) {
        lua_pushstring(state, obj.toString().c_str());
    }
    else if (obj.isStruct()) {
        lua_newtable(state);
        Poco::DynamicStruct str = obj.extract<Poco::DynamicStruct>();
        for (auto name : str.members()) {
            setArgumentsToLua(str[name], state);
            lua_setfield(state, -2, name.c_str());
        }
    }
    else if (obj.isArray()) {
        lua_newtable(state);
        for (unsigned i = 0; i < obj.size(); i++) {
            lua_pushinteger(state, i + 1); // lua's index starts at 1
            setArgumentsToLua(obj[i], state);
            lua_settable(state, -3);
        }
    }
}
