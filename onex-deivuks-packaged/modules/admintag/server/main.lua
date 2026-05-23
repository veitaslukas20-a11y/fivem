local Admins = {}
ESX = exports["es_extended"]:getSharedObject()

-- ===== RANGAI (palikau kaip buvo, tik pavadinimai turi sutapti su RankKeyMapping) =====
local AdminRanks = {
    ['owner'] = { label = 'Savininkas',             prefix = 'Savininkas',             color = '~r~' },
    ['dev']   = { label = 'Developeris',            prefix = 'Developeris',            color = '~p~' },
    ['pagradmin'] = { label = 'Pagr. Administratorius(-e)', prefix = 'Pagr. Administratorius(-e)', color = '~o~' },
    ['vyradmin']  = { label = 'Vyr. Administratorius(-e)',  prefix = 'Vyr. Administratorius(-e)',  color = '~o~' },
    ['admin']     = { label = 'Administratorius(-e)',       prefix = 'Administratorius(-e)',       color = '~y~' },
    ['vyrsupport']= { label = 'Vyr. Support',        prefix = 'Vyr. Support',          color = '~b~' },
    ['support']   = { label = 'Support',             prefix = 'Support',               color = '~g~' }
}

-- ===== ŽEMĖLAPIS JSON raktų -> vidinių rangų =====
-- SUTVARKYTA: atitinka admins.json grupes
local RankKeyMapping = {
    ['owner']         = 'owner',
    ['dev']           = 'dev',
    ['pagr.admins']   = 'pagradmin',
    ['vyr.admins']    = 'vyradmin',
    ['admins']        = 'admin',       -- FIX: buvo 'admins'
    ['vyr.supports']  = 'vyrsupport',  -- FIX: buvo 'vyr.support'
    ['supports']      = 'support'      -- FIX: json turi 'supports'
}

-- ===== Užsikraunam JSON ir pasidarom indeksus =====
local adminData = json.decode(LoadResourceFile(GetCurrentResourceName(), 'admins.json')) or {}

local licenseToName   = {}
local licenseToRank   = {}

local function BuildIndexes()
    licenseToName = {}
    licenseToRank = {}
    for jsonRank, players in pairs(adminData) do
        local mapped = RankKeyMapping[jsonRank] or RankKeyMapping[string.lower(jsonRank or '')]
        if mapped then
            for displayName, license in pairs(players) do
                if type(license) == 'string' and license ~= '' then
                    licenseToName[license] = displayName
                    licenseToRank[license] = mapped
                end
            end
        end
    end
end
BuildIndexes()

-- Kad klientas pasiimtų pilną Admins lentą
lib.callback.register('tag:getAdmins', function(_)
    return Admins
end)

-- ===== Pagalbinės =====
local function GetPlayerSteamName(playerId)
    return GetPlayerName(playerId)
end

-- Patikimiau pagaunam license (pirmiausia 'license:', jei nera grazinam 'license2:')
local function GetPlayerLicense(playerId)
    local ids = GetPlayerIdentifiers(playerId)
    for _, id in ipairs(ids) do
        if id:sub(1, 8) == 'license:' then
            return id
        end
    end
    -- fallback, jeigu serveryje liktu tik license2 (JSON tokiu atveju irgi turi tureti license2)
    for _, id in ipairs(ids) do
        if id:sub(1, 9) == 'license2:' then
            return id
        end
    end
    return nil
end

local function GetPlayerStaffRank(playerId)
    local license = GetPlayerLicense(playerId)
    if not license then return nil end
    return licenseToRank[license]
end

local function GetJsonDisplayName(playerId)
    local license = GetPlayerLicense(playerId)
    if license and licenseToName[license] then
        return licenseToName[license] -- VARDAS Is admins.json
    end
    return GetPlayerSteamName(playerId) -- saugus atsarginis variantas
end

local function UpdateAdminData(playerId, showTag)
    local rankKey = GetPlayerStaffRank(playerId)
    local rankData = rankKey and AdminRanks[rankKey] or nil
    if not rankKey or not rankData then return end

    Admins[playerId] = {
        name  = rankData.prefix,          -- rodomas rango prefiksas
        color = rankData.color,
        nick  = GetJsonDisplayName(playerId), -- rodomas vardas iš admins.json, o ne Steam
        show  = showTag or false,
        rank  = rankData.label
    }

    TriggerClientEvent('tag:updateTags', -1, playerId, Admins[playerId])
end

-- ===== Komandos =====
RegisterCommand('admintag', function(source)
    local rankKey = GetPlayerStaffRank(source)
    local rankData = rankKey and AdminRanks[rankKey]
    if not rankKey or not rankData then
        return TriggerClientEvent('esx:showNotification', source, '~r~Jūs nesate administracijos narys!')
    end

    local currentState = Admins[source] and Admins[source].show or false
    UpdateAdminData(source, not currentState)

    local status = (not currentState) and '~g~ĮJUNGTAS' or '~r~IŠJUNGTAS'
    TriggerClientEvent('esx:showNotification', source, 'Administracijos žymė: '..status)
end, false)

RegisterCommand('refreshadmintags', function(source)
    if source == 0 or GetPlayerStaffRank(source) then
        adminData = json.decode(LoadResourceFile(GetCurrentResourceName(), 'admins.json')) or {}
        BuildIndexes()

        local players = ESX.GetPlayers()
        for _, playerId in ipairs(players) do
            if GetPlayerStaffRank(playerId) then
                UpdateAdminData(playerId, true)
            end
        end
        print('[TAG] Administracijos žymės perkrautos iš admins.json')
    end
end, true)

AddEventHandler('playerJoining', function()
    local playerId = source
    if GetPlayerStaffRank(playerId) then
        UpdateAdminData(playerId, true)
    end
end)

AddEventHandler('playerDropped', function()
    local playerId = source
    Admins[playerId] = nil
    TriggerClientEvent('tag:removeTag', -1, playerId)
end)

AddEventHandler('onResourceStart', function(res)
    if res ~= GetCurrentResourceName() then return end
    BuildIndexes()
    local players = ESX.GetPlayers()
    for _, playerId in ipairs(players) do
        if GetPlayerStaffRank(playerId) then
            UpdateAdminData(playerId, true)
        end
    end
    print('[TAG] Žymės paruoštos.')
end)
