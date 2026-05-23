local DaroAnimacija = false
local IsDead = false

AddEventHandler('esx:onPlayerDeath', function()
	IsDead = true
end)

AddEventHandler('reload_death:onPlayerRevive', function()
	IsDead = false
end)

RegisterCommand("nesti",function(source, args)
	if IsDead then return end 

	local Neleisti = exports['s1m1s-pataisos']:checkPataisos()
	if Neleisti then return end

	if not DaroAnimacija then
		DaroAnimacija = true	
		dict = 'missfinale_c2mcs_1'
		anim1 = 'fin_c2_mcs_1_camman'
		dict2 = 'nm'
		anim2 = 'firemans_carry'
		distans = 0.15
		distans2 = 0.27
		height = 0.63
		spin = 0.0		
		length = 1000000
		controlFlagMe = 49
		controlFlagTarget = 33
		animFlagTarget = 1
		playerId, _, _ = lib.getClosestPlayer(GetEntityCoords(cache.ped), 3.0, false)
		if playerId then
			TriggerServerEvent('deivuks-anims:play:server', GetPlayerServerId(playerId), {dict = dict, dict2 = dict2, anim = anim1, anim2 = anim2, distans = distans, distans2 = distans2, height = height, xRot = 0.5, yRot = 0.5, length = length, spin = spin, flag = controlFlagMe, flag2 = controlFlagTarget})
		end
	else
		DaroAnimacija = false
		ClearPedSecondaryTask(cache.ped)
		DetachEntity(cache.ped, true, false)
		playerId, _, _ = lib.getClosestPlayer(GetEntityCoords(cache.ped), 3.0, false)
		if playerId then
			TriggerServerEvent("deivuks-anims:stop", GetPlayerServerId(playerId))
		end
	end
end, false)

RegisterCommand("nesti2",function(source, args)
	if IsDead then return end 

	local Neleisti = exports['s1m1s-pataisos']:checkPataisos()
	if Neleisti then return end

	if not DaroAnimacija then
		DaroAnimacija = true
		dict = 'anim@heists@box_carry@'
		anim1 = 'idle'
		dict2 = 'amb@code_human_in_car_idles@generic@ps@base'
		anim2 = 'base'
		distans = 0.05
		distans2 = 0.00
		height = -0.25
		spin = 0.0		
		length = 1000000
		controlFlagMe = 49
		controlFlagTarget = 33
		animFlagTarget = 1
		playerId, _, _ = lib.getClosestPlayer(GetEntityCoords(cache.ped), 3.0, false)
		if playerId then
			TriggerServerEvent('deivuks-anims:play:server', GetPlayerServerId(playerId), {bone = 90, dict = dict, dict2 = dict2, anim = anim1, anim2 = anim2, distans = distans, distans2 = distans2, height = height, xRot = 1.0, yRot = -90.0, length = length, spin = spin, flag = controlFlagMe, flag2 = controlFlagTarget})
		end
	else
		DaroAnimacija = false
		ClearPedSecondaryTask(cache.ped)
		DetachEntity(cache.ped, true, false)
		playerId, _, _ = lib.getClosestPlayer(GetEntityCoords(cache.ped), 3.0, false)
		if playerId then
			TriggerServerEvent("deivuks-anims:stop", GetPlayerServerId(playerId))
		end
	end
end, false)

RegisterCommand("nesti3",function(source, args)
	if IsDead then return end  

	local Neleisti = exports['s1m1s-pataisos']:checkPataisos()
	if Neleisti then return end

	if not DaroAnimacija then
		DaroAnimacija = true
		dict = 'anim@heists@box_carry@'
		anim1 = 'idle'
		dict2 = 'amb@code_human_in_car_idles@generic@ps@base'
		anim2 = 'base'
		distans = 0.05
		distans2 = 0.00
		height = -0.25
		spin = 0.0		
		length = 1000000
		controlFlagMe = 49
		controlFlagTarget = 33
		animFlagTarget = 1
		playerId, _, _ = lib.getClosestPlayer(GetEntityCoords(cache.ped), 3.0, false)
		if playerId then
			TriggerServerEvent('deivuks-anims:play:server', GetPlayerServerId(playerId), {bone = 90, dict = dict, dict2 = dict2, anim = anim1, anim2 = anim2, distans = distans, distans2 = distans2, height = height, xRot = 0.5, yRot = -0.0, length = length, spin = spin, flag = controlFlagMe, flag2 = controlFlagTarget})
		end
	else
		DaroAnimacija = false
		ClearPedSecondaryTask(cache.ped)
		DetachEntity(cache.ped, true, false)
		playerId, _, _ = lib.getClosestPlayer(GetEntityCoords(cache.ped), 3.0, false)
		if playerId then
			TriggerServerEvent("deivuks-anims:stop", GetPlayerServerId(playerId))
		end
	end
end, false)

