ESX = exports["es_extended"]:getSharedObject()

-- Society Registration
TriggerEvent('esx_society:registerSociety', 'police', 'Policija', 'society_police', 'society_police', 'society_police', {
    type = 'public'
})

-- ================== STATE ==================
local cuffedPlayers   = {}      -- [targetId] = true/false
local escortedPlayers = {}      -- [targetId] = officerId
local inVehicle       = {}      -- [targetId] = vehicleNetId (server-side atmintis)

-- ===== Helpers =====
local function isPolice(id)
    local x = ESX.GetPlayerFromId(id)
    return x and x.job and x.job.name == 'police'
end

local function isOnline(id)
    return GetPlayerPing(id) and GetPlayerPing(id) > 0
end

local function getPed(id)
    local ped = GetPlayerPed(id)
    if not ped or ped == 0 then return nil end
    return ped
end

local function getVehicleNetIdOfPed(id)
    local ped = getPed(id); if not ped then return 0 end
    local veh = GetVehiclePedIsIn(ped, false) -- 0 jei nieko
    if veh == 0 then return 0 end
    return NetworkGetNetworkIdFromEntity(veh) or 0
end

-- ================== DUTY ==================
RegisterServerEvent('esx_policejob:setDuty')
AddEventHandler('esx_policejob:setDuty', function(status)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    if not xPlayer or xPlayer.job.name ~= 'police' then return end
    xPlayer.set('onduty', status)
    TriggerClientEvent('esx_policejob:updateDuty', -1, src, status)
end)

-- ================== CUFF ==================
lib.callback.register('s1m1s-police:setPlayerCuffs', function(source, targetId)
    local xPlayer = ESX.GetPlayerFromId(source)
    local target  = ESX.GetPlayerFromId(targetId)
    if not xPlayer or not target or xPlayer.job.name ~= 'police' then return false end

    local newState = not cuffedPlayers[targetId]
    cuffedPlayers[targetId] = newState or nil

    pcall(function()
        if Player and type(Player) == 'function' then
            Player(targetId).state.isCuffed = newState
        else
            TriggerClientEvent('s1m1s-police:updateCuffState', targetId, newState)
        end
    end)

    TriggerEvent('esx_policejob:logAction', source, 'cuff', newState and 'cuffed' or 'uncuffed', targetId)
    return newState
end)

-- ================== ESCORT ==================
RegisterServerEvent('s1m1s-police:setPlayerEscort')
AddEventHandler('s1m1s-police:setPlayerEscort', function(targetId, state)
    local src = source
    if not isPolice(src) or not isOnline(targetId) then return end

    if state then
        escortedPlayers[targetId] = src
    else
        escortedPlayers[targetId] = nil
    end

    pcall(function()
        if Player and type(Player) == 'function' then
            Player(targetId).state.isEscorted = state and src or false
        else
            TriggerClientEvent('s1m1s-police:updateEscortState', targetId, state and src or false)
        end
    end)

    TriggerClientEvent('s1m1s-police:syncEscort', targetId, state and src or false)
    if state then
        TriggerClientEvent('s1m1s-police:syncEscort', src, targetId)
    end

    TriggerEvent('esx_policejob:logAction', src, 'escort', state and 'escorted' or 'released', targetId)
end)

-- ================== VEHICLES ==================
RegisterServerEvent('s1m1s-police:deleteveh')
AddEventHandler('s1m1s-police:deleteveh', function(netId)
    local src = source
    if not isPolice(src) then return end
    TriggerClientEvent('s1m1s-police:deleteVehicleEntity', src, netId)
end)

RegisterServerEvent('s1m1s-police:unlockveh')
AddEventHandler('s1m1s-police:unlockveh', function(netId)
    local src = source
    if not isPolice(src) then return end
    TriggerClientEvent('s1m1s-police:confirmUnlock', src, netId)
end)

