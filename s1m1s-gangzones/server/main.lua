local ESX = exports['es_extended'] and exports['es_extended']:getSharedObject() or nil
if not ESX then
    TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
end

-- ================== KONFIGAS (runtime) ==================
local Config = {
    Zones = {},          -- [zoneKey] = zoneData
    GangsList = {},      -- [job]     = { official=bool, name='...' }
    GangColors = {},     -- [job]     = 'FFAABB'
    Accounts = { cash = 'money', black = 'black_money' },
    BossGrade = 3,
    Reward = { cooldownHours = 24, fallbackMoney = 50000 },
    Take = { pauseDeadlineMs = 90 * 60 * 1000 } -- 90 min UI langas
}

-- ================== BŪSENA ==================
local ZoneMembers = {}   -- [zkey] = { [src] = job }
local ActiveTakes = {}   -- [zkey] = { attackers, remaining, deadline, stopped, ... }

-- ================== UTILS ==================
local function nowMs() return math.floor(os.time() * 1000) end
local function zoneKey(title) return string.lower(title or '') end
local function toBool(v) return v == 1 or v == true end
local function mkVec(x,y,z) return vector3(tonumber(x) + 0.0, tonumber(y) + 0.0, tonumber(z) + 0.0) end
local function diffDays(sinceUnixSec) if not sinceUnixSec or sinceUnixSec == 0 then return 0 end return math.max(0, math.floor((os.time() - sinceUnixSec)/(60*60*24))) end
local function notify(src, msg) TriggerClientEvent('esx:showNotification', src, msg or '') end

local function isAllowedAdminGroup(group)
    group = (group or 'user'):lower()
    return group == 'admin' or group == 'superadmin' or group == 'owner' or group == 'dev'
end

-- ================== DB HELPERS ==================
local function dbAll(q,p) return MySQL.query.await(q,p) end
local function dbOne(q,p) return MySQL.single.await(q,p) end
local function dbExec(q,p) return MySQL.update.await(q,p) end
local function dbInsert(q,p) return MySQL.insert.await(q,p) end
local function dbScalar(q,p) return MySQL.scalar.await(q,p) end

-- ================== LOAD ==================
local function loadGangs()
    Config.GangsList = {}
    Config.GangColors = {}
    local rows = dbAll('SELECT job, official, color, name FROM d_gangzones_gangs', {})
    for _, r in ipairs(rows or {}) do
        Config.GangsList[r.job] = { official = toBool(r.official), name = r.name }
        Config.GangColors[r.job] = r.color
    end
end

local function loadZones()
    Config.Zones = {}
    local rows = dbAll([[
        SELECT id, title, type, x, y, z, size_x, size_y, size_z, rotation,
               cooldown_hours, time_minutes, official, owners, owned_since, times_taken,
               ppercent, armour_max, armour_cooldown, crafting, market_json, dealer_json,
               next_take_at, launder_cooldown_until
        FROM d_gangzones_zones
    ]], {})
    for _, r in ipairs(rows or {}) do
        local key = zoneKey(r.title)
        local zone = {
            id       = r.id,
            title    = r.title,
            coords   = mkVec(r.x, r.y, r.z),
            size     = { x = r.size_x + 0.0, y = r.size_y + 0.0, z = r.size_z + 0.0 },
            rotation = r.rotation + 0.0,
            cooldown = r.cooldown_hours,
            time     = r.time_minutes,
            type     = r.type,
            official = toBool(r.official),
            owners   = r.owners or nil,
            owned_since = r.owned_since or 0,
            daysOwned   = diffDays(r.owned_since),
            timesTaken  = r.times_taken or 0,
            ppercent    = r.ppercent,
            pcooldown   = math.max(0, (r.launder_cooldown_until or 0) - math.floor(os.time())),
            armour      = (r.armour_max and r.armour_cooldown) and { max = r.armour_max, cooldown = r.armour_cooldown } or nil,
            crafting    = r.crafting or nil,
            blackmarket = r.market_json and json.decode(r.market_json) or nil,
            drugdealer  = r.dealer_json and json.decode(r.dealer_json) or nil,
            takers      = nil,
            next_take_at = r.next_take_at or 0
        }
        if zone.drugdealer and zone.timesTaken and zone.timesTaken >= 3 then
            for _, it in pairs(zone.drugdealer) do it.timesTaken = true end
        end
        Config.Zones[key] = zone
    end
end

local function saveZone(z)
    local owners = z.owners or nil
    local market = z.blackmarket and json.encode(z.blackmarket) or nil
    local dealer = z.drugdealer and json.encode(z.drugdealer) or nil
    local armour_max, armour_cd = nil, nil
    if z.armour then armour_max = z.armour.max; armour_cd = z.armour.cooldown end

    if z.id then
        dbExec([[
            UPDATE d_gangzones_zones
               SET title=?, type=?, x=?, y=?, z=?, size_x=?, size_y=?, size_z=?, rotation=?,
                   cooldown_hours=?, time_minutes=?, official=?, owners=?, owned_since=?, times_taken=?,
                   ppercent=?, armour_max=?, armour_cooldown=?, crafting=?, market_json=?, dealer_json=?,
                   next_take_at=?, launder_cooldown_until=?
             WHERE id=?
        ]], {
            z.title, z.type, z.coords.x, z.coords.y, z.coords.z,
            z.size.x, z.size.y, z.size.z, z.rotation,
            z.cooldown, z.time, z.official and 1 or 0, owners, z.owned_since or 0, z.timesTaken or 0,
            z.ppercent, armour_max, armour_cd, z.crafting, market, dealer,
            z.next_take_at or 0, (z.launder_cooldown_until or 0), z.id
        })
    else
        z.id = dbInsert([[
            INSERT INTO d_gangzones_zones
            (title, type, x, y, z, size_x, size_y, size_z, rotation,
             cooldown_hours, time_minutes, official, owners, owned_since, times_taken,
             ppercent, armour_max, armour_cooldown, crafting, market_json, dealer_json,
             next_take_at, launder_cooldown_until)
            VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)
        ]], {
            z.title, z.type, z.coords.x, z.coords.y, z.coords.z,
            z.size.x, z.size.y, z.size.z, z.rotation,
            z.cooldown, z.time, z.official and 1 or 0, owners, z.owned_since or 0, z.timesTaken or 0,
            z.ppercent, armour_max, armour_cd, z.crafting, market, dealer,
            z.next_take_at or 0, (z.launder_cooldown_until or 0)
        })
    end
