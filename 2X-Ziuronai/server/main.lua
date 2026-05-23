local ESX = exports['es_extended']:getSharedObject()

ESX.RegisterUsableItem('binoculars', function(source)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then return end

    TriggerClientEvent('binoculars:Activate', source)
end)