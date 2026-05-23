local ox_inventory = exports.ox_inventory

local addCommas = function(n)
    return tostring(math.floor(n)):reverse():gsub("(%d%d%d)", "%1,")
        :gsub(",(%-?)$", "%1"):reverse()
end

lib.callback.register('d-kasykla:buyPickaxe', function(source)
    local xPlayer = ESX.GetPlayerFromId(source)

    if xPlayer.getAccount('bank').money >= Config.PickaxePrice then
        if ox_inventory:CanCarryItem(source, 'pickaxe', 1) then
            xPlayer.removeAccountMoney('bank', Config.PickaxePrice)
            ox_inventory:AddItem(source, 'pickaxe', 1)
            return true
        end
    end

    return false
end)

lib.callback.register('d-kasykla:addItem', function(source)
    local ox_inventory = exports.ox_inventory
    local randomItemData = Config.Items[math.random(#Config.Items)]
    local randomItem = randomItemData.item
    local amount = math.random(1, 3)

    if ox_inventory:CanCarryItem(source, randomItem, amount) then
        ox_inventory:AddItem(source, randomItem, amount)
        print(('^2[d-kasykla]: Added %dx %s to player %s inventory.^7'):format(amount, randomItem, source))
        return true
    else
        print(('^1[d-kasykla]: Player %s does not have enough space for %dx %s.^7'):format(source, amount, randomItem))
        return false
    end
end)

lib.callback.register('d-kasykla:sell', function(source, item)
    local xPlayer = ESX.GetPlayerFromId(source)
    local itemCount = ox_inventory:GetItemCount(source, item)

    if itemCount > 0 then
        local price = Config.Prices[item] * itemCount
        xPlayer.addAccountMoney('bank', price)
        ox_inventory:RemoveItem(source, item, itemCount)
        return price
    end

    return false
end)
