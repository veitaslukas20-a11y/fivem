local ESX = exports['es_extended']:getSharedObject()
local lib = lib
local Alarms = {}

lib.callback.register('s1m1s-signalizacija:getData', function(source, plate)
    local level = Alarms[plate] or 0
    local cfg = Config.Signalization[level]
    if not cfg then return false, 'easy' end
    return cfg.announce, cfg.lock
end)

lib.callback.register('s1m1s-signalization:getVehicleCoords', function(source, netid, plate)
    if not Alarms[plate] then return false end
    local entity = NetworkGetEntityFromNetworkId(netid)
    if entity ~= 0 and DoesEntityExist(entity) then
        local c = GetEntityCoords(entity)
        return {x = c.x, y = c.y, z = c.z}
    end
    return false
end)

RegisterNetEvent('s1m1s-signalizacija:unlockVehicle', function(netid)
    local entity = NetworkGetEntityFromNetworkId(netid)
    if entity ~= 0 and DoesEntityExist(entity) then
        SetVehicleDoorsLocked(entity, 1)
    end
end)

RegisterNetEvent('s1m1s-signalizacija:startEngine', function(netid)
    local src = source
    -- Trigger the client that owns this vehicle to start the engine
    TriggerClientEvent('s1m1s-signalizacija:client:startEngine', src, netid)
end)


RegisterNetEvent('s1m1s-signalizacija:removeLockpick', function()
    local xPlayer = ESX.GetPlayerFromId(source)
    if xPlayer then
        xPlayer.removeInventoryItem('lockpick', 1)
    end
end)

ESX.RegisterUsableItem('caralarm', function(source)
    TriggerClientEvent('s1m1s-signalization:install', source)
end)

RegisterNetEvent('s1m1s-signalizacija:setAlarmLevel', function(plate, level)
    if type(level) ~= 'number' or not Config.Signalization[level] then return end
    Alarms[plate] = level
end)

RegisterNetEvent('s1m1s-signalizacija:clearAlarm', function(plate)
    Alarms[plate] = nil
end)
