local OnDuty = false
local Job = {}
local Garage = exports['s1m1s-jobgarage']:initGarages()

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(xPlayer)
	Job.grade = xPlayer.job.grade_name
	Job.name = xPlayer.job.name

	if Job.name == 'police' then
		InitZones()
	end
end)

RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job)
	Job.grade = job.grade_name
	Job.name = job.name

	if Job.name == 'police' then
		RemoveZones()
		InitZones()
	else 
		RemoveActions()
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

	if uniform ~= 'citizen_wear' then
		TriggerEvent('skinchanger:getSkin', function(skin)
			local uniformObject

			if skin.sex == 0 then
				uniformObject = Config.Uniforms[uniform].male
			else
				uniformObject = Config.Uniforms[uniform].female
			end

			if uniformObject then
				TriggerEvent('skinchanger:loadClothes', skin, uniformObject)

				if string.find(uniform, "bullet_") then
					exports['deivuks-utils']:armour()
					SetPedArmour(cache.ped, 99)
				end

				TurnDuty(true)
			end
		end)
	else
		ESX.TriggerServerCallback('esx_skin:getPlayerSkin', function(skin)
			TriggerEvent('skinchanger:loadSkin', skin)
		end)

		SetPedArmour(cache.ped, 0)

		TurnDuty(false)
		RemoveActions()
	end
end

function TurnDuty(value)
	if value then
		if value and OnDuty == value then return end
		OnDuty = value 
		TriggerEvent('cd_dispatch:OnDutyChecks', true)
		TriggerServerEvent('esx_policejob:setDuty', true)
		exports['ren-duty']:SetDuty('police', true)

		TriggerServerEvent('s1m1s-police:changeDuty', true)

		exports['1x-hud']:sendNotification({
			type = 'SUCCESS',
			title = 'Policija',
			message = 'Pradėjote savo darbo pamainą.',
			duration = 6000,
			icon = 'shield'
		})

		exports.ox_target:addGlobalPlayer({
			{
				name = 'police:search',
				icon = "fa-solid fa-magnifying-glass",
				label = "Apieškoti asmenį",
				distance = 1.5,
				canInteract = function(entity)
					return canSearchPed(entity) and not IsEntityAttachedToEntity(entity, cache.ped)
				end,
				onSelect = function(data)
					if GetEntityType(data.entity) ~= 1 or not IsPedAPlayer(data.entity) then return end
					if canSearchPed(data.entity) and not IsEntityAttachedToEntity(data.entity, cache.ped) then
						exports.ox_inventory:openNearbyInventory()
					end
				end
			},
			{
				name = 'police:cuff',
				icon = "fa-solid fa-handcuffs",
				label = "Surakinti asmenį",
				items = 'handcuffs',
				distance = 1.5,
				canInteract = function(entity)
					return canCuffPed(entity) and not IsPedCuffed(entity) and not IsEntityAttachedToEntity(entity, cache.ped)
				end,
				onSelect = function(data)
					if GetEntityType(data.entity) ~= 1 or not IsPedAPlayer(data.entity) then return end
					if canCuffPed(data.entity) and not IsPedCuffed(data.entity) and not IsEntityAttachedToEntity(data.entity, cache.ped) then

						cuffPlayer(data.entity)
					end
				end
			},
			{
				name = 'police:uncuff',
				icon = "fa-solid fa-handcuffs",
				label = "Atrakinti asmenį",
				distance = 1.5,
				canInteract = function(entity)
					return IsPedCuffed(entity) and not IsEntityAttachedToEntity(entity, cache.ped)
				end,
				onSelect = function(data)
					cuffPlayer(data.entity)
				end
			},
			{
				name = 'police:escort',
				icon = "fas fa-hands-bound",
				label = "Vestis su savimi",
				distance = 1.5,
				canInteract = function(entity)
					return IsPedCuffed(entity) and not IsEntityAttachedToEntity(entity, cache.ped)
				end,
				onSelect = function(data)
					escortPlayer(data.entity)
				end
			},
		})

		exports.ox_target:addGlobalVehicle({
			{
				name = 'police:outcar',
				icon = "fa-solid fa-car",
				label = "Išlaipinti iš automobilio",
				distance = 2.0,
				bones = { 'door_dside_r', 'seat_dside_r' },
				canInteract = function(entity, distance, coords)
					return canInteractWithDoor(entity, coords, 2)
				end,
				onSelect = function(data)
					SetOutVehicle(data.entity, 2)
				end
			},
			{
				name = 'police:outcar',
				icon = "fa-solid fa-car",
				label = "Išlaipinti iš automobilio",
				distance = 2.0,
				bones = { 'door_pside_r', 'seat_pside_r' },
				canInteract = function(entity, distance, coords)
					return canInteractWithDoor(entity, coords, 3)
				end,
				onSelect = function(data)
					SetOutVehicle(data.entity, 3)
				end
			},
			{
				name = 'police:incar',
				icon = "fa-solid fa-car",
				label = "Pasodinti į automobilį",
				distance = 2.0,
				bones = { 'door_dside_r', 'seat_dside_r' },
				canInteract = function(entity, distance, coords)
					return canInteractWithDoor(entity, coords, 2)
				end,
				onSelect = function(data)
					SetIntoVehicle(data.entity, 2)
				end
			},
			{
				name = 'police:incar',
				icon = "fa-solid fa-car",
				label = "Pasodinti į automobilį",
				distance = 2.0,
				bones = { 'door_pside_r', 'seat_pside_r' },
				canInteract = function(entity, distance, coords)
					return canInteractWithDoor(entity, coords, 3)
				end,
				onSelect = function(data)
					SetIntoVehicle(data.entity, 3)
				end
			},
			{
				name = 'police:confiscate',
				icon = "fa-solid fa-car-burst",
				label = "Konfiskuoti automobilį",
				distance = 2.0,
				onSelect = function(data)
					ImpoundVehicle(data.entity)
				end
			},
			{
				name = 'police:unlockcar',
				icon = "fa-solid fa-lock-open",
				label = "Išlaušti automobilio spyną",
				distance = 2.0,
				onSelect = function(data)
					UnlockVehicle(data.entity)
				end
			}
		})
	else
		if not value and OnDuty == value then return end
		OnDuty = value
		TriggerEvent('cd_dispatch:OnDutyChecks', false)
		TriggerServerEvent('esx_policejob:setDuty', false)
		exports['ren-duty']:SetDuty('police', false)
		TriggerServerEvent('s1m1s-police:changeDuty', false)

		exports['1x-hud']:sendNotification({
			type = 'SUCCESS',
			title = 'Policija',
			message = 'Baigėte savo darbo pamainą.',
			duration = 6000,
			icon = 'shield'
		})
	end
