local firstSpawn = true
local pState = LocalPlayer.state
local fakeDied = false
local fontId = RegisterFontId('Roboto')

isDead, isSearched, medic = false, false, 0

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(xPlayer)
	ESX.PlayerData = xPlayer
	ESX.PlayerLoaded = true
end)

RegisterNetEvent('esx:onPlayerLogout')
AddEventHandler('esx:onPlayerLogout', function()
	ESX.PlayerLoaded = false
	ESX.PlayerData = {}
	firstSpawn = true
end)

RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job)
	ESX.PlayerData.job = job
end)

AddEventHandler('esx:onPlayerDeath', function()
	isDead = true
end)

local function StopTimer()
	isDead = false
	bleedoutTimer = ESX.Math.Round(Config.BleedoutTimer / 1000)
	earlySpawnTimer = ESX.Math.Round(Config.EarlyRespawnTimer / 1000)
	exports.cylex_animmenuv2:DisableCrawl(false)
	if IsPlayerCrawling() then
		EnsureCrawl()
	end
	pState.invBusy = false
end

exports('StopTimer', StopTimer)

exports('fakeDead', function()
	return fakeDied
end)

AddEventHandler('reload_death:onPlayerRevive', function()
	isDead = false
	fakeDied = false
	StopTimer()
end)

Citizen.CreateThread(function()
	for k,v in pairs(Config.Hospitals) do
		local blip = AddBlipForCoord(v.Blip.coords)
		SetBlipSprite(blip, v.Blip.sprite)
		SetBlipScale(blip, v.Blip.scale)
		SetBlipColour(blip, v.Blip.color)
		SetBlipAsShortRange(blip, true)
		BeginTextCommandSetBlipName('STRING')
		AddTextComponentString('<font face="Roboto">'.._U('blip_hospital')..'</font>')
		EndTextCommandSetBlipName(blip)
	end
end)

function DrawGenericTextThisFrame()
	SetTextFont(fontId)
	SetTextScale(0.0, 0.32)
	SetTextColour(255, 255, 255, 255)
	SetTextOutline()
	SetTextCentre(true)
end

exports('medikitas', function(data, slot)
	local maxHealth = GetEntityMaxHealth(cache.ped) - 1
	local health = GetEntityHealth(cache.ped)
	if health >= maxHealth then return false end
	if lib.progressCircle({
		duration = 8000,
		label = 'Naudojama vaistinėlė...',
		position = 'bottom',
		useWhileDead = false,
		canCancel = true,
		anim = {dict = 'mp_safehouseshower@male@',clip = 'male_shower_idle_a'},
		disable = {car = true,move = true,combat = true,sprint = true},
	}) then
		exports.ox_inventory:useItem(data, function(data)
			if data then
				exports['deivuks-utils']:health()
				SetEntityHealth(cache.ped, maxHealth)
				exports['1x-hud']:sendNotification({
					type = 'SUCCESS',
					title = 'Greitoji medicinos pagalba',
					message = _U('used_medikit'),
					duration = 6000,
					icon = 'staff-snake'
				})
			end
		end)
	end
end)

exports('bandage', function(data, slot)
	local maxHealth = GetEntityMaxHealth(cache.ped) - 1
	local health = GetEntityHealth(cache.ped)
	if health >= maxHealth then return false end
	if lib.progressCircle({
		duration = 2500,
		label = 'Naudojamas tvarstis...',
		position = 'bottom',
		useWhileDead = false,
		canCancel = true,
		anim = {dict = 'missheistdockssetup1clipboard@idle_a',clip = 'idle_a',flag = 1},
		prop = {model = `prop_rolled_sock_02`,pos = vec3(-0.14, -0.14, -0.08),rot = vec3(-50.0, -50.0, 0.0)},
		disable = {combat = true},
	}) then
		exports.ox_inventory:useItem(data, function(data)
			if data then
				local newHealth = math.min(maxHealth, math.floor(health + 10))
				exports['deivuks-utils']:health()
				SetEntityHealth(cache.ped, newHealth)
				exports['1x-hud']:sendNotification({
					type = 'SUCCESS',
					title = 'Greitoji medicinos pagalba',
					message = _U('used_bandage'),
					duration = 6000,
					icon = 'staff-snake'
				})
			end
		end)
	end
end)

