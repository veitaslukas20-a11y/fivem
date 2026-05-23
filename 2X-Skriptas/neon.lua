local alavalot = false
RegisterCommand('neonai', function()
    local ped = PlayerPedId()
    local vehicle = GetVehiclePedIsIn(ped, false)
	local driver  = GetPedInVehicleSeat(vehicle, -1)
    local alavalotkiinni = IsVehicleNeonLightEnabled(vehicle, 1)
		
    if IsPedInVehicle(ped,vehicle, true) and driver == ped then
		if alavalotkiinni then
			if alavalot == false then
				alavalot = true
				DisableVehicleNeonLights(vehicle, true)
				ESX.ShowNotification('Neonai: Išjungti')
				Wait(2000)
			elseif alavalot == true then
				alavalot = false
				DisableVehicleNeonLights(vehicle, false)
				ESX.ShowNotification('Neonai: Įjungti')
				Wait(2000)
			end
		else
			ESX.ShowNotification('Ši mašina neturi neonų')
			Wait(2000)
        end
    end
end)
