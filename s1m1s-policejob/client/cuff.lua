local playerState = LocalPlayer.state

function cuffPlayer(ped)
    local playerId = GetPlayerServerId(NetworkGetPlayerIndexFromPed(ped))
    if not playerId then return end
    if not tonumber(playerId) then return end
    local state = lib.callback.await('s1m1s-police:setPlayerCuffs', false, playerId)

    if state == nil then return end

    --FreezeEntityPosition(cache.ped, true)
    SetCurrentPedWeapon(cache.ped, `WEAPON_UNARMED`, true)
    AttachEntityToEntity(cache.ped, ped, 11816, -0.07, -0.58, 0.0, 0.0, 0.0, 0.0, false, false , false, true, 2, true)

    local dict = state and 'mp_arrest_paired' or 'mp_arresting'

    if state then
        lib.progressCircle({
            label = 'Surakinate asmenį...',
            duration = 3750,
            position = 'bottom',
            useWhileDead = false,
            canCancel = false,
            anim = {
                dict = dict,
                clip = 'cop_p2_back_right',
                flag = 33,
            },
        })

        DetachEntity(cache.ped, true, false)
    else
        lib.progressCircle({
            label = 'Atrakinate asmenį...',
            duration = 3750,
            position = 'bottom',
            useWhileDead = false,
            canCancel = false,
            anim = {
                dict = dict,
                clip = 'a_uncuff'
            },
        })
 
        DetachEntity(cache.ped, true, false)
        FreezeEntityPosition(cache.ped, false)
        if escorting then 
            escortPlayer(ped)
        end
    end
end

function canCuffPed(ped)
	return IsPedFatallyInjured(ped)
    or IsPedRagdoll(ped)
	or IsEntityPlayingAnim(ped, 'dead', 'dead_a', 3)
    or IsEntityPlayingAnim(ped, 'missminuteman_1ig_2', 'handsup_base', 3)
	or IsEntityPlayingAnim(ped, 'missminuteman_1ig_2', 'handsup_enter', 3)
	or IsEntityPlayingAnim(ped, 'random@mugging3', 'handsup_standing_base', 3)
end

function canSearchPed(ped)
    return IsPedFatallyInjured(ped)
	or IsEntityPlayingAnim(ped, 'dead', 'dead_a', 3)
	or IsPedCuffed(ped)
	or IsEntityPlayingAnim(ped, 'mp_arresting', 'idle', 3)
	or IsEntityPlayingAnim(ped, 'missminuteman_1ig_2', 'handsup_base', 3)
	or IsEntityPlayingAnim(ped, 'missminuteman_1ig_2', 'handsup_enter', 3)
	or IsEntityPlayingAnim(ped, 'random@mugging3', 'handsup_standing_base', 3)
end

local isCuffed = playerState.isCuffed

local function whileCuffed()
    while isCuffed do
        if not IsEntityPlayingAnim(cache.ped, 'mp_arresting', 'idle', 3) then
            lib.requestAnimDict('mp_arresting')
            TaskPlayAnim(cache.ped, 'mp_arresting', 'idle', 8.0, -8, -1, 49, 0, 0, 0, 0)
        end

        DisablePlayerFiring(cache.playerId, true)
        
        DisableControlAction(0, 22, true) -- Jump

        DisableControlAction(0, 288,  true) -- Disable phone
        DisableControlAction(0, 289, true) -- Inventory
        DisableControlAction(0, 170, true) -- Animations
        DisableControlAction(0, 167, true) -- Job

        DisableControlAction(0, 73, true) -- Disable clearing animation
        DisableControlAction(2, 199, true) -- Disable pause screen

        DisableControlAction(0, 59, true) -- Disable steering in vehicle
        DisableControlAction(0, 71, true) -- Disable driving forward in vehicle
        DisableControlAction(0, 72, true) -- Disable reversing in vehicle

        DisableControlAction(0, 21, true)

        DisableControlAction(0, 75, true)  -- Disable exit vehicle
        DisableControlAction(27, 75, true) -- Disable exit vehicle

        DisableControlAction(0, 140, true) -- Disable Fight 
        DisableControlAction(0, 142, true) -- Disable Fight 

        SetPlayerStamina(cache.playerId, 0.0)

        Wait(1)
    end

    ClearPedTasks(cache.ped)
    RemoveAnimDict('mp_arresting')
end

AddStateBagChangeHandler('isCuffed', ('player:%s'):format(cache.serverId), function(_, _, value)
    SetEnableHandcuffs(cache.ped, value)
    SetEnableBoundAnkles(cache.ped, value)
    exports.ox_target:disableTargeting(value)

    if isCuffed ~= value then
        SetCurrentPedWeapon(cache.ped, `WEAPON_UNARMED`, true)
        ClearPedTasksImmediately(cache.ped)

        Wait(100)

        if value then
            playerState.invBusy = value

            lib.requestAnimDict('mp_arrest_paired')
            TaskPlayAnim(cache.ped, 'mp_arrest_paired', 'crook_p2_back_right', 8.0, -8.0, 3750, 33, 0, false, false, false)
            Wait(3750)
            RemoveAnimDict('mp_arrest_paired')
        else
            FreezeEntityPosition(cache.ped, true)
            Wait(3750)
            playerState.invBusy = value
            FreezeEntityPosition(cache.ped, false)
        end

        isCuffed = value
    end

    isCuffed = value
    if value then 
        whileCuffed()
    end
end)

playerState.isCuffed = isCuffed