local CrawlAvailable = false

local function StartCrawling()
	if CrawlAvailable and not IsPlayerCrawling() and not exports['deivuks-pack']:isCaried() and not IsEntityInWater(cache.ped) then
		FreezeEntityPosition(cache.ped, true)
		pState.invBusy = true
		FakeRevive()
		EnsureCrawl()
		while not IsPlayerCrawling() do
			Wait(100)
		end
		FreezeEntityPosition(cache.ped, false)
		Citizen.CreateThread(function()
			while IsPlayerCrawling() do
				Wait(1000)
			end
			if isDead then
				SetEntityHealth(cache.ped, 0)
				CrawlAvailable = false
			end
		end)
	end
end

local pressed = false
local holdh = 0
local sent, distext, locktime, presscount = false, _U('distress_send'), 0, 0

exports('StartDistressSignal', function()
	CreateThread(function()
		local timer = Config.BleedoutTimer

		while timer > 0 and isDead do
			Wait(0)
			timer = timer - 30

			DrawGenericTextThisFrame()
			BeginTextCommandDisplayText('STRING')
			AddTextComponentSubstringPlayerName(_U('distress_send'))
			EndTextCommandDisplayText(0.5, 0.71)

			if IsControlJustReleased(0, 47) then
				SendDistressSignal()
				break
			end
		end
	end)
end)

function SendDistressSignal()
	ESX.ShowNotification(_U('distress_sent'))

	local coords = GetEntityCoords(PlayerPedId())
	exports["lb-phone"]:SendCompanyCoords('ambulance', nil, false)

end

function StartPositionRefresh()
	CreateThread(function()
		while isDead do
			Wait(0)

			DrawGenericTextThisFrame()
			BeginTextCommandDisplayText('STRING')
			AddTextComponentSubstringPlayerName('Spauskite [~o~E~s~] kad atnaujintumete poziciją')
			EndTextCommandDisplayText(0.5, 0.73)

			if IsControlJustPressed(0, 74) and not IsEntityAttached(cache.ped) then
				local ped = cache.ped
				local coords = GetEntityCoords(ped)

				SetEntityCoordsNoOffset(ped, coords.x, coords.y, coords.z, false, false, false)
				NetworkResurrectLocalPlayer(coords.x, coords.y, coords.z, GetEntityHeading(ped), true, false)

				Wait(5000)
			end
		end
	end)
end

exports('StartDiedHunger', function()
	Citizen.CreateThread(function()
		local timer = 5 * 60 * 1000
		while timer > 0 and isDead do
			Wait(1000)
			timer = timer - 1000
			local min, sec = secondsToClock(timer / 1000)
			exports['s1m1s-ui']:topText(true, 'Jūs esate be sąmonės, sąmonę atgausite už <a style="color: #336EFF">'..min..':'..sec..'</a> <br> <a style="color: #FF3333;">Jūs nualpote, nes nepavalgėte.</a>')
		end
		TriggerEvent('reload_death:revive')
		Wait(1000)
		exports['s1m1s-ui']:topText(false)
		local playerPed = PlayerPedId()
		RequestAnimSet("move_m@drunk@moderatedrunk")
		while not HasAnimSetLoaded("move_m@drunk@moderatedrunk") do
			Citizen.Wait(0)
		end
		SetPedMovementClipset(playerPed, "move_m@drunk@moderatedrunk", true)
		SetTimecycleModifier("spectator5")
		SetPedMotionBlur(playerPed, true)
		SetPedIsDrunk(playerPed, true)
		timer = 2 * 60 * 1000
		while timer > 0 and not isDead do
			Wait(1000)
			timer = timer - 1000
		end
		ClearTimecycleModifier()
		ResetScenarioTypesEnabled()
		ResetPedMovementClipset(playerPed, 0)
		SetPedIsDrunk(playerPed, false)
		SetPedMotionBlur(playerPed, false)
	end)
end)

