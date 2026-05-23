ESX = exports["es_extended"]:getSharedObject()
local Inventory = exports.ox_inventory

-- ✅ Add recycled item
lib.callback.register('d-perdirbimas:additem', function(source, entity, isRinkti, index)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then return false end

    if isRinkti then
        -- 🗑️ Player is collecting trash
        if Inventory:CanCarryItem(source, 'siuksles', 1) then
            Inventory:AddItem(source, 'siuksles', 1)
            TriggerClientEvent('esx:showNotification', source, ' Surinkote šiukšlių maišą!')
            return true
        else
            TriggerClientEvent('esx:showNotification', source, ' Neturite vietos inventoriuje!')
            return false
        end
    else
        -- 🔄 Player is recycling
        if Inventory:GetItemCount(source, 'siuksles') > 0 then
            Inventory:RemoveItem(source, 'siuksles', 1)

            -- 🎲 Give random recycled material
            local items = { 'plastikas', 'metalas', 'stiklas', 'popierius' }
            local item = items[math.random(#items)]

            Inventory:AddItem(source, item, math.random(1, 3))
            TriggerClientEvent('esx:showNotification', source, ' Perdirbote šiukšles ir gavote medžiagų!')
            return true
        else
            TriggerClientEvent('esx:showNotification', source, ' Neturite šiukšlių perdirbimui!')
            return false
        end
    end
end)

-- ✅ Sell / turn in recycled items
lib.callback.register('d-perdirbimas:pridavimas', function(source)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then return 'Klaida: žaidėjas nerastas.', 'error' end

    local total = 0
    local recyclableItems = {
        { name = 'plastikas', price = 5 },
        { name = 'metalas', price = 8 },
        { name = 'stiklas', price = 6 },
        { name = 'popierius', price = 4 },
    }

    for _, v in ipairs(recyclableItems) do
        local count = Inventory:GetItemCount(source, v.name)
        if count > 0 then
            Inventory:RemoveItem(source, v.name, count)
            total = total + (count * v.price)
        end
    end

    if total > 0 then
        xPlayer.addMoney(total)
        return (' Uždirbote %s€ už perdirbtas medžiagas!'):format(total), 'success'
    else
        return ' Neturite ką priduoti!', 'error'
    end
end)
