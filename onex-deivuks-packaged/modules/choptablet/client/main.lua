local ped

local function CreateLocalPed()
    if not ped then
        local pedModel = `s_m_y_armymech_01`
        lib.requestModel(pedModel)

        ped = CreatePed(4, pedModel, 956.8864, -1514.2760, 31.2937 - 1.0, 5.9334, false, true)
        SetModelAsNoLongerNeeded(pedModel)

        FreezeEntityPosition(ped, true)
        SetEntityInvincible(ped, true)
        SetBlockingOfNonTemporaryEvents(ped, true)
        NetworkFadeInEntity(ped, true)

        exports.ox_target:addLocalEntity(ped, {
            {
                label = 'Kalbėtis su bahuru',
                icon = "fa-solid fa-car-burst",
                onSelect = function()
                    TriggerServerEvent('kub_chop:giveTablet')
                end,
                distance = 2.0,
            },
        })
    end
end

Citizen.CreateThread(function()
    while not ESX.IsPlayerLoaded() do
        Wait(500)
    end

    lib.points.new({
        coords = vec3(956.8864, -1514.2760, 31.2937),
        distance = 50,
        onEnter = function()
            CreateLocalPed()
        end,
        onExit = function()
            if ped then
                exports.ox_target:removeLocalEntity(ped)
                DeletePed(ped)
                ped = nil
            end
        end
    })
end)