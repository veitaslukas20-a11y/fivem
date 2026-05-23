local ESX = exports["es_extended"]:getSharedObject()
local inv = exports.ox_inventory

lib.callback.register('onex-fuel:processFuelPayment', function(source, stationId, paymentMethod, fuelType, liters)
    liters = tonumber(liters) or 0
    if liters <= 0 then return false, 'Neteisingas kiekis' end

    local pricePerL = (fuelType == 'premium') and (Config.FuelSystem.PremiumFuelPrice or 65.0) or (Config.FuelSystem.RegularFuelPrice or 45.0)
    local total = math.floor(liters * pricePerL + 0.5)

    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then return false, '�aidejas nerastas' end

    if paymentMethod == 'bank' then
        local bank = xPlayer.getAccount('bank')
        if bank.money >= total then
            xPlayer.removeAccountMoney('bank', total)
            TriggerClientEvent('esx:showNotification', source, ('Apmoketa i� banko: %d�'):format(total), 'success')
            return true
        else
            TriggerClientEvent('esx:showNotification', source, 'Nepakanka le�u banke.', 'error')
            return false
        end
    else
        if xPlayer.getMoney() >= total then
            xPlayer.removeMoney(total)
            TriggerClientEvent('esx:showNotification', source, ('Apmoketa grynais: %d�'):format(total), 'success')
            return true
        else
            TriggerClientEvent('esx:showNotification', source, 'Nepakanka grynuju.', 'error')
            return false
        end
    end
end)

RegisterNetEvent('onex-fuel:buyItem', function(data)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    if not xPlayer then return end

    local item = data.item or data
    local payment = data.paymentMethod or "cash" -- numatyta grynais
    local price = 0
    local itemName = item

    if item == 'fixkitas' then
        price = 10000
    elseif item == 'WEAPON_PETROLCAN' or item == 'WEAPON_PETROLCAN' then
        price = 14300
        itemName = 'WEAPON_PETROLCAN'
    else
        return
    end

    if payment == 'bank' then
        local bank = xPlayer.getAccount('bank')
        if bank.money >= price then
            xPlayer.removeAccountMoney('bank', price)
            exports.ox_inventory:AddItem(src, itemName, 1)
            TriggerClientEvent('esx:showNotification', src, ('Nupirkta (banku): %s.'):format(itemName), 'success')
        else
            TriggerClientEvent('esx:showNotification', src, 'Nepakanka le�u banke.', 'error')
        end
    else
        if xPlayer.getMoney() >= price then
            xPlayer.removeMoney(price)
            exports.ox_inventory:AddItem(src, itemName, 1)
            TriggerClientEvent('esx:showNotification', src, ('Nupirkta: %s.'):format(itemName), 'success')
        else
            TriggerClientEvent('esx:showNotification', src, 'Nepakanka grynuju.', 'error')
        end
    end
end)
