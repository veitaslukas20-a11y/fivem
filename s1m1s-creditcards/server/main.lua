
ESX = exports['es_extended']:getSharedObject()
local ox_inventory = exports.ox_inventory


lib.callback.register('creditcard:cashOut', function(source, entity)

    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then
        return false
    end

    local amount = math.random(2500, 7500) 
    local didPayout = false

    local success, validCardsOrErr = pcall(function()
        return ox_inventory:Search(source, 'slots', 'credit_card', { creditUsed = false })
    end)

    if success and validCardsOrErr and type(validCardsOrErr) == 'table' and #validCardsOrErr > 0 then
        local card = validCardsOrErr[1]

        local okSetMeta, setMetaErr = pcall(function()
            ox_inventory:SetMetadata(source, card.slot, { creditUsed = true })
        end)
        if not okSetMeta then

        end

        if xPlayer.addMoney then
            xPlayer.addMoney(amount)
        elseif xPlayer.addAccountMoney then
            xPlayer.addAccountMoney('money', amount)
        else
        end

        didPayout = true
    else
        local inv = {}
        if xPlayer.getInventory then inv = xPlayer.getInventory() end
        for _, item in ipairs(inv) do
            if item.name == 'credit_card' and (item.count and item.count > 0) then
                if xPlayer.removeInventoryItem then
                    xPlayer.removeInventoryItem('credit_card', 1)
                else
                end

                if xPlayer.addMoney then
                    xPlayer.addMoney(amount)
                elseif xPlayer.addAccountMoney then
                    xPlayer.addAccountMoney('money', amount)
                end

                didPayout = true
                break
            end
        end
    end

    if didPayout then
        lib.notify(source, {
            title = 'Bankomatas',
            description = ('Išsigryninai $%s iš kreditinės kortelės.'):format(amount),
            type = 'success'
        })
        return true
    else
        lib.notify(source, {
            title = 'Bankomatas',
            description = 'Neturi galiojančios kreditinės kortelės.',
            type = 'error'
        })
        return false
    end
end)
