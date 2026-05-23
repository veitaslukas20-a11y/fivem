-- SERVER SIDE --

ESX = exports["es_extended"]:getSharedObject()
local Searching = {}

local Config = {
    Locations = {
        {coords = vector3(-1095.42, -834.32, 19.29), radius = 30.0},
        {coords = vector3(295.12, 2843.23, 43.89), radius = 25.0},
        {coords = vector3(1256.32, -2567.83, 43.42), radius = 35.0},
        {coords = vector3(-1523.88, 1491.02, 110.34), radius = 28.0},
        {coords = vector3(3169.71, -1304.99, 41.40), radius = 32.0},
    },
    DigTime = 30000, -- digging duration in ms
    Rewards = {
        {item = "old_boot", min = 1, max = 3, chance = 50},
        {item = "black_money", min = 1, max = 1, chance = 10},
        {item = "siuksles", min = 1, max = 5, chance = 25},
        {item = "weapon_snspistol", min = 1, max = 2, chance = 15},
        {item = "ammunition_pistol", min = 1, max = 1, chance = 5},
    }
}

-- Register callback for client to get treasure map config
lib.callback.register("map:getConfig", function(source)
    return Config
end)

-- Set player as searching
RegisterNetEvent("map:setSearching")
AddEventHandler("map:setSearching", function()
    local _source = source
    Searching[_source] = true
end)

-- Start digging and reward player
lib.callback.register("map:startDigg", function(source, UID)
    local player = ESX.GetPlayerFromId(source)
    if not player then 
        return {success = false} 
    end

    if not Searching[source] then 
        return {success = false} 
    end

    Searching[source] = nil
    Citizen.Wait(Config.DigTime)

    local selectedReward = nil
    for _, reward in ipairs(Config.Rewards) do
        if math.random(100) <= reward.chance then
            selectedReward = reward
            break
        end
    end

    if not selectedReward then
        selectedReward = Config.Rewards[math.random(#Config.Rewards)]
    end

    local amount = math.random(selectedReward.min, selectedReward.max)
    player.addInventoryItem(selectedReward.item, amount)
    TriggerClientEvent("map:ended", source)

    return {success = true, item = selectedReward.item, amount = amount}
end)

-- Show treasure location to player
RegisterNetEvent("map:useTreasureMap")
AddEventHandler("map:useTreasureMap", function()
    local _source = source
    if Searching[_source] then return end

    local player = ESX.GetPlayerFromId(_source)
    if not player then return end

    local locationID = math.random(#Config.Locations)
    local location = Config.Locations[locationID]

    Searching[_source] = true
    TriggerClientEvent("map:showTreasure", _source, location.coords, location.radius)
end)
