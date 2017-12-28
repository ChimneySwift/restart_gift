-- Set this to how soon after crash/restart the person must log back in by to recieve a gift
local gift_timeout = 300

-- Set this to the name of the gift you wish to give
local gift_name = "default:mese"
-- Set this to how many of the gift you wish to give
local gift_count = 1

local function load_data(filename)
    local file = io.open(filename, "r")
    if file then
        local table = minetest.deserialize(file:read("*all"))
        file:close()
        if type(table) == "table" then
            return table
        else
            return {}
        end
    end
end

local function save_data(filename, data)
    local file = io.open(filename, "w")
    if file then
        file:write(minetest.serialize(data))
        file:close()
    end
end

local db_filename = minetest.get_worldpath().."/kicked_players.txt"
local kicked_players = load_data(db_filename) or {} -- loads file if it exists, or makes empty table

local current_players = {}

local give_gifts = true
minetest.after(gift_timeout, function()
    give_gifts = false
end)

local function get_description(name)
    if not minetest.registered_items[name] then return name end
    return minetest.registered_items[name].description or name
end

minetest.register_on_joinplayer(function(player)
    name = player:get_player_name()
    if give_gifts == true then
        if kicked_players[name] then
            player:get_inventory():add_item("main", ItemStack(gift_name.." "..tostring(gift_count)))
            minetest.chat_send_player(name, "We're sorry you were kicked, have "..tostring(gift_count).." "..get_description(gift_name).." as a thank you gift for coming back :)")
            kicked_players[name] = nil
        end
    end
    current_players[name] = true
    save_data(db_filename, current_players)
end)

minetest.register_on_leaveplayer(function(player)
    name = player:get_player_name()
    current_players[name] = nil
    save_data(db_filename, current_players)
end)
