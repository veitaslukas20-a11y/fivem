local ESX = exports['es_extended']:getSharedObject()

ESX.RegisterUsableItem('oxtankas', function(source, item)
    local xPlayer = ESX.GetPlayerFromId(source)

    if xPlayer then
        if xPlayer.getInventoryItem('oxtankas').count > 0 then
            xPlayer.removeInventoryItem('oxtankas', 1)
            TriggerClientEvent('ox_inventory:useItem', source, item, true)
        end
    end
end)

RegisterNetEvent('scuba:returnTank', function()
    local xPlayer = ESX.GetPlayerFromId(source)
    if xPlayer then
        xPlayer.addInventoryItem('oxtankas', 1)
    end
end)
