local rotationTime = 5000
local brightness = 255
local saturation = 255
local reverse = false

-- Check parameters
rotationTime = math.max(100, rotationTime)
brightness = math.max(0, math.min(brightness, 255))
saturation = math.max(0, math.min(saturation, 255))

-- Initialize the led data
local screen = {}
local ledCount = engine.screenWidth * engine.screenHeight
for i = 1, ledCount do
    local hue = (i-1) * 359 / ledCount
    screen[i] = colors.hsv2rgb(hue, saturation, brightness)
end

-- Calculate the sleep time and rotation increment
local increment = 3
local sleepTime = rotationTime / ledCount
while sleepTime < 50 do
    increment = increment * 2
    sleepTime = sleepTime * 2
end
increment = increment % ledCount

function printScreen()
    view = {}
    for i = 1, engine.screenHeight do
        view[i] = {}
        for j = 1, engine.screenWidth do
            view[i][j] = screen[(i-1) * engine.screenWidth + engine.screenWidth]
        end
    end
    engine:setScreen(view)
end

-- Start the write data loop
while not engine:abort() do
    printScreen();
    local key = engine:getKey();
    if key == "a" then
        reverse = not reverse;
    end
    for i = 1, increment do
        local removed
        if reverse == true then
            removed = table.remove(screen, 1)
            table.insert(screen, removed)
        else
            removed = table.remove(screen)
            table.insert(screen, 1, removed)
        end
    end
    engine:sleep(sleepTime)
end

