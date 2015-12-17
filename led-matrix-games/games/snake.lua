--------------------------------------------------------------
-- Classic snake game
--
-- 2009 Led Lab @PUC-Rio www.eluaproject.net
-- Dado Sutter
-- Ives Negreiros
-- Téo Benjamin
---------------------------------------------------------------

local xMax = 15
local yMax = 31
local game_map = {}

local Head = {}
local Tail = {}

local highscore = 0
local size = 3
Tail.x = 1
Tail.y = 1
Head.x = Tail.x + (size - 1)
Head.y = Tail.y

local Food = {}
Food.x = false
Food.y = false

Head.dx = 1
Head.dy = 0
Tail.dx = Head.dx
Tail.dy = Head.dy
local direction = "right"
local level = 1
local score = 0

--lm3s.disp.init( 1000000 )

--local kit = require( pd.board() )
local pressed = {}

local foodColor = { 255, 0, 0 }
local snakeColor = { 0, 255, 0 }
local clearColor = { 0, 0, 0 }

local function create_food()
    -- if not food then
    Food.x, Food.y = math.random(xMax - 1), math.random(yMax - 1)
    while game_map[Food.x][Food.y] do
        Food.x, Food.y = math.random(xMax - 1), math.random(yMax - 1)
    end
    game_map[Food.x][Food.y] = "food"
    --    lm3s.disp.print( "@", Food.x * 6, Food.y * 8, 10 )
    engine:setPoint(Food.x, Food.y, foodColor)

    -- end
end

local function eat_food()
    --    lm3s.disp.print( "@", Head.x * 6, Head.y * 8, 0 )
    engine:setPoint(Head.x, Head.y, snakeColor)
    game_map[Head.x][Head.y] = nil
    create_food()
    score = score + level
end

local function check_collision()
    if Head.x <= 0 or Head.x >= xMax then
        return true
    elseif Head.y <= 0 or Head.y >= yMax then
        return true
    elseif ((game_map[Head.x][Head.y]) and (game_map[Head.x][Head.y] ~= "food")) then
        return true
    end
    return false
end

local function move()
    if game_map[Tail.x][Tail.y] == "right" then
        Tail.dx = 1
        Tail.dy = 0
    elseif game_map[Tail.x][Tail.y] == "left" then
        Tail.dx = -1
        Tail.dy = 0
    elseif game_map[Tail.x][Tail.y] == "up" then
        Tail.dx = 0
        Tail.dy = -1
    elseif game_map[Tail.x][Tail.y] == "down" then
        Tail.dx = 0
        Tail.dy = 1
    end
    game_map[Head.x][Head.y] = direction
    Head.x = Head.x + Head.dx
    Head.y = Head.y + Head.dy

    if game_map[Head.x][Head.y] == "food" then
        eat_food()
    else
        --        lm3s.disp.print( "*", Tail.x * 6, Tail.y * 8, 0 )
        engine:setPoint(Tail.x, Tail.y, clearColor)
        game_map[Tail.x][Tail.y] = nil
        Tail.x = Tail.x + Tail.dx
        Tail.y = Tail.y + Tail.dy
    end

    --    lm3s.disp.print( "*", Head.x * 6, Head.y * 8, 10 )
    engine:setPoint(Head.x, Head.y, snakeColor)
end

function init()
    food = false
    --    lm3s.disp.clear()
    engine:clearScreen()
    size = 3
    score = 0
    level = 1
    Tail.x = 1
    Tail.y = 1
    Head.x = Tail.x + (size - 1)
    Head.y = Tail.y
    Head.dx = 1
    Head.dy = 0
    Tail.dx = Head.dx
    Tail.dy = Head.dy
    direction = "right"

    for i = 0, xMax, 1 do
        game_map[i] = {}
    end
    for i = 0, size - 1, 1 do
        game_map[Tail.x + (i * Tail.dx)][Tail.y + (i * Tail.dy)] = direction
        --        lm3s.disp.print( "*", ( Tail.x + ( i * Tail.dx ) ) * 6, ( Tail.y + ( i * Tail.dy ) ) * 8, 10 )
        local sx = Tail.x + (i * Tail.dx)
        local sy = Tail.y + (i * Tail.dy)
        engine:setPoint(sx, sy, snakeColor)
    end
    create_food()
end

--init()
--create_food()

repeat
    init()
    while true do
        local dir = direction
        local key = engine:getKey();
        for i = 1, 1000 - (100 * level), 1 do
            if key == "right" and direction ~= "left" then
                dir = "right"
                Head.dx = 1
                Head.dy = 0
            end
            if key == "left" and direction ~= "right" then
                dir = "left"
                Head.dx = -1
                Head.dy = 0
            end
            if key == "up" and direction ~= "down" then
                dir = "up"
                Head.dx = 0
                Head.dy = -1
            end
            if key == "down" and direction ~= "up" then
                dir = "down"
                Head.dx = 0
                Head.dy = 1
            end
            --[[
                        if button_clicked( kit.BTN_SELECT ) and level < 10 then
                            level = level + 1
                        end
            ]]
        end
        direction = dir
        move()

        if check_collision() then break end

        collectgarbage("collect")
        engine:sleep(400)
    end

    if score > highscore then
        highscore = score
    end

    enough = true
    for i = 1, 100000 do
        local key = engine:getKey();
        if key == "b" then
            enough = false
            break
        end
        engine:sleep(1000)
    end
    --    lm3s.disp.clear()

until (enough)
--lm3s.disp.off()
