---@diagnostic disable: undefined-global
--========================================================
--  House Robbery (server)
--========================================================

local ESX = exports['es_extended'] and exports['es_extended']:getSharedObject() or nil
local ox_inventory = exports.ox_inventory

-- ======= KONFIGŪRUOJAMI PARAMETRAI =======
local RESET_INTERVAL_MIN = 45
local LUXURY_GUARD_COUNT  = 2
local BUCKET_BASE         = 5000
local PENDING_LOOT_TTL    = 60

-- ======= VIDINĖ BŪSENA =======
---@class HouseRuntime
---@field bucket number
---@field players table<number, true>
---@field ped_single number|nil
---@field peds table<number, true>|nil
---@field loots table<string, true>
---@field startedAt number

local HouseState = {}      
local Sessions   = {}      
local PendingLoot = {}     

local Houses           = Config.Houses
local Interiors        = Config.Interiors
local LuxuryInteriors  = Config.LuxuryInteriors or {}
local NPCAnim          = Config.NPCAnim or { dict = "timetable@tracy@sleep@", name = "idle_c" }

--========================================================
--  PAGALBINĖS FUNKCIJOS
--========================================================

local function toNumHouseId(hid)
    local n = tonumber(hid)
    if n then return n end
    local h = GetHashKey(tostring(hid))
    return (h % 1000) + 1
end

local function bucketForHouse(hid)
    return BUCKET_BASE + toNumHouseId(hid)
end

local function ensureHouseState(hid)
    if not HouseState[hid] then HouseState[hid] = { lockpicked = false, signalization = false } end
    return HouseState[hid]
end

local function ensureSession(hid)
    local s = Sessions[hid]
    if not s then
        s = {
            bucket    = bucketForHouse(hid),
            players   = {},
            ped_single= nil,
            peds      = nil,
            loots     = {},
            startedAt = os.time()
        }
        Sessions[hid] = s
    end
    return s
end

local function addPlayerToSession(hid, src)
    local s = ensureSession(hid)
    s.players[src] = true
    SetPlayerRoutingBucket(src, s.bucket)
end

local function removePlayerFromSession(hid, src)
    local s = Sessions[hid]
    if not s then return end
    s.players[src] = nil
    SetPlayerRoutingBucket(src, 0)
end

local function forEachPlayerInSession(hid, cb)
    local s = Sessions[hid]
    if not s then return end
    for src, _ in pairs(s.players) do
        cb(src)
    end
end

local function clearSessionIfEmpty(hid)
    local s = Sessions[hid]
    if not s then return end
    for _ in pairs(s.players) do
        return
    end
    if s.ped_single then
        local ent = NetworkGetEntityFromNetworkId(s.ped_single)
        if ent and DoesEntityExist(ent) then DeleteEntity(ent) end
        s.ped_single = nil
    end
    if s.peds then
        for netId, _ in pairs(s.peds) do
            local ent = NetworkGetEntityFromNetworkId(netId)
            if ent and DoesEntityExist(ent) then DeleteEntity(ent) end
        end
        s.peds = nil
    end
    Sessions[hid] = nil
end

local function safeModel(hashOrName)
    local hash = type(hashOrName) == 'number' and hashOrName or GetHashKey(hashOrName)
    local ok = (IsModelValid and IsModelValid(hash)) or (IsModelInCdimage and IsModelInCdimage(hash))
    if not ok then return nil end
    return hash
end

local function spawnServerPed(model, coords, heading, bucket, invisible)
    local m = safeModel(model)
    if not m then return nil end

    local ped = CreatePed(4, m, coords.x, coords.y, coords.z, heading or 0.0, true, true)
    if not ped or ped == 0 then return nil end

    SetEntityAsMissionEntity(ped, true, true)
    SetEntityRoutingBucket(ped, bucket)
    SetEntityInvincible(ped, true)
    SetPedDropsWeaponsWhenDead(ped, false)
    SetBlockingOfNonTemporaryEvents(ped, true)
    if invisible then SetEntityVisible(ped, false, false) end

    FreezeEntityPosition(ped, true)

    return ped, NetworkGetNetworkIdFromEntity(ped)
end

local function getPoliceCount()
    if ESX and ESX.GetExtendedPlayers then
        local xPlayers = ESX.GetExtendedPlayers('job', 'police') or {}
        return #xPlayers
    end
    local c = 0
    for _, id in ipairs(GetPlayers()) do
        local xP = ESX and ESX.GetPlayerFromId(tonumber(id)) or nil
        if xP and xP.getJob and xP.getJob().name == 'police' then c = c + 1 end
    end
    return c
end

--========================================================
--  LOOT
--========================================================

