local ESX = exports['es_extended']:getSharedObject()
local VehiclesForSale = {}
local MarketData = {
    { id = 1, hours = 24, price = 1000 },
    { id = 2, hours = 72, price = 2500 },
    { id = 3, hours = 168, price = 6000 },
}

local function now() return os.time() end

local function getIdentifier(src)
    local xPlayer = ESX.GetPlayerFromId(src)
    return xPlayer and xPlayer.identifier or nil
end

local function getPlayerPhone(identifier)
    local result = MySQL.single.await('SELECT phone_number FROM phone_phones WHERE owner_id = ?', { identifier })
    return result and result.phone_number or 'N/A'
end

MySQL.ready(function()
    local results = MySQL.query.await('SELECT * FROM vehiclemarket_listings WHERE expireAt > ?', { now() })
    if results then
        for _, r in ipairs(results) do
            table.insert(VehiclesForSale, {
                owner = r.owner,
                plate = r.plate,
                vehicle = json.decode(r.vehicle),
                price = r.price,
                phone = r.phone,
                lambrachip = r.lambrachip,
                createdAt = r.createdAt,
                expireAt = r.expireAt
            })
        end
    end
end)

lib.callback.register('s1m1s-aturgus:GetVehicles', function(source)
    local identifier = getIdentifier(source)
    return VehiclesForSale, identifier
end)

lib.callback.register('s1m1s-aturgus:getMarketData', function(source)
    return MarketData
end)

lib.callback.register('s1m1s-aturgus:sellVehicle', function(source, marketId, props)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then return false, false end

    local identifier = xPlayer.identifier
    local option
    for _, v in ipairs(MarketData) do
        if tonumber(v.id) == tonumber(marketId) then
            option = v
            break
        end
    end
    if not option then return false, false end

    local plate = props.plate
    if not plate then return false, false end

    local vehicleData = MySQL.single.await('SELECT * FROM owned_vehicles WHERE plate = ? AND owner = ?', { plate, identifier })
    if not vehicleData then return false, false end

    local phone = getPlayerPhone(identifier)

    local fee = option.price
    if xPlayer.getMoney() >= fee then
        xPlayer.removeMoney(fee)
    elseif xPlayer.getAccount('bank').money >= fee then
        xPlayer.removeAccountMoney('bank', fee)
    else
        return false, false
    end

    MySQL.update.await('DELETE FROM owned_vehicles WHERE plate = ?', { plate })

    local expireAt = now() + (option.hours * 3600)
    local newEntry = {
        owner = identifier,
        plate = plate,
        vehicle = props,
        price = tonumber(props.price) or 0,
        phone = phone,
        lambrachip = props.lambrachip or nil,
        createdAt = now(),
        expireAt = expireAt
    }

    MySQL.insert.await('INSERT INTO vehiclemarket_listings (owner, plate, vehicle, price, phone, lambrachip, createdAt, expireAt) VALUES (?, ?, ?, ?, ?, ?, ?, ?)', {
        newEntry.owner,
        newEntry.plate,
        json.encode(newEntry.vehicle),
        newEntry.price,
        newEntry.phone,
        newEntry.lambrachip,
        newEntry.createdAt,
        newEntry.expireAt
    })

    table.insert(VehiclesForSale, newEntry)
    TriggerClientEvent('s1m1s-aturgus:insertVehicle', -1, {
        owner = newEntry.owner,
        plate = newEntry.plate,
        vehicle = newEntry.vehicle,
        price = newEntry.price,
        phone = newEntry.phone,
        lambrachip = newEntry.lambrachip
    })

    return true, true
end)

lib.callback.register('s1m1s-aturgus:buyVehicle', function(source, data)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then return false end

    local plate, price = data.plate, tonumber(data.price)
    if not plate or not price or price <= 0 then return false end

    local paid = false
    if xPlayer.getMoney() >= price then
        xPlayer.removeMoney(price)
        paid = true
    elseif xPlayer.getAccount('bank').money >= price then
        xPlayer.removeAccountMoney('bank', price)
        paid = true
    end
    if not paid then return false end

    for i = #VehiclesForSale, 1, -1 do
        local v = VehiclesForSale[i]
        if v.plate == plate then
            table.remove(VehiclesForSale, i)
            MySQL.update.await('DELETE FROM vehiclemarket_listings WHERE plate = ?', { plate })

            for _, id in pairs(ESX.GetPlayers()) do
                local seller = ESX.GetPlayerFromId(id)
                if seller and seller.identifier == v.owner then
                    seller.addAccountMoney('bank', price)
                    break
                end
            end

            MySQL.insert.await([[
                INSERT INTO owned_vehicles (owner, plate, vehicle, type, job, stored, parking, pound, mileage, glovebox, trunk, lambrachip)
                VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
            ]], {
                xPlayer.identifier,
                plate,
                json.encode(v.vehicle),
                v.vehicle.type or 'car',
                'civ',
                1,
                'autoturgus',
                0,
                v.vehicle.mileage or 0,
                json.encode(v.vehicle.glovebox or {}),
                json.encode(v.vehicle.trunk or {}),
                v.lambrachip or ''
            })

            TriggerClientEvent('s1m1s-aturgus:takeoutVehicle', -1, plate)
            return true
        end
    end
    return false
end)

lib.callback.register('s1m1s-aturgus:takeOut', function(source, data)
    local identifier = getIdentifier(source)
    local plate = data.plate or (data.vehicle and data.vehicle.plate)
    if not plate then return false end

    for i = #VehiclesForSale, 1, -1 do
        local v = VehiclesForSale[i]
        if v.owner == identifier and v.plate == plate then
            table.remove(VehiclesForSale, i)
            MySQL.update.await('DELETE FROM vehiclemarket_listings WHERE plate = ?', { plate })

            MySQL.insert.await([[
                INSERT INTO owned_vehicles (owner, plate, vehicle, type, job, stored, parking, pound, mileage, glovebox, trunk, lambrachip)
                VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
            ]], {
                identifier,
                plate,
                json.encode(v.vehicle),
                v.vehicle.type or 'car',
                'civ',
                1,
                'autoturgus',
                0,
                v.vehicle.mileage or 0,
                json.encode(v.vehicle.glovebox or {}),
                json.encode(v.vehicle.trunk or {}),
                v.lambrachip or ''
            })

            TriggerClientEvent('s1m1s-aturgus:takeoutVehicle', -1, plate)
            return true
        end
    end
    return false
end)

RegisterNetEvent('s1m1s-aturgus:deleteVehicle', function(netId)
    TriggerClientEvent('s1m1s-aturgus:removeNetworkEntity', -1, netId)
end)

CreateThread(function()
    while true do
        Wait(60000)
        local t = now()
        for i = #VehiclesForSale, 1, -1 do
            if VehiclesForSale[i].expireAt <= t then
                local plate = VehiclesForSale[i].plate
                table.remove(VehiclesForSale, i)
                MySQL.update.await('DELETE FROM vehiclemarket_listings WHERE plate = ?', { plate })
                TriggerClientEvent('s1m1s-aturgus:takeoutVehicle', -1, plate)
            end
        end
    end
end)
