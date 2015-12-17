cmake_minimum_required(VERSION 2.8)
project(serial)

set(serial_SRCS
    src/serial.cc
    include/serial/serial.h
    include/serial/v8stdint.h
)

list(APPEND serial_SRCS src/impl/unix.cc)

add_library(${PROJECT_NAME} ${serial_SRCS})
target_link_libraries(${PROJECT_NAME} rt pthread)

include_directories(include)

install(TARGETS ${PROJECT_NAME}
	DESTINATION lib
)

install(FILES include/serial/serial.h include/serial/v8stdint.h
  DESTINATION serial
)
