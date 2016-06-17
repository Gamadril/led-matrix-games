local tools = require("lib.tools")

local demo = {};

demo.brightness = 255
demo.saturation = 255
demo.reverse = false
demo.increment = 3

-- Initialize the led data
demo.screen = {}
demo.ledCount = engine.screenWidth * engine.screenHeight
for i = 1, demo.ledCount do
    local hue = (i - 1) * 359 / demo.ledCount
    demo.screen[i] = colors.hsv2rgb(hue, demo.saturation, demo.brightness)
end


function demo.printScreen()
    local view = {}
    for x = 1, engine.screenWidth do
        view[x] = {}
        for y = 1, engine.screenHeight do
            view[x][y] = demo.screen[(y - 1) * engine.screenWidth + engine.screenWidth]
        end
    end
    engine:setScreen(view)
end

function demo.run()
    -- Start the write data loop
    while not engine:abort() do
        demo.printScreen();
        local key = engine:getKey();
        if key == "a" then
            demo.reverse = not demo.reverse;
        elseif key == "select" then
            break
        end
        for i = 1, demo.increment do
            local removed
            if demo.reverse == true then
                removed = table.remove(demo.screen, 1)
                table.insert(demo.screen, removed)
            else
                removed = table.remove(demo.screen)
                table.insert(demo.screen, 1, removed)
            end
        end
        engine:sleep(50)
    end
end

return demo

