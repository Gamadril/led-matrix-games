local tools = require("lib.tools")
local currentSelection = 1
local entries = { "TETRIS", "SNAKE", "DEMO" }
local scrollpos = 10
local game

function handle_input()
    local key = engine:getKey() -- Nonblocking; returns nil if no key was pressed.

    if key == nil then return end

    if key == "right" then
        if currentSelection == #entries then
            currentSelection = 1
        else
            currentSelection = currentSelection + 1
        end
        scrollpos = 10
    elseif key == "left" then
        if currentSelection == 1 then
            currentSelection = #entries
        else
            currentSelection = currentSelection - 1
        end
        scrollpos = 10
    elseif key == "a" then
        game = require(entries[currentSelection]:lower())
        game.run()
    end
end

function updateScreen()
    tools.clearScreen()

    tools.print("GAME", 1, 3, { 0, 255, 255 })

    tools.print(entries[currentSelection], scrollpos, 12, { 255, 255, 0 })

    tools.print("<     >", 3, 26, { 255, 0, 0 })

    tools.updateScreen()
end

tools.initScreen()

while true do -- main loop.
handle_input()
updateScreen()
engine:sleep(100)
scrollpos = scrollpos - 1
local charcount = #tostring(entries[currentSelection])
if scrollpos == - charcount * 4 then scrollpos = engine.screenWidth end
end