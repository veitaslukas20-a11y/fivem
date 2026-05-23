local ESX = exports['es_extended']:getSharedObject()
local Config = Config or require 'config'

---@diagnostic disable: undefined-global

local Admins = {}
local Reports = {}
local ReportCount = 0
local Spectating = {}
local OnlinePlayers = {}
local OfflinePlayers = {}
local Pataisos = {}

CreateThread(function()
    while true do
        Wait(10000)
        local prisoners = exports['s1m1s-prison']:GetPrisoners()
        if prisoners then
            Pataisos = prisoners
            TriggerClientEvent('adminmenu:fetchPataisos', -1, Pataisos)
        end
    end
end)

local function GetIdentifier(src)
    local identifiers = GetPlayerIdentifiers(src)
    for _, id in ipairs(identifiers) do
        if id:sub(1,8) == 'license:' then
            return id:sub(9)
        end
    end
    return nil
end

local Roles = {
    owner = 7,
    dev = 6,
    pagradmin = 5,
    vyradmin = 4,
    admin = 3,
    vyrsupport = 2,
    support = 1,
}

local function IsSuper(admin)
    return admin and admin.perms == 'super'
end

local function GetAdminByLicense(license)
    for i, a in ipairs(Admins) do
        if a.license == license then
            return a, i
        end
    end
end

local function HasPerms(src)
    local lic = GetIdentifier(src)
    if not lic then return false end
    return GetAdminByLicense(lic) ~= nil
end

local function HasSuper(src)
    local lic = GetIdentifier(src)
    if not lic then return false end
    local admin = GetAdminByLicense(lic)
    return IsSuper(admin)
end

local function BuildOnline()
    local t = {}
    for _, id in ipairs(GetPlayers()) do
        local sid = tonumber(id)
        if sid then
            local pname = GetPlayerName(sid) or ''
            t[tostring(sid)] = {
                id = tostring(sid),
                name = pname,
                pataisos = OnlinePlayers[sid] and OnlinePlayers[sid].pataisos or nil
            }
        end
    end
    return t
end

local function BroadcastOnline(target)
    local data = BuildOnline()
    if target then
        TriggerClientEvent('adminmenu:fetchPlayers', target, data)
    else
        TriggerClientEvent('adminmenu:fetchPlayers', -1, data)
    end
end

local function BroadcastOffline(target)
    if target then
        TriggerClientEvent('adminmenu:fetchOffline', target, OfflinePlayers)
    else
        TriggerClientEvent('adminmenu:fetchOffline', -1, OfflinePlayers)
    end
end

local function BroadcastPataisos(target)
    if target then
        TriggerClientEvent('adminmenu:fetchPataisos', target, Pataisos)
    else
        TriggerClientEvent('adminmenu:fetchPataisos', -1, Pataisos)
    end
end

lib.callback.register('adminmenu:permissions', function(src)
    local allowed = HasPerms(src)
    if allowed then
        BroadcastReports(src)
        BroadcastOnline(src)
        BroadcastOffline(src)
        BroadcastPataisos(src)
        SetTimeout(500, function()
            local list = lib.callback.execute and {} or nil 
            local onlineLicenses = {}
            for _, pid in ipairs(GetPlayers()) do
                local l = GetIdentifier(pid)
                if l then onlineLicenses[l] = true end
            end
            local enriched = {}
            for _, a in ipairs(Admins) do
                enriched[#enriched+1] = {
                    name = a.name, license = a.license, role = a.role, perms = a.perms,
                    online = onlineLicenses[a.license] and true or false,
                    reports = a.reports or 0, claimed = a.claimed or 0,
                    reports7 = a.reports7 or 0, claimed7 = a.claimed7 or 0,
                    reports30 = a.reports30 or 0, claimed30 = a.claimed30 or 0,
                    time = a.time or 0, time7 = a.time7 or 0, time30 = a.time30 or 0,
                    alltime = a.alltime or 0, upvotes = a.upvotes or 0, downvotes = a.downvotes or 0
                }
            end
            TriggerClientEvent('adminmenu:pushAdmins', src, enriched)
        end)
    end
    return allowed
end)

