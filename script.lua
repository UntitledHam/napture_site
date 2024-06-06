-- tty_mode should be set to false for it to be playable on napture.
-- When true it is playable in terminal.
local tty_mode = true;

local empty_space_character = "⬜";
local block_character = "⬛";
local player_character = "🙂";
local player_position = {0,0};
local board;

local text_box = nil;
if (not tty_mode) then text_box = get("block" ) end


local function generateBoard(height, width)
    local new_board = {};
    for i = 1,width do
        local new_col = {};
        for j = 1, height do
            table.insert(new_col, empty_space_character);
        end
        table.insert(new_board, new_col);

    end     

    board = new_board;
end


local function objectAt(postion)
    return board[#board - postion[2]+1][postion[1]];
end
local function setObjectAt(postion, object)
    board[#board - postion[2]+1][postion[1]] = object;
end


local function setPlayerPositon(new_postion)
    setObjectAt(new_postion, player_character)
    player_position = new_postion;
end

local function move(x,y)
    local future_postion = {player_position[1] + x, player_position[2] + y};
    print(string.format("Attempted to move to: (%d, %d)", future_postion[1], future_postion[2]));

    if objectAt(future_postion) == block_character then
        return;
    end
    setObjectAt(player_position, empty_space_character);
    setObjectAt(future_postion, player_character);

    player_position = future_postion;
end

local function renderBoard()

    local output = "";

    for i = 1, #board do
        for j = 1, #board[i] do 
            output = output .. board[i][j]
        end
        output = output .. "\n";
    end
    
    if not tty_mode then text_box.set_content(output)
    else print(output) end
end

local function main() 
    generateBoard(10,10);
    setPlayerPositon({5,3});
    setObjectAt({5,5},block_character);
    setObjectAt({6,5},block_character);
    setObjectAt({7,5},block_character);
    renderBoard();
    

end

main()

if (not tty_mode) then
    get("up").on_click(function()
        move(0,1);
        renderBoard()
        
    end)
    get("down").on_click(function()
        move(0,-1);
        renderBoard();
    end)
    get("left").on_click(function()
        move(-1,0);
        renderBoard();

    end)
    get("right").on_click(function()
        move(1,0);
        renderBoard();

    end)
else
    local next_input = "";

    while true do 
        next_input = string.lower(io.read())
        if next_input == "up" then
            move(0,1);
            renderBoard();
        elseif next_input == "down" then
            move(0,-1);
            renderBoard()
        elseif next_input == "left" then
            move(-1,0);
            renderBoard()
        elseif next_input == "right" then
            move(1,0);
            renderBoard()
        else
            error("Command not found.");
        end
    end
end