end

function RemoveActions()
	exports.ox_target:removeGlobalVehicle({"police:search", "police:cuff", "police:uncuff", "police:escort", 'police:unescort'})
	exports.ox_target:removeGlobalPlayer({"police:outcar", "police:confiscate", 'police:incar'})
end

function OpenCloakroomMenu()
	lib.registerContext({
		id = 'police:clothing',
		title = 'Persirengimas',
		options = Data.Uniforms
	})

	lib.showContext('police:clothing')
end

function Ekipuote()
	local elements = {
		{label = ('Tazeris'), icon = "fa-solid fa-gun", value = 'WEAPON_STUNGUN'},
		{label = ('Žibintuvėlis'), icon = "fa-solid fa-lightbulb", value = 'WEAPON_FLASHLIGHT'},
		{label = ('Policijos Lazda'), icon = "fa-solid fa-baseball-bat-ball", value = 'WEAPON_NIGHTSTICK'},
		{label = ('Kūno kamera'), icon = "fa-solid fa-video", value = 'bodycam'},
	}
	if ESX.GetPlayerData().job.grade >= 1 then
		table.insert(elements, {label = ('Pistoletas'), icon = "fa-solid fa-gun", value = 'WEAPON_PISTOL'})
		table.insert(elements, {label = ('Kulkos'), icon = "fa-solid fa-person-military-rifle", value = 'ammunition_pistol'})
	end

	local Options = {}
	for k,v in pairs(elements) do 
		Options[k] = {}
		Options[k].title = v.label
		Options[k].description = 'Atsiimti - '..v.label
		Options[k].icon = v.icon 
		Options[k].onSelect = function()
			local time = lib.callback.await('deivuks-ekipuote:atsiimti', false, v.value)
			if time then
				if tonumber(time) then
					local hours = math.floor(time/60/60)
					local minutes = math.floor((time - (hours * 60 * 60)) / 60)
					exports['1x-hud']:sendNotification({
						type = 'SUCCESS',
						title = 'Policija',
						message = 'Negalite atsiimti ekipuotės, kadangi dar nėra praėjęs atsiėmimo laikas. Likęs laikas: '..hours..'h '..minutes..' min.',
						duration = 6000,
						icon = 'shield'
					})
				else
					exports['1x-hud']:sendNotification({
						type = 'SUCCESS',
						title = 'Policija',
						message = 'Sėkmingai atsiėmėte ekipuotės dalį.',
						duration = 6000,
						icon = 'shield'
					})
				end
			else
				exports['1x-hud']:sendNotification({
					type = 'SUCCESS',
					title = 'Policija',
					message = 'Nepavyko atsiimti ekipuotės, galbūt jūs ją jau turite, todėl ekipuotė jums galėjo būti nesuteikta, arba ekipuotei nėra išteklių sandėlyje.',
					duration = 6000,
					icon = 'shield'
				})
			end
		end
	end

	lib.registerContext({
		id = 'police:ekipuote',
		title = 'Atsiimti ekipuotę',
		options = Options
	})
	lib.showContext('police:ekipuote')