lib.callback.register('adminmenu:superPermissions', function(src)
    return HasSuper(src)
end)

lib.callback.register('adminmenu:returnAdmins', function(src)
    if not HasPerms(src) then return {} end
    local list = {}
    local onlineLicenses = {}
    for _, pid in ipairs(GetPlayers()) do
        local l = GetIdentifier(pid)
        if l then onlineLicenses[l] = true end
    end
    for _, a in ipairs(Admins) do
        list[#list+1] = {
            name = a.name,
            license = a.license,
            role = a.role,
            perms = a.perms,
            online = onlineLicenses[a.license] and true or false,
            reports = a.reports or 0,
            claimed = a.claimed or 0,
            reports7 = a.reports7 or 0,
            claimed7 = a.claimed7 or 0,
            reports30 = a.reports30 or 0,
            claimed30 = a.claimed30 or 0,
            time = a.time or 0,
            time7 = a.time7 or 0,
            time30 = a.time30 or 0,
            alltime = a.alltime or 0,
            upvotes = a.upvotes or 0,
            downvotes = a.downvotes or 0,
        }
    end
    return list
end)

lib.callback.register('adminmenu:insertAdmin', function(src, data)
    if not HasSuper(src) then return end
    if not data or not data.license then return end
    data.license = data.license:gsub('^license:', '')
    local exists = GetAdminByLicense(data.license)
    if exists then return end
    local admin = {
        name = data.name or 'Nezinomas',
        license = data.license,
        role = data.role or 'support',
        perms = data.super and 'super' or 'admin',
        reports = 0, claimed = 0, reports7 = 0, claimed7 = 0, reports30 = 0, claimed30 = 0,
        time = 0, time7 = 0, time30 = 0, alltime = 0, upvotes = 0, downvotes = 0
    }
    table.insert(Admins, admin)
    if MySQL then
        MySQL.insert('INSERT INTO adminmenu_admins (name, license, role, perms, reports, claimed, reports7, claimed7, reports30, claimed30, time, time7, time30, alltime, upvotes, downvotes) VALUES (?, ?, ?, ?, 0,0,0,0,0,0,0,0,0,0,0,0)', {admin.name, admin.license, admin.role, admin.perms})
    end
    return true
end)

lib.callback.register('adminmenu:updateAdmin', function(src, data)
    if not HasSuper(src) then return end
    if not data or not data.license2 then return end
    data.license2 = data.license2:gsub('^license:', '')
    data.license = data.license and data.license:gsub('^license:', '')
    local admin = GetAdminByLicense(data.license2)
    if not admin then return end
    admin.name = data.name or admin.name
    admin.license = data.license or admin.license
    admin.role = data.role or admin.role
    admin.perms = data.super and 'super' or 'admin'
    if MySQL then
        MySQL.update('UPDATE adminmenu_admins SET name = ?, license = ?, role = ?, perms = ? WHERE license = ?', {admin.name, admin.license, admin.role, admin.perms, data.license2})
    end
    return true
end)

lib.callback.register('adminmenu:deleteAdmin', function(src, data)
    if not HasSuper(src) then return end
    if not data or not data.license then return end
    data.license = data.license:gsub('^license:', '')
    local _, idx = GetAdminByLicense(data.license)
    if not idx then return end
    table.remove(Admins, idx)
    if MySQL then
        MySQL.update('DELETE FROM adminmenu_admins WHERE license = ?', {data.license})
    end
    return true
end)

function BroadcastReports(target)
    local list = {}
    for id, r in pairs(Reports) do
        list[id] = r
    end
    if target then
        TriggerClientEvent('adminmenu:fetchReports', target, list)
    else
        TriggerClientEvent('adminmenu:fetchReports', -1, list)
    end
