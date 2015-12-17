add_library(game_engine
        Game.cpp
        GameEngine.cpp
        )

target_link_libraries(game_engine
        utils
        lua
        )

if(UNIX AND NOT APPLE)
	target_link_libraries(game_engine pthread)
endif()
