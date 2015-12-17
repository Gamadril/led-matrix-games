add_library(utils
	HsvTransform.cpp
	RgbChannelTransform.cpp
)

target_link_libraries(utils
    PocoFoundation
)

