local playerState = LocalPlayer.state
escorting = nil

function WhileEscorting()
    CreateThread(function()
        local dict, name = 'amb@code_human_wander_drinking@beer@male@base', 'static'

        lib.showTextUI('Spauskite [H], kad paleistumete asmenį', {
            icon = 'fas fa-hands-bound',
            position = 'left-center'
        })

        while IsEntityAttachedToEntity(escorting, cache.ped) do 
            if not IsEntityPlayingAnim(cache.ped, dict, name, 3) then
                lib.requestAnimDict(dict)
                TaskPlayAnim(cache.ped, dict, name, 8.0, -8, -1, 49, 0, 0, 0, 0)
            end
            Wait(200)
        end

        lib.hideTextUI()

        ClearPedTasks(cache.ped)
    end)
end

function escortPlayer(ped, id)
    if not id then
        id = NetworkGetPlayerIndexFromPed(ped)
    end

    if not escorting then
        escorting = ped 
    else
        escorting = nil 
    end
    
    TriggerServerEvent('s1m1s-gangs:setPlayerEscort', GetPlayerServerId(id), not IsEntityAttachedToEntity(ped, cache.ped))

    Wait(200)
    WhileEscorting()
end

RegisterCommand('gangs:escortrelease', function()
    if escorting and IsPedCuffed(escorting) and IsEntityAttachedToEntity(escorting, cache.ped) then
        escortPlayer(escorting)
    end
end)
RegisterKeyMapping('gangs:escortrelease', 'Paleisti asmeni', 'keyboard', 'H')

RegisterNetEvent('s1m1s-gangs:escortStart', function(escorterId)
    local escorterPed = GetPlayerPed(GetPlayerFromServerId(escorterId))
    if DoesEntityExist(escorterPed) then
        AttachEntityToEntity(cache.ped, escorterPed, 11816, 0.15, 0.35, 0.0, 0.0, 0.0, 90.0, false, false, false, false, 2, true)
    end
end)

RegisterNetEvent('s1m1s-gangs:escortStop', function()
    DetachEntity(cache.ped, true, false)
    ClearPedTasks(cache.ped)
end)
