-- server.lua for prison (s1m1s, fixed by GPT)
-- Now saves and restores player skin when jailed/unjailed
-- Requires: es_extended, oxmysql, esx_skin, skinchanger

ESX = exports['es_extended']:getSharedObject()

local ALLOWED_GROUPS = {
    owner = true,
    dev = true,
    vyradmin = true,
    admin = true,
    vyrsupport = true,
    support = true
}

-- In-memory caches
local Jailed = {}          -- identifier -> jail data
local PlayerSkins = {}     -- identifier -> saved skin before jail

-- Utility: get identifier
local function getIdentifierFromId(source)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then return nil end
    return xPlayer.identifier
end

local function isAllowed(source)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then return false end
    local group = xPlayer.getGroup and xPlayer.getGroup() or (xPlayer.get_permissions and xPlayer.get_permissions() or nil)
    if not group then return false end
    return ALLOWED_GROUPS[group] == true
end

-- Database loading
local function loadJailedFromDB()
    local ok, result = pcall(function()
        return MySQL.Sync.fetchAll('SELECT * FROM prison_jails')
    end)
    if ok and result then
        for _, row in ipairs(result) do
            local until_ts = tonumber(row.jail_until) or 0
            if until_ts > os.time() then
                Jailed[row.identifier] = {
                    identifier = row.identifier,
                    server_id = row.server_id,
                    jail_until = until_ts,
                    price = tonumber(row.price) or 0,
                    jailed_by = row.jailed_by,
                    jailed_at = row.jailed_at
                }
            else
                pcall(function()
                    MySQL.Sync.execute('DELETE FROM prison_jails WHERE identifier = ?', {row.identifier})
                end)
            end
        end
    end
end

local function saveJailToDB(data)
    local ok, exists = pcall(function()
        return MySQL.Sync.fetchScalar('SELECT identifier FROM prison_jails WHERE identifier = ?', {data.identifier})
    end)
    if ok and exists then
        pcall(function()
            MySQL.Sync.execute('UPDATE prison_jails SET server_id = ?, jail_until = ?, price = ?, jailed_by = ?, jailed_at = NOW() WHERE identifier = ?', {
                data.server_id, data.jail_until, data.price, data.jailed_by, data.identifier
            })
        end)
    else
        pcall(function()
            MySQL.Sync.insert('INSERT INTO prison_jails (identifier, server_id, jail_until, price, jailed_by, jailed_at) VALUES (?, ?, ?, ?, ?, NOW())', {
                data.identifier, data.server_id, data.jail_until, data.price, data.jailed_by
            })
        end)
    end
end

local function removeJailFromDB(identifier)
    pcall(function()
        MySQL.Sync.execute('DELETE FROM prison_jails WHERE identifier = ?', {identifier})
    end)
end

local function notify(source, typ, title, message)
    if source and ESX.GetPlayerFromId(source) then
        TriggerClientEvent('esx:showNotification', source, ('[%s] %s'):format(title or 'Kalëjimas', message or ''))
    else
        print(('[prison] %s: %s'):format(title or 'prison', message or ''))
    end
end

