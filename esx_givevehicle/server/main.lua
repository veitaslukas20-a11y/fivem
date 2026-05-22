-- givecar (server) — vehicleshop-style insert FIX (uniform plates)

ESX = ESX or exports['es_extended']:getSharedObject()
local MySQL = rawget(_G, 'MySQL') or MySQL

-- laikini automobiliai iki /importcar patvirtinimo
local tempVehicles = {}

-- === helpers ===============================================================

-- GTA-style: maks. 8, A-Z/0-9 + viengubas vidinis tarpas, be kraštinių tarpų, UPPER
local function normalizePlate(p)
    if not p then return nil end
    local s = tostring(p)
    s = s:gsub('[^%w ]', '')   -- paliekam tik A-Z, 0-9 ir tarpą
    s = s:gsub('%s+', ' ')     -- viengubinam vidinius tarpus
    s = s:gsub('^%s+', ''):gsub('%s+$', '') -- nukerpam kraštinius
    s = s:upper()
    if #s > 8 then s = s:sub(1, 8) end      -- GTA rodo iki 8 simbolių
    return s
end

local BASE_TABLE  = 'owned_vehicles'
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
    return CLASS_TABLE[class] or BASE_TABLE
end

local function typeForClass(class)
    if class == 'Water' then return 'boat'
    elseif class == 'Sky' then return 'plane'
    else return 'car' end
end

-- Patikrinam dublius visose lentelėse pagal normalizuotą plokštelę (be tarpų)
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
            color = {255,255,255},
            multiline = true,
            args = { data.title or 'Info', data.message or 'No message' }
        })
    end
end

-- === bootstrap ==============================================================

