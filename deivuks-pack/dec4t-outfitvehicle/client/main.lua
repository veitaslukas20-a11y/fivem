Citizen.CreateThread(function()
    while not ESX.IsPlayerLoaded() do Wait(500) end

    exports.ox_target:addGlobalVehicle({
        {
            label = 'Pakeisti aprangą',
            name = 'outfitvehicle',
            icon = 'fa-solid fa-shirt',
            distance = 1,
            bones = 'boot',
            onSelect = function(data)
                local canOpen = lib.callback.await('s1m1s-outfitveh:hasOutfit', false, ESX.Game.GetVehicleProperties(data.entity).plate)
                if canOpen then 
                    exports['vms_clothestore']:OpenWardrobe()
                else 
                    exports['1x-hud']:sendNotification({
                        type = 'ERROR',
                        title = 'Bagažinė',
                        message = 'Neturite aprangų krepšio savo bagažinėje, todėl ir neturite kuom persirengti.',
                        duration = 6000,
                        icon = 'car-back'
                    })
                    
                end
            end,
        }
    })
end)