ESX = ESX or exports['es_extended']:getSharedObject()
local MySQL = rawget(_G, 'MySQL') or MySQL

local function normalizePlate(p)
    if not p then return nil end
    local s = tostring(p)
    s = s:gsub('[^%w ]', '')
    s = s:gsub('%s+', ' ')
    s = s:gsub('^%s+', ''):gsub('%s+$', '')
    s = s:upper()
    if #s > 8 then s = s:sub(1, 8) end
    return s
end

local CLASS_TABLE = {
    Land  = 'owned_vehicles',
    Truck = 'owned_vehicles',
    Water = 'owned_laivai',
    Sky   = 'owned_planes',
}

local function toClassFromParam(vehicleType)
    if not vehicleType or vehicleType == '' then return 'Land' end
    local t = tostring(vehicleType):lower()
    if t == 'owned_vehicles' or t == 'car' or t == 'cars' or t == 'land' then
        return 'Land'
    elseif t == 'owned_laivai' or t == 'boat' or t == 'boats' or t == 'water' then
        return 'Water'
    elseif t == 'owned_planes' or t == 'plane' or t == 'planes' or t == 'sky' or t == 'air' then
        return 'Sky'
    elseif t == 'truck' or t == 'trucks' then
        return 'Truck'
    end
    return 'Land'
end

local function tableForClass(class)
    return CLASS_TABLE[class] or 'owned_vehicles'
end

local function typeForClass(class)
    if class == 'Water' then return 'boat'
    elseif class == 'Sky' then return 'plane'
    else return 'car' end
end

local function plateExistsAnywhere(nPlate)
    local key = (nPlate or ''):gsub('%s+', ''):upper()
    local tbls = { 'owned_vehicles', 'owned_laivai', 'owned_planes' }
    for _, tbl in ipairs(tbls) do
        local ok, row = pcall(MySQL.single.await,
            ('SELECT plate FROM `%s` WHERE UPPER(REPLACE(plate," ","")) = ? LIMIT 1'):format(tbl),
            { key }
        )
        if ok and row then return true, tbl end
    end
    return false, nil
end

local function sendNotification(source, data)
    if GetResourceState('litrp-hud') == 'started' then
        TriggerClientEvent('1x:hud:notification', source, data)
    else
        TriggerClientEvent('chat:addMessage', source, {
            color = {255, 255, 255},
            multiline = true,
            args = { data.title or 'Info', data.message or 'No message' }
        })
    end
end

AddEventHandler('onResourceStart', function(resourceName)
    if resourceName ~= GetCurrentResourceName() then return end
    MySQL.query.await([[
        CREATE TABLE IF NOT EXISTS `dec4t_vehicle_names` (
            `plate` varchar(12) NOT NULL,
            `name` varchar(64) DEFAULT NULL,
            PRIMARY KEY (`plate`)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
    ]])
    MySQL.query.await([[
        CREATE TABLE IF NOT EXISTS `owned_laivai` (
            `owner` varchar(46) DEFAULT NULL,
            `plate` varchar(12) NOT NULL,
            `vehicle` longtext DEFAULT NULL,
            `type` varchar(20) NOT NULL DEFAULT 'boat',
            `stored` tinyint(1) NOT NULL DEFAULT 1,
            PRIMARY KEY (`plate`)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
    ]])
    MySQL.query.await([[
        CREATE TABLE IF NOT EXISTS `owned_planes` (
            `owner` varchar(46) DEFAULT NULL,
            `plate` varchar(12) NOT NULL,
            `vehicle` longtext DEFAULT NULL,
            `type` varchar(20) NOT NULL DEFAULT 'plane',
            `stored` tinyint(1) NOT NULL DEFAULT 1,
            PRIMARY KEY (`plate`)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
    ]])
end)

lib.callback.register('givecar:player', function(source, targetId, props, vehicleType, model, present)
    local xPlayer = ESX.GetPlayerFromId(source)
    local xTarget = ESX.GetPlayerFromId(targetId)
    if not xPlayer or not xTarget then return false, 'Žaidėjas nerastas' end

    props = props or {}

    local nPlate = normalizePlate(props.plate or '')
    if not nPlate or nPlate == '' then return false, 'Neteisingi numeriai' end

    local class = toClassFromParam(vehicleType)
    local targetTable = tableForClass(class)
    local storeType = typeForClass(class)

    if type(props.model) == 'string' then
        props.model = GetHashKey(props.model)
    end

    props.plate       = nPlate
    props.plateText   = nPlate
    props.numberPlate = nPlate
    props.spawnName   = tostring(model or ''):lower()
    props.name        = tostring(model or ''):lower()

    local exists = plateExistsAnywhere(nPlate)
    if exists then
        return false, 'Numeriai jau egzistuoja'
    end

    local stored = (class == 'Land' or class == 'Truck') and 1 or 0
    local vehicleJson = json.encode(props)

    local ok = MySQL.insert.await(
        ('INSERT INTO `%s` (owner, plate, vehicle, type, stored) VALUES (?, ?, ?, ?, ?)'):format(targetTable),
        { xTarget.identifier, nPlate, vehicleJson, storeType, stored }
    )

    if not ok then
        return false, 'Duomenų bazės klaida'
    end

    MySQL.update.await('REPLACE INTO `dec4t_vehicle_names` (plate, name) VALUES (?, ?)', { nPlate, tostring(model or ''):lower() })

    local fulltune = (props.modEngine and props.modEngine > -1) and 1 or 0
    TriggerEvent('Boost-Logs:SendLog', {
        ['Player']  = source,
        ['Target']  = targetId,
        ['Log']     = 'give_car',
        ['Title']   = 'Gave Vehicle',
        ['Message'] = ('Spawn: `%s`\nPlate: `%s`\nFull Tune: `%s`\nGift: `%s`'):format(
            model or 'n/a', nPlate,
            fulltune == 1 and 'yes' or 'no',
            present and 'yes' or 'no'
        ),
        ['Color'] = 'blue',
    })

    local locationText = stored == 1 and 'garaže' or 'impound\'e'
    sendNotification(targetId, {
        type     = 'SUCCESS',
        title    = 'Automobilis gautas!',
        message  = ('Modelis: %s\nNumeris: %s\nAutomobilis yra jūsų %s'):format(model or 'n/a', nPlate, locationText),
        duration = 10000,
        icon     = 'car'
    })

    return true, nPlate
end)

RegisterCommand('givecar', function(source)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then return end

    local playerGroup = xPlayer.getGroup()
    if playerGroup ~= 'dev' and playerGroup ~= 'owner' and playerGroup ~= 'admin' and playerGroup ~= 'superadmin' then
        sendNotification(source, {
            type     = 'ERROR',
            title    = 'Prieiga uždrausta',
            message  = 'Tau negalima berniuk...',
            duration = 5000,
            icon     = 'ban'
        })
        return
    end

    TriggerClientEvent('givecar:menu', source)
end, false)
