local tools = require("lib.tools")

local snake = {}
snake.colors = { border = { 255, 255, 255 }, empty = { 0, 0, 0 }, food = { 255, 0, 0 }, body = { 0, 255, 0 }, head = { 255, 255, 0 } }
snake.board_size = { x = 14, y = 20 }

local function contains_coordinate(table, coordinate)
    for _, value in ipairs(table) do
        if coordinate.x == value.x and coordinate.y == value.y then
            return true
        end
    end
    return false
end

local function create_food()
    snake.food.x, snake.food.y = math.random(snake.board_size.x), math.random(snake.board_size.y)
    while contains_coordinate(snake.snake, snake.food) do
        snake.food.x, snake.food.y = math.random(snake.board_size.x), math.random(snake.board_size.y)
    end
end

local function eat_food()
    create_food()
    snake.score = snake.score + 1
    if snake.score % 10 == 0 then snake.speed = snake.speed + 1 end
end

local function check_collision(coordinate)
    if coordinate.x == 0 or coordinate.x == snake.board_size.x + 1 then
        return true
    elseif coordinate.y == 0 or coordinate.y == snake.board_size.y + 1 then
        return true
    elseif contains_coordinate(snake.snake, coordinate) then
        return true
    end
    return false
end

local function move()
    local head = snake.snake[1]
    local next
    if snake.direction == "right" then
        next = { x = head.x + 1, y = head.y }
    elseif snake.direction == "left" then
        next = { x = head.x - 1, y = head.y }
    elseif snake.direction == "up" then
        next = { x = head.x, y = head.y - 1 }
    elseif snake.direction == "down" then
        next = { x = head.x, y = head.y + 1 }
    end

    if check_collision(next) then
        return false
    end

    if snake.food.x == next.x and snake.food.y == next.y then
        eat_food()
    else
        table.remove(snake.snake)
    end

    table.insert(snake.snake, 1, next)

    return true
end

local function init()
    tools.initScreen()

    snake.snake = { { x = 3, y = 1 }, { x = 2, y = 1 }, { x = 1, y = 1 } }
    snake.game_state = 'playing' -- 'paused' or 'over'
    snake.lastTimestamp = engine:time()
    snake.speed = 0
    snake.food = {}
    create_food()
    snake.direction = "right"
    snake.score = 0
    snake.exit = false
end

local function handle_input()
    local key = engine:getKey() -- Nonblocking; returns nil if no key was pressed.

    if key == nil then return end

    if key == "select" then
        snake.exit = true
        do return end
    end

    if key == "b" then
        if snake.game_state == 'playing' then
            snake.game_state = 'paused'
        elseif snake.game_state == 'paused' then
            snake.game_state = 'playing'
        end
        do return end
    end

    if snake.game_state ~= 'playing' then return end

    if key == "right" and snake.direction ~= "left" then
        snake.direction = "right"
    end
    if key == "left" and snake.direction ~= "right" then
        snake.direction = "left"
    end
    if key == "up" and snake.direction ~= "down" then
        snake.direction = "up"
    end
    if key == "down" and snake.direction ~= "up" then
        snake.direction = "down"
    end
end

local function draw_screen()
    tools.clearScreen()

    -- draw board
    for x = 0, snake.board_size.x + 1 do
        for y = 0, snake.board_size.y + 1 do
            if x == 0 or y == 0 or x == snake.board_size.x + 1 or y == snake.board_size.y + 1 then
                tools.setScreenDot(x + 1, y + 1, snake.colors.border)
            end
        end
    end

    -- draw the snake
    for index, value in ipairs(snake.snake) do
        if index == 1 then
            tools.setScreenDot(value.x + 1, value.y + 1, snake.colors.head)
        else
            tools.setScreenDot(value.x + 1, value.y + 1, snake.colors.body)
        end
    end

    -- draw food
    tools.setScreenDot(snake.food.x + 1, snake.food.y + 1, snake.colors.food)

    -- draw score
    tools.print(snake.score, 2, snake.board_size.y + 5, snake.colors.body);

    tools.updateScreen()
end

function snake.run()
    init()
    while not snake.exit do -- main loop.
    if snake.game_state == 'over' then
        local key = engine:getKey()
        if key == "a" then
            init()
            snake.game_state = 'playing'
        elseif key == "select" then
            break
        end
    elseif snake.game_state == 'paused' then
        handle_input()
        local timestamp = engine:time()
        if timestamp - snake.lastTimestamp > 500 then
            tools.clearScreen()
            tools.updateScreen()
            snake.lastTimestamp = timestamp
        else
            draw_screen()
        end
    else
        handle_input()
        local timestamp = engine:time()
        if timestamp - snake.lastTimestamp > (450 - snake.speed * 50) then
            if not move() then snake.game_state = 'over' end
            snake.lastTimestamp = timestamp
            draw_screen()
        end
    end
    engine:sleep(50);
    end
end

return snake