end

local function broadcastZone(zone) TriggerClientEvent('d-gangzones:update', -1, zone) end
local function pushZoneReplace(oldKey, newZone)
    if oldKey and oldKey ~= zoneKey(newZone.title) then
        TriggerClientEvent('d-gangzones:updateZone', -1, oldKey, newZone)
    else
        TriggerClientEvent('d-gangzones:update', -1, newZone)
    end
end
local function broadcastColors() TriggerClientEvent('d-gangzones:updateColors', -1, Config.GangColors) end
local function broadcastGangs()  TriggerClientEvent('d-gangzones:updateGangs', -1, Config.GangsList) end

-- ================== START ==================
AddEventHandler('onResourceStart', function(res)
    if GetCurrentResourceName() ~= res then return end
    loadGangs()
    loadZones()
    -- Job seed'inimas be esx:playerLoaded (kad neatidarytų skino)
    CreateThread(function()
        for i=1,5 do
            Wait(1000)
            for _, xp in pairs(ESX.GetExtendedPlayers() or {}) do
                TriggerClientEvent('esx:setJob', xp.source, xp.job)
            end
        end
    end)
end)

-- ================== ZONOS NARIAI (jei klientas siunčia) ==================
RegisterNetEvent('d-gangzones:addMember', function(title)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src); if not xPlayer then return end
    local key = zoneKey(title)
    ZoneMembers[key] = ZoneMembers[key] or {}
    ZoneMembers[key][src] = xPlayer.job.name
end)

RegisterNetEvent('d-gangzones:removeMember', function(title)
    local src = source
    local key = zoneKey(title)
    if ZoneMembers[key] then ZoneMembers[key][src] = nil end
end)

AddEventHandler('playerDropped', function()
    local src = source
    for k, members in pairs(ZoneMembers) do
        if members[src] then members[src] = nil end
    end
end)

-- Optional: baseevents švara (jei įdiegta)
local function removeFromAllZones(src)
    for k, members in pairs(ZoneMembers) do
        if members[src] then members[src] = nil end
    end
end
AddEventHandler('baseevents:onPlayerDied',   function() removeFromAllZones(source) end)
AddEventHandler('baseevents:onPlayerKilled', function() removeFromAllZones(source) end)

-- ================== CONFIG CALLBACK ==================
lib.callback.register('d-gangzones:getConfig', function(src)
    for k, z in pairs(Config.Zones) do
        z.daysOwned = diffDays(z.owned_since)
        if z.drugdealer then
            local boost = z.timesTaken and z.timesTaken >= 3
            for _, it in pairs(z.drugdealer) do it.timesTaken = boost or nil end
        end
    end
    return Config
end)

-- ================== ZONOS INFO ==================
lib.callback.register('d-gangzones:zoneInfo', function(src, title)
    local z = Config.Zones[zoneKey(title)]
    if not z then return end
    local owners = z.owners and (Config.GangsList[z.owners] and Config.GangsList[z.owners].name or z.owners) or 'Niekas'
    local info = ('~y~%s~s~\nTipas: ~b~%s~s~, Oficialumas: ~b~%s~s~\nValdytojai: ~g~%s~s~\nUžėmimo laikas: ~b~%d min~s~, Cooldown: ~b~%d h~s~\nKiek kartų užimta: ~b~%d~s~, Dienų valdyta: ~b~%d~s~'):
                 format(z.title, z.type, z.official and 'Taip' or 'Ne', owners, z.time or 15, z.cooldown or 12, z.timesTaken or 0, z.daysOwned or 0)
    notify(src, info)
    return true
end)

-- ================== ADMIN CMD ==================
RegisterCommand('gzadmin', function(src)
    local xPlayer = ESX.GetPlayerFromId(src); if not xPlayer then return end
    local group = xPlayer.getGroup and xPlayer.getGroup() or 'user'
    if not isAllowedAdminGroup(group) then return notify(src, 'Neturite teisės atidaryti zonų administravimo meniu.') end
    -- atidarom kliento meniu (client turi lib.callback.register('d-gangzones:adminmenu'))
    lib.callback.await('d-gangzones:adminmenu', src)
end, false)

-- ================== ESX JOB SYNC ==================
AddEventHandler('esx:playerLoaded', function(playerId, xPlayer)
    if not xPlayer then return end
    TriggerClientEvent('esx:setJob', playerId, xPlayer.job)
end)

AddEventHandler('esx:setJob', function(playerId, job, lastJob)
    TriggerClientEvent('esx:setJob', playerId, job)
end)

-- ================== GLOBAL eksportai kitiems failams ==================
_G.dgz = {
    cfg = Config,
    members = ZoneMembers,
    active = ActiveTakes,
    saveZone = saveZone,
    broadcastZone = broadcastZone,
    pushZoneReplace = pushZoneReplace,
    loadZones = loadZones,
    loadGangs = loadGangs,
    colorsChanged = broadcastColors,
    gangsChanged = broadcastGangs,
    nowMs = nowMs,
}
