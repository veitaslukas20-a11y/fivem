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
    id = id or NetworkGetPlayerIndexFromPed(ped)

    if not id then return end
    if not tonumber(id) then return end

    if not escorting then
        escorting = ped 
    else
        escorting = nil 
    end

    TriggerServerEvent('s1m1s-police:setPlayerEscort', GetPlayerServerId(id), not IsEntityAttachedToEntity(ped, cache.ped))

    Wait(200)
    WhileEscorting()
end

local isEscorted = playerState.isEscorted

function setEscorted(serverId)
    CreateThread(function()
        local dict = 'anim@move_m@prisoner_cuffed'
        local dict2 = 'anim@move_m@trash'

        while isEscorted do
            local player = GetPlayerFromServerId(serverId)
            local ped = player > 0 and GetPlayerPed(player)

            if not ped then break end

            if not IsEntityAttachedToEntity(cache.ped, ped) then
                AttachEntityToEntity(cache.ped, ped, 11816, 0.24, 0.50, 0.0, 0.0, 0.0, 0.0, false, false, false, false, 2, true)
            end

           if IsPedWalking(ped) then
                if not IsEntityPlayingAnim(cache.ped, dict, 'walk', 3) then
                    lib.requestAnimDict(dict)
                    TaskPlayAnim(cache.ped, dict, 'walk', 8.0, -8, -1, 1, 0.0, false, false, false)
                end
            elseif IsPedRunning(ped) or IsPedSprinting(ped) then
                if not IsEntityPlayingAnim(cache.ped, dict2, 'run', 3) then
                    lib.requestAnimDict(dict2)
                    TaskPlayAnim(cache.ped, dict2, 'run', 8.0, -8, -1, 1, 0.0, false, false, false)
                end
            else
                StopAnimTask(cache.ped, dict, 'walk', -8.0)
                StopAnimTask(cache.ped, dict2, 'run', -8.0)
            end

            Wait(0)
        end

        StopAnimTask(cache.ped, dict, 'walk', -8.0)
        StopAnimTask(cache.ped, dict2, 'run', -8.0)

        RemoveAnimDict(dict)
        RemoveAnimDict(dict2)
        playerState:set('isEscorted', false, true)
    end)
end

AddStateBagChangeHandler('isEscorted', ('player:%s'):format(cache.serverId), function(_, _, value)
    isEscorted = value

    if IsEntityAttached(cache.ped) then
        DetachEntity(cache.ped, true, false)
    end

    if value then 
        setEscorted(value)
    end
end)

if isEscorted then
    CreateThread(function()
        setEscorted(isEscorted)
    end)
end

RegisterCommand('police:escortrelease', function()
    if escorting and IsPedCuffed(escorting) and IsEntityAttachedToEntity(escorting, cache.ped) then
        escortPlayer(escorting)
    end
end)
RegisterKeyMapping('police:escortrelease', 'Paleisti asmeni', 'keyboard', 'H')