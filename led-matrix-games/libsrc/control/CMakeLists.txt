add_library(control
		Gamepad.cpp
)

target_link_libraries(control
		utils
		PocoFoundation
)
