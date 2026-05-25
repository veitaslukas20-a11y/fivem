ESX = exports['es_extended']:getSharedObject()

-- Kai žaidėjas panaudoja fixkitą

-- Callback, kurį kviečia client.lua, kad pašalintų itemą po taisymo
lib.callback.register('s1m1s-mechanicjob:removeFixkit', function(source)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then return false end

    local item = xPlayer.getInventoryItem('fixkitas')
    if not item or item.count <= 0 then
        return false
    end

    -- Pašalinam tik po sėkmingo taisymo
    xPlayer.removeInventoryItem('fixkitas', 1)
    return true
end)

-- ox_inventory iškviečia šį exportą kai žaidėjas naudoja fixkitas
exports('fixkitas', function(event, item, inventory, slot, data)
    local source = inventory.id
    TriggerClientEvent('s1m1s-mechanicjob:onFixkit', source)
end)

-- // Transporto priemonės ištrynimas (Impound)
RegisterNetEvent('s1m1s-mechanic:deleteveh', function(netId)
    local src = source
    if not netId then return end

    local vehicle = NetworkGetEntityFromNetworkId(netId)
    if vehicle and DoesEntityExist(vehicle) then
        DeleteEntity(vehicle)
        TriggerClientEvent('ox_lib:notify', src, {
            title = 'Mechanikai',
            description = 'Automobilis konfiskuotas.',
            type = 'success'
        })
    else
        TriggerClientEvent('ox_lib:notify', src, {
            title = 'Mechanikai',
            description = 'Nepavyko rasti transporto priemonės.',
            type = 'error'
        })
    end
end)

-- // Sąskaitų išrašymas
RegisterNetEvent('esx_billing:isiustiisrasa', function(target, society, reason, amount)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    local xTarget = ESX.GetPlayerFromId(target)

    if not xPlayer or not xTarget then return end
    amount = tonumber(amount)
    if not amount or amount <= 0 then return end

    TriggerEvent('esx_addonaccount:getSharedAccount', society, function(account)
        if account then
            MySQL.insert('INSERT INTO billing (identifier, sender, target, target, label, amount) VALUES (?, ?, ?, ?, ?, ?)', {
                xTarget.identifier, xPlayer.identifier, 'society', society, reason, amount
            })

            TriggerClientEvent('ox_lib:notify', src, {
                title = 'Sąskaita išrašyta',
                description = 'Sėkmingai išrašėte sąskaitą '..xTarget.getName()..' už '..amount..'€.',
                type = 'success'
            })
            TriggerClientEvent('ox_lib:notify', target, {
                title = 'Gauta sąskaita',
                description = 'Gavote sąskaitą už '..amount..'€ ('..reason..') iš '..xPlayer.getName()..'.',
                type = 'info'
            })
        end
    end)
end)

