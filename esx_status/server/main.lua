ESX = exports['es_extended']:getSharedObject()

local playerStatuses = {}
local msgpack = msgpack or {}

-- Funkcija dekoduoti msgpack duomenis
local function decodeStatusData(payload)
    if not payload then return {} end
    
    -- Jei msgpack yra available, naudojam jį
    if msgpack.unpack then
        local success, result = pcall(msgpack.unpack, payload)
        if success then
            return result or {}
        end
    end
    
    -- Fallback: jei msgpack nepalaikomas, bandome JSON
    local success, result = pcall(json.decode, payload)
    if success then
        return result or {}
    end
    
    return {}
end

-- Eventas gauti statusų atnaujinimus iš client
RegisterNetEvent('esx_status:update')
AddEventHandler('esx_status:update', function(payload, payloadLen)
    local source = source
    local xPlayer = ESX.GetPlayerFromId(source)
    
    if not xPlayer then return end
    
    -- Dekoduojam statusų duomenis
    local statusData = decodeStatusData(payload)
    
    -- Išsaugom statusus
    playerStatuses[xPlayer.identifier] = statusData
    
    -- Debug log
    if Config.Debug then
        print(string.format("^5[esx_status] Updated statuses for %s: %s^7", 
            xPlayer.getName(), json.encode(statusData)))
    end
end)

-- Eventas nustatyti statusą
RegisterNetEvent('esx_status:set')
AddEventHandler('esx_status:set', function(statusName, value)
    local source = source
    local xPlayer = ESX.GetPlayerFromId(source)
    
    if not xPlayer then return end
    
    -- Inicializuojam žaidėjo statusus jei reikia
    if not playerStatuses[xPlayer.identifier] then
        playerStatuses[xPlayer.identifier] = {}
    end
    
    -- Nustatom statusą
    playerStatuses[xPlayer.identifier][statusName] = tonumber(value) or 0
    
    -- Siunčiam atnaujinimą atgal į client
    TriggerClientEvent('esx_status:set', source, statusName, value)
    
    if Config.Debug then
        print(string.format("^5[esx_status] Set status %s to %s for %s^7", 
            statusName, value, xPlayer.getName()))
    end
end)

-- Eventas pridėti prie statuso
RegisterNetEvent('esx_status:add')
AddEventHandler('esx_status:add', function(statusName, value)
    local source = source
    local xPlayer = ESX.GetPlayerFromId(source)
    
    if not xPlayer then return end
    
    -- Inicializuojam žaidėjo statusus jei reikia
    if not playerStatuses[xPlayer.identifier] then
        playerStatuses[xPlayer.identifier] = {}
    end
    
    -- Gaunam dabartinę reikšmę
    local currentValue = playerStatuses[xPlayer.identifier][statusName] or 0
    local newValue = math.min(Config.StatusMax, currentValue + (tonumber(value) or 0))
    
    -- Atnaujinam statusą
    playerStatuses[xPlayer.identifier][statusName] = newValue
    
    -- Siunčiam atnaujinimą atgal į client
    TriggerClientEvent('esx_status:set', source, statusName, newValue)
    
    if Config.Debug then
        print(string.format("^5[esx_status] Added %s to status %s for %s (now: %s)^7", 
            value, statusName, xPlayer.getName(), newValue))
    end
end)

-- Eventas atimti iš statuso
RegisterNetEvent('esx_status:remove')
AddEventHandler('esx_status:remove', function(statusName, value)
    local source = source
    local xPlayer = ESX.GetPlayerFromId(source)
    
    if not xPlayer then return end
    
    -- Inicializuojam žaidėjo statusus jei reikia
    if not playerStatuses[xPlayer.identifier] then
        playerStatuses[xPlayer.identifier] = {}
    end
    
    -- Gaunam dabartinę reikšmę
    local currentValue = playerStatuses[xPlayer.identifier][statusName] or 0
    local newValue = math.max(0, currentValue - (tonumber(value) or 0))
    
    -- Atnaujinam statusą
    playerStatuses[xPlayer.identifier][statusName] = newValue
    
    -- Siunčiam atnaujinimą atgal į client
    TriggerClientEvent('esx_status:set', source, statusName, newValue)
    
    if Config.Debug then
        print(string.Sprintf("^5[esx_status] Removed %s from status %s for %s (now: %s)^7", 
            value, statusName, xPlayer.getName(), newValue))
    end
end)

