local ESX = exports['es_extended']:getSharedObject()

local paycheckBalances = {}

AddEventHandler('esx:playerLoaded', function(playerId, xPlayer)
    local identifier = xPlayer.getIdentifier()
    if not paycheckBalances[identifier] then
        paycheckBalances[identifier] = 0
    end
end)

lib.callback.register('paycheck:getMoney', function(source)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then return 0 end

    local identifier = xPlayer.getIdentifier()
    return paycheckBalances[identifier] or 0
end)

lib.callback.register('paycheck:payout', function(source)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then return false end

    local identifier = xPlayer.getIdentifier()
    local amount = paycheckBalances[identifier] or 0

    if amount > 0 then
        xPlayer.addAccountMoney('bank', amount)
        paycheckBalances[identifier] = 0

        xPlayer.showNotification(("Jūs atsiėmėte savo algą: %s€"):format(amount))
        return true
    else
        xPlayer.showNotification("Jus neturite algos fonde.")
        return false
    end
end)