-- MAIN: Jail player
local function jailPlayer(targetServerId, minutes, price, adminSource)
    local xTarget = ESX.GetPlayerFromId(targetServerId)
    if not xTarget then return false, 'Þaidëjas nëra prisijungæs' end
    local identifier = xTarget.identifier
    if not identifier then return false, 'Negalima rasti identifikatoriaus' end

    local until_ts = os.time() + (minutes * 60)

    -- Save skin before applying prisoner outfit
    TriggerEvent('esx_skin:getPlayerSkin', targetServerId, function(skin)
        if skin then
            PlayerSkins[identifier] = skin
        end
    end)

    -- Store jail data
    Jailed[identifier] = {
        identifier = identifier,
        server_id = targetServerId,
        jail_until = until_ts,
        price = price or 0,
        jailed_by = getIdentifierFromId(adminSource) or ('server:'..tostring(adminSource)),
        jailed_at = os.date('%Y-%m-%d %H:%M:%S')
    }

    saveJailToDB({
        identifier = identifier,
        server_id = targetServerId,
        jail_until = until_ts,
        price = price or 0,
        jailed_by = getIdentifierFromId(adminSource) or ('server:'..tostring(adminSource))
    })

    -- Notify
    notify(targetServerId, 'INFO', 'Kalëjimas', ('Jûs buvote ákalintas %d minuèiø.'):format(minutes))
    notify(adminSource, 'INFO', 'Kalëjimas', ('Ákalinote %s uþ %d min. (%d€)'):format(GetPlayerName(targetServerId) or 'Þaidëjà', minutes, price or 0))

    -- Trigger client event to apply prisoner uniform (handled client-side)
    TriggerClientEvent('prison:jailed', targetServerId)

    return true
end

-- Unjail and restore skin
local function unjailByIdentifier(identifier)
    if not identifier then return false end
    local entry = Jailed[identifier]
    if entry then
        local serverId = entry.server_id
        Jailed[identifier] = nil
        removeJailFromDB(identifier)

        if serverId and serverId > 0 then
            -- Restore skin if saved
            if PlayerSkins[identifier] then
                local oldSkin = PlayerSkins[identifier]
                TriggerEvent('esx_skin:save', serverId)
                SetTimeout(2000, function()
                    TriggerClientEvent('skinchanger:loadSkin', serverId, oldSkin)
                    TriggerClientEvent('esx_skin:setLastSkin', serverId, oldSkin)
                end)
                PlayerSkins[identifier] = nil
            end

            TriggerClientEvent('prison:unjailed', serverId)
            notify(serverId, 'INFO', 'Kalëjimas', 'Jûs buvote paleistas ið kalëjimo.')
        end
        return true
    end
    return false
end

local function unjailByServerId(targetServerId)
    local xTarget = ESX.GetPlayerFromId(targetServerId)
    if not xTarget then return false end
    return unjailByIdentifier(xTarget.identifier)
end

-- Auto-unlock expired
CreateThread(function()
    while true do
        local now = os.time()
        for identifier, data in pairs(Jailed) do
            if data.jail_until and data.jail_until <= now then
                print(('[prison] Auto-unjailing %s'):format(identifier))
                unjailByIdentifier(identifier)
            end
        end
        Wait(30000)
    end
end)

-- Resource start
AddEventHandler('onResourceStart', function(res)
    if GetCurrentResourceName() ~= res then return end
    loadJailedFromDB()
    print('^2[prison] Loaded jailed players.^7')
end)

-- Player load: reapply jail if still active
AddEventHandler('esx:playerLoaded', function(playerId, xPlayer)
    if not xPlayer then return end
    local ident = xPlayer.identifier
    if not ident then return end
    local ok, result = pcall(function()
        return MySQL.Sync.fetchAll('SELECT * FROM prison_jails WHERE identifier = ? LIMIT 1', {ident})
    end)
    if ok and result and result[1] then
        local row = result[1]
        local until_ts = tonumber(row.jail_until) or 0
        if until_ts > os.time() then
            Jailed[ident] = {
                identifier = ident,
                server_id = playerId,
                jail_until = until_ts,
                price = tonumber(row.price) or 0,
                jailed_by = row.jailed_by,
                jailed_at = row.jailed_at
            }
            TriggerClientEvent('prison:jailed', playerId)
        else
            pcall(function()
                MySQL.Sync.execute('DELETE FROM prison_jails WHERE identifier = ?', {ident})
            end)
        end
    end
end)

-- LIB CALLBACKS ------------------------------------------------------

lib.callback.register('prison:getTime', function(source)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then return 0 end
    local ident = xPlayer.identifier
    local entry = Jailed[ident]
    if not entry then return 0 end
    local remaining = entry.jail_until - os.time()
    if remaining <= 0 then
        Jailed[ident] = nil
        removeJailFromDB(ident)
        return 0
    end
    return remaining * 1000
end)