end

lib.callback.register('adminmenu:createReport', function(src, data)
    if not data then return end
    ReportCount = ReportCount + 1
    local id = ReportCount
    local playerName = GetPlayerName(src) or 'Nežinomas'
    local category = data.category or 'player'
    Reports[id] = {
        id = id,
        time = os.date('%H:%M:%S'),
        player = { name = playerName, id = src },
        category = category,
        rplayer = data.rplayer or '',
        rules = data.rules or '',
        description = data.description or '',
        status = false,
        admin = nil,
        chat = {}
    }

    -- **Pranešimas visiems adminams: žaidėjas sukūrė reportą**
    for _, pid in ipairs(GetPlayers()) do
        if HasPerms(pid) then
            TriggerClientEvent('esx:showNotification', pid, ("Naujas reportas #%d nuo %s"):format(id, playerName))
        end
    end

    BroadcastReports()
    return Reports[id]
end)

lib.callback.register('adminmenu:selfClose', function(src, id)
    local r = Reports[id]
    if not r then return end
    if not r.player or r.player.id ~= src then return end

    TriggerClientEvent('adminmenu:selfClosedReport', src)
    TriggerClientEvent('adminmenu:updateReport', -1, 'close', { id = id })

    -- **Žaidėjui (kuris uždarė) – jis jau žiūri, bet jei nori:**
    TriggerClientEvent('esx:showNotification', src, ("Jūs uždarėte reportą #%d"):format(id))

    Reports[id] = nil
    BroadcastReports()
end)

lib.callback.register('adminmenu:reportAction', function(src, data)
    if not HasPerms(src) then return end
    local id = tonumber(data and data.id)
    if not id then return end
    local r = Reports[id]
    if not r then return end
    local act = data.action
    if act == 'claim' and not r.status then
        r.status = true
        r.admin = GetPlayerName(src)
        TriggerClientEvent('adminmenu:updateReport', -1, 'claim', {id = id, admin = r.admin})
        BroadcastReports()

        -- **Pranešimas žaidėjui, kad adminas priėmė reportą**
        if r.player and r.player.id then
            TriggerClientEvent('esx:showNotification', r.player.id, ("Administratoriaus %s priėmė jūsų reportą #%d"):format(r.admin, id))
        end

    elseif act == 'close' then
        TriggerClientEvent('adminmenu:updateReport', -1, 'close', {id = id})
        if r.player and r.player.id then
            TriggerClientEvent('adminmenu:selfClosedReport', r.player.id)
            -- **Pranešimas žaidėjui, kad adminas uždarė reportą**
            TriggerClientEvent('esx:showNotification', r.player.id, ("Jūsų reportas #%d buvo uždarytas administratoriumi"):format(id))
        end
        Reports[id] = nil
        BroadcastReports()
    end
end)

lib.callback.register('adminmenu:sendMessage', function(src, id, message)
    local r = Reports[id]
    if not r then return end
    if (not r.player or r.player.id ~= src) and not HasPerms(src) then return end

    local lic = GetIdentifier(src)
    local admin = lic and GetAdminByLicense(lic)
    local role = admin and admin.role or 'player'
    local entry = {user = GetPlayerName(src), message = message, role = role}

    table.insert(r.chat, entry)
    TriggerClientEvent('adminmenu:updateReport', -1, 'chat', {id = id, user = entry.user, message = entry.message, role = entry.role})

    if r.player and src == r.player.id then
        -- žaidėjas rašo → tik tam adminui, kuris priėmė
        for _, pid in ipairs(GetPlayers()) do
            if HasPerms(pid) and r.admin and GetPlayerName(pid) == r.admin then
                TriggerClientEvent('esx:showNotification', pid, ("Žaidėjas %s jums parašė"):format(entry.user))
            end
        end
        TriggerClientEvent('adminmenu:updateSelfChat', src, entry)
    else
        -- adminas rašo žaidėjui
        if r.player and r.player.id then
            TriggerClientEvent('esx:showNotification', r.player.id, ("Adminas %s jums atrašė"):format(entry.user))
        end
    end
end)


