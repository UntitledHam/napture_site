-- tty_mode should be set to false for it to be playable on napture.
-- When true it is playable in terminal.
local tty_mode = false;


local empty_space_character = "⬜";
local block_character = "❎"
local wall_character = "🧱"
local player_character = "🙂";
local flagpole_character = "🏁";
local top_text = "";
local current_level = 1;
local player_position = {1,1};
local board;



local levels = {
    {
        size = {5,7},
        walls = {{1,4}, {2,4}, {4,4}, {5,4}},
        blocks = {{3,4}},
        spawn = {3,1},
        flagpole = {3,7},
        text = string.format("You can push blocks (%s) by running into them.\nReach the flagpole (%s) to win!", block_character, flagpole_character)
    },

    {
        size = {5,7},
        walls = {{3,3}, {4,3}, {5,3}, {5,4}, {2,5}, {4,5}, {5,5}, {1,6}, {2,6}, {4,6}, {5,6}, {1,7}, {2,7}, {4,7}, {5,7}},
        blocks = {{1,3},{2,4}},
        spawn = {3,1},
        flagpole = {3,7},
        text = string.format("Walls (%s) will block your way.\nTry and make it around them!", wall_character)
    },
    {
        size = {10,10};
        walls = {},
        blocks = {{5,3},{6,3},{7,3},{8,3}},
        spawn = {5,5},
        flagpole = {5,10},
        text = "Test map\nNot Implemented Yet :3"

    }

};

local text_box = nil;
if (not tty_mode) then text_box = get("block") end


local function generateBoard(size)
    local new_board = {};
    for i = 1,size[2] do
        local new_col = {};
        for j = 1, size[1] do
            table.insert(new_col, empty_space_character);
        end
        table.insert(new_board, new_col);

    end     

    return new_board;
end


local function objectAt(position)
    return board[#board - position[2]+1][position[1]];
end

local function setObjectAt(position, object)
    board[#board - position[2]+1][position[1]] = object;
end

local function setPlayerPositon(new_postion)
    setObjectAt(player_position, empty_space_character);
    setObjectAt(new_postion, player_character)
    player_position = new_postion;
end

local function print_to_screen(content)
    if not tty_mode then text_box.set_content(content)
    else print(content) end
end

local function renderBoard()                                                

    local output = top_text .. "\n\n";

    for i = 1, #board do
        for j = 1, #board[i] do 
            output = output .. board[i][j]
        end
        output = output .. "\n";
    end
    
    print_to_screen(output);
end

local function generate_level(level)
    board = generateBoard(level["size"]);

    for i=1, #level["blocks"] do
        setObjectAt(level["blocks"][i], block_character);
    end
    for i=1, #level["walls"] do
        setObjectAt(level["walls"][i], wall_character);
    end

    setObjectAt(level["flagpole"], flagpole_character);
    top_text = level["text"];
    setPlayerPositon(level["spawn"]);
    renderBoard();


end

local function load_level(level) 
    current_level = level;
    generate_level(levels[level]);
end

local function next_level()
    current_level = current_level + 1;
    if current_level > #levels then
        print_to_screen("You Win!!!");
        current_level = 0;
        os.exit();
    end
    generate_level(levels[current_level]);
end

local function canMoveTo(postion)
    local translated_position = {postion[1], (#board - postion[2]+1)};

    if (translated_position[1] < 1) or (translated_position[1] > #(board[1])) then -- x not in range.
        return false;
    elseif (translated_position[2] > #board) or (translated_position[2] < 1) then -- y not in range.
        return false;
    elseif objectAt(postion) == wall_character then -- if it's a block, you cannot move there.
        return false;
    end
    return true;
end

local function canMoveBlock(block_position, amount_to_move_by)
    local future_postion = {block_position[1] + amount_to_move_by[1], block_position[2] + amount_to_move_by[2]};
    if (not canMoveTo(future_postion) or objectAt(future_postion) == flagpole_character) then
        return false;
    elseif objectAt(future_postion) == block_character then
        return canMoveBlock(future_postion, amount_to_move_by);
    else
        return true;
    end

end

local function getRow(position) 
    local translated_position = {position[1], (#board - position[2]+1)};
    return board[translated_position[2]]; 
end

local function getCol(position) 
    local output = {}; 
    for i=1, #board do
        table.insert(output,objectAt({position[1], i}));
    end
    return output;
end

local function moveBlock(player_position, amount_to_move_by)
    --[[
        - Get direction
        - Loop through until non block char
        - Set all to blocks between player pos and the empty pos.
    ]]
    if amount_to_move_by[1] == 1 then
        local row = getRow(player_position);
        for i=player_position[1],#row, 1 do
            if objectAt({i,player_position[2]}) == empty_space_character then
                setObjectAt({i,player_position[2]}, block_character);
                return;
            end
        end

    elseif amount_to_move_by[1] == -1 then
        local row = getRow(player_position);
        for i=player_position[1],1,-1 do
            if objectAt({i,player_position[2]}) == empty_space_character then
                setObjectAt({i,player_position[2]}, block_character);
                return;
            end
        end
    elseif amount_to_move_by[2] == 1 then
        local col = getCol(player_position);
        for i=player_position[2], #col, 1 do
            if objectAt({player_position[1], i}) == empty_space_character then
                setObjectAt({player_position[1], i}, block_character);
                return
            end
        end
    elseif amount_to_move_by[2] == -1 then
        local col = getCol(player_position);
        for i=player_position[2], 1, -1 do
            if objectAt({player_position[1], i}) == empty_space_character then
                setObjectAt({player_position[1], i}, block_character);
                return
            end
        end
    end


end   

local function move(amount_to_move_by)
    local future_postion = {player_position[1] + amount_to_move_by[1], player_position[2] + amount_to_move_by[2]};
    if (not canMoveTo(future_postion)) then
        return;
    elseif objectAt(future_postion) == block_character then
        if (not canMoveBlock(future_postion, amount_to_move_by)) then 
            return;
        else
            moveBlock(player_position,amount_to_move_by);
        end
    elseif objectAt(future_postion) == flagpole_character then
        next_level();
        future_postion = player_position
        
    end
    setObjectAt(player_position, empty_space_character);
    setObjectAt(future_postion, player_character);

    player_position = future_postion;
end



local function main() 
    load_level(current_level);

end

main()

if (not tty_mode) then
    get("up").on_click(function()
        move({0,1});
        renderBoard()
        
    end)
    get("down").on_click(function()
        move({0,-1});
        renderBoard();
    end)
    get("left").on_click(function()
        move({-1,0});
        renderBoard();

    end)
    get("right").on_click(function()
        move({1,0});
        renderBoard();

    end)
else
    local next_input = "";

    while true do 
        next_input = string.lower(io.read())
        if next_input == "up" then
            move({0,1});
            renderBoard();
        elseif next_input == "down" then
            move({0,-1});
            renderBoard()
        elseif next_input == "left" then
            move({-1,0});
            renderBoard()
        elseif next_input == "right" then
            move({1,0});
            renderBoard()
        else
            error("Command not found.");
        end
    end
end