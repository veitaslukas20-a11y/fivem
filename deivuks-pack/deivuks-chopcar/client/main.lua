local vykdoma = false
local motorcycle = false
local wheel_lf, wheel_rf, wheel_lr, wheel_rr, boot, bonnet, door_dside_f, door_dside_r, door_pside_f, door_pside_r = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
local Vehicle = nil
local Time = {min = 0, sec = 0}

local InZone = false
local currectZone
Citizen.CreateThread(function()
	while not ESX.IsPlayerLoaded() do Wait(500) end

	for index, coords in pairs(deivuks_chopcar.vehiclesCoords) do
		lib.points.new({
			coords = vec3(coords.x, coords.y, coords.z),
			distance = 3,
			onEnter = function(self)
				InZone = true
				CheckTimeout()
				currectZone = index
			end,
			onExit = function()
				InZone = false
				currectZone = nil
			end,
			nearby = function(self)
				if Vehicle then
					DrawText3D(self.coords, (Time.min > 0 or Time.sec > 0) and ('Iki kito išrinkimo liko ~b~'..((Time.min >= 10) and Time.min or '0'..Time.min)..':'..((Time.sec >= 10) and Time.sec or '0'..Time.sec)) or '[~b~E~w~] Išrinkti automobilį')
				end
			end
		})
	end
end)

function CheckTimeout()
	Citizen.CreateThread(function()
		while InZone do
			local timeout = lib.callback.await('d-chopcar:getTime', false, currectZone)

			timeout = (15 * 60) - timeout

			if timeout > 0 then
				Time.sec = time
				Time.min = math.floor(timeout / 60)
				Time.sec = math.floor(timeout - (Time.min * 60))
			else
				Time = {min = 0, sec = 0}
			end

			Wait(1000)
		end
	end)
end

lib.onCache('vehicle', function(value)
	if value then
		Vehicle = value
	else
		Vehicle = nil
	end
end)

lib.addKeybind({
    name = 'isrinktiAutomobili',
    description = 'Isrinkti automobili',
    defaultKey = 'E',
    onPressed = function(self)
		if not InZone then return end
		if (Time.min > 0 or Time.sec > 0) then return end
		if not Vehicle then return end
        StartintPokalbi()
    end,
})

local timeriuks = 2000
Citizen.CreateThread(function()
	while true do
		if vykdoma then
			timeriuks = 1000
			if not Vehicle then
				notify('Deja, ardymas nutrauktas.', 'error')
				TriggerServerEvent('d-chopcar:setData', currectZone, false)
				vykdoma = false
				timeriuks = 2000
			end
		else
			timeriuks = 2000
		end
		Wait(timeriuks)
	end
end)

