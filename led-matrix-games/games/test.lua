local tools = require("lib.tools")

local ix = 1
local iy = 1
local ledCount = engine.screenWidth * engine.screenHeight

tools.initScreen()
tools.updateScreen()

while not engine:abort() do
	tools.setScreenDot(ix, iy, {255,0,0})
	tools.updateScreen()

	ix = ix + 1
	if ix > engine.screenWidth then
		ix = 1
		iy = iy + 1
		if iy > engine.screenHeight then
			iy = 1
			tools.clearScreen()
			tools.updateScreen()
		end
	end
	engine:sleep(50)
end