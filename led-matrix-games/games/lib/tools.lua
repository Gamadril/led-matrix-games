--- tools module
-- @module tools

require("lib.chars")

local tools = {}

--- init screen with width and height provided by the engine
-- @return screen as table
function tools.initScreen()
    tools.screen = {}
    for x = 1, engine.screenWidth do
        tools.screen[x] = {}
        for y = 1, engine.screenHeight do
            tools.screen[x][y] = { 0, 0, 0 }
        end
    end
    return tools.screen
end

--- clears the screen
function tools.clearScreen()
    for x = 1, engine.screenWidth do
        for y = 1, engine.screenHeight do
            tools.screen[x][y] = { 0, 0, 0 }
        end
    end
end

--- updates the screen
function tools.updateScreen()
    engine:setScreen(tools.screen)
end

--- sets a dot on a screen
-- @param x - X coordinate
-- @param y - Y coordinate
-- @param color - color to set
--
function tools.setScreenDot(x, y, color)
    if x <= engine.screenWidth and x >= 1 and y <= engine.screenHeight and y >= 1 then
        tools.screen[x][y] = color
    end
end

--- prints text at specified coordinates
-- @param value - text to print
-- @param x - X coordinate of the top left corner to start at
-- @param y - Y coordinate of the top left corner to start at
-- @param color - color of text
--
function tools.print(value, x, y, color)
    local chars_count = #tostring(value)
    local len = 0
    for d = 0, chars_count - 1 do
        local c = tostring(value):sub(d + 1, d + 1)
        local l = CHARS[c]
        for dy, col in ipairs(l) do
            for dx, val in ipairs(col) do
                if val == 1 then
                    tools.setScreenDot(len + dx - 1 + x, dy - 1 + y, color)
                end
            end
        end
        len = len + #l[1] + 1
    end
end

--- helper function to print lua variables
-- @param t
--
function tools.print_r(t)
    local print_r_cache = {}
    local function sub_print_r(t, indent)
        if (print_r_cache[tostring(t)]) then
            print(indent .. "*" .. tostring(t))
        else
            print_r_cache[tostring(t)] = true
            if (type(t) == "table") then
                for pos, val in pairs(t) do
                    if (type(val) == "table") then
                        print(indent .. "[" .. pos .. "] => " .. tostring(t) .. " {")
                        sub_print_r(val, indent .. string.rep(" ", string.len(pos) + 8))
                        print(indent .. string.rep(" ", string.len(pos) + 6) .. "}")
                    elseif (type(val) == "string") then
                        print(indent .. "[" .. pos .. '] => "' .. val .. '"')
                    else
                        print(indent .. "[" .. pos .. "] => " .. tostring(val))
                    end
                end
            else
                print(indent .. tostring(t))
            end
        end
    end

    if (type(t) == "table") then
        print(tostring(t) .. " {")
        sub_print_r(t, "  ")
        print("}")
    else
        sub_print_r(t, "  ")
    end
    print()
end

return tools