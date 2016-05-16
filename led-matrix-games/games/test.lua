local screen = {}
local ix = 1
local iy = 1
local ledCount = engine.screenWidth * engine.screenHeight
for y = 1, engine.screenHeight do
    screen[y] = {}
    for x = 1, engine.screenWidth do
        screen[y][x] = { 0, 0, 0 }
    end
end

function printScreen()
    engine:setScreen(screen)
end
printScreen()

while not engine:abort() do
	screen[iy][ix] = {255,0,0}
	printScreen()
	ix = ix + 1
	if ix > engine.screenWidth then
		ix = 1
		iy = iy + 1
		if iy > engine.screenHeight then
			iy = 1
		end
	end
	engine:sleep(100)
end