lib.callback.register('prison:getJailed', function(source)
    local result = {}
    for identifier, data in pairs(Jailed) do
        local name = "Offline"
        if data.server_id and data.server_id > 0 then
            name = GetPlayerName(data.server_id)
        end
        table.insert(result, {
            id = data.server_id or 0,
            identifier = identifier,
            name = name,
            time = math.ceil((data.jail_until - os.time()) / 60),
            price = data.price or 0
        })
    end
    return result
end)

lib.callback.register('prison:tryUnjail', function(source, targetServerId)
    local caller = ESX.GetPlayerFromId(source)
    if not caller then return false, 0 end
    local target = ESX.GetPlayerFromId(targetServerId)
    if not target then return false, 0 end

    local ident = target.identifier
    local jailData = Jailed[ident]
    if not jailData then return false, 0 end

    local price = tonumber(jailData.price) or 0
    if caller.getMoney() >= price then
        caller.removeMoney(price)
        unjailByServerId(targetServerId)
        notify(source, 'INFO', 'Kalëjimas', ('Iðpirkote %s uþ %d€'):format(GetPlayerName(targetServerId) or 'Þaidëjà', price))
        return true, price
    else
        notify(source, 'ERROR', 'Kalëjimas', 'Neturite pakankamai pinigø.')
        return false, 0
    end
end)

lib.callback.register('prison:doJail', function(source, targetServerId, minutes, price)
    if not isAllowed(source) then
        notify(source, 'ERROR', 'Kalëjimas', 'Neturite teisiø.')
        return false
    end
    local success, err = jailPlayer(tonumber(targetServerId), tonumber(minutes), tonumber(price), source)
    if success then return true end
    notify(source, 'ERROR', 'Kalëjimas', 'Nepavyko ákalinti: '..tostring(err))
    return false
end)

lib.callback.register('prison:doneJob', function(source)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then return false end
    local ident = xPlayer.identifier
    local data = Jailed[ident]
    if not data then return false end

    local newUntil = data.jail_until - 60
    if newUntil <= os.time() then
        unjailByIdentifier(ident)
    else
        data.jail_until = newUntil
        saveJailToDB({
            identifier = ident,
            server_id = source,
            jail_until = newUntil,
            price = data.price or 0,
            jailed_by = data.jailed_by
        })
    end
    return true
end)

-- COMMANDS -------------------------------------------------------------

RegisterCommand('jailmenu', function(src)
    if src == 0 then return end
    if not isAllowed(src) then
        notify(src, 'ERROR', 'Kalëjimas', 'Neturite teisiø.')
        return
    end
    TriggerClientEvent('prison:openJailMenu', src)
end, false)

RegisterCommand('unjail', function(src, args)
    if src == 0 then return end
    if not isAllowed(src) then
        notify(src, 'ERROR', 'Kalëjimas', 'Neturite teisiø.')
        return
    end
    local target = tonumber(args[1])
    if not target then
        notify(src, 'ERROR', 'Kalëjimas', 'Naudojimas: /unjail [id]')
        return
    end
    if unjailByServerId(target) then
        notify(src, 'INFO', 'Kalëjimas', 'Þaidëjas paleistas.')
    else
        notify(src, 'ERROR', 'Kalëjimas', 'Þaidëjas nerastas.')
    end
end, false)

-- EXPORT: GetPrisoners (naudojamas s1m1s-adminmenu)
exports('GetPrisoners', function()
    local result = {}
    for identifier, data in pairs(Jailed) do
        local name = "Offline"
        if data.server_id and data.server_id > 0 then
            name = GetPlayerName(data.server_id) or "Offline"
        end
        table.insert(result, {
            id = data.server_id or 0,
            identifier = identifier,
            name = name,
            time = math.ceil((data.jail_until - os.time()) / 60),
            price = data.price or 0
        })
    end
    return result
end)