-- Eventas žaidėjo prisijungimui - įkelti statusus
AddEventHandler('esx:playerLoaded', function(playerId, xPlayer)
    -- Palaukti kol client bus ready
    Citizen.SetTimeout(3000, function()
        -- Gaunam išsaugotus statusus iš duomenų bazės
        LoadPlayerStatus(xPlayer.identifier, playerId)
    end)
end)

-- Eventas žaidėjo atsijungimui - išsaugoti statusus
AddEventHandler('playerDropped', function(reason)
    local source = source
    local xPlayer = ESX.GetPlayerFromId(source)
    
    if xPlayer and playerStatuses[xPlayer.identifier] then
        SavePlayerStatus(xPlayer.identifier, playerStatuses[xPlayer.identifier])
        
        -- Išvalyti iš atminties
        playerStatuses[xPlayer.identifier] = nil
        
        if Config.Debug then
            print(string.format("^3[esx_status] Saved statuses for disconnected player %s^7", 
                xPlayer.getName()))
        end
    end
end)

-- Funkcija įkelti žaidėjo statusus
function LoadPlayerStatus(identifier, playerId)
    -- Čia galima pridėti duomenų bazės įkėlimą
    -- Kol kas naudosim default statusus
    
    local defaultStatuses = {
        hunger = Config.StatusMax,
        thirst = Config.StatusMax
        -- Čia galima pridėti kitus default statusus
    }
    
    -- Išsaugom atmintyje
    playerStatuses[identifier] = defaultStatuses
    
    -- Siunčiam į client
    TriggerClientEvent('esx_status:load', playerId, defaultStatuses)
    
    if Config.Debug then
        print(string.format("^2[esx_status] Loaded default statuses for player %s^7", identifier))
    end
end

-- Funkcija išsaugoti žaidėjo statusus
function SavePlayerStatus(identifier, statusData)
    -- Čia galima pridėti duomenų bazės išsaugojimą
    -- Kol kas tiesiog log'as
    
    if Config.Debug then
        print(string.format("^5[esx_status] Would save statuses for %s: %s^7", 
            identifier, json.encode(statusData)))
    end
end

-- Callback'ai client side naudojimui
lib.callback.register('esx_status:getStatus', function(source, statusName)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer or not playerStatuses[xPlayer.identifier] then return nil end
    
    return playerStatuses[xPlayer.identifier][statusName]
end)

lib.callback.register('esx_status:getAllStatuses', function(source)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer or not playerStatuses[xPlayer.identifier] then return {} end
    
    return playerStatuses[xPlayer.identifier]
end)


-- Eventas resurso paleidimui
AddEventHandler('onResourceStart', function(resourceName)
    if GetCurrentResourceName() ~= resourceName then return end
        
    -- Inicializuoti visų prisijungusių žaidėjų statusus
    for _, playerId in ipairs(GetPlayers()) do
        local xPlayer = ESX.GetPlayerFromId(playerId)
        if xPlayer then
            Citizen.SetTimeout(3000, function()
                LoadPlayerStatus(xPlayer.identifier, playerId)
            end)
        end
    end
end)

-- Eventas resurso sustabdymui
AddEventHandler('onResourceStop', function(resourceName)
    if GetCurrentResourceName() ~= resourceName then return end
    
    print("^3[esx_status] Resource stopped - saving all player statuses^7")
    
    -- Išsaugoti visų žaidėjų statusus
    for identifier, statusData in pairs(playerStatuses) do
        SavePlayerStatus(identifier, statusData)
    end
end)

-- Periodinis statusų išsaugojimas
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(5 * 60 * 1000) -- Kas 5 minutes
        
        for identifier, statusData in pairs(playerStatuses) do
            SavePlayerStatus(identifier, statusData)
        end
        
        if Config.Debug then
            print("^5[esx_status] Periodically saved all player statuses^7")
        end
    end
end)