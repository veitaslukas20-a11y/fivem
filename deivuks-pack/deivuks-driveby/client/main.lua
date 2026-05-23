--[[local Sleep = 1000

Citizen.CreateThread(function()
	while true do

		if IsPedInAnyVehicle(playerPed) then
			if GetVehicleClass(GetVehiclePedIsIn(playerPed, false)) then
				if math.ceil(GetEntitySpeed(GetVehiclePedIsIn(playerPed, false)) * 3.6) <= 55.0 then 
					if GetPedInVehicleSeat(GetVehiclePedIsIn(playerPed), -1) ~= playerPed then
						SetPlayerCanDoDriveBy(PlayerId(), true)
					else
						SetPlayerCanDoDriveBy(PlayerId(), false)
					end
					Sleep = 100
				else 
					Sleep = 500
					SetPlayerCanDoDriveBy(PlayerId(), false)
				end
			else
				SetPlayerCanDoDriveBy(PlayerId(), false)
			end
		else 
			Sleep = 1000
		end

		Wait(Sleep)
	end
end)]]

local vehicle = nil
local driveby = false
lib.onCache('vehicle', function(value)
	if value and not Veh then
		vehicle = value

		while vehicle do
			SetPlayerCanDoDriveBy(cache.playerId, driveby)
			Wait(100)
		end

	else
		vehicle = nil
	end
end)

lib.onCache('seat', function (value)
	if not vehicle then return end

	local allowed = (GetVehicleClass(vehicle) == 15 or GetVehicleClass(vehicle) == 16)
	if allowed then
		if (value == -1 or value == 0) then
			driveby = false
		else
			driveby = true
		end
	else
		driveby = false
	end
end)