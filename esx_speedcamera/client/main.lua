local defaultPrices = {
	[60] = 200,
	[80] = 300,
	[120] = 400,
}

local SpeedCameras = {
	{
		pos = vec3(172.1492, -817.4976, 30.9092),
		limit = 80,
	},
	{
		pos = vec3(150.0204, -1392.9052, 29.0444),
		limit = 80,
	},
	{
		pos = vec3(32.0318, -283.0300, 47.4756),
		limit = 80,
	},
	{
		pos = vec3(-1043.1880, -189.4442, 37.6047),
		limit = 80,
	},
	{
		pos = vec3(-861.4150, -655.3851, 27.6094),
		limit = 80,
	},
	{
		pos = vec3(691.1573, 7.5954, 84.7002),
		limit = 80,
	},
	{
		pos = vec3(-629.8467, 264.7304, 90.7237),
		limit = 80,
	},
	{
		pos = vec3(768.3449, -2062.8909, 29.9163),
		limit = 80,
	},
	{
		pos = vec3(1698.0377, 3507.4185, 37.2387),
		limit = 80,
	},
	{
		pos = vec3(178.8100, 6544.3330, 33.0887),
		limit = 80,
	},
	{
		pos = vec3(-418.3124, 5952.9355, 32.5955),
		limit = 80,
	},
	{
		pos = vec3(-1576.1481, -161.8416, 56.7314),
		limit = 80,
	},
	{
		pos = vec3(1026.9597, 490.3143, 97.0662),
		limit = 80,
	},
	{
		pos = vec3(1615.1042, 1095.7086, 81.3997),
		limit = 120,
	},
	{
		pos = vec3(-2650.3550, -83.0505, 17.5612),
		limit = 120,
	},
	{
		pos = vec3(1598.9968, -968.6283, 61.2228),
		limit = 120,
	},
	{
		pos = vec3(2539.8066, 2013.6449, 20.9617),
		limit = 120,
	},
	{
		pos = vec3(-2594.5000, 3110.0488, 15.5453),
		limit = 120,
	},
	{
		pos = vec3(2792.0747, 4406.5093, 50.4591),
		limit = 120,
	},
}

Citizen.CreateThread(function()
	for i = 1, #SpeedCameras do
		local Camera = SpeedCameras[i]
		local blip = AddBlipForCoord(Camera.pos.x, Camera.pos.y, Camera.pos.z)
		SetBlipSprite(blip, 604)
		SetBlipDisplay(blip, 4)
		SetBlipScale(blip, 1.0)
		SetBlipColour(blip, (Camera.limit == 80) and 2 or 5)
		SetBlipAsShortRange(blip, true)
		BeginTextCommandSetBlipName('STRING')
		AddTextComponentString('<font face="Roboto">Radaras ('..Camera.limit..'KM/H)</font>')
		EndTextCommandSetBlipName(blip)
	end
end)

CreateThread(function()
	while not ESX.IsPlayerLoaded() do Wait(500) end
	InitZones()
end)

local WhitelistedVehicles = {
	[`onexpd23g20`] = true,
	[`onexpdfpace`] = true,
	[`onexpdgt63`] = true,
	[`onexpdh2`] = true,
	[`onexpdrs3`] = true,
	[`gcapdaras`] = true,
	[`onexpdvwt6`] = true,
	[`gcpdaras`] = true,
	[`pdcapm5e60`] = true,
	[`pde63amg2`] = true,
	[`pdm3g80tdb`] = true,
	[`pdsclkuz`] = true,
	[`dcpdramtrx`] = true,
	[`caddyvw`] = true,
	[`gcpdhel1`] = true,
	[`nnpdhel`] = true,
	[`dcpdhel`] = true,
	[`bcgmphel1`] = true,
	[`supervolito`] = true,
	[`gcgmp3`] = true,
	[`gcgmp1`] = true,
	[`rs6nn`] = true,
	[`nm_z71`] = true,
	[`dcmd5`] = true,
	[`22g63`] = true,
	[`gcpd21`] = true,
	[`pgt218`] = true,
	[`dcpdb800`] = true,
	[`dcpdch`] = true,
	[`gcapd5`] = true,
	[`dcpdmas`] = true,
	[`pdlocors6`] = true,
	[`cls500w219`] = true,
}

InitZones = function()
	for i = 1, #SpeedCameras do
		local Camera = SpeedCameras[i]

		local Point = lib.points.new({
			coords = Camera.pos,
			distance = 30,
			limit = Camera.limit,
			hasBeenCaught = false
		})

		function Point:nearby()
			if cache.seat == -1 and not self.hasBeenCaught then
				local SpeedKM = GetEntitySpeed(cache.vehicle) * 3.6
				local maxSpeed = self.limit

				if SpeedKM > (maxSpeed + 20) and not WhitelistedVehicles[GetEntityModel(cache.vehicle)] then
					exports['1x-hud']:sendNotification({
						type = 'WARNING',
						title = 'Viršyjote greitį',
						message = ('Jūs viršyjote greitį radaro zonoje! Jūsų greitis: %s km/h (leistinas: %s km/h)!'):format(math.floor(SpeedKM), maxSpeed),
						duration = 6000,
						icon = 'gauge-simple-high'
					})

					local finalBillingPrice = defaultPrices[self.limit]
					local multiplier = ESX.GetAccount('bank').money > 15000000 and 1.3 or 1.0

					if SpeedKM > maxSpeed then
						finalBillingPrice += math.floor(SpeedKM * 1.2)
					end

					TriggerServerEvent('esx_billing:isiustiisrasa', cache.serverId, 'society_admin', ('Greicio virsijimas (%sKM/H)'):format(maxSpeed), finalBillingPrice * multiplier)

					self.hasBeenCaught = true
				end
			end
		end

		function Point:onExit()
			if self.hasBeenCaught then
				self.hasBeenCaught = false
			end
		end
	end
end