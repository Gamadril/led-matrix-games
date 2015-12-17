add_library(control_server
		ControlServer.cpp
		ClientConnection.cpp
)

target_link_libraries(control_server
		utils
		PocoFoundation
		PocoNet
)
