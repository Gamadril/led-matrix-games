local tools = require("lib.tools")

local tetris = {}
tetris.colors = { [-1] = { 255, 255, 255 }, [0] = { 0, 0, 0 }, { 255, 255, 255 }, { 0, 255, 0 }, { 0, 255, 255 }, { 255, 0, 0 }, { 255, 255, 0 }, { 255, 0, 255 }, { 255, 128, 0 } }
tetris.offsets = { board_x = 0, board_y = 0 }
tetris.board_size = { x = 10, y = 20 }
tetris.val = { border = -1, empty = 0 } -- Shorthand to avoid magic numbers.
tetris.showFallingShdow = false

tetris.game_state = 'playing' -- Could also be 'paused' or 'over'.
tetris.board = {} -- board[x][y] = shape_num; 0=empty; -1=border.
tetris.moving_piece = {} -- Keys will be: shape, rot_num, x, y.

local all_shapes = {
    {
        { 0, 1, 0 },
        { 1, 1, 1 }
    },
    {
        { 0, 1, 1 },
        { 1, 1, 0 }
    },
    {
        { 1, 1, 0 },
        { 0, 1, 1 }
    },
    {
        { 1, 1, 1, 1 }
    },
    {
        { 1, 1 },
        { 1, 1 }
    },
    {
        { 1, 0, 0 },
        { 1, 1, 1 }
    },
    {
        { 0, 0, 1 },
        { 1, 1, 1 }
    }
}