exports('stopCarry', function()
	if DaroAnimacija then 
		DaroAnimacija = false
		ClearPedSecondaryTask(cache.ped)
		DetachEntity(cache.ped, true, false)
		playerId, _, _ = lib.getClosestPlayer(GetEntityCoords(cache.ped), 3.0, false)
		if playerId then
			TriggerServerEvent("deivuks-anims:stop", GetPlayerServerId(playerId))
		end
	end
end)

RegisterNetEvent('deivuks-anims:play', function(target, data)
	local Neleisti = exports['s1m1s-pataisos']:checkPataisos()
	if Neleisti then return end

	local targetPed = GetPlayerPed(GetPlayerFromServerId(target))
	DaroAnimacija = true
	RequestAnimDict(data.dict2)

	while not HasAnimDictLoaded(data.dict2) do
		Citizen.Wait(100)
	end
	AttachEntityToEntity(cache.ped, targetPed, data.bone or 0, data.distans2, data.distans, data.height, data.xRot, data.yRot, data.spin, false, false, false, false, 0, false)
	TaskPlayAnim(cache.ped, data.dict2, data.anim2, 8.0, -8.0, data.length, data.flag2, 0, false, false, false)
end)

exports('isCaried', function()
	return DaroAnimacija
end)

RegisterNetEvent('deivuks-anims:play.me', function(data)
	RequestAnimDict(data.dict)

	while not HasAnimDictLoaded(dict) do
		Citizen.Wait(10)
	end
	Wait(500)
	TaskPlayAnim(cache.ped, data.dict, data.anim, 8.0, -8.0, data.length, data.flag, 0, false, false, false)
end)

RegisterNetEvent('deivuks-anims:stop', function()
	DaroAnimacija = false
	ClearPedSecondaryTask(cache.ped)
	DetachEntity(cache.ped, true, false)
end)

--[[function GetPlayers()
    local players = {}

    for i = 0, 255 do
        if NetworkIsPlayerActive(i) then
            table.insert(players, i)
        end
    end

    return players
end

function GetClosestPlayer(radius)
    local players = GetPlayers()
    local closestDistance = -1
    local closestPlayer = -1
    local ply = GetPlayerPed(-1)
    local plyCoords = GetEntityCoords(ply, 0)

    for index,value in ipairs(players) do
        local target = GetPlayerPed(value)
        if(target ~= ply) then
            local targetCoords = GetEntityCoords(GetPlayerPed(value), 0)
            local distance = GetDistanceBetweenCoords(targetCoords['x'], targetCoords['y'], targetCoords['z'], plyCoords['x'], plyCoords['y'], plyCoords['z'], true)
            if(closestDistance == -1 or closestDistance > distance) then
                closestPlayer = value
                closestDistance = distance
            end
        end
    end

	if closestDistance <= radius then
		return closestPlayer
	else
		return nil
	end
end]]

