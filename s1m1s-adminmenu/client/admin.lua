Offline = {}
Online = {}
Pataisos = {}

---@diagnostic disable-next-line: undefined-global
RegisterNetEvent('adminmenu:fetchReports', function(reports)
    Reports = {}
    for id, report in pairs(reports) do
        Reports['report_'..id] = report
    end

    SendNUIMessage({
        type = 'reports',
        reports = Reports,
    })
end)

---@diagnostic disable-next-line: undefined-global
RegisterNetEvent('adminmenu:fetchPlayers', function(players)
    for id, player in pairs(players) do
        Online['player_'..id] = player
    end

    SendNUIMessage({
        type = 'online',
        players = Online,
    })
end)

RegisterNetEvent('adminmenu:fetchOffline', function(offline)
    for id, player in pairs(offline) do
        Offline['player_'..id] = player
        Offline['player_'..id].time = GetGameTimer()
    end

    SendNUIMessage({
        type = 'offline',
        players = Offline,
    })
end)

RegisterNetEvent('adminmenu:fetchPataisos', function(pataisos)
    for id, jobData in pairs(pataisos) do
        Pataisos['pataisos_'..id] = jobData
    end

    SendNUIMessage({
        type = 'pataisos',
        players = Pataisos,
    })
end)

RegisterNetEvent('adminmenu:pushAdmins', function(list)
    SendNUIMessage({
        type = 'admins',
        admins = list,
    })
end)

---@diagnostic disable-next-line: undefined-global
RegisterNetEvent('adminmenu:updatePlayers', function(action, array)
    local playerKey = 'player_'..array.id
    if action == 'add' then
    ---@diagnostic disable-next-line: undefined-global
    if array.id == tostring(cache.serverId) then return end

        Online[playerKey] = array

        SendNUIMessage({
            type = 'online',
            players = Online,
        })
        return
    elseif action == 'update' then
        local updatedPlayer = Online[playerKey]

        if not updatedPlayer then return end

        updatedPlayer.pataisos = array.data

        SendNUIMessage({
            type = 'player-update',
            player = updatedPlayer,
        })

        SendNUIMessage({
            type = 'online',
            players = Online,
        })
    end
end)

RegisterNetEvent('adminmenu:updateOffline', function(action, id)
    local playerKey = 'player_'..id
    if action == 'add' then
        local player = Online[playerKey]
        if player then
            Offline[playerKey] = lib.table.deepclone(player)
            Offline[playerKey].time = GetGameTimer()
            Online[playerKey] = nil

            SendNUIMessage({
                type = 'player-remove',
                player = id,
            })
            SendNUIMessage({
                type = 'offline',
                players = Offline,
            })
            SendNUIMessage({
                type = 'online',
                players = Online,
            })
        end
    end
end)

local clearTimeout = 15 * 60 * 1000
local clearInterval = 1 * 60 * 60 * 1000
local function clearOfflinePlayers()
    local currentTime = GetGameTimer()
    for key, player in pairs(Offline) do
        if player.time and (currentTime - player.time) >= clearInterval then
            Offline[key] = nil
        end
    end
    SetTimeout(clearTimeout, clearOfflinePlayers)
end

SetTimeout(clearTimeout, clearOfflinePlayers)

RegisterNetEvent('adminmenu:updatePataisos', function(action, array)
    local pataisosKey = 'pataisos_'..array.id
    if action == 'add' then
    ---@diagnostic disable-next-line: undefined-global
    if array.id == tostring(cache.serverId) then return end

        Pataisos[pataisosKey] = array

        SendNUIMessage({
            type = 'pataisos',
            pataisos = Pataisos,
        })
        return
    elseif action == 'remove' then
        if not Pataisos[pataisosKey] then return end
        Pataisos[pataisosKey] = nil

        SendNUIMessage({
            type = 'pataisos-remove',
            player = array.id,
        })

        SendNUIMessage({
            type = 'pataisos',
            pataisos = Pataisos,
        })
        return
    elseif action == 'update' then
        if not Pataisos[pataisosKey] then return end

        Pataisos[pataisosKey] = array

        SendNUIMessage({
            type = 'pataisos-update',
            player = array,
        })

        SendNUIMessage({
            type = 'pataisos',
            pataisos = Pataisos,
        })
    end
end)

---@diagnostic disable-next-line: undefined-global
RegisterCommand('tpVehicle', function()
    local allowed = lib.callback.await('adminmenu:permissions', false)
    if not allowed then return end

    ---@diagnostic disable-next-line: undefined-global
    local vehicle, _ = lib.getClosestVehicle(GetEntityCoords(cache.ped), 7.0, false)
    if not vehicle then return end
    for i=-1, 6 do
        if IsVehicleSeatFree(vehicle, i) then
            ---@diagnostic disable-next-line: undefined-global
            SetPedIntoVehicle(cache.ped, vehicle, i)
            break
        end
    end
end, false)

RegisterCommand('fixAdminMenu', function()
    if #Online == 0 then return end
    if #Offline == 0 then return end

    for k,v in pairs(Offline) do
        if not v.name then
            Offline[k] = nil
        end
    end

    for k,v in pairs(Online) do
        if not v.name then
            Online[k] = nil
        end
    end

    SendNUIMessage({
        type = 'online',
        players = Online,
    })

    SendNUIMessage({
        type = 'offline',
        players = Offline,
    })
end, false)

local invisible = false
---@diagnostic disable-next-line: undefined-global
RegisterCommand('invisible', function()
    local allowed = lib.callback.await('adminmenu:permissions', false)
    if not allowed then return end

    invisible = not invisible
    ---@diagnostic disable-next-line: undefined-global
    SetEntityVisible(cache.ped, not invisible, false)
end, false)