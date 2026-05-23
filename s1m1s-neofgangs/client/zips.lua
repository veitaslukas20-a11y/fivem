local playerState = LocalPlayer.state

function zippPlayer(ped)
    local playerId = GetPlayerServerId(NetworkGetPlayerIndexFromPed(ped))
    local state = lib.callback.await('s1m1s-neofgang:setPlayerZipps', false, playerId)

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