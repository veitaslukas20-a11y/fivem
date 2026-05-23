local ESX = exports['es_extended']:getSharedObject()

-- Laikinas mileage saugojimas atmintyje
-- Rekomenduojama vëliau perkelti á duomenø bazæ
local vehicleMileage = {}

----------------------------------------------------------------
-- ÞAIDËJØ SKAIÈIUS
----------------------------------------------------------------

RegisterNetEvent('hud:requestPlayerCount', function()
    local src = source
    local players = GetPlayers()
    TriggerClientEvent('hud:updatePlayerCount', src, #players)
end)

AddEventHandler('playerJoining', function()
    TriggerClientEvent('hud:updatePlayerCount', -1, #GetPlayers())
end)

AddEventHandler('playerDropped', function()
    TriggerClientEvent('hud:updatePlayerCount', -1, #GetPlayers())
end)

----------------------------------------------------------------
-- TRANSPORTO PRIEMONËS RIDA (MILEAGE)
----------------------------------------------------------------

-- Klientas praðo ridos, kai pirmà kartà pradeda vaþiuoti
RegisterNetEvent('hud:getMileage', function(plate)
    local src = source
    if not plate then return end

    local km = vehicleMileage[plate] or 0.0
    TriggerClientEvent('hud:setMileage', src, km)
end)

-- Klientas kas ~30 sek. iðsaugo ridà
RegisterNetEvent('hud:saveMileage', function(plate, km)
    if not plate or not km then return end
    vehicleMileage[plate] = km
end)

----------------------------------------------------------------
-- (PASIRENKAMA) KOMANDA DEBUG'UI
----------------------------------------------------------------

RegisterCommand('checkkm', function(source, args)
    if source == 0 then return end
    local plate = args[1]
    if not plate then return end

    print(('Mileage [%s]: %.2f km'):format(plate, vehicleMileage[plate] or 0))
end, true)
