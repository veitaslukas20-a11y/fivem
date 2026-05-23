Citizen.CreateThread(function()
    while not ESX.IsPlayerLoaded() do
        Wait(100)
    end

    local Places = lib.callback.await('moneywash:getPlaces', false)

    for k, v in ipairs(Places) do
        exports.ox_target:addBoxZone({
            coords = v.coords,
            size = vec3(1.0, 1.0, 1.0),
            rotation = 0.0, 
            options = {
                {
                    label = 'Plauti pinigus',
                    name = 'moneywash'..k,
                    icon = 'fa-solid fa-money-bill-transfer',
                    distance = 2.0,
                    onSelect = function()
                        local data = lib.callback.await('moneywash:getinfo', false, k)
                        if not data.occupied then
                            local input = lib.inputDialog('Plauti pinigus', {
                                {type = 'number', label = 'Įveskite pinigų sumą', description = 'Įveskite pinigų sumą kurią norite išplauti.', icon = 'fa-solid fa-money-bill-transfer'},
                            })

                            if not input then return end 

                            lib.callback.await('moneywash:addmoney', false, k, input[1])
                        else
                            lib.registerContext({
                                id = 'moneywash',
                                title = 'Pinigų plovimas',
                                options = {
                                    {
                                        title = 'Pinigų plovimo procesas',
                                        description = 'Žemiau galite matyti pinigų plovimo procesą.',
                                        icon = 'fa-solid fa-money-bill-transfer',
                                        metadata = {
                                            {
                                                label = 'Procesas',
                                                value = data.progress..'%',
                                            }
                                        },
                                        progress = data.progress,
                                        readOnly = data.time > 0,
                                        onSelect = function()
                                            lib.callback.await('moneywash:getout', false, k)
                                        end
                                    }
                                }
                            })
                            
                            lib.showContext('moneywash')
                        end
                    end
                }
            }
        })
    end
end)