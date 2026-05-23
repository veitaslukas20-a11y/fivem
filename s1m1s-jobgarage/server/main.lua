
ESX = exports["es_extended"]:getSharedObject()

local MySQL = rawget(_G, "MySQL")
if not MySQL then
    MySQL = {
        single = { await = function(...) return nil end },
        query  = { await = function(...) return {} end },
        update = { await = function(...) return 0 end },
        insert = { await = function(...) return 0 end },
        ready  = function(cb) if cb then cb() end end
    }
end

local lib = rawget(_G, "lib") or { callback = { register = function(...) end } }

MySQL.ready(function()
    MySQL.query.await([[
        CREATE TABLE IF NOT EXISTS jobgarage_vehicles (
            owner VARCHAR(64),
            plate VARCHAR(12) PRIMARY KEY,
            vehicle LONGTEXT,
            type VARCHAR(32),
            job VARCHAR(50),
            stored TINYINT DEFAULT 1
        )
    ]])
end)

-- ===== Safe native wrappers (skip if not available in this build) =====
local function safeCall(name, ...)
    local fn = _G[name]
    if type(fn) == 'function' then
        local ok, err = pcall(fn, ...)
        if not ok then
            print(('^3[s1m1s-jobgarage]^7 safeCall %s failed: %s'):format(name, tostring(err)))
        end
        return ok
    end
    return false
end
local function setNetExistsOnAll(netId, toggle) safeCall('SetNetworkIdExistsOnAllMachines', netId, toggle) end
local function setNetCanMigrate(netId, toggle) safeCall('SetNetworkIdCanMigrate', netId, toggle) end
local function setNetSyncToPlayer(netId, src, toggle) safeCall('SetNetworkIdSyncToPlayer', netId, src, toggle) end
local function setPlateText(veh, plate) safeCall('SetVehicleNumberPlateText', veh, plate) end

-- ===== Helpers =====
local function vehTypeForServer(vtype)
    vtype = (vtype or "car"):lower()
    if vtype == "motorcycle" or vtype == "bike" then return "bike" end
    if vtype == "bicycle" then return "bike" end -- CreateVehicleServerSetter doesn't use "bicycle"
    if vtype == "boat" then return "boat" end
    if vtype == "heli" or vtype == "helicopter" then return "heli" end
    if vtype == "plane" or vtype == "airplane" then return "plane" end
    return "automobile"
end

