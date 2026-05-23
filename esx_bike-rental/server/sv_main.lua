ESX = nil

ESX = exports["es_extended"]:getSharedObject()

lib.callback.register('onex:bike:rental', function(source, price, spawncode, coords)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then return false end

    local playerMoney = xPlayer.getMoney()
    
    if playerMoney >= price then
        xPlayer.removeMoney(price)
        
        local vehicle = CreateVehicleServerSetter(GetHashKey(spawncode), 'automobile', coords.x, coords.y, coords.z, coords.w)
        while not DoesEntityExist(vehicle) do
            Wait(100)
        end

        TriggerClientEvent('esx:showNotification', source, "✅ Sėkmingai išsinuomojote dviratį!", 'success')
        return true
    else
        TriggerClientEvent('esx:showNotification', source, "❌ Neturite pakankamai pinigų dviračiui išsinuomoti!", 'error')
        return false
    end
end)