function SendDistressSignal()
	local playerPed = PlayerPedId()
	local coords = GetEntityCoords(playerPed)
	PedPosition = coords
	local PlayerCoords = { x = PedPosition.x, y = PedPosition.y, z = PedPosition.z }
	exports['1x-hud']:sendNotification({
		type = 'SUCCESS',
		title = 'Greitoji medicinos pagalba',
		message = _U('distress_sent'),
		duration = 6000,
		icon = 'staff-snake'
	})
	local data = exports['cd_dispatch']:GetPlayerInfo()
	TriggerServerEvent('cd_dispatch:AddNotification', {
		job_table = {'ambulance'},
		coords = data.coords,
		title = 'Žmogus be sąmonės',
		message = 'Asmeniui kurio lytis '..data.sex..' reikia skubios medicininės pagalbos ties: '..data.street,
		flash = 0,
		unique_id = tostring(math.random(0000000,9999999)),
		blip = {
			sprite = 153,
			scale = 0.7,
			colour = 1,
			flashes = true,
			text = '<font face="Roboto">Asmuo be sąmonės<font>',
			time = (10 * 60 * 1000),
			sound = 2,
		}
	})
end

function secondsToClock(seconds)
	if seconds <= 0 then
		return 0, 0
	else
		local mins = math.floor(seconds / 60)
		local secs = math.floor(seconds - mins * 60)
		if #tostring(secs) < 2 then
			secs = string.format('0%s', tostring(secs))
		end
		return mins, secs
	end
end

exports('StartDeathTimer', function()
	local canPayFine = false

	if Config.EarlyRespawnFine then
		ESX.TriggerServerCallback('esx_ambulancejob:checkBalance', function(canPay)
			canPayFine = canPay
		end)
	end

	local earlySpawnTimer = ESX.Math.Round(Config.EarlyRespawnTimer / 1000)
	local bleedoutTimer = ESX.Math.Round(Config.BleedoutTimer / 1000)

	CreateThread(function()
		while earlySpawnTimer > 0 and isDead do
			Wait(1000)
			if earlySpawnTimer > 0 then
				earlySpawnTimer = earlySpawnTimer - 1
			end
		end

		while bleedoutTimer > 0 and isDead do
			Wait(1000)
			if bleedoutTimer > 0 then
				bleedoutTimer = bleedoutTimer - 1
			end
		end
	end)

	CreateThread(function()
		local timeHeld = 0

		while earlySpawnTimer > 0 and isDead do
			Wait(0)
			DrawGenericTextThisFrame()
			BeginTextCommandDisplayText('STRING')
			AddTextComponentSubstringPlayerName(_U('respawn_available_in', secondsToClock(earlySpawnTimer)))
			EndTextCommandDisplayText(0.5, 0.75)
		end

		while bleedoutTimer > 0 and isDead do
			Wait(0)

			if not Config.EarlyRespawnFine then
				DrawGenericTextThisFrame()
				BeginTextCommandDisplayText('STRING')
				AddTextComponentSubstringPlayerName(_U('respawn_bleedout_prompt'))
				EndTextCommandDisplayText(0.5, 0.77)

				if IsControlPressed(0, 38) and timeHeld > 60 then
					RemoveItemsAfterRPDeath()
					break
				end
			elseif Config.EarlyRespawnFine and canPayFine then
				DrawGenericTextThisFrame()
				BeginTextCommandDisplayText('STRING')
				AddTextComponentSubstringPlayerName(_U('respawn_bleedout_fine', ESX.Math.GroupDigits(Config.EarlyRespawnFineAmount)))
				EndTextCommandDisplayText(0.5, 0.77)

				if IsControlPressed(0, 38) and timeHeld > 60 then
					TriggerServerEvent('esx_ambulancejob:payFine')
					RemoveItemsAfterRPDeath()
					break
				end
			end

			if IsControlPressed(0, 38) then
				timeHeld = timeHeld + 1
			else
				timeHeld = 0
			end

			DrawGenericTextThisFrame()
			BeginTextCommandDisplayText('STRING')
			AddTextComponentSubstringPlayerName(_U('respawn_bleedout_in', secondsToClock(bleedoutTimer)))
			EndTextCommandDisplayText(0.5, 0.75)
		end

		if bleedoutTimer < 1 and isDead then
			RemoveItemsAfterRPDeath()
		end
	end)
end)

