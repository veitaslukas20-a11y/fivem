local ox = exports.oxmysql
local players = {}

local function getPlayer(src)
    local xPlayer = ESX.GetPlayerFromId(src)
    if not xPlayer then return nil end
    return xPlayer
end

lib.callback.register('s1m1s-gangs:setPlayerZipps', function(src, targetId)
    local srcId = src
    local xTarget = getPlayer(targetId)
    if not xTarget then return nil end

    local targetPed = GetPlayerPed(targetId)
    if not DoesEntityExist(targetPed) then return nil end

    local playerPed = GetPlayerPed(srcId)
    if not DoesEntityExist(playerPed) then return nil end

    local current = Player(targetId).state.isZipped or false
    local newState = not current

    Player(targetId).state:set('isZipped', newState, true)

    print(('[s1m1s-gangs] %s %s %s'):format(GetPlayerName(srcId), newState and 'CUFFED' or 'UNCUFFED', GetPlayerName(targetId)))

    return newState
end)

RegisterNetEvent('s1m1s-gangs:setPlayerEscort', function(targetId, toggle)
    local src = source
    local target = tonumber(targetId)

    if not target or not GetPlayerPed(target) or not GetPlayerPed(src) then return end

    local srcPed = GetPlayerPed(src)
    local tgtPed = GetPlayerPed(target)

    -- Allow escort only if target is cuffed/zipped
    local isZipped = Player(target).state.isZipped
    if not isZipped then
        TriggerClientEvent('ox_lib:notify', src, {
            type = 'error',
            title = 'Gangs',
            description = 'Žaidėjas nėra surištas!'
        })
        return
    end

    if toggle then
        -- Ask target client to attach to escorter
        TriggerClientEvent('s1m1s-gangs:escortStart', target, src)
        TriggerClientEvent('ox_lib:notify', src, {
            type = 'success',
            title = 'Gangs',
            description = 'Jūs vedate asmenį.'
        })
    else
        -- Ask target client to detach
        TriggerClientEvent('s1m1s-gangs:escortStop', target)
        TriggerClientEvent('ox_lib:notify', src, {
            type = 'info',
            title = 'Gangs',
            description = 'Jūs paleidote asmenį.'
        })
    end
end)

AddEventHandler('playerDropped', function()
    local src = source
    for k,v in pairs(players) do
        if v == src then
            local ped = GetPlayerPed(k)
            if DoesEntityExist(ped) then
                DetachEntity(ped, true, false)
            end
            players[k] = nil
        end
    end
end)

--[[==================================================
    VEHICLE PUT IN / OUT
==================================================]]--
RegisterNetEvent('s1m1s-gangs:setinveh', function(targetId, vehicleNetId, seat)
    local veh = NetworkGetEntityFromNetworkId(vehicleNetId)
    local tgt = GetPlayerPed(targetId)

    if DoesEntityExist(veh) and DoesEntityExist(tgt) then
        TaskWarpPedIntoVehicle(tgt, veh, seat)
    end
end)

RegisterNetEvent('s1m1s-gangs:outveh', function(targetId, vehicleNetId)
    local veh = NetworkGetEntityFromNetworkId(vehicleNetId)
    local tgt = GetPlayerPed(targetId)

    if DoesEntityExist(veh) and DoesEntityExist(tgt) then
        TaskLeaveVehicle(tgt, veh, 256)
    end
end)

--[[==================================================
    UTILITY / CLEANUP
==================================================]]--
AddEventHandler('onResourceStop', function(res)
    if res ~= GetCurrentResourceName() then return end
    for _, src in pairs(GetPlayers()) do
        local ped = GetPlayerPed(src)
        if DoesEntityExist(ped) then
            DetachEntity(ped, true, false)
            Player(src).state:set('isZipped', false, true)
        end
    end
end)

AddEventHandler('onResourceStart', function(res)
    if res ~= GetCurrentResourceName() then return end

    local hasExport = exports.ox_inventory and exports.ox_inventory.RegisterStash

    for jobName, station in pairs(Config.Stations) do
        local stashId = jobName
        local bossId = jobName..'_boss'

        if hasExport then
            -- ✅ Naujas API (ox_inventory 2.30+)
            exports.ox_inventory:RegisterStash(
                stashId,
                ('%s Saugykla'):format(jobName),
                50000,
                10000000,
                false
            )

            exports.ox_inventory:RegisterStash(
                bossId,
                ('%s Boso Saugykla'):format(jobName),
                100000,
                20000000,
                false
            )
        else
            -- ✅ Senas API (TriggerEvent)
            TriggerEvent('ox_inventory:RegisterStash', stashId, ('%s Saugykla'):format(jobName), 50000, 10000000, false)
            TriggerEvent('ox_inventory:RegisterStash', bossId, ('%s Boso Saugykla'):format(jobName), 100000, 20000000, false)
        end

        print(('[s1m1s-gangs] Registered stashes for %s'):format(jobName))
    end
end)
