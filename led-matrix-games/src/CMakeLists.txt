#SET(CMAKE_SKIP_BUILD_RPATH TRUE)
#SET(CMAKE_BUILD_WITH_INSTALL_RPATH TRUE)
if(APPLE)
    SET(CMAKE_INSTALL_RPATH "@executable_path/lib")
else()
    SET(CMAKE_INSTALL_RPATH "\$ORIGIN/lib")
endif()
#SET(CMAKE_INSTALL_RPATH_USE_LINK_PATH FALSE)

add_executable(led_games
		led_games.cpp)

target_link_libraries(led_games
		PocoUtil
		PocoFoundation
		game_engine
		led_device
		control_server
		control
)

target_link_libraries(led_games ${CROSS_LIBS})

install(TARGETS led_games RUNTIME DESTINATION .)