end

-- Create blips
Citizen.CreateThread(function()
	for k,v in pairs(Config.PoliceStations) do
		if v.Blip then
			local blip = AddBlipForCoord(v.Blip.Coords)

			SetBlipSprite (blip, v.Blip.Sprite)
			SetBlipDisplay(blip, v.Blip.Display)
			SetBlipScale  (blip, v.Blip.Scale)
			SetBlipColour (blip, v.Blip.Colour)
			SetBlipAsShortRange(blip, true)

			BeginTextCommandSetBlipName('STRING')
			AddTextComponentString('<font face="Roboto">Policijos Departamentas</font>')
			EndTextCommandSetBlipName(blip)
		end
	end
end)

local Points = {}
local InsidePoint, CurrentPoint, PointInfo = false, nil, nil
local PointCoords = nil
function InitZones()
	for k,v in pairs(Config.PoliceStations) do
		Points['clothing'] = {}
		for i=1, #v.Cloakrooms, 1 do
			Points['clothing'][i] = lib.points.new({
				coords = v.Cloakrooms[i],
				distance = 3.0,
			})
			
			local point = Points['clothing'][i]

			function point:onEnter()
				InsidePoint = true
				CurrentPoint = 'clothing'
				PointCoords = v.Cloakrooms[i]
			end
			
			function point:onExit()
				InsidePoint = false
				CurrentPoint = nil
				PointCoords = nil
			end
			
			function point:nearby()
				DrawMarker(Config.MarkerType.Cloakrooms, self.coords, 0.0, 0.0, 0.0, 0, 0.0, 0.0, 0.5, 0.5, 0.5, Config.MarkerColor.r, Config.MarkerColor.g, Config.MarkerColor.b, 100, false, true, 2, true, false, false, false)
			end
		end

		Points['vehicles'] = {}
		for i=1, #v.Vehicles, 1 do
			Points['vehicles'][i] = lib.points.new({
				coords = v.Vehicles[i].Spawner,
				distance = 3.0,
			})
			
			local point = Points['vehicles'][i]

			function point:onEnter()
				InsidePoint = true
				CurrentPoint = 'vehicles'
				PointInfo = {
					type = 'car',
					coords = v.Vehicles[i].InsideShop,
					vehicles = Config.AuthorizedVehicles['car'][Job.grade],
					spawns = v.Vehicles[i].SpawnPoints
				}
				PointCoords = v.Vehicles[i].Spawner
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

		Points['ekipuote'] = {}
		for i=1, #v.Ekipuote, 1 do
			Points['ekipuote'][i] = lib.points.new({
				coords = v.Ekipuote[i],
				distance = 3.0,
			})
			
			local point = Points['ekipuote'][i]

			function point:onEnter()
				InsidePoint = true
				CurrentPoint = 'ekipuote'
				PointCoords = v.Ekipuote[i]
			end
			
			function point:onExit()
				InsidePoint = false
				CurrentPoint = nil
				PointCoords = nil
			end
			
			function point:nearby()
				DrawMarker(Config.MarkerType.Ekipuote, self.coords, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0, 1.0, 1.0, Config.MarkerColor.r, Config.MarkerColor.g, Config.MarkerColor.b, 100, false, true, 2, true, false, false, false)
			end
		end

		Points['helicopters'] = {}
		for i=1, #v.Helicopters, 1 do
			Points['helicopters'][i] = lib.points.new({
				coords = v.Helicopters[i].Spawner,
				distance = 3.0,
			})
			
			local point = Points['helicopters'][i]

			function point:onEnter()
				InsidePoint = true
				CurrentPoint = 'helicopters'
				PointInfo = {
					type = 'helicopter',
					coords = v.Helicopters[i].InsideShop,
					vehicles = Config.AuthorizedVehicles['helicopter'][Job.grade],
					spawns = v.Helicopters[i].SpawnPoints
				}
				PointCoords = v.Helicopters[i].Spawner
			end
			
			function point:onExit()
				InsidePoint = false
				CurrentPoint = nil
				PointInfo = nil
				PointCoords = nil
			end
			
			function point:nearby()
				DrawMarker(Config.MarkerType.Helicopters, self.coords, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0, 1.0, 1.0, Config.MarkerColor.r, Config.MarkerColor.g, Config.MarkerColor.b, 100, false, true, 2, true, false, false, false)
			end
		end

		if Job.grade == 'boss' then
			Points['bossactions'] = {}
			for i=1, #v.BossActions, 1 do
				Points['bossactions'][i] = lib.points.new({
					coords = v.BossActions[i],
					distance = 3.0,
				})
				
				local point = Points['bossactions'][i]

				function point:onEnter()
					InsidePoint = true
					CurrentPoint = 'bossactions'
					PointCoords = v.BossActions[i]
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
end

