local IsDead = false
local playerState = LocalPlayer.state

AddEventHandler('esx:onPlayerDeath', function()
	IsDead = true
end)

AddEventHandler('reload_death:onPlayerRevive', function()
	IsDead = false
end)

RegisterCommand('+handsup', function()
    if IsDead or IsPedCuffed(cache.ped) or IsPedReloading(cache.ped) or cache.weapon then return end

    if IsEntityPlayingAnim(cache.ped, 'missmic2ig_11', 'mic_2_ig_11_intro_goon', 3) then return end
    if IsEntityPlayingAnim(cache.ped, 'missmic2ig_11', 'mic_2_ig_11_intro_p_one', 3) then return end
    if IsEntityPlayingAnim(cache.ped, 'anim@heists@narcotics@funding@gang_idle', 'gang_chatting_idle01', 3) then return end

    local dict = "missminuteman_1ig_2"
    lib.requestAnimDict(dict)

    ClearPedTasks(cache.ped)
    TaskPlayAnim(cache.ped, dict, "handsup_enter", 8.0, 8.0, -1, 50, 0, false, false, false)
end)

RegisterCommand('-handsup', function()
    if IsDead or IsPedCuffed(cache.ped) or IsPedReloading(cache.ped) then return end

    if IsEntityPlayingAnim(cache.ped, 'missmic2ig_11', 'mic_2_ig_11_intro_goon', 3) then return end
    if IsEntityPlayingAnim(cache.ped, 'missmic2ig_11', 'mic_2_ig_11_intro_p_one', 3) then return end
    if IsEntityPlayingAnim(cache.ped, 'anim@heists@narcotics@funding@gang_idle', 'gang_chatting_idle01', 3) then return end
    
    ClearPedTasks(cache.ped)
end)

RegisterKeyMapping('+handsup', 'Pakelti rankas', 'keyboard', 'x')