function PradetiIsrinkima()
	if not vykdoma then
		if Vehicle then
			TaskWarpPedIntoVehicle(PlayerPedId(), Vehicle, -1)
			vykdoma = true
			local vehicleCoords = deivuks_chopcar.vehiclesCoords[currectZone]
			SetEntityCoords(Vehicle, vehicleCoords.x, vehicleCoords.y, vehicleCoords.z, false, false, false, false)
			SetEntityHeading(Vehicle, vehicleCoords.w)
			TriggerServerEvent('d-chopcar:setData', currectZone, true)

			if currectZone == 1 and math.random(0, 100) < 40 then
				TriggerServerEvent('cd_dispatch:AddNotification', {
					job_table = {'police'}, --{'police', 'sheriff} 
					coords = vehicleCoords.Vehicle,
					title = '10-98 - Automobilio ardymas',
					message = 'Asmuo buvo aptiktas bandant išardyti automobilį, apie tai pranešė aplikniniai žmonės.',
					flash = 1,
					unique_id = tostring(math.random(0000000,9999999)),
					blip = {
						sprite = 620, 
						scale = 1.2, 
						colour = 1,
						flashes = true, 
						text = '<font face="Roboto">10-98 - Automobilio išrinkimas</font>',
						time = (15*60*1000), --(5 mins)
						sound = 2,
					}
				})
			end

			FreezeEntityPosition(Vehicle, true)
			if GetVehicleClass(Vehicle) ~= 8 then
				motorcycle = false
				wheel_lf = GetWorldPositionOfEntityBone(Vehicle, GetEntityBoneIndexByName(Vehicle, "wheel_lf"))
				wheel_rf = GetWorldPositionOfEntityBone(Vehicle, GetEntityBoneIndexByName(Vehicle, "wheel_rf"))
				wheel_lr = GetWorldPositionOfEntityBone(Vehicle, GetEntityBoneIndexByName(Vehicle, "wheel_lr"))
				wheel_rr = GetWorldPositionOfEntityBone(Vehicle, GetEntityBoneIndexByName(Vehicle, "wheel_rr"))
				boot = GetWorldPositionOfEntityBone(Vehicle, GetEntityBoneIndexByName(Vehicle, "boot"))
				if boot ~= nil then
					boot = vector3(boot.x +0.7, boot.y, boot.z)
				end
				bonnet = GetWorldPositionOfEntityBone(Vehicle, GetEntityBoneIndexByName(Vehicle, "bonnet"))
				if bonnet ~= nil then
					bonnet = vector3(bonnet.x -0.7, bonnet.y, bonnet.z)
				end
				door_dside_f = GetWorldPositionOfEntityBone(Vehicle, GetEntityBoneIndexByName(Vehicle, "door_dside_f"))
				door_dside_r = GetWorldPositionOfEntityBone(Vehicle, GetEntityBoneIndexByName(Vehicle, "door_dside_r"))
				door_pside_f = GetWorldPositionOfEntityBone(Vehicle, GetEntityBoneIndexByName(Vehicle, "door_pside_f"))
				door_pside_r = GetWorldPositionOfEntityBone(Vehicle, GetEntityBoneIndexByName(Vehicle, "door_pside_r"))
			else
				motorcycle = true
				GetWorldPositionOfEntityBone(Vehicle, GetEntityBoneIndexByName(Vehicle, "wheel_lf"))
				GetWorldPositionOfEntityBone(Vehicle, GetEntityBoneIndexByName(Vehicle, "wheel_lr"))
			end
			StartChopCar()
		end
	else
		notify('Deja, bet jau kažkas ardo autmobilį.', 'error')
	end
end

function StartChopCar()
	if vykdoma and wheel_lf ~= nil and wheel_lf ~= vector3(0,0,0) and Vehicle ~= nil then
		RemovePart('ratai', 0)
	end
	if vykdoma and wheel_rf ~= nil and wheel_rf ~= vector3(0,0,0) and Vehicle ~= nil and not motorcycle then
		RemovePart('ratai', 1)
	end
	if vykdoma and wheel_lr ~= nil and wheel_lr ~= vector3(0,0,0) and Vehicle ~= nil then
		RemovePart('ratai', 4)
	end
	if vykdoma and wheel_rr ~= nil and wheel_rr ~= vector3(0,0,0) and Vehicle ~= nil and not motorcycle then
		RemovePart('ratai', 5)
	end
	if vykdoma and boot ~= nil and boot ~= vector3(0,0,0) and Vehicle ~= nil and not motorcycle then
		RemovePart('durys', 5)
	end
	if vykdoma and bonnet ~= nil and bonnet ~= vector3(0,0,0) and Vehicle ~= nil and not motorcycle then
		RemovePart('durys', 4)
	end
	if vykdoma and door_dside_f ~= nil and door_dside_f ~= vector3(0,0,0) and Vehicle ~= nil and not motorcycle then
		RemovePart('durys', 0)
	end
	if vykdoma and door_pside_f ~= nil and door_pside_f ~= vector3(0,0,0) and Vehicle ~= nil and not motorcycle then
		RemovePart('durys', 1)
	end
	if vykdoma and door_dside_r ~= nil and door_dside_r ~= vector3(0,0,0) and Vehicle ~= nil and not motorcycle then
		RemovePart('durys', 2)
	end
	if vykdoma and door_pside_r ~= nil and door_pside_r ~= vector3(0,0,0) and Vehicle ~= nil and not motorcycle then
		RemovePart('durys', 3)
	end

	lib.callback.await('d-chopcar:endChop', false, currectZone, ESX.Game.GetVehicleProperties(Vehicle).plate, NetworkGetNetworkIdFromEntity(Vehicle), GetEntityHealth(Vehicle))
	TriggerServerEvent('d-chopcar:setData', currectZone, false)
end

function RemovePart(part, index)
	if Vehicle ~= nil then
		if part == 'durys' then
			SetVehicleDoorOpen(Vehicle, index, false, true)
			PlayLoading(7000, 'Nuimate dalis...')
			notify('Sėkmingai nuėmei dalis.', 'success')
			SetVehicleDoorBroken(Vehicle, index, true)
		elseif part == 'ratai' then
			PlayLoading(7000, 'Nuimate ratą...')
			notify('Sėkmingai nuėmei ratą.', 'success')
			SetVehicleTyreBurst(Vehicle, index, true, 1000.0)
		end
	end
end

local waitResponse = false
function StartintPokalbi()
	if waitResponse then return end
	if not Vehicle then return notify('Turite sėdėti automobilyje norint jį išrinkti', 'erro') end
	if ESX.Game.GetVehicleProperties(Vehicle) then
		waitResponse = true
		local owned = lib.callback.await('d-chopcar:getVehicle', false, ESX.Game.GetVehicleProperties(Vehicle).plate, NetworkGetNetworkIdFromEntity(Vehicle))
		waitResponse = false
		if owned then
			local copsRequire = false

			waitResponse = true
			local data = lib.callback.await('d-chopcar:getData', false, currectZone)
			waitResponse = false

			vykdoma = data.vykdoma
			copsRequire = data.cops
			local timeout = data.timeout

			if copsRequire then
				if timeout then
					if not vykdoma then
						notify('Prieik prie automobilio ir pradėk ardyti.', 'info')
						PradetiIsrinkima()
					end
				else 
					notify('Turite palaukti, kol vėl galėsite išrinkti automobilį.', 'error')
				end
			else
				notify('Nėra pakankamai pareigūnų, kad galėtumėte išrinkti automobilį.', 'error')
			end
		else
			notify('Deja, šio automobilio išrinkti negalite.', 'error')
		end
	end
end

function PlayLoading(time, label, scenario, animationDictionary, flag)
	if scenario ~= nil then
		lib.progressBar({
			duration = time,
			label = label,
			useWhileDead = false,
			canCancel = false,
			disable = {
				car = true,
				move = true,
			},
			anim = {
				dict = scenario,
				clip = animationDictionary,
				flag = flag,
			},
		})
	else
		lib.progressBar({
			duration = time,
			label = label,
			useWhileDead = false,
			canCancel = false,
			disable = {
				car = true,
				move = true,
			},
		})
	end
end

function notify(text, type)
	exports['1x-hud']:sendNotification({
		type = string.upper(tostring(type)),
		title = 'Automobilio išrinkimas',
		message = text,
		duration = 6000,
		icon = 'car-burst'
	})
end


function DrawText3D(coords, text)
	coords = vector3(coords.x, coords.y, coords.z + 1)

	local camCoords = GetGameplayCamCoords()
	local distance = #(coords - camCoords)


	local scale = (1 / distance) * 2
	local fov = (1 / GetGameplayCamFov()) * 100
	scale = scale * fov

	SetTextScale(0.0 * scale, 0.55 * scale)
	SetTextFont(13)
	SetTextColour(255, 255, 255, 255)
	SetTextDropshadow(0, 0, 0, 0, 255)
	SetTextDropShadow()
	SetTextOutline()
	SetTextCentre(true)

	SetDrawOrigin(coords, 0)
	BeginTextCommandDisplayText('STRING')
	AddTextComponentSubstringPlayerName(text)
	EndTextCommandDisplayText(0.0, 0.0)
	ClearDrawOrigin()
end

function playAnim(ped, animDict, animName, duration, flag)
	RequestAnimDict(animDict)
	while not HasAnimDictLoaded(animDict) do Wait(100) end
	TaskPlayAnim(PlayerPedId(), animDict, animName, 1.0, -1.0, duration, flag, 1, false, false, false)
	RemoveAnimDict(animDict)
end