-- >>> ĮLAIPINTI
-- Client -> Server: TriggerServerEvent('s1m1s-police:setinveh', targetId, vehicleNetId, seatOrDoor)
RegisterServerEvent('s1m1s-police:setinveh')
AddEventHandler('s1m1s-police:setinveh', function(targetId, vehicleNetId, seat)
    local officer = source
    if not isPolice(officer) or not isOnline(targetId) then return end

    -- Jei target jau sėdi kažkur – pirma išlaipinam
    local currentVehNet = getVehicleNetIdOfPed(targetId)
    if currentVehNet ~= 0 then
        TriggerClientEvent('s1m1s-police:outveh', targetId, currentVehNet)
        inVehicle[targetId] = nil
        -- trumpas palaukimas ir tik tada sodinam
        SetTimeout(600, function()
            if not isOnline(targetId) then return end
            TriggerClientEvent('s1m1s-police:setinveh', targetId, vehicleNetId, seat, officer)
            inVehicle[targetId] = vehicleNetId
        end)
    else
        TriggerClientEvent('s1m1s-police:setinveh', targetId, vehicleNetId, seat, officer)
        inVehicle[targetId] = vehicleNetId
    end
end)

-- >>> IŠLAIPINTI
-- Client -> Server: TriggerServerEvent('s1m1s-police:outveh', targetId[, vehicleNetId])
RegisterServerEvent('s1m1s-police:outveh')
AddEventHandler('s1m1s-police:outveh', function(targetId, vehicleNetId)
    local officer = source
    if not isPolice(officer) or not isOnline(targetId) then return end

    -- Patikrinam ar tikrai sėdi
    local currentVehNet = getVehicleNetIdOfPed(targetId)
    if currentVehNet == 0 then
        -- Nieko nedarom – nėra ką išlaipinti
        return
    end

    -- jei klientas atsiuntė konkretų veh – naudok jį, kitu atveju naudok realų
    local useNet = (type(vehicleNetId) == 'number' and vehicleNetId ~= 0) and vehicleNetId or currentVehNet
    TriggerClientEvent('s1m1s-police:outveh', targetId, useNet)
    inVehicle[targetId] = nil
end)

-- ================== EQUIPMENT ==================
local cooldowns = {}

lib.callback.register('deivuks-ekipuote:atsiimti', function(source, item)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer or xPlayer.job.name ~= 'police' then
        return false
    end

    local playerId = tostring(source)
    cooldowns[playerId] = cooldowns[playerId] or {}

    if cooldowns[playerId][item] then
        local remaining = cooldowns[playerId][item] - os.time()
        if remaining > 0 then
            return remaining
        end
    end

    local function setCooldown()
        cooldowns[playerId][item] = os.time() + (60 * 60) -- 1 hour
    end

    local hasItem = exports.ox_inventory:Search(source, 'count', item) > 0
    if hasItem then
        return false
    end

    local amount = 1
    if item == 'ammunition_pistol' then
        amount = 200
    end

    local success = exports.ox_inventory:AddItem(source, item, amount)
    if success then
        setCooldown()
        return true
    end

    return false
end)

-- ================== CLEANUP ==================
AddEventHandler('playerDropped', function()
    local src = source
    for targetId, officerId in pairs(escortedPlayers) do
        if officerId == src then
            TriggerEvent('s1m1s-police:setPlayerEscort', targetId, false)
        end
    end
    cuffedPlayers[src] = nil
    inVehicle[src] = nil
    pcall(function()
        if Player and type(Player) == 'function' then
            Player(src).state.isCuffed = false
            Player(src).state.isEscorted = false
        else
            TriggerClientEvent('s1m1s-police:updateCuffState', src, false)
            TriggerClientEvent('s1m1s-police:syncEscort', src, false)
        end
    end)
end)

-- ================== BOSS MENU ==================
ESX.RegisterServerCallback('s1m1s-bossmenu:openMenu', function(source, cb)
    local xPlayer = ESX.GetPlayerFromId(source)
    cb(xPlayer.job.name == 'police' and xPlayer.job.grade_name == 'boss')
end)

-- ================== LOG ==================
RegisterNetEvent('esx_policejob:logAction')
AddEventHandler('esx_policejob:logAction', function(source, actionType, action, targetId)
    print(('^3[POLICE] ^0Officer %s %s player %s'):format(source, action, targetId))
end)