local function basePool(isLuxury)
    local pool = {
        { label = "Telefonas",        name = "phone",   count = {1, 2}, chance = isLuxury and 75 or 70, image = "phone" },
        { label = "Racija",           name = "radio",   count = {1, 1}, chance = isLuxury and 65 or 60, image = "radio" },
        { label = "Dronas",           name = "drone",   count = {1, 1}, chance = isLuxury and 30 or 25, image = "drone" },
        { label = "Koldūnai",         name = "koldunai",count = {2, 4}, chance = 85,                   image = "bread" },
        { label = "Rolex laikrodis",  name = "watch",   count = {1, 1}, chance = isLuxury and 55 or 45, image = "watch" },
    }
    if isLuxury then
        pool[#pool+1] = { label = "Auksinė grandinėlė", name = "goldchain", count = {1, 2}, chance = 40, image = "goldchain" }
        pool[#pool+1] = { label = "Brangakmenis",       name = "diamond",   count = {1, 1}, chance = 25, image = "diamond" }
    end
    return pool
end

local function materializeCounts(items)
    local out = {}
    for i = 1, #items do
        local it = items[i]
        local c = it.count
        local cnt = type(c) == 'table' and math.random(c[1], c[2]) or (tonumber(c) or 1)
        out[#out+1] = {
            label = it.label,
            name  = it.name,
            count = cnt,
            chance= tonumber(it.chance) or 0,
            image = it.image
        }
    end
    return out
end

--========================================================
--  CALLBACKS
--========================================================

lib.callback.register('houserobbery:getConfig', function(source)
    local stateCopy = {}
    for hid, st in pairs(HouseState) do
        stateCopy[hid] = { lockpicked = st.lockpicked or false, signalization = st.signalization or false }
    end

    return {
        Houses          = Houses,
        Interiors       = Interiors,
        LuxuryInteriors = LuxuryInteriors,
        NPCAnim         = NPCAnim,
        HouseData       = stateCopy
    }
end)

lib.callback.register('houserobbery:getPolice', function(source)
    return getPoliceCount()
end)

lib.callback.register('houserobbery:getHouse', function(source, houseId)
    local src = source
    if not houseId or not Houses[houseId] then return nil end

    local hCfg = Houses[houseId]
    local interTable = (hCfg.isLuxury and LuxuryInteriors or Interiors)
    local interior = interTable and interTable[hCfg.interiorId]
    if not interior then return nil end

    local hState = ensureHouseState(houseId)
    if not hState.lockpicked then
        hState.lockpicked = true
        TriggerClientEvent('houserobbery:updateHouse', -1, houseId, 'lockpicked')
    end

    local sess = ensureSession(houseId)
    addPlayerToSession(houseId, src)

    -- Spawn NPCs
    if not hCfg.isLuxury then
        if not sess.ped_single then
            local spawn = interior.resident or interior.bed or interior.coords
            local heading = (spawn.w or 180.0)
            local ped, netId = spawnServerPed('a_m_m_business_01', vector3(spawn.x, spawn.y, spawn.z), heading, sess.bucket, false)
            if netId then sess.ped_single = netId end
        end
    else
        if not sess.peds then
            sess.peds = {}
            local spawn = interior.coords
            for i = 1, LUXURY_GUARD_COUNT do
                local offs = vector3(spawn.x + (0.8 * i), spawn.y + (0.2 * i), spawn.z)
                local ped, netId = spawnServerPed('s_m_m_highsec_01', offs, 0.0, sess.bucket, true)
                if netId then sess.peds[netId] = true end
                Wait(75)
            end
        end
    end

    return {
        interiorId = hCfg.interiorId,
        isLuxury   = hCfg.isLuxury,
        ped        = sess.ped_single,
        peds       = sess.peds,
        loots      = sess.loots
    }
end)

lib.callback.register('houserobbery:getLoot', function(source, houseId, lootId)
    local src = source
    if not houseId or not lootId then return nil end
    local hCfg = Houses[houseId]
    if not hCfg then return nil end

    local sess = ensureSession(houseId)
    if sess.loots[lootId] then return nil end

    local pool  = basePool(hCfg.isLuxury)
    local items = materializeCounts(pool)

    local shown = {}
    for i = 1, #items do
        local it = items[i]
        local roll = math.random(1, 100)
        if roll <= (it.chance or 0) then
            shown[#shown+1] = { label = it.label, name = it.name, count = it.count, image = it.image }
        end
    end

    if #shown == 0 and #items > 0 then
        table.sort(items, function(a,b) return (a.chance or 0) > (b.chance or 0) end)
        local top = items[1]
        shown[1] = { label = top.label, name = top.name, count = top.count, image = top.image }
    end

    PendingLoot[src] = PendingLoot[src] or {}
    PendingLoot[src][houseId] = PendingLoot[src][houseId] or {}
    PendingLoot[src][houseId][lootId] = {
        items     = shown,
        expiresAt = os.time() + PENDING_LOOT_TTL
    }

    return shown
end)

--========================================================
--  SERVER EVENTS
--========================================================

RegisterNetEvent('houserobbery:removeLockpick', function(_houseId)
    local src = source
    if ox_inventory then ox_inventory:RemoveItem(src, 'lockpick', 1) end
end)

RegisterNetEvent('houserobbery:hackedSignalization', function(houseId)
    local src = source
    if not houseId or not Houses[houseId] then return end
    local st = ensureHouseState(houseId)
    if not st.signalization then
        st.signalization = true
        TriggerClientEvent('houserobbery:updateHouse', -1, houseId, 'signalization')
    end
end)

RegisterNetEvent('houserobbery:updateLoot', function(houseId, lootId)
    local src = source
    if not houseId or not lootId then return end
    local hCfg = Houses[houseId]
    if not hCfg then return end

    local sess = ensureSession(houseId)
    if sess.loots[lootId] then return end

    local pendHouse = PendingLoot[src] and PendingLoot[src][houseId] or nil
    local pend = pendHouse and pendHouse[lootId] or nil
    if not pend or not pend.items or os.time() > (pend.expiresAt or 0) then
        sess.loots[lootId] = true
        forEachPlayerInSession(houseId, function(tgt)
            TriggerClientEvent('houserobbery:updateLoot', tgt, lootId)
        end)
        return
    end

    for i = 1, #pend.items do
        local item = pend.items[i]
        if ox_inventory then ox_inventory:AddItem(src, item.name, tonumber(item.count) or 1) end
    end

    sess.loots[lootId] = true
    pendHouse[lootId] = nil

    forEachPlayerInSession(houseId, function(tgt)
        TriggerClientEvent('houserobbery:updateLoot', tgt, lootId)
    end)
end)

RegisterNetEvent('houserobbery:attackPlayer', function(houseId)
    -- server-side galim daryti log/policijos dispatch
end)

RegisterNetEvent('houserobbery:leaveHouse', function(houseId)
    local src = source
    if not houseId then return end
    removePlayerFromSession(houseId, src)
    clearSessionIfEmpty(houseId)
end)

AddEventHandler('playerDropped', function()
    local src = source
    for hid, sess in pairs(Sessions) do
        if sess.players[src] then
            removePlayerFromSession(hid, src)
            clearSessionIfEmpty(hid)
        end
    end
    PendingLoot[src] = nil
end)

--========================================================
--  PERIODIC RESET
--========================================================

local function resetAllHouses()
    local list = {}
    for hid, _ in pairs(Houses) do
        HouseState[hid] = nil
        forEachPlayerInSession(hid, function(tgt) end)
        list[#list+1] = hid
        Sessions[hid] = nil
    end
    if #list > 0 then
        TriggerClientEvent('houserobbery:resetHouses', -1, list)
    end
end

if RESET_INTERVAL_MIN and RESET_INTERVAL_MIN > 0 then
    CreateThread(function()
        while true do
            Wait(RESET_INTERVAL_MIN * 60 * 1000)
            resetAllHouses()
        end
    end)
end

--========================================================
--  NPC AI LOOP
--========================================================

CreateThread(function()
    while true do
        Wait(500)

        for hid, sess in pairs(Sessions) do
            -- Single ped
            if sess.ped_single then
                local ped = NetworkGetEntityFromNetworkId(sess.ped_single)
                if ped and DoesEntityExist(ped) then
                    for src, _ in pairs(sess.players) do
                        local playerPed = GetPlayerPed(src)
                        if DoesEntityExist(playerPed) then
                            local pedCoords = GetEntityCoords(ped)
                            local playerCoords = GetEntityCoords(playerPed)
                            local dist = #(pedCoords - playerCoords)
                            if dist < 10.0 then
                                TaskCombatPed(ped, playerPed, 0, 16)
                                FreezeEntityPosition(ped, false)
                                SetEntityVisible(ped, true, false)
                            end
                        end
                    end
                end
            end

            -- Luxury guards
            if sess.peds then
                for netId,_ in pairs(sess.peds) do
                    local ped = NetworkGetEntityFromNetworkId(netId)
                    if ped and DoesEntityExist(ped) then
                        for src, _ in pairs(sess.players) do
                            local playerPed = GetPlayerPed(src)
                            if DoesEntityExist(playerPed) then
                                local pedCoords = GetEntityCoords(ped)
                                local playerCoords = GetEntityCoords(playerPed)
                                local dist = #(pedCoords - playerCoords)
                                if dist < 15.0 then
                                    TaskCombatPed(ped, playerPed, 0, 16)
                                    FreezeEntityPosition(ped, false)
                                    SetEntityVisible(ped, true, false)
                                end
                            end
                        end
                    end
                end
            end
        end
    end
end)