local function strictPlate()
    -- ABC 123 format (with space), uppercase
    local letters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'
    local numbers = '0123456789'
    local out = {}
    for i=1,3 do
        local idx = math.random(#letters)
        out[#out+1] = letters:sub(idx, idx)
    end
    out[#out+1] = ' '
    for i=1,3 do
        local idx = math.random(#numbers)
        out[#out+1] = numbers:sub(idx, idx)
    end
    return table.concat(out)
end

local function plateExists(plate)
    local row = MySQL.single.await('SELECT 1 FROM jobgarage_vehicles WHERE plate = ? LIMIT 1', { plate })
    return row ~= nil
end

local function uniquePlate()
    local tries = 0
    local p
    repeat
        p = strictPlate()
        tries = tries + 1
        if tries > 50 then break end
    until (not plateExists(p))
    return p
end

-- ====== BUY ======
lib.callback.register('s1m1s-jobgarage:buyvehicle', function(source, data)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer or not data or not data.vehicle then return false end
    local v = data.vehicle
    local props = data.props or {}
    local price = v.price
    local vtype = data.type or 'car'
    if not v.model or not price then return false end

    -- force a valid plate if missing
    if not props.plate or props.plate == '' then
        props.plate = uniquePlate()
    end

    if xPlayer.getMoney() < price then return false end
    xPlayer.removeMoney(price)

    MySQL.insert.await(
        'INSERT INTO jobgarage_vehicles (owner, plate, vehicle, type, job, stored) VALUES (?, ?, ?, ?, ?, ?)',
        { xPlayer.identifier, props.plate, json.encode(props), vtype, xPlayer.job.name, 1 }
    )
    -- keys: many scripts listen to server-side event name like this; keep original behavior
    TriggerEvent('carkeys:giveInitialKey', props.plate)
    return props.plate
end)

-- ====== RETURN LIST ======
lib.callback.register("s1m1s-jobgarages:returnJobVeh", function(source, vtype)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then return {} end
    vtype = vtype or "car"
    local rows = MySQL.query.await([[
        SELECT plate, vehicle, stored
        FROM jobgarage_vehicles
        WHERE owner = ? AND type = ? AND stored = 1
          AND (job IS NULL OR job = ?)
    ]], { xPlayer.identifier, vtype, xPlayer.job.name }) or {}
    return rows
end)

-- ====== SPAWN ======
lib.callback.register('s1m1s-jobgarages:spawnVehicle', function(source, vtype, plate, coords)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then return nil end
    if not plate or not coords then
        TriggerClientEvent('esx:showNotification', source, 'Trūksta duomenų.')
        return nil
    end
    local row = MySQL.single.await('SELECT vehicle, stored, job, type FROM jobgarage_vehicles WHERE plate = ?', { plate })
    if not row then
        TriggerClientEvent('esx:showNotification', source, 'Mašina nerasta duomenų bazėje.')
        return nil
    end
    if row.job and row.job ~= xPlayer.job.name then
        TriggerClientEvent('esx:showNotification', source, 'Ši mašina nepriklauso tavo darbui.')
        return nil
    end
    if tonumber(row.stored) == 0 then
        TriggerClientEvent('esx:showNotification', source, 'Ši mašina jau ištraukta!')
        return nil
    end
    local props = row.vehicle and json.decode(row.vehicle) or nil
    if not props or not props.model then
        TriggerClientEvent('esx:showNotification', source, 'Netinkami transporto duomenys.')
        return nil
    end

    local model = type(props.model) == 'string' and joaat(props.model) or props.model
    local vehType = vehTypeForServer(vtype)
    local x, y, z, w = coords.x + 0.0, coords.y + 0.0, coords.z + 0.0, (coords.w or 0.0) + 0.0
    local veh = CreateVehicleServerSetter(model, vehType, x, y, z, w)
    if not veh or veh == 0 then
        TriggerClientEvent('esx:showNotification', source, 'Nepavyko sukurti transporto.')
        return nil
    end

    -- Ensure entity exists before continuing
    local tries = 0
    while not DoesEntityExist(veh) and tries < 50 do
        Wait(50)
        tries = tries + 1
    end
    if not DoesEntityExist(veh) then
        TriggerClientEvent('esx:showNotification', source, 'Transporto sukurti nepavyko (entity).')
        return nil
    end

    local netId = NetworkGetNetworkIdFromEntity(veh)
    setNetExistsOnAll(netId, true)
    setNetCanMigrate(netId, true)
    setNetSyncToPlayer(netId, source, true)

    -- SERVER authority: set plate & enforce
    local finalPlate = (props.plate and props.plate ~= '') and props.plate or plate
    if not finalPlate or finalPlate == '' then finalPlate = uniquePlate() end

    setPlateText(veh, finalPlate)
    Wait(0)
    setPlateText(veh, finalPlate)
    Entity(veh).state:set('plate', finalPlate, true)
    Entity(veh).state.fuel = 100.0
    if type(SetVehicleOnGroundProperly) == 'function' then SetVehicleOnGroundProperly(veh) end

    -- Anti-NPC plate late-overrides (short loop)
    CreateThread(function()
        local i=0
        while DoesEntityExist(veh) and i < 30 do
            setPlateText(veh, finalPlate)
            Wait(100)
            i = i + 1
        end
    end)

    -- Seat buyer client-side (server task can be flaky; rely on client)
    TriggerClientEvent('s1m1s-jobgarages:clientSeat', source, netId)

    -- Mark as out of garage
    MySQL.update.await("UPDATE jobgarage_vehicles SET stored = 0 WHERE plate = ?", { finalPlate })

    -- Apply saved props client-side and clear any fade
    TriggerClientEvent('s1m1s-jobgarages:clientApplyProps', source, netId, props, finalPlate)
    TriggerClientEvent('s1m1s-jobgarages:clearFade', source)

    -- Keys after plate (server-side event, as in your original code)
    TriggerEvent('carkeys:giveInitialKey', finalPlate)

    return netId
end)

-- ====== DELETE / STORE BACK ======
RegisterNetEvent("s1m1s-jobgarages:deleteveh")
AddEventHandler("s1m1s-jobgarages:deleteveh", function(netId)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    if not xPlayer then return end
    local veh = NetworkGetEntityFromNetworkId(netId)
    if not veh or not DoesEntityExist(veh) then return end

    local plate = Entity(veh).state.plate
    if (not plate or plate == '') and type(GetVehicleNumberPlateText) == 'function' then
        local ok, p = pcall(GetVehicleNumberPlateText, veh)
        if ok then plate = (p or ""):gsub("%s+$","") end
    end
    if not plate or plate == '' then
        TriggerClientEvent('esx:showNotification', src, 'Nepavyko nustatyti numerių.')
        return
    end
    local row = MySQL.single.await("SELECT owner, job, stored FROM jobgarage_vehicles WHERE plate = ?", { plate })
    if not row then
        TriggerClientEvent('esx:showNotification', src, 'Mašina nerasta duomenų bazėje.')
        return
    end
    if row.owner ~= xPlayer.identifier or (row.job and row.job ~= xPlayer.job.name) then
        TriggerClientEvent('esx:showNotification', src, 'Negali grąžinti šios tr. priemonės.')
        return
    end
    if tonumber(row.stored) == 1 then
        DeleteEntity(veh)
        TriggerClientEvent('esx:showNotification', src, 'Ši tr. priemonė jau buvo garaže.')
        return
    end

    local props = nil
    local ok, res = pcall(function()
        return lib.callback.await('s1m1s-jobgarages:getVehProps', src, netId)
    end)
    if ok then props = res end

    if props then
        MySQL.update.await("UPDATE jobgarage_vehicles SET stored = 1, vehicle = ? WHERE plate = ?", { json.encode(props), plate })
    else
        MySQL.update.await("UPDATE jobgarage_vehicles SET stored = 1 WHERE plate = ?", { plate })
    end

    DeleteEntity(veh)
    TriggerClientEvent('esx:showNotification', src, 'Transporto priemonė pastatyta į garažą.')
end)
