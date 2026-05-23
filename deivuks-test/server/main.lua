AddEventHandler('onResourceStart', function(resourceName)
    if GetCurrentResourceName() == resourceName then
    end
end)

AddEventHandler('onResourceStop', function(resourceName)
    if GetCurrentResourceName() == resourceName then
    end
end)

AddEventHandler('playerConnecting', function(name, setKickReason, deferrals)
end)

AddEventHandler('playerDropped', function(reason)
end)

RegisterCommand('propfix', function(source)
    local xPlayer = source
    if xPlayer then
        TriggerClientEvent('propfix:client', xPlayer)
    end
end, false)

RegisterNetEvent('server:syncSuppression')
AddEventHandler('server:syncSuppression', function()
    TriggerClientEvent('client:applySuppression', -1)
end)