AddEventHandler('onResourceStart', function(resourceName)
    if resourceName ~= GetCurrentResourceName() then return end
    -- import codes table
    MySQL.query.await([[
        CREATE TABLE IF NOT EXISTS `esx_givevehicle_imports` (
            `id` int(11) NOT NULL AUTO_INCREMENT,
            `uid` int(11) NOT NULL,
            `owner` varchar(60) NOT NULL,
            `plate` varchar(12) NOT NULL,
            `vehicle_type` varchar(50) NOT NULL,
            `fulltune` tinyint(1) DEFAULT 0,
            `present` tinyint(1) DEFAULT 0,
            `created_at` timestamp DEFAULT CURRENT_TIMESTAMP,
            PRIMARY KEY (`id`),
            UNIQUE KEY `uid` (`uid`)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
    ]])
    -- names table (used by vehicleshop/garage)
    MySQL.query.await([[
        CREATE TABLE IF NOT EXISTS `dec4t_vehicle_names` (
            `plate` varchar(12) NOT NULL,
            `name` varchar(64) DEFAULT NULL,
            PRIMARY KEY (`plate`)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
    ]])
    -- boat and plane vehicle tables
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

-- === main callbacks/commands ===============================================

lib.callback.register('givecar:player', function(source, targetId, props, vehicleType, model, present)
    local xPlayer = ESX.GetPlayerFromId(source)
    local xTarget = ESX.GetPlayerFromId(targetId)
    if not xPlayer or not xTarget then return false, 'Player not found' end

    props = props or {}

    -- normalizuojam numerį (GTA-style)
    local nPlate = normalizePlate(props.plate or '')
    if not nPlate or nPlate == '' then return false, 'Bad plate' end

    local class = toClassFromParam(vehicleType)
    local targetTable = tableForClass(class)
    local storeType = typeForClass(class) -- 'car' | 'boat' | 'plane'

    -- model hash jei reikia
    if type(props.model) == 'string' then
        props.model = GetHashKey(props.model)
    end

    -- ABSOLIUTUS suvienodinimas (JSON turi tą patį tekstą kaip DB)
    props.plate       = nPlate
    props.plateText   = nPlate
    props.numberPlate = nPlate
    props.spawnName   = tostring(model or ''):lower()
    props.name        = tostring(model or ''):lower()

    -- dublių tikrinimas per visas lenteles
    local exists = plateExistsAnywhere(nPlate)
    if exists then
        return false, 'Plate already exists'
    end

    -- unikalus importo kodas
    local uid = math.random(100000, 999999)
    while MySQL.scalar.await('SELECT uid FROM esx_givevehicle_imports WHERE uid = ?', { uid }) do
        uid = math.random(100000, 999999)
    end

    -- saugom laikinai iki /importcar
    local fulltune = (props.modEngine and props.modEngine > -1) and 1 or 0
    tempVehicles[uid] = {
        owner       = xTarget.identifier,
        plate       = nPlate,
        vehicle     = props,          -- jau suvienodintas JSON
        class       = class,          -- Land/Water/Sky/Truck
        tableName   = targetTable,    -- owned_vehicles / owned_laivai / owned_planes
        storeType   = storeType,      -- 'car'/'boat'/'plane'
        fulltune    = fulltune,
        present     = present and 1 or 0,
        model       = tostring(model or ''):lower()
    }

    -- pranešimai gavėjui
    sendNotification(targetId, {
        type = 'SUCCESS',
        title = 'Automobilis gautas!',
        message = ('Modelis: %s\nNumeris: %s\nImporto kodas: %s'):format(model or 'n/a', nPlate, uid),
        duration = 10000,
        icon = 'car'
    })
    sendNotification(targetId, {
        type = 'INFO',
        title = 'Instrukcijos',
        message = 'Naudokite /importcar ' .. uid .. ' norėdami išsaugoti automobilį garaže!',
        duration = 8000,
        icon = 'info-circle'
    })

    return true, uid
end)

RegisterCommand('givecar', function(source)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then return end

    local playerGroup = xPlayer.getGroup()
    if playerGroup ~= 'dev' and playerGroup ~= 'owner' and playerGroup ~= 'admin' and playerGroup ~= 'superadmin' then
        sendNotification(source, {
            type = 'ERROR',
            title = 'Prieiga uždrausta',
            message = 'Tau negalima berniuk...',
            duration = 5000,
            icon = 'ban'
        })
        return
    end

    TriggerClientEvent('givecar:menu', source)
end, false)


RegisterCommand('importcar', function(source, args)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then return end

    local uid = tonumber(args[1] or '')
    if not uid then
        sendNotification(source, { type='ERROR', title='Klaida', message='Naudojimas: /importcar [kodas]', duration=5000, icon='question-circle' })
        return
    end

    local imp = tempVehicles[uid]
    if not imp or imp.owner ~= xPlayer.identifier then
        sendNotification(source, { type='ERROR', title='Klaida', message='Automobilis su šiuo importo kodu nerastas arba jau paimtas', duration=5000, icon='search' })
        return
    end

    -- saugiklis: dar kartą tikrinam dublius
    local exists, where = plateExistsAnywhere(imp.plate)
    if exists then
        tempVehicles[uid] = nil
        sendNotification(source, { type='ERROR', title='Klaida', message=('Numeris jau egzistuoja duomenų bazėje (%s)'):format(where or '?'), duration=6000, icon='database' })
        return
    end

    -- dar kartą suvienodinam JSON prieš encode
    imp.vehicle = imp.vehicle or {}
    imp.vehicle.plate       = imp.plate
    imp.vehicle.plateText   = imp.plate
    imp.vehicle.numberPlate = imp.plate

    local vehicleJson = json.encode(imp.vehicle)
    local stored = (imp.class == 'Land' or imp.class == 'Truck') and 1 or 0

    -- vehicleshop-style INSERT
    local cols = '(owner, plate, vehicle, type, stored)'
    local sql  = ('INSERT INTO `%s` %s VALUES (?, ?, ?, ?, ?)'):format(imp.tableName, cols)
    local ok   = MySQL.insert.await(sql, {
        xPlayer.identifier,
        imp.plate,
        vehicleJson,
        imp.storeType,   -- 'car'/'boat'/'plane'
        stored
    })

    if ok then
        -- išsaugom pavadinimą (garage/vehicleshop UI)
        MySQL.update.await('REPLACE INTO `dec4t_vehicle_names` (plate, name) VALUES (?, ?)', { imp.plate, imp.model })

        -- log (jei turi Boost-Logs)
        local logas = {
            ['Player'] = source,
            ['Log'] = 'import_vehicle',
            ['Title'] = 'Imported Vehicle',
            ['Message'] = ('Import Code: `%s`\nSpawn: `%s`\nPlate: `%s`\nFull Tune: `%s`\nGift: `%s`'):
                format(uid, imp.model, imp.plate, (imp.fulltune==1 and 'yes' or 'no'), (imp.present==1 and 'yes' or 'no')),
            ['Color'] = 'green',
        }
        TriggerEvent('Boost-Logs:SendLog', logas)

        tempVehicles[uid] = nil

        local statusText = (stored == 1) and 'garaže' or 'impound\'e'
        sendNotification(source, { type='SUCCESS', title='Sėkmė', message='Automobilis sėkmingai išsaugotas jūsų '..statusText..'!', duration=6000, icon='check-circle' })
        if stored == 1 then
            sendNotification(source, { type='INFO', title='Informacija', message='Automobilis yra garaže - galite jį paimti per garažo meniu', duration=7000, icon='warehouse' })
        else
            sendNotification(source, { type='WARNING', title='Įspėjimas', message='Automobilis yra impound\'e - kreipkitės į policiją', duration=7000, icon='exclamation-triangle' })
        end
    else
        sendNotification(source, { type='ERROR', title='Klaida', message='Nepavyko išsaugoti automobilio duomenų bazėje', duration=6000, icon='database' })
    end
end, false)

-- Išvalyti laikinus (admin)
RegisterCommand('cleantempvehicles', function(source)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then return end
    tempVehicles = {}
    sendNotification(source, { type='SUCCESS', title='Sėkmė', message='Visi laikini automobiliai išvalyti', duration=5000, icon='trash' })
end, false)
