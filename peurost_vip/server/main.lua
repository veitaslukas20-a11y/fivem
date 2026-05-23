local RES_NAME = GetCurrentResourceName()

--========================================================
-- Framework & library detection
--========================================================
local ESX, QBCore

if GetResourceState('es_extended') == 'started' then
    ESX = exports['es_extended']:getSharedObject()
end

if GetResourceState('qb-core') == 'started' then
    QBCore = exports['qb-core']:GetCoreObject()
end

-- ox_lib present?
if not lib then
    print(('[%s] ERROR: ox_lib not found (lib is nil).'):format(RES_NAME))
    print(('-> Please ensure ox_lib is started before %s.'):format(RES_NAME))
end

--========================================================
-- Database wrapper (oxmysql preferred, otherwise MySQL global/async)
--========================================================
local function _await(p)
    return Citizen.Await(p)
end

local function db_query(query, params)
    params = params or {}
    if MySQL and MySQL.query and MySQL.query.await then
        return MySQL.query.await(query, params) or {}
    end
    if GetResourceState('oxmysql') == 'started' then
        local pr = promise.new()
        exports.oxmysql:execute(query, params, function(rows)
            pr:resolve(rows or {})
        end)
        return _await(pr)
    end
    if MySQL and MySQL.Async and MySQL.Async.fetchAll then
        local pr = promise.new()
        MySQL.Async.fetchAll(query, params, function(rows)
            pr:resolve(rows or {})
        end)
        return _await(pr)
    end
    print(('[%s] WARNING: No SQL adapter detected for query.'):format(RES_NAME))
    return {}
end

local function db_exec(query, params)
    params = params or {}
    if MySQL and MySQL.update and MySQL.update.await then
        return MySQL.update.await(query, params) or 0
    end
    if GetResourceState('oxmysql') == 'started' then
        local pr = promise.new()
        exports.oxmysql:execute(query, params, function(affected)
            pr:resolve(affected or 0)
        end)
        return _await(pr)
    end
    if MySQL and MySQL.Async and MySQL.Async.execute then
        local pr = promise.new()
        MySQL.Async.execute(query, params, function(affected)
            pr:resolve(affected or 0)
        end)
        return _await(pr)
    end
    print(('[%s] WARNING: No SQL adapter detected for exec.'):format(RES_NAME))
    return 0
end

--========================================================
-- Local config for DB integration (edit here if needed)
--========================================================
local DB = {}

-- Our VIP state table (auto-created)
DB.VIP_TABLE = 'peurost_vip'

-- ESX vehicle storage (typical)
DB.ESX = {
    table = 'owned_vehicles',
    owner = 'owner',
    plate = 'plate',
    vehicle_json = 'vehicle', -- JSON column
}