lib.callback.register('adminmenu:action', function(src, data)
    if not HasPerms(src) then return end
    if not data or not data.action then return end
    local act = data.action
    local target = tonumber(data.id)
        or tonumber(data.player)
        or (type(data.player) == 'table' and tonumber(data.player.id))
        or (type(data.report) == 'table' and data.report.player and tonumber(data.report.player.id))
        or (type(data.report) == 'table' and tonumber(data.report.id))
        or tonumber(data.target)
    if not target then target = src end

    if act == 'bring' then
        if target then
            local coords = GetEntityCoords(GetPlayerPed(src))
            SetEntityCoords(GetPlayerPed(target), coords.x, coords.y, coords.z, false, false, false, false)
        end

    elseif act == 'goto' or act == 'teleport' then
        if target then
            local coords = GetEntityCoords(GetPlayerPed(target))
            SetEntityCoords(GetPlayerPed(src), coords.x, coords.y, coords.z, false, false, false, false)
        end

    elseif act == 'heal' then
        if target then TriggerClientEvent('esx_basicneeds:healPlayer', target) end

    elseif act == 'revive' then
        if target then TriggerClientEvent('esx_ambulancejob:revive', target) end

    elseif act == 'freeze' then
        if target then TriggerClientEvent('esx:freezePlayer', target, true) end

    elseif act == 'unfreeze' then
        if target then TriggerClientEvent('esx:freezePlayer', target, false) end

    elseif act == 'kick' then
        DropPlayer(tostring(target), 'Išmestas administratoriaus.')

    elseif act == 'spectate' then
        if target then
            TriggerClientEvent('adminmenu:startSpectate', src, target)
        end

    elseif act == 'claim' or act == 'close' or act == 'solve' then
        local rid = tonumber(data.report) or tonumber(data.id)
        if rid then
            if act == 'claim' then
                local adminName = GetPlayerName(src)
                if Reports[rid] and not Reports[rid].status then
                    Reports[rid].status = true
                    Reports[rid].admin = adminName
                    TriggerClientEvent('adminmenu:updateReport', -1, 'claim', {id = rid, admin = adminName})
                    BroadcastReports()

                    -- **Pranešimas žaidėjui**
                    local r2 = Reports[rid]
                    if r2 and r2.player and r2.player.id then
                        TriggerClientEvent('esx:showNotification', r2.player.id, ("Administratorius %s priėmė jūsų reportą #%d"):format(adminName, rid))
                    end

                    local lic2 = GetIdentifier(src)
                    local ad = lic2 and GetAdminByLicense(lic2)
                    if ad then
                        ad.reports = (ad.reports or 0) + 1
                        ad.reports7 = (ad.reports7 or 0) + 1
                        ad.reports30 = (ad.reports30 or 0) + 1
                        if MySQL then
                            MySQL.update('UPDATE adminmenu_admins SET reports = reports + 1, reports7 = reports7 + 1, reports30 = reports30 + 1 WHERE license = ?', {lic2})
                        end
                    end
                end

            else
                TriggerClientEvent('adminmenu:updateReport', -1, 'close', {id = rid})
                local r3 = Reports[rid]
                if r3 and r3.player and r3.player.id then
                    TriggerClientEvent('adminmenu:selfClosedReport', r3.player.id)
                    -- **Pranešimas žaidėjui**
                    TriggerClientEvent('esx:showNotification', r3.player.id, ("Administratorius uždarė jūsų reportą #%d"):format(rid))
                end
                Reports[rid] = nil
                BroadcastReports()

                local lic3 = GetIdentifier(src)
                local ad3 = lic3 and GetAdminByLicense(lic3)
                if ad3 then
                    ad3.claimed = (ad3.claimed or 0) + 1
                    ad3.claimed7 = (ad3.claimed7 or 0) + 1
                    ad3.claimed30 = (ad3.claimed30 or 0) + 1
                    if MySQL then
                        MySQL.update('UPDATE adminmenu_admins SET claimed = claimed + 1, claimed7 = claimed7 + 1, claimed30 = claimed30 + 1 WHERE license = ?', {lic3})
                    end
                end
            end
        end

    elseif act == 'pataisosTime' then
        local jobs = tonumber(data.jobs)
        if jobs and Pataisos[target] then
            Pataisos[target].jobs = jobs
            TriggerClientEvent('adminmenu:updatePataisos', -1, 'update', Pataisos[target])
        end

    elseif act == 'pataisosRemove' then
        if target and Pataisos[target] then
            Pataisos[target] = nil
            TriggerClientEvent('adminmenu:updatePataisos', -1, 'remove', { id = tostring(target) })
        end
    end
end)

