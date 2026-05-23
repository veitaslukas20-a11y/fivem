Citizen.CreateThread(function()
    while not ESX.IsPlayerLoaded() do
        Wait(100)
    end

    exports.ox_target:addGlobalPlayer({
        {
            label = 'Nukirpti antrankius',
            icon = 'fa-solid fa-handcuffs',
            items = 'metalscissors',
            distance = 1.5,
            canInteract = function(entity)
                return IsPedCuffed(entity) and not IsEntityAttachedToEntity(entity, cache.ped)
            end,
            onSelect = function(data)
                local canUncuff = lib.callback.await('metalscissors:tryUncuff', false, GetPlayerServerId(NetworkGetPlayerIndexFromPed(data.entity)))
                if canUncuff then
                    AttachEntityToEntity(cache.ped, data.entity, 11816, -0.07, -0.7, 0.0, 0.0, 0.0, 0.0, false, false , false, true, 2, true)
                    lib.progressCircle({
                        label = 'Nukerpate antrankius...',
                        duration = 3750,
                        position = 'bottom',
                        useWhileDead = false,
                        canCancel = false,
                        anim = {
                            dict = 'anim@scripted@freemode@ig1_cut_open_container_positive@heeled@',
                            clip = 'action'
                        },
                    })
                    DetachEntity(cache.ped, true, false)
                    FreezeEntityPosition(cache.ped, false)
                end
            end
        }
    })
end)