function RemoveItemsAfterRPDeath()
	DoScreenFadeOut(800)
	while not IsScreenFadedOut() do
		Citizen.Wait(10)
	end
	TriggerServerEvent('esx_ambulancejob:removeItemsAfterRPDeath')
	local formattedCoords = {
		x = Config.RespawnPoint.coords.x,
		y = Config.RespawnPoint.coords.y,
		z = Config.RespawnPoint.coords.z
	}
	ESX.SetPlayerData('loadout', {})
	Wait(1500)
	local playerPed = PlayerPedId()
	RespawnPed(playerPed, formattedCoords, Config.RespawnPoint.heading)
	exports['deivuks-utils']:health()
	SetEntityHealth(playerPed, GetPedMaxHealth(playerPed) - 1)
	StopScreenEffect('DeathFailOut')
	DoScreenFadeIn(800)
	TriggerServerEvent('reload_death:setDead', false)
end

function RespawnPed(ped, coords, heading)
	SetEntityCoordsNoOffset(ped, coords.x, coords.y, coords.z, false, false, false, true)
	FreezeEntityPosition(ped, true)
	exports['deivuks-utils']:health()
	NetworkResurrectLocalPlayer(coords.x, coords.y, coords.z, heading, true, false)
	SetEntityHealth(ped, GetPedMaxHealth(ped) - 1)
	SetPlayerInvincible(ped, false)
	TriggerEvent('reload_death:reviveRPDeath', ped)
	ClearPedBloodDamage(ped)
	StopEntityFire(ped)
	Wait(2000)
	FreezeEntityPosition(ped, false)
end

function FakeRevive()
	local coords = GetEntityCoords(cache.ped)
	local heading = GetEntityHeading(cache.ped)
	SetEntityCoordsNoOffset(cache.ped, coords.x, coords.y, coords.z, false, false, false, true)
	exports['deivuks-utils']:health()
	NetworkResurrectLocalPlayer(coords.x, coords.y, coords.z, heading, true, false)
	SetEntityHealth(cache.ped, GetPedMaxHealth(cache.ped) - 1)
	SetPlayerInvincible(cache.ped, false)
	ClearPedBloodDamage(cache.ped)
	StopEntityFire(cache.ped)
	TriggerEvent('reload_death:fakeRevive')
	fakeDied = true
end

RegisterNetEvent('esx_ambulancejob:revive')
AddEventHandler('esx_ambulancejob:revive', function()
	local playerPed = PlayerPedId()
	local coords = GetEntityCoords(playerPed)
	DoScreenFadeOut(800)
	while not IsScreenFadedOut() do
		Citizen.Wait(50)
	end
	local formattedCoords = {
		x = ESX.Math.Round(coords.x, 1),
		y = ESX.Math.Round(coords.y, 1),
		z = ESX.Math.Round(coords.z, 1)
	}
	RespawnPed(playerPed, formattedCoords, 0.0)
	exports['deivuks-utils']:health()
	SetEntityHealth(playerPed, GetPedMaxHealth(playerPed) - 1)
	StopScreenEffect('DeathFailOut')
	DoScreenFadeIn(800)
	Citizen.Wait(5000)
	TriggerServerEvent('esx_ambulancejob:setDeathStatus', false)
end)

if Config.LoadIpl then
	RequestIpl('Coroner_Int_on')
end
