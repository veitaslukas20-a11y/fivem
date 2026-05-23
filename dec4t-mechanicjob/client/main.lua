local OnDuty = false
local Job = {}
local Garage = exports['dec4t-jobgarage']:initGarages()

function IsMechanic()
	return Config.Jobs[Job.name]
end

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(xPlayer)
	Job.grade = xPlayer.job.grade_name
	Job.name = xPlayer.job.name
	Job.grade_num = xPlayer.job.grade

	if IsMechanic() then
		InitZones()
	end
end)

RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job)
	Job.grade = job.grade_name
	Job.name = job.name
	Job.grade_num = job.grade

	if IsMechanic() then
		RemoveZones()
		InitZones()
	else 
		if OnDuty then
			exports.ox_target:removeGlobalPlayer('mechanic:bill')
			exports.ox_target:removeGlobalVehicle('mechanic:impound')
		end
		RemoveZones()
	end
end)

function SetUniform(uniform)
	local status = lib.progressCircle({
		label = 'Apsirengiate uniformą...',
		duration = 2000,
		position = 'bottom',
		useWhileDead = false,
		canCancel = true,
		anim = {
			dict = 'clothingtie',
			clip = 'try_tie_positive_a'
		},
	})

	if not status then return end 

	if uniform then
		TriggerEvent('skinchanger:getSkin', function(skin)
			local uniformObject

			if skin.sex == 0 then
				uniformObject = Config.Uniforms[Job.name] and Config.Uniforms[Job.name][Job.grade_num] and Config.Uniforms[Job.name][Job.grade_num].male
			else
				uniformObject = Config.Uniforms[Job.name] and Config.Uniforms[Job.name][Job.grade_num] and Config.Uniforms[Job.name][Job.grade_num].female
			end

			if uniformObject then
				TriggerEvent('skinchanger:loadClothes', skin, uniformObject)
			end
		end)

		TriggerEvent('cd_dispatch:OnDutyChecks', true)
		
		if OnDuty then return end
		exports.ox_target:addGlobalPlayer({
			{
				name = 'mechanic:bill',
				event = "d-mechanic:send",
				icon = "fa-solid fa-file-invoice",
				label = "Išrašyti sąskaitą",
				distance = 2.0,
			},
		})

		exports.ox_target:addGlobalVehicle({
			{
				name = 'mechanic:impound',
				icon = "fa-solid fa-car-burst",
				label = "Konfiskuoti automobilį",
				distance = 2.0,
				onSelect = function(data)
					ImpoundVehicle(data.entity)
				end
			}
		})

		OnDuty = true
		exports['ren-duty']:SetDuty(Job.name, true)
	else
		if not OnDuty then return end
		exports['ren-duty']:SetDuty(Job.name, false)
		TriggerEvent('cd_dispatch:OnDutyChecks', false)
		
		exports.ox_target:removeGlobalPlayer('mechanic:bill')
		exports.ox_target:removeGlobalVehicle('mechanic:impound')

		ESX.TriggerServerCallback('esx_skin:getPlayerSkin', function(skin)
			TriggerEvent('skinchanger:loadSkin', skin)
		end)
		OnDuty = false
	end
end

function OpenCloakroomMenu()
	lib.registerContext({
		id = 'police:clothing',
		title = 'Persirengimas',
		options = {
			{
				title = 'Darbinė uniforma',
				description = 'Užsivilkite darbinę uniformą.',
				icon = 'fas fa-lg fa-tshirt',
				onSelect = function()
					SetUniform(true)
				end
			},
			{
				title = 'Civiliniai rūbai',
				description = 'Užsivilkite savo drabužius.',
				icon = 'fas fa-lg fa-tshirt',
				onSelect = function()
					SetUniform(false)
				end
			}
		}
	})

	lib.showContext('police:clothing')
end

RegisterNetEvent('d-mechanic:isonduty')
AddEventHandler('d-mechanic:isonduty', function(cb)
	cb(OnDuty)

	if not OnDuty then return end

	exports.ox_target:removeGlobalPlayer('mechanic:bill')
	exports.ox_target:removeGlobalVehicle('mechanic:impound')
	exports['ren-duty']:SetDuty(Job.name, false)
	TriggerEvent('cd_dispatch:OnDutyChecks', false)

	OnDuty = false 
end)