function RemoveZones()
	for k,v in pairs(Points) do 
		for j, h in pairs(Points[k]) do 
			local point = Points[k][j]
			point:remove()
		end
	end
end

lib.addKeybind({
    name = 'policemenu',
    description = 'Policijos meniu',
    defaultKey = 'E',
    onPressed = function(self)
        if not InsidePoint then return end
		if not CurrentPoint then return end
		if not PointCoords then return end

		if #(GetEntityCoords(cache.ped) - PointCoords) > 1.0 then return end

		if CurrentPoint == 'clothing' then 
			OpenCloakroomMenu()
		elseif CurrentPoint == 'ekipuote' then 
			Ekipuote()
		elseif CurrentPoint == 'vehicles' then 
			if not PointInfo then return end
			Garage.OpenMenu(PointInfo)
		elseif CurrentPoint == 'helicopters' then 
			if not PointInfo then return end
			Garage.OpenMenu(PointInfo)
		elseif CurrentPoint == 'bossactions' then 
			exports['s1m1s-bossmenu']:openMenu(true)
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
		TriggerServerEvent('s1m1s-police:deleteveh', NetworkGetNetworkIdFromEntity(vehicle))
	end
end

function UnlockVehicle(vehicle)
	local status = lib.progressCircle({
		duration = 30000,
		position = 'bottom',
		label = 'Atrakinama automobilio spyną...',
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
			dict = 'missheistfbisetup1',
			clip = 'hassle_intro_loop_f',
			flag = 49,
			duration = 30000,
		},
	})

	if status then
		TriggerServerEvent('s1m1s-police:unlockveh', NetworkGetNetworkIdFromEntity(vehicle))
		SetVehicleDoorsLockedForAllPlayers(vehicle, false)
	end
end

Citizen.CreateThread(function()
	while not ESX.IsPlayerLoaded() do Wait(500) end 

	SetPedMinGroundTimeForStungun(cache.ped, 10000)
end)

RegisterCommand('pdoff', function()
	if Job.name ~= 'police' then return end
	TriggerEvent('cd_dispatch:OnDutyChecks', false)
end)

RegisterCommand('pdon', function()
	if Job.name ~= 'police' then return end
	TriggerEvent('cd_dispatch:OnDutyChecks', true)
end)