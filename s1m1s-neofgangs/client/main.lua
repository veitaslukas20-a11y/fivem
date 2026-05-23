local Job = {}

function GetJob()
	if Job.name then
		for i = 1, #Config.Jobs do
			if Job.name == Config.Jobs[i] then
				return true
			end
		end
	end
	return false
end

exports('GetJob', GetJob)

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(xPlayer)
	Job.grade = xPlayer.job.grade_name
	Job.name = xPlayer.job.name

	if GetJob() then
		InitZones()
		InitTargets()
	end
end)

RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job)
	Job.grade = job.grade_name
	Job.name = job.name

	if GetJob() then
		RemoveZones()
		InitZones()
		InitTargets()
	else 
		RemoveActions()
		RemoveZones()
	end
end)

local Points = {}
local InsidePoint, CurrentPoint, PointInfo = false, nil, nil
local PointCoords = nil
function InitZones()
	local Station = Config.Stations[Job.name]

	if Job.grade == 'boss' then
		Points['bossactions'] = {}
		for i=1, #Station.BossActions, 1 do
			Points['bossactions'][i] = lib.points.new({
				coords = Station.BossActions[i],
				distance = 3.0,
			})
			
			local point = Points['bossactions'][i]

			function point:onEnter()
				InsidePoint = true
				CurrentPoint = 'bossactions'
				PointCoords = Station.BossActions[i]
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
end

lib.addKeybind({
    name = 'neofgangmenu',
    description = 'Neoficialios Gaujos meniu',
    defaultKey = 'E',
    onPressed = function(self)
        if not InsidePoint then return end
		if not CurrentPoint then return end
		if not PointCoords then return end

		if #(GetEntityCoords(cache.ped) - PointCoords) > 1.0 then return end

		if CurrentPoint == 'bossactions' then 
			exports['s1m1s-bossmenu']:openMenu(true)
		end
    end,
})

local Targets = false
function InitTargets()
	if not Targets then 
		Targets = true 
		exports.ox_target:addGlobalPlayer({
			{
				name = 'neofgang:search',
				icon = "fa-solid fa-magnifying-glass",
				label = "Apieškoti asmenį",
				distance = 1.5,
				canInteract = function(entity)
					return canSearchPed(entity) and not IsEntityAttachedToEntity(entity, cache.ped)
				end,
				onSelect = function(data)
					if GetEntityType(data.entity) ~= 1 or not IsPedAPlayer(data.entity) then return end
					if canSearchPed(data.entity) and #(GetEntityCoords(cache.ped) - GetEntityCoords(data.entity)) <= 1.5 and not IsEntityAttachedToEntity(data.entity, cache.ped) then
						exports.ox_inventory:openNearbyInventory()
					end
				end
			},
			{
				name = 'neofgang:cuff',
				icon = "fa-solid fa-handcuffs",
				label = "Surišti asmenį",
				items = 'zipties',
				distance = 1.5,
				canInteract = function(entity)
					return canZippPed(entity) and not IsPedCuffed(entity) and not IsEntityAttachedToEntity(entity, cache.ped)
				end,
				onSelect = function(data)
					if GetEntityType(data.entity) ~= 1 or not IsPedAPlayer(data.entity) then return end
					if canZippPed(data.entity) and #(GetEntityCoords(cache.ped) - GetEntityCoords(data.entity)) <= 1.5 and not IsPedCuffed(data.entity) and not IsEntityAttachedToEntity(data.entity, cache.ped) then
						local soundId = lib.callback.await('itemsounds:playSound', false, 'zipties')
						if not soundId then return end

						if not exports.xsound:isPlayerInStreamerMode() then
							local attempts = 100
							while not exports.xsound:soundExists(soundId) or attempts <= 0 do
								attempts -= 1
								Wait(100)
							end

							exports.xsound:onPlayEnd(soundId, function ()
								TriggerServerEvent('itemsounds:removeSound', soundId)
							end)
						else
							SetTimeout(2000, function()
								TriggerServerEvent('itemsounds:removeSound', soundId)
							end)
						end

						zippPlayer(data.entity)
					end
				end
			},
			{
				name = 'neofgang:uncuff',
				icon = "fa-solid fa-handcuffs",
				label = "Atrišti asmenį",
				items = {
					WEAPON_SWITCHBLADE = 1,
					WEAPON_KNIFE = 1,
					WEAPON_MACHETE = 1,
					zirkles = 1,
				},
				anyItem = true,
				distance = 1.5,
				canInteract = function(entity)
					return IsPedCuffed(entity) and not IsEntityAttachedToEntity(entity, cache.ped)
				end,
				onSelect = function(data)
					zippPlayer(data.entity)
				end
			},
			{
				name = 'neofgang:escort',
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
			{
				name = 'neofgang:unescort',
				icon = "fa-solid fa-person",
				label = "Paleisti asmenį",
				distance = 1.5,
				canInteract = function(entity)
					return IsPedCuffed(entity) and IsEntityAttachedToEntity(entity, cache.ped)
				end,
				onSelect = function(data)
					escortPlayer(data.entity)
				end
			},
		})

		exports.ox_target:addGlobalVehicle({
			{
				name = 'neofgang:outcar',
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
				name = 'neofgang:outcar',
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
				name = 'neofgang:incar',
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
				name = 'neofgang:incar',
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
		})
	end
end

function RemoveActions()
	if Targets then
		Targets = false
		exports.ox_target:removeGlobalPlayer({"neofgang:search", "neofgang:cuff", "neofgang:uncuff", "neofgang:escort", 'neofgang:unescort'})
		exports.ox_target:removeGlobalVehicle({"neofgang:outcar", "neofgang:incar"})
	end
end