lib.callback.register('adminmenu:playerCoords', function(src, target)
    if not HasPerms(src) then return end
    local ped = GetPlayerPed(target)
    if not ped or ped == 0 then return end
    local c = GetEntityCoords(ped)
    return { x = c.x, y = c.y, z = c.z }
end)

RegisterNetEvent('adminmenu:spectateEnded', function()
end)

AddEventHandler('playerJoining', function()
    local src = source
    if HasPerms(src) then
        BroadcastReports(src)
        BroadcastOnline(src)
        BroadcastOffline(src)
        BroadcastPataisos(src)
    end
end)

AddEventHandler('playerDropped', function()
    local src = source
    if GetPlayerName(src) then
        OfflinePlayers['player_'..src] = { id = tostring(src), name = GetPlayerName(src) }
        TriggerClientEvent('adminmenu:updateOffline', -1, 'add', src)
    end
    local removed = {}
    for id, r in pairs(Reports) do
        if r.player and r.player.id == src then
            TriggerClientEvent('adminmenu:updateReport', -1, 'close', { id = id })
            removed[#removed+1] = id
        end
    end
    if #removed > 0 then
        for _, rid in ipairs(removed) do Reports[rid] = nil end
        BroadcastReports()
    end
    OnlinePlayers[src] = nil
    BroadcastOnline()
end)

AddEventHandler('playerJoining', function()
    local src = source
    SetTimeout(1000, function()
        if GetPlayerName(src) then
            OnlinePlayers[src] = { id = tostring(src), name = GetPlayerName(src) }
            TriggerClientEvent('adminmenu:updatePlayers', -1, 'add', { id = tostring(src), name = GetPlayerName(src) })
        end
    end)
end)

RegisterNetEvent('esx:setJob', function(job)
    local src = source
    if not OnlinePlayers[src] then return end
    OnlinePlayers[src].job = job and job.name or nil
    if job and job.name == 'pataisos' then
        Pataisos[src] = {
            id = tostring(src),
            name = GetPlayerName(src),
            job = job.name,
            grade = job.grade
        }
        TriggerClientEvent('adminmenu:updatePataisos', -1, 'add', Pataisos[src])
    else
        if Pataisos[src] then
            TriggerClientEvent('adminmenu:updatePataisos', -1, 'remove', { id = tostring(src) })
        end
        Pataisos[src] = nil
    end
    TriggerClientEvent('adminmenu:updatePlayers', -1, 'update', { id = tostring(src), data = OnlinePlayers[src].pataisos })
end)

AddEventHandler('onResourceStart', function(res)
    if res ~= GetCurrentResourceName() then return end
    if MySQL then
        MySQL.prepare([[CREATE TABLE IF NOT EXISTS adminmenu_admins (
            id INT AUTO_INCREMENT PRIMARY KEY,
            name VARCHAR(50),
            license VARCHAR(60) UNIQUE,
            role VARCHAR(30),
            perms VARCHAR(10),
            reports INT DEFAULT 0,
            claimed INT DEFAULT 0,
            reports7 INT DEFAULT 0,
            claimed7 INT DEFAULT 0,
            reports30 INT DEFAULT 0,
            claimed30 INT DEFAULT 0,
            time INT DEFAULT 0,
            time7 INT DEFAULT 0,
            time30 INT DEFAULT 0,
            alltime INT DEFAULT 0,
            upvotes INT DEFAULT 0,
            downvotes INT DEFAULT 0
        )]], {}, function()
            MySQL.query('SELECT name, license, role, perms, reports, claimed, reports7, claimed7, reports30, claimed30, time, time7, time30, alltime, upvotes, downvotes FROM adminmenu_admins', {}, function(rows)
                for _, r in ipairs(rows) do
                    table.insert(Admins, {
                        name = r.name, license = r.license, role = r.role, perms = r.perms,
                        reports = r.reports or 0, claimed = r.claimed or 0,
                        reports7 = r.reports7 or 0, claimed7 = r.claimed7 or 0,
                        reports30 = r.reports30 or 0, claimed30 = r.claimed30 or 0,
                        time = r.time or 0, time7 = r.time7 or 0, time30 = r.time30 or 0,
                        alltime = r.alltime or 0, upvotes = r.upvotes or 0, downvotes = r.downvotes or 0
                    })
                end
            end)
        end)
    end
end)

local function BroadcastAdmins()
    local onlineLicenses = {}
    for _, pid in ipairs(GetPlayers()) do
        local l = GetIdentifier(pid)
        if l then onlineLicenses[l] = true end
    end
    local enriched = {}
    for _, a in ipairs(Admins) do
        enriched[#enriched+1] = {
            name = a.name,
            license = a.license,
            role = a.role,
            perms = a.perms,
            online = onlineLicenses[a.license] and true or false,
            reports = a.reports or 0,
            claimed = a.claimed or 0,
            reports7 = a.reports7 or 0,
            claimed7 = a.claimed7 or 0,
            reports30 = a.reports30 or 0,
            claimed30 = a.claimed30 or 0,
            time = a.time or 0,
            time7 = a.time7 or 0,
            time30 = a.time30 or 0,
            alltime = a.alltime or 0,
            upvotes = a.upvotes or 0,
            downvotes = a.downvotes or 0
        }
    end
    for _, pid in ipairs(GetPlayers()) do
        local num = tonumber(pid)
        if num and HasPerms(num) then
            TriggerClientEvent('adminmenu:pushAdmins', num, enriched)
        end
    end
end

CreateThread(function()
    while true do
        Wait(60000)
        local onlineLicenses = {}
        for _, pid in ipairs(GetPlayers()) do
            local l = GetIdentifier(pid)
            if l then onlineLicenses[l] = true end
        end
        for _, a in ipairs(Admins) do
            if onlineLicenses[a.license] then
                a.time = (a.time or 0) + 60
                a.time7 = (a.time7 or 0) + 60
                a.time30 = (a.time30 or 0) + 60
                a.alltime = (a.alltime or 0) + 60
                if MySQL then
                    MySQL.update('UPDATE adminmenu_admins SET time = time + 60, time7 = time7 + 60, time30 = time30 + 60, alltime = alltime + 60 WHERE license = ?', { a.license })
                end
            end
        end
        BroadcastAdmins()
    end
end)

AddEventHandler('playerJoining', function()
    SetTimeout(3000, BroadcastAdmins)
end)
AddEventHandler('playerDropped', function()
    SetTimeout(1000, BroadcastAdmins)
end)


exports('GetPrisoners', function()
    -- return whatever your prisoner data is; for example:
    return PataisosTableOrList  -- the table/list of prisoners in your prison resource
end)