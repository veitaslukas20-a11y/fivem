local ESX = exports['es_extended']:getSharedObject()

lib.callback.register('esx_ambulancejob:getItemAmount', function(source, itemName)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then return 0 end

    local item = xPlayer.getInventoryItem(itemName)
    return item and item.count or 0
end)

lib.callback.register('esx_ambulancejob:removeItem', function(source, itemName)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then return false end

    local item = xPlayer.getInventoryItem(itemName)
    if not item or item.count <= 0 then return false end

    xPlayer.removeInventoryItem(itemName, 1)
    return true
end)