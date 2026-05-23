ESX = nil
ESX = exports['es_extended']:getSharedObject()

lib.callback.register('vaistine:getConfig', function()
    return Vaistine
end)

lib.callback.register('s1m1s-vaistine:returnPrices', function()
    return Vaistine.Prices
end)

lib.callback.register('s1m1s-vaistine:buy', function(source, item, amount)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then
        print("[Vaistine] ERROR: xPlayer is nil for source "..source)
        return false
    end

    if not Vaistine.Prices[item] then
        print("[Vaistine] ERROR: No price found for item "..tostring(item))
        return false
    end

    local price = Vaistine.Prices[item] * amount

    if xPlayer.getMoney() >= price then
        local added = xPlayer.addInventoryItem(item, amount)
        if added then
            xPlayer.removeMoney(price)
            return true
        else
            print("[Vaistine] ERROR: Could not add item "..item.." to player "..source)
            return false
        end
    else
        print("[Vaistine] ERROR: Player "..source.." does not have enough money")
        return false
    end
end)