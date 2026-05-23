local playerState = LocalPlayer.state

function zippPlayer(ped)
    local playerId = GetPlayerServerId(NetworkGetPlayerIndexFromPed(ped))
    local state = lib.callback.await('s1m1s-gangs:setPlayerZipps', false, playerId)

    if state == nil then return end

    --FreezeEntityPosition(cache.ped, true)
    SetCurrentPedWeapon(cache.ped, `WEAPON_UNARMED`, true)
    AttachEntityToEntity(cache.ped, ped, 11816, -0.07, -0.58, 0.0, 0.0, 0.0, 0.0, false, false , false, true, 2, true)

    local dict = 'mp_arresting'

    if state then
        lib.progressCircle({
            label = 'Surišate asmenį...',
            duration = 3750,
            position = 'bottom',
            useWhileDead = false,
            canCancel = false,
            anim = {
                dict = dict,
                clip = 'a_uncuff',
                flag = 33,
            },
        })

        DetachEntity(cache.ped, true, false)
    else
        lib.progressCircle({
            label = 'Atrišate asmenį...',
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

function canZippPed(ped)
	return IsPedFatallyInjured(ped)
    or GetIsTaskActive(ped, 0)
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

local isZipped = playerState.isZipped

local function whileZipped()
    while isZipped do
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
DisableControlAction(0, 200, true) -- ESC
DisableControlAction(0, 243, true) -- M (map)
DisableControlAction(0, 322, true) -- Close menu
DisableControlAction(0, 177, true) -- Backspace
DisableControlAction(0, 199, true) -- Pause
DisableControlAction(0, 37, true)  -- Weapon wheel
SetPauseMenuActive(false)

        DisableControlAction(0, 59, true) -- Disable steering in vehicle
        DisableControlAction(0, 71, true) -- Disable driving forward in vehicle
        DisableControlAction(0, 72, true) -- Disable reversing in vehicle

        DisableControlAction(0, 21, true)

        DisableControlAction(0, 75, true)  -- Disable exit vehicle
        DisableControlAction(27, 75, true) -- Disable exit vehicle

        SetPlayerStamina(cache.playerId, 0.0)

        Wait(10)
    end

    ClearPedTasks(cache.ped)
    RemoveAnimDict('mp_arresting')
end

AddStateBagChangeHandler('isZipped', ('player:%s'):format(cache.serverId), function(_, _, value)
    local ped = cache.ped

    SetEnableHandcuffs(cache.ped, value)
    SetEnableBoundAnkles(cache.ped, value)
    exports.ox_target:disableTargeting(value)

    if isZipped ~= value then
        SetCurrentPedWeapon(cache.ped, `WEAPON_UNARMED`, true)
        ClearPedTasksImmediately(cache.ped)

        Wait(100)

        --[[if value then
            playerState.invBusy = value

            lib.requestAnimDict('mp_arrest_paired')
            TaskPlayAnim(cache.ped, 'mp_arrest_paired', 'crook_p2_back_right', 8.0, -8.0, 3750, 33, 0, false, false, false)
            Wait(3750)
            RemoveAnimDict('mp_arrest_paired')
        else]]
            FreezeEntityPosition(cache.ped, true)
            Wait(3750)
            playerState.invBusy = value
            FreezeEntityPosition(cache.ped, false)
        --end

        isZipped = value
    end

    isZipped = value
if value then
    Wait(200) -- mažas delay, kad išvengtų pirmo ESC
    SetPauseMenuActive(false) -- uždaro map jei spėjo atsidaryt
    whileZipped()
else
    SetPauseMenuActive(false)
end
end)

playerState.isZipped = isZipped