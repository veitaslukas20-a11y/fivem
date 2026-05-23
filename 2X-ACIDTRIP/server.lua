local Framework = nil
local cooldown = {}

-- Bandome nustatyti framework'ą
CreateThread(function()
    if GetResourceState('es_extended') == 'started' then
        Framework = 'ESX'
        ESX = exports['es_extended']:getSharedObject()
        print('[1X-ACIDTRIP] ESX framework detected.')
    elseif GetResourceState('qb-core') == 'started' then
        Framework = 'QBCore'
        QBCore = exports['qb-core']:GetCoreObject()
        print('[1X-ACIDTRIP] QBCore framework detected.')
    else
        Framework = 'Standalone'
        print('[1X-ACIDTRIP] Running in standalone mode.')
    end
end)

---------------------------------------
-- ADMIN TIKRINIMAS
---------------------------------------
AddEventHandler('playerConnecting', function(name, setKickReason, deferrals)
    cooldown[source] = 0
end)