local function init()
    -- Use the current time's microseconds as our random seed.
    math.randomseed(os.time())

    tools.initScreen()
    tetris.exit = false

    -- Set up the shapes table.
    tetris.shapes = {}
    for s_index, s in ipairs(all_shapes) do
        tetris.shapes[s_index] = {}
        for rot_num = 1, 4 do
            -- Set up new_shape as s rotated by 90 degrees.
            local new_shape = {}
            local x_end = #s[1] + 1 -- Chosen so that x_end - x is in [1, x_max].
            for x = 1, #s[1] do -- Coords x & y are indexes for the new shape.
            new_shape[x] = {}
            for y = 1, #s do
                new_shape[x][y] = s[y][x_end - x]
            end
            end
            s = new_shape
            tetris.shapes[s_index][rot_num] = s
        end
    end

    --[[
    #### Set up the board
    As mentioned above, the board is mostly 0's with a U-shaped
    border of -1 values along the left, right, and bottom edges.
    --]]
    local border = { x = tetris.board_size.x + 1, y = tetris.board_size.y + 1 }
    for x = 0, border.x do
        tetris.board[x] = {}
        for y = 1, border.y do
            tetris.board[x][y] = tetris.val.empty
            if x == 0 or x == border.x or y == border.y then
                tetris.board[x][y] = tetris.val.border -- This is a border cell.
            end
        end
    end

    --[[
    #### Set up player stats and the next and falling pieces
    We track the position, orientation, and shape number of the currently
    moving piece in the `moving_piece` table. The `next_piece` table needs only
    track the shape of the next piece. The `stats` table tracks lines, level, and
    score; the `fall` table tracks when and how quickly the moving piece falls.
    --]]
    -- Set up the next and currently moving piece.
    tetris.moving_piece = { shape = math.random(#tetris.shapes), rot_num = 1, x = 4, y = 0 }

    -- Use a table so functions can edit its value without having to return it.
    tetris.next_piece = { shape = math.random(#tetris.shapes) }

    tetris.stats = { level = 1, lines = 0, score = 0 } -- Player stats.

    -- fall.interval is the number of seconds between downward piece movements.
    tetris.fall = { interval = 1200 } -- A 'last_at' time is added to this table later.
end

-- This function calls callback(x, y) for each x, y coord
-- in the given piece. Example use using draw_point(x, y):
-- call_fn_for_xy_in_piece(moving_piece, draw_point)
local function call_fn_for_xy_in_piece(piece, callback, param, param2)
    local s = tetris.shapes[piece.shape][piece.rot_num]
    for x, row in ipairs(s) do
        for y, val in ipairs(row) do
            if val == 1 then callback(piece.x + x, piece.y + y, param, param2) end
        end
    end
end


-- Returns true if and only if the move was valid.
local function set_moving_piece_if_valid(piece)
    -- Use values of moving_piece as defaults.
    for k, v in pairs(tetris.moving_piece) do
        if piece[k] == nil then piece[k] = tetris.moving_piece[k] end
    end
    local is_valid = true
    call_fn_for_xy_in_piece(piece, function(x, y)
        if tetris.board[x] and tetris.board[x][y] ~= tetris.val.empty then is_valid = false end
    end)
    if is_valid then tetris.moving_piece = piece end
    return is_valid
end

local function lock_and_update_moving_piece()
    call_fn_for_xy_in_piece(tetris.moving_piece, function(x, y)
        tetris.board[x][y] = tetris.moving_piece.shape -- Lock the moving piece in place.
    end)

    -- Clear any lines possibly filled up by the just-placed piece.
    local num_removed = 0
    local max_line_y = math.min(tetris.moving_piece.y + 4, tetris.board_size.y)
    for line_y = tetris.moving_piece.y + 1, max_line_y do
        local is_full_line = true
        for x = 1, tetris.board_size.x do
            if tetris.board[x][line_y] == tetris.val.empty then is_full_line = false end
        end
        if is_full_line then
            -- Remove the line at line_y.
            for y = line_y, 2, -1 do
                for x = 1, tetris.board_size.x do
                    tetris.board[x][y] = tetris.board[x][y - 1]
                end
            end
            -- Record the line and level updates.
            tetris.stats.lines = tetris.stats.lines + 1
            if tetris.stats.lines % 8 == 0 then -- Level up when lines is a multiple of 10.
            tetris.stats.level = tetris.stats.level + 1
            tetris.fall.interval = tetris.fall.interval * 0.8 -- The pieces will fall faster.
            end
            num_removed = num_removed + 1
        end
    end
    --    if num_removed > 0 then curses.flash() end
    tetris.stats.score = tetris.stats.score + num_removed * num_removed

    -- Bring in the waiting next piece and set up a new next piece.
    tetris.moving_piece = { shape = tetris.next_piece.shape, rot_num = 1, x = 4, y = 0 }
    if not set_moving_piece_if_valid(tetris.moving_piece) then
        tetris.game_state = 'over'
    end
    tetris.next_piece.shape = math.random(#tetris.shapes)
end


local function handle_input()
    local key = engine:getKey() -- Nonblocking; returns nil if no key was pressed.
    if key == nil then return end

    if key == "select" then
        tetris.exit = true
        do return end
    end

    if tetris.game_state ~= 'playing' then return end -- Arrow keys only work if playing.

    -- Handle buttons.
    local new_rot_num_right = (tetris.moving_piece.rot_num % 4) + 1 -- Map 1->2->3->4->1.
    local new_rot_num_left -- Map 1->4->3->2->1.
    if tetris.moving_piece.rot_num == 1 then
        new_rot_num_left = 4
    else
        new_rot_num_left = tetris.moving_piece.rot_num - 1
    end
    local moves = {
        ['left'] = { x = tetris.moving_piece.x - 1 },
        ['right'] = { x = tetris.moving_piece.x + 1 },
        ['a'] = { rot_num = new_rot_num_left },
        ['b'] = { rot_num = new_rot_num_right },
        ['up'] = { rot_num = new_rot_num_left },
    }
    if moves[key] then set_moving_piece_if_valid(moves[key]) end

    -- Handle the down arrow.
    if key == 'down' then
        while set_moving_piece_if_valid({ y = tetris.moving_piece.y + 1 }) do end
        lock_and_update_moving_piece()
    end
end


local function lower_piece_at_right_time()
    -- This function does nothing if the game is paused or over.
    if tetris.game_state ~= 'playing' then return end

    --    local timeval = posix.gettimeofday()
    --    local timestamp = timeval.sec + timeval.usec * 1e-6
    --local timestamp = os.clock() * 1000
    local timestamp = engine:time()
    if tetris.fall.last_at == nil then tetris.fall.last_at = timestamp end -- Happens at startup.

    -- print(timestamp .. ' - ' .. fall.last_at .. ' < ' .. fall.interval)
    -- Do nothing until it's been fall.interval seconds since the last fall.
    if timestamp - tetris.fall.last_at < tetris.fall.interval then return end

    if not set_moving_piece_if_valid({ y = tetris.moving_piece.y + 1 }) then
        lock_and_update_moving_piece()
    end
    tetris.fall.last_at = timestamp
end


local function draw_point(x, y, color, y_offset)
    --    if (type(color) == "table") then
    tools.setScreenDot(x + 1, y + y_offset, color)
    --    else
    --        print('Passed color parameter is not a table')
    --        print(debug.traceback())
    --    end
end

local function draw_screen()
    tools.clearScreen()

    -- Draw the board's border and non-falling pieces if we're not paused.
    for x = 0, tetris.board_size.x + 1 do
        for y = 1, tetris.board_size.y + 1 do
            tools.setScreenDot(x + 1, y + tetris.offsets.board_y, tetris.colors[tetris.board[x][y]])
        end
    end

    if tetris.showFallingShdow then
        -- Fill the space under the piece for better orientation
        call_fn_for_xy_in_piece(tetris.moving_piece, function(px, py, color)
            --print("px: " .. px .. ", py: " .. py .. ", color: " .. color[1] .. "," .. color[2] .. "," .. color[3])
            for y = py + 1, tetris.board_size.y do
                local dot = tetris.board[px][y]
                --print('x: ' .. px .. ' ,y: ' .. y .. ', dot: ' .. dot)
                if dot == 0 then
                    tools.setScreenDot(px + 1, y + tetris.offsets.board_y, { math.floor(color[1] / 10), math.floor(color[2] / 10), math.floor(color[3] / 10) })
                else
                    break
                end
            end
        end, tetris.colors[tetris.moving_piece.shape], tetris.offsets.board_y);
    end


    call_fn_for_xy_in_piece(tetris.moving_piece, draw_point, tetris.colors[tetris.moving_piece.shape], tetris.offsets.board_y)

    -- Clear place of next piece
    local next_y = tetris.offsets.board_y + 3
    local next_x = tetris.offsets.board_x + tetris.board_size.x + 2

    -- Draw the next piece.
    local piece = { shape = tetris.next_piece.shape, rot_num = 2, x = next_x, y = next_y }
    call_fn_for_xy_in_piece(piece, draw_point, tetris.colors[piece.shape], tetris.offsets.board_y)


    -- draw current score
    tools.print(tetris.stats.score, 2, tetris.board_size.y + 5, tetris.colors[1])

    tools.updateScreen()
end

function tetris.run()
    init()

    while not tetris.exit do -- Main loop.
    if tetris.game_state == 'over' then
        local key = engine:getKey()
        if key == "a" then
            init()
            tetris.game_state = 'playing'
        elseif key == "select" then
            break
        end
    else
        handle_input()
        lower_piece_at_right_time()
        draw_screen()
    end
    engine:sleep(200);
    end
end

return tetris