-- QBCore vehicle storage (typical)
DB.QB = {
    table = 'player_vehicles',
    citizenid = 'citizenid',
    plate = 'plate',
    mods_json = 'mods',       -- JSON column name in many servers (sometimes it's 'vehicle')
    vehicle_str = 'vehicle',  -- spawn name column
    hash = 'hash',            -- joaat / model hash column (if present)
}

-- Money source preference when buying VIP imports
local MONEY_PREF = {
    primary = 'bank',     -- 'bank' for QB/ESX accounts
    fallback = 'cash',    -- fallback money pocket
}

--========================================================
-- Helpers
--========================================================
local function now() return os.time() end

local function joaat_model(name)
    if joaat then return joaat(name) end
    return GetHashKey(name)
end

local function to_upper(s)
    return (s and s:upper()) or s
end

local function notify(src, title, desc, typ)
    -- Server-side notify via ox_lib (if available)
    if GetResourceState('ox_lib') == 'started' then
        TriggerClientEvent('ox_lib:notify', src, {
            title = title or 'Info',
            description = desc or '',
            type = typ or 'inform'
        })
        return
    end
    -- Fallback
    TriggerClientEvent('chat:addMessage', src, {
        args = {title or 'VIP', desc or ''}
    })
end

local function getIdentifier(src)
    -- Preferred: framework-unique id
    if QBCore then
        local Player = QBCore.Functions.GetPlayer(src)
        if Player and Player.PlayerData and Player.PlayerData.citizenid then
            return ('qb:%s'):format(Player.PlayerData.citizenid), 'qb', Player
        end
    end
    if ESX then
        local xP = ESX.GetPlayerFromId(src)
        if xP and xP.identifier then
            return ('esx:%s'):format(xP.identifier), 'esx', xP
        end
    end
    -- Standalone: use license if present
    local license, discord
    for _, id in ipairs(GetPlayerIdentifiers(src)) do
        if id:find('license:') == 1 then
            license = id:gsub('license:', '')
        elseif id:find('discord:') == 1 then
            discord = id:gsub('discord:', '')
        end
    end
    return ('lic:%s'):format(license or ('src:'..tostring(src))), 'standalone', nil, discord
end

local function getDiscordId(src)
    for _, id in ipairs(GetPlayerIdentifiers(src)) do
        if id:sub(1, 8) == 'discord:' then
            return id:sub(9)
        end
    end
end

-- Try to get discord roles from common resources
local function getDiscordRoles(src)
    -- Badger_Discord_API
    if GetResourceState('Badger_Discord_API') == 'started' then
        local ok, roles = pcall(function()
            return exports['Badger_Discord_API']:GetDiscordRoles(src)
        end)
        if ok and roles then return roles end
    end
    -- discordroles
    if GetResourceState('discordroles') == 'started' then
        local ok, roles = pcall(function()
            return exports['discordroles']:GetRoles(src)
        end)
        if ok and roles then return roles end
    end
    -- discord_perms
    if GetResourceState('discord-perms') == 'started' then
        local ok, roles = pcall(function()
            return exports['discord-perms']:GetDiscordRoles(src)
        end)
        if ok and roles then return roles end
    end
    return {}
end

local function resolveVipLevel(src)
    local roles = getDiscordRoles(src)
    local highest = 0
    if roles and next(roles) then
        for role, lvl in pairs(Config.Roles or {}) do
            -- roles may be an array or a set-like table; normalize
            if (type(roles) == 'table' and (roles[role] or (type(roles[1]) == 'string' and table.contains and table.contains(roles, role)))) then
                highest = math.max(highest, tonumber(lvl) or 0)
            elseif type(roles) == 'table' then
                -- if array
                for _, r in ipairs(roles) do
                    if tostring(r) == tostring(role) then
                        highest = math.max(highest, tonumber(lvl) or 0)
                        break
                    end
                end
            end
        end
    end
    return highest
end

-- Ensure VIP row exists
local function ensureVipRow(identifier)
    local rows = db_query(('SELECT * FROM %s WHERE identifier = ? LIMIT 1'):format(DB.VIP_TABLE), {identifier})
    if not rows or not rows[1] then
        db_exec(('INSERT INTO %s (identifier) VALUES (?)'):format(DB.VIP_TABLE), {identifier})
        return {
            identifier = identifier,
            level = 0,
            last_plate_change = 0,
            kit_last = 0,
            inventory_claimed = 0,
            discounts_claimed = 0,
            vehicle_last = 0,
            legend_claimed = 0
        }
    end
    return rows[1]
end

local function updateVipColumns(identifier, cols)
    if not cols or not next(cols) then return 0 end
    local sets, params = {}, {}
    for k, v in pairs(cols) do
        sets[#sets+1] = ('`%s` = ?'):format(k)
        params[#params+1] = v
    end
    params[#params+1] = identifier
    local q = ('UPDATE %s SET %s WHERE identifier = ?'):format(DB.VIP_TABLE, table.concat(sets, ', '))
    return db_exec(q, params)
end

-- Money API (QB/ESX/none)
local function getMoney(src, account)
    account = account or MONEY_PREF.primary
    if QBCore then
        local Player = QBCore.Functions.GetPlayer(src)
        if not Player then return 0 end
        local amt = Player.Functions.GetMoney(account)
        if (not amt or amt <= 0) and MONEY_PREF.fallback and MONEY_PREF.fallback ~= account then
            amt = Player.Functions.GetMoney(MONEY_PREF.fallback) or 0
        end
        return amt or 0
    elseif ESX then
        local xP = ESX.GetPlayerFromId(src)
        if not xP then return 0 end
        local acc = xP.getAccount(account)
        if acc and acc.money then
            return acc.money
        end
        if account == 'cash' then
            return xP.getMoney() or 0
        end
        return 0
    end
    return 999999999 -- standalone fallback (no framework) for testing
end

local function removeMoney(src, amount, account)
    account = account or MONEY_PREF.primary
    if QBCore then
        local Player = QBCore.Functions.GetPlayer(src)
        if not Player then return false end
        local ok = Player.Functions.RemoveMoney(account, amount, 'vip-vehicle')
        if not ok and MONEY_PREF.fallback and MONEY_PREF.fallback ~= account then
            ok = Player.Functions.RemoveMoney(MONEY_PREF.fallback, amount, 'vip-vehicle')
        end
        return ok and true or false
    elseif ESX then
        local xP = ESX.GetPlayerFromId(src)
        if not xP then return false end
        local acc = xP.getAccount(account)
        if acc and acc.money and acc.money >= amount then
            xP.removeAccountMoney(account, amount)
            return true
        end
        if account == 'cash' and (xP.getMoney() or 0) >= amount then
            xP.removeMoney(amount)
            return true
        end
        return false
    end
    return true -- standalone fallback
end

-- Inventory add item (ox_inventory > QB > ESX)
local function addItem(src, name, count, meta)
    count = count or 1
    meta = meta or {}
    if GetResourceState('ox_inventory') == 'started' then
        local ok = exports.ox_inventory:AddItem(src, name, count, meta)
        return ok and true or false
    end
    if QBCore then
        local Player = QBCore.Functions.GetPlayer(src)
        if not Player then return false end
        return Player.Functions.AddItem(name, count, false, meta) and true or false
    end
    if ESX then
        local xP = ESX.GetPlayerFromId(src)
        if not xP then return false end
        xP.addInventoryItem(name, count)
        return true
    end
    return true
end

-- Apply inventory upgrades if ox_inventory present
local function applyInventoryUpgrade(src, levelCfg)
    if not levelCfg or not levelCfg.inventory then return false end
    if GetResourceState('ox_inventory') == 'started' then
        if levelCfg.inventory.slots then
            pcall(function() exports.ox_inventory:SetSlotCount(src, levelCfg.inventory.slots) end)
        end
        if levelCfg.inventory.weigth then
            pcall(function()
                -- Both spellings used in configs; support SetMaxWeight / SetWeight
                if exports.ox_inventory.SetMaxWeight then
                    exports.ox_inventory:SetMaxWeight(src, levelCfg.inventory.weigth)
                elseif exports.ox_inventory.SetWeight then
                    exports.ox_inventory:SetWeight(src, levelCfg.inventory.weigth)
                end
            end)
        end
        return true
    end
    return false
end

--========================================================
-- Vehicle DB helpers (ESX / QB)
--========================================================
local function isPlateTaken_all(plate)
    plate = to_upper(plate)
    -- ESX
    local esxRows = db_query(('SELECT %s FROM %s WHERE %s = ? LIMIT 1')
        :format(DB.ESX.plate, DB.ESX.table, DB.ESX.plate), {plate})
    if esxRows and esxRows[1] then return true end

    -- QB
    local qbRows = db_query(('SELECT %s FROM %s WHERE %s = ? LIMIT 1')
        :format(DB.QB.plate, DB.QB.table, DB.QB.plate), {plate})
    if qbRows and qbRows[1] then return true end

    return false
end

local function findOwnedVehicleRow(src, plate)
    plate = to_upper(plate)
    if QBCore then
        local Player = QBCore.Functions.GetPlayer(src)
        if not Player then return nil, nil end
        local cid = Player.PlayerData.citizenid
        local rows = db_query(('SELECT * FROM %s WHERE %s = ? AND %s = ? LIMIT 1')
            :format(DB.QB.table, DB.QB.citizenid, DB.QB.plate), {cid, plate})
        if rows and rows[1] then return 'qb', rows[1] end
        return nil, nil
    elseif ESX then
        local xP = ESX.GetPlayerFromId(src)
        if not xP then return nil, nil end
        local owner = xP.identifier
        local rows = db_query(('SELECT * FROM %s WHERE %s = ? AND %s = ? LIMIT 1')
            :format(DB.ESX.table, DB.ESX.owner, DB.ESX.plate), {owner, plate})
        if rows and rows[1] then return 'esx', rows[1] end
        return nil, nil
    end
    -- standalone: no ownership check possible
    return 'standalone', nil
end

local function updatePlateOwner(src, oldPlate, newPlate)
    newPlate = to_upper(newPlate)
    oldPlate = to_upper(oldPlate)
    local flavor, row = findOwnedVehicleRow(src, oldPlate)

    if flavor == 'qb' and row then
        -- Update both column and JSON (if present)
        local modsJSON = row[DB.QB.mods_json]
        local updatedJSON
        if modsJSON and modsJSON ~= '' then
            local ok, mods = pcall(json.decode, modsJSON)
            if ok and type(mods) == 'table' then
                mods.plate = newPlate
                updatedJSON = json.encode(mods)
            end
        end
        if updatedJSON then
            db_exec(('UPDATE %s SET %s = ?, %s = ? WHERE %s = ? AND %s = ?')
                :format(DB.QB.table, DB.QB.plate, DB.QB.mods_json, DB.QB.citizenid, DB.QB.plate),
                {newPlate, updatedJSON, row[DB.QB.citizenid], oldPlate})
        else
            db_exec(('UPDATE %s SET %s = ? WHERE %s = ? AND %s = ?')
                :format(DB.QB.table, DB.QB.plate, DB.QB.citizenid, DB.QB.plate),
                {newPlate, row[DB.QB.citizenid], oldPlate})
        end
        return true
    elseif flavor == 'esx' and row then
        -- Update both column and JSON
        local vehJSON = row[DB.ESX.vehicle_json]
        local updatedJSON
        if vehJSON and vehJSON ~= '' then
            local ok, props = pcall(json.decode, vehJSON)
            if ok and type(props) == 'table' then
                props.plate = newPlate
                updatedJSON = json.encode(props)
            end
        end
        if updatedJSON then
            db_exec(('UPDATE %s SET %s = ?, %s = ? WHERE %s = ? AND %s = ?')
                :format(DB.ESX.table, DB.ESX.plate, DB.ESX.vehicle_json, DB.ESX.owner, DB.ESX.plate),
                {newPlate, updatedJSON, row[DB.ESX.owner], oldPlate})
        else
            db_exec(('UPDATE %s SET %s = ? WHERE %s = ? AND %s = ?')
                :format(DB.ESX.table, DB.ESX.plate, DB.ESX.owner, DB.ESX.plate),
                {newPlate, row[DB.ESX.owner], oldPlate})
        end
        return true
    elseif flavor == 'standalone' then
        -- Can't validate ownership; skip DB
        return true
    end

    return false
end

local function saveVehicleToDB(src, spawnName, modelHash, props, plate)
    plate = to_upper(plate)

    if QBCore then
        local Player = QBCore.Functions.GetPlayer(src)
        if not Player then return false end
        local cid = Player.PlayerData.citizenid
        local license
        for _, id in ipairs(GetPlayerIdentifiers(src)) do
            if id:find('license:') == 1 then license = id:gsub('license:', '') break end
        end

        local modsJSON = json.encode(props or {})
        local q = ('INSERT INTO %s (%s, license, %s, %s, %s, %s, garage, state, depotprice) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)')
            :format(DB.QB.table, DB.QB.citizenid, DB.QB.vehicle_str, DB.QB.hash, DB.QB.mods_json, DB.QB.plate)
        local affected = db_exec(q, {cid, license or '', spawnName, modelHash, modsJSON, plate, 'A', 1, 0})
        return affected > 0
    elseif ESX then
        local xP = ESX.GetPlayerFromId(src)
        if not xP then return false end
        local vehicleJSON = json.encode(props or {})
        local q = ('INSERT INTO %s (%s, %s, %s, type, stored) VALUES (?, ?, ?, ?, ?)')
            :format(DB.ESX.table, DB.ESX.owner, DB.ESX.plate, DB.ESX.vehicle_json)
        local affected = db_exec(q, {xP.identifier, plate, vehicleJSON, 'car', 1})
        return affected > 0
    end

    -- Standalone: nothing to save
    return true
end

--========================================================
-- VIP table bootstrap
--========================================================
CreateThread(function()
    -- create vip table if not exists
    local q = ([[
        CREATE TABLE IF NOT EXISTS %s (
            identifier VARCHAR(64) PRIMARY KEY,
            level INT DEFAULT 0,
            last_plate_change INT DEFAULT 0,
            kit_last INT DEFAULT 0,
            inventory_claimed TINYINT DEFAULT 0,
            discounts_claimed TINYINT DEFAULT 0,
            vehicle_last INT DEFAULT 0,
            legend_claimed TINYINT DEFAULT 0
        )
    ]]):format(DB.VIP_TABLE)
    db_exec(q)
    print(('[%s] VIP table ensured: %s'):format(RES_NAME, DB.VIP_TABLE))
end)

--========================================================
-- Core: compute data blob for clients
--========================================================
local function buildVipData(src)
    local identifier, flavor, fwPlayer = getIdentifier(src)
    local level = resolveVipLevel(src)
    local row = ensureVipRow(identifier)
    if row.level ~= level then
        updateVipColumns(identifier, { level = level })
    end

    -- send to client for their local export
    TriggerClientEvent('vipmenu:setLevel', src, level)

    local data = { level = level }

    local cfgLvl = Config.Levels[level] or {}

    -- Vehicle plates cooldown
    local platesCooldown = cfgLvl.vehicleNumbers
    data.vehiclePlates = { state = false, timeLeft = 0 }
    if platesCooldown then
        local elapsed = now() - (row.last_plate_change or 0)
        local left = math.max(platesCooldown - elapsed, 0)
        data.vehiclePlates.state = (left <= 0)
        data.vehiclePlates.timeLeft = left
    end

    -- Kit (optional)
    if cfgLvl.kit then
        local delay = cfgLvl.kit.delay or 0
        local elapsed = now() - (row.kit_last or 0)
        local left = math.max(delay - elapsed, 0)
        data.kit = {
            state = (left <= 0),
            timeLeft = left
        }
    end

    -- Inventory (optional one-time claim)
    if cfgLvl.inventory then
        data.inventory = {
            state = (row.inventory_claimed or 0) == 0
        }
    end

    -- Discounts (optional one-time claim)
    if cfgLvl.discounts then
        data.discounts = {
            state = (row.discounts_claimed or 0) == 0
        }
    end

    -- Vehicle imports cooldown
    if cfgLvl.vehicle then
        local elapsed = now() - (row.vehicle_last or 0)
        local left = math.max(cfgLvl.vehicle - elapsed, 0)
        data.vehicle = {
            state = (left <= 0),
            timeLeft = left
        }
    end

    -- Legend gift (client v2)
    if cfgLvl.legendGift then
        data.legendGift = {
            state = (row.legend_claimed or 0) == 0
        }
    end

    return data, cfgLvl, row, identifier
end

--========================================================
-- Callbacks
--========================================================
lib.callback.register('peurost_vip:GetVIPData', function(source)
    local data = buildVipData(source)
    return data
end)

lib.callback.register('peurost_vip:ChangeVehiclePlates', function(source, oldPlate, newPlate)
    local data, cfgLvl, row, identifier = buildVipData(source)

    if not cfgLvl.vehicleNumbers then
        return { state = false, message = 'Neturi leidimo keisti numerių.' }
    end

    oldPlate = to_upper(oldPlate)
    newPlate = to_upper(newPlate or '')

    -- cooldown check
    if not data.vehiclePlates.state then
        return { state = false, message = 'Laukimo laikas dar nesibaigė.' }
    end

    -- sanity checks (client already validates chars/length)
    if #newPlate < 1 or #newPlate > 8 then
        return { state = false, message = 'Neteisinga įvestis.' }
    end

    -- new plate unique?
    if isPlateTaken_all(newPlate) then
        return { state = false, message = 'Tokie numeriai jau naudojami.' }
    end

    -- ensure ownership in DB (when framework present)
    local ok = updatePlateOwner(source, oldPlate, newPlate)
    if not ok then
        return { state = false, message = 'Negalima keisti šios transporto priemonės numerių.' }
    end

    -- set cooldown
    updateVipColumns(identifier, { last_plate_change = now() })

    return { state = true, message = 'Valstybiniai numeriai sėkmingai pakeisti.' }
end)

lib.callback.register('peurost_vip:ClaimKit', function(source)
    local data, cfgLvl, row, identifier = buildVipData(source)
    if not cfgLvl.kit then
        return { state = false, message = 'Neturi teisės gauti rinkinuko.' }
    end
    local delay = cfgLvl.kit.delay or 0
    local elapsed = now() - (row.kit_last or 0)
    if elapsed < delay then
        return { state = false, message = 'Rinkinukas dar nepasiekiamas.' }
    end

    local allOk = true
    for _, it in ipairs(cfgLvl.kit.items or {}) do
        local ok = addItem(source, it.item, it.amount or 1)
        if not ok then allOk = false end
    end

    if allOk then
        updateVipColumns(identifier, { kit_last = now() })
        return { state = true, message = 'Rinkinukas įteiktas.' }
    else
        return { state = false, message = 'Nepavyko įdėti kai kurių daiktų.' }
    end
end)

lib.callback.register('peurost_vip:ClaimInventory', function(source)
    local data, cfgLvl, row, identifier = buildVipData(source)
    if not cfgLvl.inventory then
        return { state = false, message = 'Inventoriaus padidinimas nepasiekiamas.' }
    end
    if (row.inventory_claimed or 0) ~= 0 then
        return { state = false, message = 'Inventoriaus padidinimas jau atsiimtas.' }
    end

    local slots = cfgLvl.inventory.slots or 80
    local weight = cfgLvl.inventory.weigth or 60000
    applyInventoryUpgrade(source, cfgLvl)

    if QBCore then
        local Player = QBCore.Functions.GetPlayer(source)
        if Player then
            db_exec('UPDATE players SET vip_slots = ?, vip_weight = ? WHERE citizenid = ?', { slots, weight, Player.PlayerData.citizenid })
        end
    elseif ESX then
        local xP = ESX.GetPlayerFromId(source)
        if xP then
            db_exec('UPDATE users SET vip_slots = ?, vip_weight = ? WHERE identifier = ?', { slots, weight, xP.identifier })
        end
    end

    updateVipColumns(identifier, { inventory_claimed = 1 })
    return { state = true, message = 'Inventoriaus padidinimas pritaikytas ir išsaugotas.' }
end)

lib.callback.register('peurost_vip:ClaimDiscounts', function(source)
    local data, cfgLvl, row, identifier = buildVipData(source)
    if not cfgLvl.discounts then
        return { state = false, message = 'Nuolaidos nepasiekiamos.' }
    end
    if (row.discounts_claimed or 0) ~= 0 then
        return { state = false, message = 'Nuolaidos jau pritaikytos.' }
    end

    updateVipColumns(identifier, { discounts_claimed = 1 })
    return { state = true, message = 'Nuolaidos pritaikytos.' }
end)

lib.callback.register('peurost_vip:ClaimLegendGift', function(source)
    local data, cfgLvl, row, identifier = buildVipData(source)
    if not cfgLvl.legendGift then
        return { state = false, message = 'Dovana nepasiekiama.' }
    end
    if (row.legend_claimed or 0) ~= 0 then
        return { state = false, message = 'Dovana jau atsiimta.' }
    end

    local items = cfgLvl.legendGift.items or {}
    local allOk = true
    for _, it in ipairs(items) do
        local ok = addItem(source, it.item, it.amount or 1)
        if not ok then allOk = false end
    end
    if allOk then
        updateVipColumns(identifier, { legend_claimed = 1 })
        return { state = true, message = 'Legendos dovana įteikta.' }
    else
        return { state = false, message = 'Nepavyko įteikti dovanos.' }
    end
end)

lib.callback.register('vipmenu:buyVehicle', function(source, key)
    local vcfg = Config.Vehicles and Config.Vehicles[key]
    if not vcfg then
        notify(source, 'VIP', 'Transporto priemonė nerasta.', 'error')
        return false
    end

    local data, cfgLvl, row, identifier = buildVipData(source)
    if not cfgLvl.vehicle then
        notify(source, 'VIP', 'Importiniai automobiliai nepasiekiami jūsų lygiui.', 'error')
        return false
    end
    if not data.vehicle or not data.vehicle.state then
        notify(source, 'VIP', 'Negalite pirkti dabar (laukiama pagal VIP laikmatį).', 'error')
        return false
    end

    -- Money check
    local price = tonumber(vcfg.price or 0) or 0
    if price > 0 then
        if getMoney(source, MONEY_PREF.primary) < price then
            notify(source, 'VIP', 'Nepakanka lėšų.', 'error')
            return false
        end
        if not removeMoney(source, price, MONEY_PREF.primary) then
            notify(source, 'VIP', 'Nepavyko nuskaičiuoti lėšų.', 'error')
            return false
        end
    end

    -- Ask client to build vehicle props & a plate
    local modelHash = joaat_model(vcfg.spawn_name)
    local props = lib.callback.await('vipmenu:getProperties', source, { model = modelHash })
    if not props or not props.plate then
        notify(source, 'VIP', 'Nepavyko paruošti transporto priemonės.', 'error')
        return false
    end

    -- Save vehicle to DB
    local ok = saveVehicleToDB(source, vcfg.spawn_name, modelHash, props, props.plate)
    if not ok then
        notify(source, 'VIP', 'Nepavyko įrašyti transporto priemonės į garžą.', 'error')
        return false
    end

    -- Set import cooldown
    updateVipColumns(identifier, { vehicle_last = now() })

    notify(source, 'VIP', ('Nupirkote %s už %s€.\nNumeriai: %s'):format(vcfg.name or vcfg.spawn_name, price, props.plate), 'success')
    return true
end)

--========================================================
-- Public exports for other resources
--========================================================
exports('GetVipLevel', function(src)
    local identifier = getIdentifier(src)
    if not identifier then return 0 end
    return resolveVipLevel(src)
end)

exports('HasVip', function(src, minLevel)
    local lvl = resolveVipLevel(src)
    return lvl >= (minLevel or 1)
end)

exports('GetVipDiscountForJob', function(src, jobName)
    local lvl = resolveVipLevel(src)
    local cfg = Config.Levels and Config.Levels[lvl]
    if not cfg or not cfg.discounts or not jobName then return 0 end

    -- Ensure user claimed discounts
    local identifier = getIdentifier(src)
    local row = ensureVipRow(identifier)
    if (row.discounts_claimed or 0) == 0 then return 0 end

    return tonumber(cfg.discounts[jobName]) or 0
end)

--========================================================
-- Optional: apply inventory boost on (re)load (best effort)
--========================================================
local function tryApplyInvOnLoad(src)
    local lvl = resolveVipLevel(src)
    local cfg = Config.Levels and Config.Levels[lvl]
    if not cfg or not cfg.inventory then return end

    local identifier = getIdentifier(src)
    local row = ensureVipRow(identifier)

    if (row.inventory_claimed or 0) ~= 0 then
        local slots, weight

        if QBCore then
            local Player = QBCore.Functions.GetPlayer(src)
            if Player then
                local rows = db_query('SELECT vip_slots, vip_weight FROM players WHERE citizenid = ? LIMIT 1', { Player.PlayerData.citizenid })
                if rows and rows[1] then
                    slots = rows[1].vip_slots or cfg.inventory.slots
                    weight = rows[1].vip_weight or cfg.inventory.weigth
                end
            end
        elseif ESX then
            local xP = ESX.GetPlayerFromId(src)
            if xP then
                local rows = db_query('SELECT vip_slots, vip_weight FROM users WHERE identifier = ? LIMIT 1', { xP.identifier })
                if rows and rows[1] then
                    slots = rows[1].vip_slots or cfg.inventory.slots
                    weight = rows[1].vip_weight or cfg.inventory.weigth
                end
            end
        end

        if slots and weight then
            pcall(function()
                exports.ox_inventory:SetSlotCount(src, slots)
                exports.ox_inventory:SetMaxWeight(src, weight)
            end)
        end
    end
end

AddEventHandler('playerJoining', function()
    local src = source
    SetTimeout(5000, function()
        tryApplyInvOnLoad(src)
    end)
end)

if QBCore then
    RegisterNetEvent('QBCore:Server:OnPlayerLoaded', function()
        local src = source
        SetTimeout(3500, function()
            tryApplyInvOnLoad(src)
        end)
    end)
end

if ESX then
    RegisterNetEvent('esx:playerLoaded', function()
        local src = source
        SetTimeout(3500, function()
            tryApplyInvOnLoad(src)
        end)
    end)
end
