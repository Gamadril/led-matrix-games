local colors = {[-1] = {255,255,255}, [0] = {0,0,0}, { 255, 255, 255 }, { 0, 255, 0 }, { 0, 255, 255 }, { 255, 0, 0 }, { 255, 255, 0 }, { 255, 0, 255 }, {255,128,0}}

local screen = {}
local game_state = 'playing' -- Could also be 'paused' or 'over'.

local offsets = { board_x = 0, board_y = 0 }
local board_size = { x = 10, y = 20 }
local board = {} -- board[x][y] = shape_num; 0=empty; -1=border.
local val = { border = -1, empty = 0 } -- Shorthand to avoid magic numbers.
local moving_piece = {} -- Keys will be: shape, rot_num, x, y.

-- Set up one orientation of each shape.

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
local shapes

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

function init()
    -- Use the current time's microseconds as our random seed.
    math.randomseed(os.time())

    for y = 1, engine.screenHeight do
        screen[y] = {}
        for x = 1, engine.screenWidth do
            screen[y][x] = { 0, 0, 0 }
        end
    end

    -- Set up the shapes table.
    shapes = {}
    for s_index, s in ipairs(all_shapes) do
        shapes[s_index] = {}
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
            shapes[s_index][rot_num] = s
        end
    end

    --[[

    #### Set up the board

    As mentioned above, the board is mostly 0's with a U-shaped
    border of -1 values along the left, right, and bottom edges.

    --]]

    -- Set up the board.
    local border = { x = board_size.x + 1, y = board_size.y + 1 }
    for x = 0, border.x do
        board[x] = {}
        for y = 1, border.y do
            board[x][y] = val.empty
            if x == 0 or x == border.x or y == border.y then
                board[x][y] = val.border -- This is a border cell.
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
    moving_piece = { shape = math.random(#shapes), rot_num = 1, x = 4, y = 0 }

    -- Use a table so functions can edit its value without having to return it.
    local next_piece = { shape = math.random(#shapes) }

    local stats = { level = 1, lines = 0, score = 0 } -- Player stats.

    -- fall.interval is the number of seconds between downward piece movements.
    local fall = { interval = 10.2 } -- A 'last_at' time is added to this table later.

    return stats, fall, next_piece
end


function handle_input(stats, fall, next_piece)
    local key = engine:getKey() -- Nonblocking; returns nil if no key was pressed.
    if key == nil then return end

    if game_state ~= 'playing' then return end -- Arrow keys only work if playing.

    -- Handle buttons.
    local new_rot_num_right = (moving_piece.rot_num % 4) + 1 -- Map 1->2->3->4->1.
    local new_rot_num_left -- Map 1->4->3->2->1.
    if moving_piece.rot_num == 1 then
        new_rot_num_left = 4
    else
        new_rot_num_left = moving_piece.rot_num - 1
    end
    local moves = {
        ['left'] = { x = moving_piece.x - 1 },
        ['right'] = { x = moving_piece.x + 1 },
        ['a'] = { rot_num = new_rot_num_left },
        ['b'] = { rot_num = new_rot_num_right }
    }
    if moves[key] then set_moving_piece_if_valid(moves[key]) end

    -- Handle the down arrow.
    if key == 'down' then
        while set_moving_piece_if_valid({ y = moving_piece.y + 1 }) do end
        lock_and_update_moving_piece(stats, fall, next_piece)
    end
end


-- Returns true if and only if the move was valid.
function set_moving_piece_if_valid(piece)
    -- Use values of moving_piece as defaults.
    for k, v in pairs(moving_piece) do
        if piece[k] == nil then piece[k] = moving_piece[k] end
    end
    local is_valid = true
    call_fn_for_xy_in_piece(piece, function(x, y)
        if board[x] and board[x][y] ~= val.empty then is_valid = false end
    end)
    if is_valid then moving_piece = piece end
    return is_valid
end

-- This function calls callback(x, y) for each x, y coord
-- in the given piece. Example use using draw_point(x, y):
-- call_fn_for_xy_in_piece(moving_piece, draw_point)
function call_fn_for_xy_in_piece(piece, callback, param, param2)
    local s = shapes[piece.shape][piece.rot_num]
    for x, row in ipairs(s) do
        for y, val in ipairs(row) do
            if val == 1 then callback(piece.x + x, piece.y + y, param, param2) end
        end
    end
end


function lock_and_update_moving_piece(stats, fall, next_piece)
    call_fn_for_xy_in_piece(moving_piece, function(x, y)
        board[x][y] = moving_piece.shape -- Lock the moving piece in place.
    end)

    -- Clear any lines possibly filled up by the just-placed piece.
    local num_removed = 0
    local max_line_y = math.min(moving_piece.y + 4, board_size.y)
    for line_y = moving_piece.y + 1, max_line_y do
        local is_full_line = true
        for x = 1, board_size.x do
            if board[x][line_y] == val.empty then is_full_line = false end
        end
        if is_full_line then
            -- Remove the line at line_y.
            for y = line_y, 2, -1 do
                for x = 1, board_size.x do
                    board[x][y] = board[x][y - 1]
                end
            end
            -- Record the line and level updates.
            stats.lines = stats.lines + 1
            if stats.lines % 8 == 0 then -- Level up when lines is a multiple of 10.
            stats.level = stats.level + 1
            fall.interval = fall.interval * 0.8 -- The pieces will fall faster.
            end
            num_removed = num_removed + 1
        end
    end
    --    if num_removed > 0 then curses.flash() end
    stats.score = stats.score + num_removed * num_removed

    -- Bring in the waiting next piece and set up a new next piece.
    moving_piece = { shape = next_piece.shape, rot_num = 1, x = 4, y = 0 }
    if not set_moving_piece_if_valid(moving_piece) then
        game_state = 'over'
    end
    next_piece.shape = math.random(#shapes)
end


function lower_piece_at_right_time(stats, fall, next_piece)
    -- This function does nothing if the game is paused or over.
    if game_state ~= 'playing' then return end

    --    local timeval = posix.gettimeofday()
    --    local timestamp = timeval.sec + timeval.usec * 1e-6
    local timestamp = os.clock() * 1000
    if fall.last_at == nil then fall.last_at = timestamp end -- Happens at startup.

    -- Do nothing until it's been fall.interval seconds since the last fall.
    if timestamp - fall.last_at < fall.interval then return end

    if not set_moving_piece_if_valid({ y = moving_piece.y + 1 }) then
        lock_and_update_moving_piece(stats, fall, next_piece)
    end
    fall.last_at = timestamp
end


function draw_point(x, y, color, y_offset)
    if (type(color) == "table") then
        screen[y + y_offset][x+1] = color
    else
        print('Passed color parameter is not a table')
        print(debug.traceback())
    end
end

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

function call_fn_for_xy_in_numbers(number, callback)
    local digits_count = #tostring(number)
    for d = 0, digits_count - 1 do
        local c = tostring(number):sub(d+1,d+1)
        local l = numbers[tonumber(c)]
        for y, col in ipairs(l) do
            for x, val in ipairs(col) do
                callback(d*4 + x, y, val)
            end
        end
    end
end

function draw_level(x, y, level)
    local color = {255,255,255}
    local letter_width = 4
    call_fn_for_xy_in_letter('L', function(lx,ly)
        screen[y + ly][x + lx] = color
    end)
    call_fn_for_xy_in_letter('V', function(lx,ly)
            screen[y + ly][x + letter_width + lx] = color
        end)
        call_fn_for_xy_in_letter('L', function(lx,ly)
                screen[y + ly][x  + 2*letter_width + lx] = color
            end)
end

function draw_screen(stats, next_piece)
    -- Update the screen dimensions.

    -- Draw the board's border and non-falling pieces if we're not paused.
    for x = 0, board_size.x + 1 do
        for y = 1, board_size.y + 1 do
            screen[y + offsets.board_y][x + 1] = colors[board[x][y]]
        end
    end

    call_fn_for_xy_in_piece(moving_piece, draw_point, colors[moving_piece.shape], offsets.board_y)

--[[
    -- Fill the space under the piece for better orientation
    call_fn_for_xy_in_piece(moving_piece, function(px, py, color)
        --print("px: " .. px .. ", py: " .. py .. ", color: " .. color[1] .. "," .. color[2] .. "," .. color[3])
        for y = py + 1, board_size.y do
            local dot = board[px][y]
            --print('x: ' .. px .. ' ,y: ' .. y .. ', dot: ' .. dot)
            if dot == 0 then
                screen[y + offsets.board_y][px][1] = math.floor(color[1] / 5)
                screen[y + offsets.board_y][px][2] = math.floor(color[2] / 5)
                screen[y + offsets.board_y][px][3] = math.floor(color[3] / 5)
            else
                break
            end
        end
    end, colors[moving_piece.shape], offsets.board_y);
--]]

  -- Clear place of next piece
  local next_y = offsets.board_y + 3
  local next_x = offsets.board_x + board_size.x + 2

  for ny = next_y + 1, next_y + 4 do
    screen[ny][next_x + 2] = {0,0,0}
    screen[ny][next_x + 3] = {0,0,0}
  end

  -- Draw the next piece.
  local piece = {shape = next_piece.shape, rot_num = 2, x = next_x, y = next_y}
  call_fn_for_xy_in_piece(piece, draw_point, colors[piece.shape], offsets.board_y)


  --stdscr:mvaddstr(11, x_labels, 'Lines ' .. stats.lines)
  --stdscr:mvaddstr(13, x_labels, 'Score ' .. stats.score)
  -- draw current level
  call_fn_for_xy_in_numbers(stats.level, function(lx,ly,val)
          screen[10 + ly][lx + board_size.x + 3] = colors[val]
  end)

  call_fn_for_xy_in_numbers(stats.score, function(lx,ly,val)
            screen[board_size.y + 5 + ly][2 + lx] = colors[val]
    end)

    engine:setScreen(screen)
end

function main()
    local stats, fall, next_piece = init()

    while true do -- Main loop.
    if game_state == 'over' then
        local key = engine:getKey()
        if key == "a" then
            stats, fall, next_piece = init()
            game_state = 'playing'
        end
    else
        handle_input(stats, fall, next_piece)
        lower_piece_at_right_time(stats, fall, next_piece)
        draw_screen(stats, next_piece)
    end
    engine:sleep(200);
    end
end

main()