RegisterNetEvent('dec4t-mechanicjob:onFixkit', function()
	if IsPedInAnyVehicle(cache.ped, false) then
		exports['onex-hud']:simpleNotification('Deja, automobilio negalite tvarkyti sėdėdami jame.', 'error')
		return
	end

	local vehicle, _ = lib.getClosestVehicle(GetEntityCoords(cache.ped), 4.0, false)


	if vehicle and IsEntityAVehicle(vehicle) and IsEntityVisible(vehicle) then
		if DoesEntityExist(vehicle) then
			local count = 0
			while not NetworkHasControlOfEntity(vehicle) do 
				NetworkRequestControlOfEntity(vehicle)
				count += 1
				if count > 100 then break end
				Wait(10)
			end

			local success = lib.progressCircle({
				label = 'Tvarkote automobilį...',
				duration = 15000,
				position = 'bottom',
				useWhileDead = false,
				canCancel = true,
				disable = {
					car = true,
					move = true, 
					combat = true, 
					sprint = true,
				},
				anim = {
					scenario = 'PROP_HUMAN_BUM_BIN'
				},
			})

			if success then
				LocalPlayer.state.invBusy = true
				local result = lib.callback.await('dec4t-mechanicjob:removeFixkit', false)
				if result then
					lib.callback('vehiclehandler:sync', -1, function()
						SetVehicleUndriveable(vehicle, false)
						SetVehicleFixed(vehicle)

						local count = 0
						while IsVehicleDamaged(vehicle) do 
							SetVehicleUndriveable(vehicle, false)
							SetVehicleDeformationFixed(vehicle)
							SetVehicleFixed(vehicle)
							count += 1
							if count > 100 then break end
							Wait(10)
						end

						LocalPlayer.state.invBusy = false
					end)
				else 
					LocalPlayer.state.invBusy = false
				end
			end
		end
	end
end)

local Points = {}
local InsidePoint, CurrentPoint, PointInfo = false, nil, nil
local PointCoords = nil
function InitZones()
	local zone = Config.Zones[Job.name]

	Points['clothing'] = {}
	for i=1, #zone.Cloakrooms, 1 do
		Points['clothing'][i] = lib.points.new({
			coords = zone.Cloakrooms[i],
			distance = 3.0,
		})
		
		local point = Points['clothing'][i]

		function point:onEnter()
			InsidePoint = true
			CurrentPoint = 'clothing'
			PointCoords = zone.Cloakrooms[i]
		end
		
		function point:onExit()
			InsidePoint = false
			CurrentPoint = nil
			PointCoords = nil
		end
		
		function point:nearby()
			DrawMarker(Config.MarkerType.Cloakrooms, self.coords, 0.0, 0.0, 0.0, 0, 0.0, 0.0, 0.5, 0.5, 0.5, Config.MarkerColor.r, Config.MarkerColor.g, Config.MarkerColor.b, 100, false, true, 2, true, false, false, false)
			if #(GetEntityCoords(cache.ped) - self.coords) < 1.5 then
				BeginTextCommandDisplayHelp('STRING')
				AddTextComponentSubstringPlayerName('Spauskite ~INPUT_CONTEXT~ ~HUD_COLOUR_FREEMODE~persirengti')
				EndTextCommandDisplayHelp(0, false, true, -1)
			end
		end
	end

	Points['vehicles'] = {}
	for i=1, #zone.Vehicles, 1 do
		Points['vehicles'][i] = lib.points.new({
			coords = zone.Vehicles[i].Spawner,
			distance = 3.0,
		})
		
		local point = Points['vehicles'][i]

		function point:onEnter()
			InsidePoint = true
			CurrentPoint = 'vehicles'
			PointInfo = {
				type = 'car',
				coords = zone.Vehicles[i].InsideShop,
				vehicles = Config.AuthorizedVehicles[Job.name]['car'][Job.grade],
				spawns = zone.Vehicles[i].SpawnPoints
			}
			PointCoords = zone.Vehicles[i].Spawner
		end
		
		function point:onExit()
			InsidePoint = false
			CurrentPoint = nil
			PointInfo = nil
			PointCoords = nil
		end
		
		function point:nearby()
			DrawMarker(Config.MarkerType.Vehicles, self.coords, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0, 1.0, 1.0, Config.MarkerColor.r, Config.MarkerColor.g, Config.MarkerColor.b, 100, false, true, 2, true, false, false, false)
		end
	end

	if Job.grade == 'boss' then
		Points['bossactions'] = {}
		for i=1, #zone.BossActions, 1 do
			Points['bossactions'][i] = lib.points.new({
				coords = zone.BossActions[i],
				distance = 3.0,
			})
			
			local point = Points['bossactions'][i]

			function point:onEnter()
				InsidePoint = true
				CurrentPoint = 'bossactions'
				PointCoords = zone.BossActions[i]
			end
			
			function point:onExit()
				InsidePoint = false
				CurrentPoint = nil
				PointCoords = nil
			end
			
			function point:nearby()
				DrawMarker(Config.MarkerType.BossActions, self.coords, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0, 1.0, 1.0, Config.MarkerColor.r, Config.MarkerColor.g, Config.MarkerColor.b, 100, false, true, 2, true, false, false, false)
			end
		end
	end
