local stam = false
local animations = {
	{ dictionary = "creatures@rottweiler@amb@sleep_in_kennel@", animation = "sleep_in_kennel", command = "laydown", },
	{ dictionary = "creatures@rottweiler@amb@world_dog_barking@idle_a", animation = "idle_a", command = "bark", },
	{ dictionary = "creatures@rottweiler@amb@world_dog_sitting@base", animation = "base", command = "sit", },
	{ dictionary = "creatures@rottweiler@amb@world_dog_sitting@idle_a", animation = "idle_a", command = "itch", },
	{ dictionary = "creatures@rottweiler@indication@", animation = "indicate_high", command = "drawattention", },
	{ dictionary = "creatures@rottweiler@melee@", animation = "dog_takedown_from_back", command = "attack", },
	{ dictionary = "creatures@rottweiler@melee@streamed_taunts@", animation = "taunt_02", command = "taunt", },
	{ dictionary = "creatures@rottweiler@swim@", animation = "swim", command = "swim", },
}

RegisterCommand('petanim', function(source, args)
	ESX.TriggerServerCallback('d-pet:caruseped', function(canuse)
		if canuse then
			if args[1] == 'cancel' then cancelEmote() return end
			for k,v in ipairs(animations) do
				if args[1] == v.command then
					playAnimation(v.dictionary, v.animation)
				end
			end
		end
	end)
end)

RegisterCommand('pdstam', function(source, args)
	ESX.TriggerServerCallback('d-pet:caruseped', function(canuse)
		if canuse then
			if stam then
				stamina(false)
			else
				stamina(true)
			end
			print(stam)
		end
	end)
end)

RegisterCommand('pdsuo', function(source, args)
	ESX.TriggerServerCallback('d-pet:caruseped', function(canuse)
		if canuse then
			if args[1] == '1' then
				local modelHash
				ESX.TriggerServerCallback('esx_skin:getPlayerSkin', function(skin, jobSkin)
					if skin.sex == 0 then
						modelHash = GetHashKey('a_c_shepherd')
					else
						modelHash = GetHashKey('a_c_shepherd')
					end
		
					ESX.Streaming.RequestModel(modelHash, function()
						SetPlayerModel(PlayerId(), modelHash)
						SetModelAsNoLongerNeeded(modelHash)
						SetPedDefaultComponentVariation(PlayerPedId())
		
						TriggerEvent('esx:restoreLoadout')
					end)
				end)
				TriggerServerEvent('esx_service:notifyAllInService', notification, 'police')
				ESX.ShowNotification(_U('service_in'))
				local data = {
					['Log'] = 'police',
					['Title'] = 'Pradėjo dirbti',
					['Message'] = 'Žaidėjas pradėjo dirbti',
					['Color'] = 'green'
				}
		
				TriggerServerEvent('Boost-Logs:SendLog', data)
				exports["rp-radio"]:GivePlayerAccessToFrequencies(1, 2, 8, 9)
			else
				ESX.TriggerServerCallback('esx_skin:getPlayerSkin', function(skin, jobSkin)
					local isMale = skin.sex == 0
		
					TriggerEvent('skinchanger:loadDefaultModel', isMale, function()
						ESX.TriggerServerCallback('esx_skin:getPlayerSkin', function(skin)
							TriggerEvent('skinchanger:loadSkin', skin)
							TriggerEvent('esx:restoreLoadout')
						end)
					end)
		
				end)
				TriggerServerEvent('esx_service:notifyAllInService', notification, 'police')
				TriggerServerEvent('esx_service:disableService', 'police')
				ESX.ShowNotification(_U('service_out'))
		
				local data = {
					['Log'] = 'police',
					['Title'] = 'Pabaigė darba',
					['Message'] = 'Žaidėjas pabaigė darba',
					['Color'] = 'yellow'
				}
		
				TriggerServerEvent('Boost-Logs:SendLog', data)
			end
		end
	end)
end)

function playAnimation(dictionary, animation)
	if emotePlaying then
		cancelEmote()
	end
	RequestAnimDict(dictionary)
	while not HasAnimDictLoaded(dictionary) do
		Wait(1)
	end
	TaskPlayAnim(GetPlayerPed(-1), dictionary, animation, 8.0, 0.0, -1, 1, 0, 0, 0, 0)
	emotePlaying = true
end

function cancelEmote()
	ClearPedTasksImmediately(GetPlayerPed(-1))
	emotePlaying = false
end

function stamina(on)
	stam = on
	Citizen.CreateThread(function()
		while true do
			if stam then
				ResetPlayerStamina(PlayerId())
			else
				break 
			end
			Wait(50)
		end
	end)
end

function playAnim(anim, animdisc, time, prop, bone, placement)
	local prop = GetHashKey(prop)
	local ped = PlayerPedId()
	RequestAnimDict(anim)
    while not HasAnimDictLoaded(anim) do
        RequestAnimDict(anim)
        Citizen.Wait(100)
    end
    TaskPlayAnim(ped, anim, animdisc, 3.0, 1.0, time, 51, 0, false, false, false)

	RequestModel(prop)
    while not HasModelLoaded(prop) do
		RequestModel(prop)
        Wait(50)
	end

    local coords = GetEntityCoords(ped)
    local newProp = CreateObject(prop, coords.x, coords.y, coords.z + 0.2, true, true, true)
    if newProp then
        AttachEntityToEntity(newProp, ped, GetPedBoneIndex(ped, bone), placement[1] + 0.0, placement[2] + 0.0, placement[3] + 0.0, placement[4] + 0.0, placement[5] + 0.0, placement[6] + 0.0, true, true, false, true, 1, true)
    end
    SetModelAsNoLongerNeeded(prop)
	Wait(time)
	DeleteEntity(newProp)
end