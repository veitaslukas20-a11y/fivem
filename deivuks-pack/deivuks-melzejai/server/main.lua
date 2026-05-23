ESX = exports["es_extended"]:getSharedObject()

lib.callback.register('d-melzejai:additem', function(source, entity, item, id)
    local xPlayer = ESX.GetPlayerFromId(source)

    if item == 'nemilk' then
        if xPlayer.canCarryItem('nemilk', 1) then
            xPlayer.addInventoryItem('nemilk', 1)
            TriggerClientEvent('esx:showNotification', source, ' Gavote nepasterizuoto pieno.')
            return true
        else
            TriggerClientEvent('esx:showNotification', source, ' Neturite vietos inventoriuje.')
            return false
        end
    elseif item == 'milk' then
        if xPlayer.getInventoryItem('nemilk').count >= 1 then
            xPlayer.removeInventoryItem('nemilk', 1)
            if xPlayer.canCarryItem('milk', 1) then
                xPlayer.addInventoryItem('milk', 1)
                TriggerClientEvent('esx:showNotification', source, ' Pienas pasterizuotas!')
                return true
            else
                TriggerClientEvent('esx:showNotification', source, ' Neturite vietos inventoriuje.')
                return false
            end
        else
            TriggerClientEvent('esx:showNotification', source, ' Neturite nepasterizuoto pieno.')
            return false
        end
    end
end)

lib.callback.register('d-melzejai:parduoti', function(source)
    local xPlayer = ESX.GetPlayerFromId(source)
    local milkCount = xPlayer.getInventoryItem('milk').count
    local pricePerMilk = 25 -- Kaina už 1 vienetą pieno

    if milkCount > 0 then
        local totalPrice = milkCount * pricePerMilk
        xPlayer.removeInventoryItem('milk', milkCount)
        xPlayer.addMoney(totalPrice)
        return milkCount, totalPrice
    else
        return false
    end
end)
