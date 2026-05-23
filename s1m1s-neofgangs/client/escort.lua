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

    TriggerServerEvent('s1m1s-neofgang:setPlayerEscort', GetPlayerServerId(id), not IsEntityAttachedToEntity(ped, cache.ped))

    Wait(200)
    WhileEscorting()
end

RegisterCommand('neofgangs:escortrelease', function()
    if escorting and IsPedCuffed(escorting) and IsEntityAttachedToEntity(escorting, cache.ped) then
        escortPlayer(escorting)
    end
end)
RegisterKeyMapping('neofgangs:escortrelease', 'Paleisti asmeni', 'keyboard', 'H')