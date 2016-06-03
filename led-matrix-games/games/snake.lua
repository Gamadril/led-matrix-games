local colors = { border = { 255, 255, 255 }, empty = { 0, 0, 0 }, food = { 255, 0, 0 }, body = { 0, 255, 0 }, head = { 255, 255, 0 } }
local game_state = 'playing' -- 'paused' or 'over'
local screen = {}
local board_size = { x = 14, y = 20 }
local snake
local lastTimestamp

local Food = {}

local direction
local score = 0

local numbers = {
    [0] = {
        { 1, 1, 1 },
        { 1, 0, 1 },
        { 1, 0, 1 },
        { 1, 0, 1 },
        { 1, 1, 1 }
    },
    {
        { 0, 1, 0 },
        { 1, 1, 0 },
        { 0, 1, 0 },
        { 0, 1, 0 },
        { 1, 1, 1 }
    },
    {
        { 1, 1, 1 },
        { 0, 0, 1 },
        { 1, 1, 1 },
        { 1, 0, 0 },
        { 1, 1, 1 }
    },
    {
        { 1, 1, 1 },
        { 0, 0, 1 },
        { 0, 1, 1 },
        { 0, 0, 1 },
        { 1, 1, 1 }
    },
    {
        { 1, 0, 1 },
        { 1, 0, 1 },
        { 1, 1, 1 },
        { 0, 0, 1 },
        { 0, 0, 1 }
    },
    {
        { 1, 1, 1 },
        { 1, 0, 0 },
        { 1, 1, 1 },
        { 0, 0, 1 },
        { 1, 1, 1 }
    },
    {
        { 1, 1, 1 },
        { 1, 0, 0 },
        { 1, 1, 1 },
        { 1, 0, 1 },
        { 1, 1, 1 }
    },
    {
        { 1, 1, 1 },
        { 0, 0, 1 },
        { 0, 1, 0 },
        { 0, 1, 0 },
        { 0, 1, 0 }
    },
    {
        { 1, 1, 1 },
        { 1, 0, 1 },
        { 1, 1, 1 },
        { 1, 0, 1 },
        { 1, 1, 1 }
    },
    {
        { 1, 1, 1 },
        { 1, 0, 1 },
        { 1, 1, 1 },
        { 0, 0, 1 },
        { 1, 1, 1 }
    }
}

function print_r(t)
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

function contains_coordinate(table, coordinate)
    for _, value in ipairs(table) do
        if coordinate.x == value.x and coordinate.y == value.y then
            return true
        end
    end
    return false
end

function call_fn_for_xy_in_numbers(number, callback)
    local digits_count = #tostring(number)
    for d = 0, digits_count - 1 do
        local c = tostring(number):sub(d + 1, d + 1)
        local l = numbers[tonumber(c)]
        for y, col in ipairs(l) do
            for x, val in ipairs(col) do
                callback(d * 4 + x, y, val)
            end
        end
    end
end


local function create_food()
    Food.x, Food.y = math.random(board_size.x), math.random(board_size.y)
    while contains_coordinate(snake, Food) do
        Food.x, Food.y = math.random(board_size.x), math.random(board_size.y)
    end
end

local function eat_food()
    create_food()
    score = score + 1
end

local function check_collision(coordinate)
    if coordinate.x == 0 or coordinate.x == board_size.x + 1 then
        return true
    elseif coordinate.y == 0 or coordinate.y == board_size.y + 1 then
        return true
    elseif contains_coordinate(snake, coordinate) then
        return true
    end
    return false
end

local function move()
    local head = snake[1]
    local next
    if direction == "right" then
        next = { x = head.x + 1, y = head.y }
    elseif direction == "left" then
        next = { x = head.x - 1, y = head.y }
    elseif direction == "up" then
        next = { x = head.x, y = head.y - 1 }
    elseif direction == "down" then
        next = { x = head.x, y = head.y + 1 }
    end

    if check_collision(next) then
        return false
    end

    if Food.x == next.x and Food.y == next.y then
        eat_food()
    else
        table.remove(snake)
    end

    table.insert(snake, 1, next)

    return true
end

function init()
    -- init screen
    for y = 1, engine.screenHeight do
        screen[y] = {}
        for x = 1, engine.screenWidth do
            screen[y][x] = colors.empty
        end
    end

    score = 0
    direction = 'right'
    snake = { { x = 3, y = 1 }, { x = 2, y = 1 }, { x = 1, y = 1 } }
    create_food()
    lastTimestamp = os.clock()
end

function handle_input()
    local key = engine:getKey() -- Nonblocking; returns nil if no key was pressed.

    if key == nil then return end

    if key == "b" then
        if game_state == 'playing' then
            game_state = 'paused'
        elseif game_state == 'paused' then
            game_state = 'playing'
        end
        do return end
    end

    if game_state ~= 'playing' then return end

    if key == "right" and direction ~= "left" then
        direction = "right"
    end
    if key == "left" and direction ~= "right" then
        direction = "left"
    end
    if key == "up" and direction ~= "down" then
        direction = "up"
    end
    if key == "down" and direction ~= "up" then
        direction = "down"
    end
end

function draw_screen()
    -- clear the board and draw the board's border
    for x = 0, board_size.x + 1 do
        for y = 0, board_size.y + 1 do
            if x == 0 or y == 0 or x == board_size.x + 1 or y == board_size.y + 1 then
                screen[y + 1][x + 1] = colors.border
            else
                screen[y + 1][x + 1] = colors.empty
            end
        end
    end

    -- draw the snake
    for index, value in ipairs(snake) do
        if index == 1 then
            screen[value.y + 1][value.x + 1] = colors.head
        else
            screen[value.y + 1][value.x + 1] = colors.body
        end
    end

    -- draw food
    screen[Food.y + 1][Food.x + 1] = colors.food

    -- draw score
    call_fn_for_xy_in_numbers(score, function(lx, ly, val)
        if val > 0 then
            screen[board_size.y + 5 + ly][2 + lx] = colors.body
        else
            screen[board_size.y + 5 + ly][2 + lx] = colors.empty
        end
    end)

    engine:setScreen(screen)
end

function main()
    init()

    while true do -- main loop.
    if game_state == 'over' then
        local key = engine:getKey()
        if key == "a" then
            init()
            game_state = 'playing'
        end
    elseif game_state == 'paused' then
        handle_input()
        local timestamp = os.clock()
        if timestamp - lastTimestamp > 0.5 then
            engine:clearScreen()
            lastTimestamp = timestamp
        else
            draw_screen()
        end
    else
        handle_input()
        local timestamp = os.clock()
        if timestamp - lastTimestamp > 0.2 then
            if not move() then game_state = 'over' end
            lastTimestamp = timestamp
            draw_screen()
        end
    end
    engine:sleep(50);
    end
end

main()
