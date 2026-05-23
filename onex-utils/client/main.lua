Citizen.CreateThread(function()
    local Inventory = exports.ox_inventory
    local ItemNames = {}

    local Items = Inventory:Items()

    for item, data in pairs(Items) do
        ItemNames[item] = data.label
    end

    exports('getLabel', function(name)
        return ItemNames[name]
    end)

    exports('CanCarryItem', function(name, count)
        local itemWeight = Items[name] and Items[name].weight * count or 0
        local weight = Inventory:GetPlayerWeight() + itemWeight
        local maxWeight = Inventory:GetPlayerMaxWeight()
        return weight < maxWeight
    end)
end)