end

function RemoveZones()
	for k,v in pairs(Points) do
		for j, h in pairs(Points[k]) do
			local point = Points[k][j]
			point:remove()
		end
	end
	Points = {}
end

CreateThread(function()
	for jobName, blipCfg in pairs(Config.Blips) do
		local zone = Config.Zones[jobName]
		if zone and zone.Vehicles and #zone.Vehicles > 0 then
			local blipCoords = #zone.Cloakrooms > 0 and zone.Cloakrooms[1] or zone.Vehicles[1].Spawner
			local blip = AddBlipForCoord(blipCoords.x, blipCoords.y, blipCoords.z)
			SetBlipSprite(blip, blipCfg.sprite)
			SetBlipColour(blip, blipCfg.color)
			SetBlipScale(blip, blipCfg.scale)
			SetBlipAsShortRange(blip, true)
			BeginTextCommandSetBlipName('STRING')
			AddTextComponentSubstringPlayerName(blipCfg.label)
			EndTextCommandSetBlipName(blip)
		end
	end
end)

lib.addKeybind({
    name = 'mechanicmenu',
    description = 'Mechaniku meniu',
    defaultKey = 'E',
    onPressed = function(self)
        if not InsidePoint then return end
		if not CurrentPoint then return end
		if not PointCoords then return end

		if #(GetEntityCoords(cache.ped) - PointCoords) > 1.0 then return end

		if CurrentPoint == 'clothing' then 
			OpenCloakroomMenu()
		elseif CurrentPoint == 'bossactions' then 
			exports['dec4t-bossmenu']:openMenu(true)
		elseif CurrentPoint == 'vehicles' then 
			if not PointInfo then return end
			Garage.OpenMenu(PointInfo)
		end
    end,
})

function ImpoundVehicle(vehicle)
	local status = lib.progressCircle({
		duration = 7000,
		position = 'bottom',
		label = 'Konfiskuojamas automobilis...',
		useWhileDead = false,
		allowRagdoll = false,
		allowCuffed = false,
		allowFalling = false,
		canCancel = true,
		disable = {
			car = true,
			combat = true, 
			sprint = true,
		},
		anim = {
			dict = 'anim@amb@clubhouse@tutorial@bkr_tut_ig3@',
			clip = 'machinic_loop_mechandplayer',
			flag = 0,
		},
	})

	if status then
		TriggerServerEvent('dec4t-mechanic:deleteveh', NetworkGetNetworkIdFromEntity(vehicle))
	end
end

local SPlayer = nil
AddEventHandler('d-mechanic:send', function(data)
	if IsMechanic() and OnDuty then
		if data.entity then
			SPlayer = GetPlayerServerId(NetworkGetPlayerIndexFromPed(data.entity))
			lib.registerContext({
				id = 'mech_saskaita',
				title = 'Išrašyti sąskaitą',
				onExit = function()
				end,
				options = Saskaitos[Job.name]
			})
			lib.showContext('mech_saskaita')
		end
	end
end)

AddEventHandler('d-mechanic:openmenu', function(data)
	if IsMechanic() and OnDuty then
		if SPlayer then
			local input = lib.inputDialog('Išrašykite sąskaitą', {
				{type = 'input', label = 'Priežastis', description = 'Įveskite sąskaitos priežastį', required = true, min = 4},
				{type = 'number', label = 'Suma', description = 'Įveskite sąskaitos sumą eurais', required = true, min = 1},
			})
			if input then
				local reason = input[1]
				local amount = tonumber(input[2])
				if reason and amount then
					TriggerServerEvent('esx_billing:isiustiisrasa', SPlayer, 'society_'..Job.name, reason, amount)
				else
					exports['onex-hud']:simpleNotification('Įvedėte neteisingą sumą arba neteisingą priežastį.', 'error')
				end
				SPlayer = nil
			else
				SPlayer = nil
			end
		end
	end
end)

AddEventHandler('d-mechanic:send2', function(data)
	if IsMechanic() and OnDuty then
		if data and data.amount and SPlayer then
			TriggerServerEvent('esx_billing:isiustiisrasa', SPlayer, 'society_'..Job.name, data.reason, data.amount)
			SPlayer = nil
		else
			SPlayer = nil
		end
	end
end)