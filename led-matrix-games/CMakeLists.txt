# Define the main-project name
project(led-matrix-games)

# define the minimum cmake version (as required by cmake)
cmake_minimum_required(VERSION 3.0)

find_package(Git)

include_directories("${PROJECT_BINARY_DIR}")

# Define the global output path of binaries
SET(LIBRARY_OUTPUT_PATH    ${PROJECT_BINARY_DIR}/lib)
SET(EXECUTABLE_OUTPUT_PATH ${PROJECT_BINARY_DIR}/bin)

file(MAKE_DIRECTORY ${LIBRARY_OUTPUT_PATH})
file(MAKE_DIRECTORY ${EXECUTABLE_OUTPUT_PATH})

# Add the project include directory as additional include path
include_directories(${CMAKE_SOURCE_DIR}/dependencies/include)
include_directories(${CMAKE_SOURCE_DIR}/include)

set(CMAKE_BUILD_TYPE "Debug")
#set(CMAKE_BUILD_TYPE "MinSizeRel")

# enable C++11
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=c++0x")

# check if cross compiling
if(NOT ${TARGET_DEVICE} STREQUAL "")
	get_filename_component(TARGET_DEVICE_FOLDER "${CMAKE_SOURCE_DIR}/platforms/${TARGET_DEVICE}" ABSOLUTE)
	include("${TARGET_DEVICE_FOLDER}/build.cmake")
	set(TOOLCHAIN_ARG "-DCMAKE_TOOLCHAIN_FILE=${TARGET_DEVICE_FOLDER}/toolchain.cmake")
endif()

include(ExternalProject)
ExternalProject_Add(poco-lib
    PREFIX "${PROJECT_BINARY_DIR}/external/poco"
    GIT_REPOSITORY "https://github.com/pocoproject/poco.git"
    GIT_TAG "poco-1.6.1"
	INSTALL_DIR ${CMAKE_BINARY_DIR}/poco-lib
	UPDATE_COMMAND ""
    CMAKE_ARGS -DCMAKE_CXX_FLAGS=${CMAKE_CXX_FLAGS} ${TOOLCHAIN_ARG} -DENABLE_JSON=OFF -DENABLE_XML=OFF -DENABLE_MONGODB=OFF -DENABLE_NETSSL=OFF -DENABLE_CRYPTO=OFF -DENABLE_DATA=OFF -DENABLE_DATA_SQLITE=OFF -DENABLE_DATA_MYSQL=OFF -DENABLE_DATA_ODBC=OFF -DENABLE_ZIP=OFF  -DENABLE_PAGECOMPILER=OFF -DENABLE_PAGECOMPILER_FILE2PAGE=OFF -DCMAKE_BUILD_TYPE=MinSizeRel -DCMAKE_INSTALL_PREFIX=<INSTALL_DIR>
)
ExternalProject_Get_Property(poco-lib INSTALL_DIR)
include_directories(${INSTALL_DIR}/include)
link_directories(${INSTALL_DIR}/lib)
install(DIRECTORY ${INSTALL_DIR}/lib DESTINATION . PATTERN "cmake" EXCLUDE)

ExternalProject_Add(serial-lib
     PREFIX "${PROJECT_BINARY_DIR}/external/serial"
     GIT_REPOSITORY "https://github.com/wjwwood/serial.git"
     GIT_TAG "1.1.6"
	 INSTALL_DIR ${CMAKE_BINARY_DIR}/serial-lib
	 UPDATE_COMMAND ""
	 PATCH_COMMAND ${CMAKE_COMMAND} -E copy "${CMAKE_SOURCE_DIR}/patches/serial/CMakeLists.txt" <SOURCE_DIR>/CMakeLists.txt
	 CMAKE_ARGS -DCMAKE_CXX_FLAGS=${CMAKE_CXX_FLAGS} ${TOOLCHAIN_ARG} -DCMAKE_BUILD_TYPE=MinSizeRel -DCMAKE_INSTALL_PREFIX=<INSTALL_DIR>
)
ExternalProject_Get_Property(serial-lib INSTALL_DIR)
include_directories(${INSTALL_DIR})
link_directories(${INSTALL_DIR}/lib)

ExternalProject_Add(lua-lib
     PREFIX "${PROJECT_BINARY_DIR}/external/lua"
	 URL "http://www.lua.org/ftp/lua-5.3.1.tar.gz"
	 URL_MD5 "797adacada8d85761c079390ff1d9961"
	 UPDATE_COMMAND ""
	 PATCH_COMMAND ${CMAKE_COMMAND} -E copy "${CMAKE_SOURCE_DIR}/patches/lua/CMakeLists.txt" <SOURCE_DIR>/CMakeLists.txt
	 INSTALL_DIR ${CMAKE_BINARY_DIR}/lua-lib
	 CMAKE_ARGS -DCMAKE_CXX_FLAGS=${CMAKE_CXX_FLAGS} ${TOOLCHAIN_ARG} -DCMAKE_BUILD_TYPE=MinSizeRel -DCMAKE_INSTALL_PREFIX:PATH=<INSTALL_DIR>
)
ExternalProject_Get_Property(lua-lib INSTALL_DIR)
include_directories("${INSTALL_DIR}/include")
link_directories("${INSTALL_DIR}/lib")

# Add the source/lib directories
add_subdirectory(libsrc)
add_subdirectory(src)

install(DIRECTORY ${PROJECT_SOURCE_DIR}/games DESTINATION .)
install(DIRECTORY ${PROJECT_SOURCE_DIR}/www DESTINATION .)
install(FILES ${PROJECT_SOURCE_DIR}/config/led_games.ini DESTINATION .)

# do packaging
SET(CPACK_PACKAGE_DESCRIPTION_SUMMARY "led-matrix-games project")
SET(CPACK_PACKAGE_VERSION_MAJOR "1")
SET(CPACK_PACKAGE_VERSION_MINOR "0")
SET(CPACK_PACKAGE_VERSION_PATCH "0")
set(CPACK_PACKAGE_FILE_NAME "${CMAKE_PROJECT_NAME}")
SET(CPACK_STRIP_FILES ON)
SET(CPACK_GENERATOR "ZIP")
set(CPACK_PACKAGE_EXECUTABLES "led-matrix-games")
set(CPACK_INCLUDE_TOPLEVEL_DIRECTORY 1)

include(CPack)