local ped = 0
RegisterCommand('playanim', function(source, args)
	if IsDead then return end 

	local Neleisti = exports['s1m1s-pataisos']:checkPataisos()
	if Neleisti then return end

	if not DaroAnimacija then
		if args[1] == '1' then
			DaroAnimacija = true	
			dict = 'mggypiggypair1@animation'
			anim1 = 'mggypiggypair1_clip'
			dict2 = 'mggypiggypair2@animation'
			anim2 = 'mggypiggypair2_clip'
			distans = -0.25
			distans2 = 0.0
			length = -1
			controlFlagMe = 49
			controlFlagTarget = 33
			spin = 0

			playerId, _, _ = lib.getClosestPlayer(GetEntityCoords(cache.ped), 3.0, false)
			if playerId then
				TriggerServerEvent('deivuks-anims:play:server', GetPlayerServerId(playerId), {dict = dict, anim = anim1, dict2 = dict2, anim2 = anim2, distans = distans, distans2 = distans2, height = 0.62, length = length, spin = spin, flag2 = controlFlagTarget, flag = controlFlagMe})
			end

			--[[RequestAnimDict(lib2)
		
			while not HasAnimDictLoaded(lib2) do
				Citizen.Wait(10)
			end
			TaskPlayAnim(ped, lib2, anim2, 8.0, -8.0, length, controlFlagTarget, 0, false, false, false)
			AttachEntityToEntity(ped, player, 0, distans2, distans, 0.68, 0.0, 0.0, 0.0, false, false, false, false, 0, false)]]
		elseif args[1] == '2' then
			DaroAnimacija = true	
			dict = 'bffcasualpose1@animation'
			anim1 = 'bffcasualpose1_clip'
			dict2 = 'bffcasualpose2@animation'
			anim2 = 'bffcasualpose2_clip'
			distans = -0.3
			distans2 = 0.4
			spin = 40.0		
			length = -1
			controlFlagMe = 1
			controlFlagTarget = 33

			playerId, _, _ = lib.getClosestPlayer(GetEntityCoords(cache.ped), 3.0, false)
			if playerId then
				TriggerServerEvent('deivuks-anims:play:server', GetPlayerServerId(playerId), {dict = dict, anim = anim1, dict2 = dict2, anim2 = anim2, distans = distans, distans2 = distans2, height = 0.0, length = length, spin = spin, flag2 = controlFlagTarget, flag = controlFlagMe})
				Wait(100)
				RequestAnimDict(dict)

				while not HasAnimDictLoaded(dict) do
					Citizen.Wait(10)
				end
				Wait(500)
				TaskPlayAnim(cache.ped, dict, anim1, 8.0, -8.0, length, controlFlagMe, 0, false, false, false)
			end
		elseif args[1] == '3' then
			DaroAnimacija = true	
			dict = 'bfflookback1@animation'
			anim1 = 'bfflookback1_clip'
			dict2 = 'bfflookback2@animation'
			anim2 = 'bfflookback2_clip'
			distans = 0.14
			distans2 = 0.9
			spin = 0.0		
			length = -1
			controlFlagMe = 33
			controlFlagTarget = 33

			playerId, _, _ = lib.getClosestPlayer(GetEntityCoords(cache.ped), 3.0, false)
			if playerId then
				TriggerServerEvent('deivuks-anims:play:server', GetPlayerServerId(playerId), {dict = dict, anim = anim1, dict2 = dict2, anim2 = anim2, distans = distans, distans2 = distans2, height = 0.0, length = length, spin = spin, flag2 = controlFlagTarget, flag = controlFlagMe})
				Wait(100)
				RequestAnimDict(dict)

				while not HasAnimDictLoaded(dict) do
					Citizen.Wait(10)
				end
				Wait(500)
				TaskPlayAnim(cache.ped, dict, anim1, 8.0, -8.0, length, controlFlagMe, 0, false, false, false)
			end
		elseif args[1] == '4' then
			DaroAnimacija = true	
			dict = 'bfffun1@animation'
			anim1 = 'bfffun1_clip'
			dict2 = 'bfffun2@animation'
			anim2 = 'bfffun2_clip'
			distans = -0.72
			distans2 = 0.0
			spin = 180.0		
			length = -1
			controlFlagMe = 49
			controlFlagTarget = 33

			playerId, _, _ = lib.getClosestPlayer(GetEntityCoords(cache.ped), 3.0, false)
			if playerId then
				TriggerServerEvent('deivuks-anims:play:server', GetPlayerServerId(playerId), {dict = dict, anim = anim1, dict2 = dict2, anim2 = anim2, distans = distans, distans2 = distans2, height = 0.2, length = length, spin = spin, flag2 = controlFlagTarget, flag = controlFlagMe})
				Wait(100)
				RequestAnimDict(dict)

				while not HasAnimDictLoaded(dict) do
					Citizen.Wait(10)
				end
				Wait(500)
				TaskPlayAnim(cache.ped, dict, anim1, 8.0, -8.0, length, controlFlagMe, 0, false, false, false)
			end
		end
	else
		DaroAnimacija = false
		ClearPedSecondaryTask(cache.ped)
		DetachEntity(cache.ped, true, false)
		playerId, _, _ = lib.getClosestPlayer(GetEntityCoords(cache.ped), 3.0, false)
		if playerId then
			TriggerServerEvent("deivuks-anims:stop", GetPlayerServerId(playerId))
		end
	end
end)

local HasRequest = false
RegisterNetEvent('deivuks-anims:wait.confirm', function(player, name, data)
	HasRequest = true

	if IsDead then
		if #(GetEntityCoords(PlayerPedId()) - GetEntityCoords(GetPlayerPed(GetPlayerFromServerId(player)))) <= 3.0 then
			TriggerServerEvent('deivuks-anims:confirm.server', player, data)
			HasRequest = false
		end
	else 
		exports['deivuks-request']:showRequest({player = name, keybind = 'ENTER', time = 30}, function(accept)
			if accept then
				if #(GetEntityCoords(PlayerPedId()) - GetEntityCoords(GetPlayerPed(GetPlayerFromServerId(player)))) <= 3.0 then
					TriggerServerEvent('deivuks-anims:confirm.server', player, data)
					HasRequest = false
				end
			else
				TriggerServerEvent('deivuks-anims:cancel', player)
				HasRequest = false
			end
		end)
	end
end)