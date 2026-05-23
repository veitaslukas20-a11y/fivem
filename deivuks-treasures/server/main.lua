local ESX = exports["es_extended"]:getSharedObject()

-- Get Config for Client
lib.callback.register('d-treasures:getConfig', function(source)
    return Config
end)

-- Sell Single Item
lib.callback.register('d-treasures:sellItem', function(source, itemName)
    local xPlayer = ESX.GetPlayerFromId(source)
    local count = exports.ox_inventory:GetItemCount(source, itemName)

    if count > 0 then
        for _, v in pairs(Config.Shop) do
            if v.name == itemName then
                local payment = v.price * count
                exports.ox_inventory:RemoveItem(source, itemName, count)
                xPlayer.addAccountMoney('cash', payment)
                return payment
            end
        end
    end

    return false
end)

-- Sell All Items
lib.callback.register('d-treasures:sellAllItems', function(source, availableItems)
    local xPlayer = ESX.GetPlayerFromId(source)
    local total = 0

    for _, v in pairs(Config.Shop) do
        if exports.ox_inventory:GetItemCount(source, v.name) > 0 then
            local count = exports.ox_inventory:GetItemCount(source, v.name)
            total = total + (v.price * count)
            exports.ox_inventory:RemoveItem(source, v.name, count)
        end
    end

    if total > 0 then
        xPlayer.addAccountMoney('cash', total)
        return total
    else
        return false
    end
end)

-- Sell with Filter (Keep some items)
lib.callback.register('d-treasures:sellItemsByFilter', function(source, availableItems, itemsToKeep)
    local xPlayer = ESX.GetPlayerFromId(source)
    local total = 0

    for _, v in pairs(Config.Shop) do
        if not itemsToKeep[v.name] then
            local count = exports.ox_inventory:GetItemCount(source, v.name)
            if count > 0 then
                total = total + (v.price * count)
                exports.ox_inventory:RemoveItem(source, v.name, count)
            end
        end
    end

    if total > 0 then
        xPlayer.addAccountMoney('cash', total)
        return total
    else
        return false
    end
end)

-- Reward when opening a box
lib.callback.register('d-treasures:getReward', function(source, locationId)
    math.randomseed(GetGameTimer())

    for _, reward in pairs(Config.Rewards) do
        if math.random(1, 100) <= reward.chance then
            exports.ox_inventory:AddItem(source, reward.name, 1)
            return true
        end
    end

    return false
end)
