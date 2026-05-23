local Job = nil
local PlayerInZone = false

RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job)
	Job = job.name
end)

CreateZones = function()
	for i=1, #Config.Zones, 1 do
		local zone = Config.Zones[i]

		if zone.poly then
			lib.zones.poly({
				points = zone.points,
				thickness = zone.thickness,
				onEnter = function()
					PlayerInZone = true
					exports['1x-hud']:updateSafeZone(true)
					lib.disableControls:Add({37, 141, 140, 142, 25, 106, 91})
				end,
				onExit = function()
					PlayerInZone = false
					exports['1x-hud']:updateSafeZone(false)
					lib.disableControls:Remove({37, 141, 140, 142, 25, 106, 91})
				end,
				inside = function()
					if not zone.AllowedJobs[Job] then
						lib.disableControls()

						if GetSelectedPedWeapon(cache.ped) ~= `WEAPON_PETROLCAN` then
							SetCurrentPedWeapon(cache.ped, `WEAPON_UNARMED`, true)
						end
					end
				end,
			})
		else
			lib.points.new({
				coords = zone.coords,
				distance = zone.size,
				onExit = function ()
					lib.disableControls:Remove({37, 141, 140, 142, 25, 106, 91})
					exports['1x-hud']:updateSafeZone(false)
					PlayerInZone = false
				end,
				nearby = function(self)
					if self.isClosest then
						if not PlayerInZone then
							lib.disableControls:Add({37, 141, 140, 142, 25, 106, 91})
							exports['1x-hud']:updateSafeZone(true)
							PlayerInZone = true
						end
					else
						if PlayerInZone then
							lib.disableControls:Remove({37, 141, 140, 142, 25, 106, 91})
							exports['1x-hud']:updateSafeZone(false)
							PlayerInZone = false
						end
					end

					if not zone.AllowedJobs[Job] then
						lib.disableControls()

						if GetSelectedPedWeapon(cache.ped) ~= `WEAPON_PETROLCAN` then
							SetCurrentPedWeapon(cache.ped, `WEAPON_UNARMED`, true)
						end
					end
				end
			})
		end

	end
end

CreateThread(function()
	while not ESX.GetPlayerData().job do
		Wait(500) -- kai char nepasirenka, loopina?
	end
	Job = ESX.GetPlayerData().job.name

	CreateZones()
end)

exports('inZone', function()
	return PlayerInZone
end)
