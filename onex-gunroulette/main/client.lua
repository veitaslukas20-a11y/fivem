local ox_target = exports.ox_target

local weapon = nil

CreateThread(function()
    for _, spot in ipairs(Config.RouletteSpots) do
        local blip = AddBlipForCoord(spot.coords.x, spot.coords.y, spot.coords.z)

        SetBlipSprite(blip, 84)
        SetBlipScale(blip, 0.8)
        SetBlipColour(blip, 1)
        SetBlipAsShortRange(blip, false)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString('<font face="Roboto">Ginklų ruletė</font>')
        EndTextCommandSetBlipName(blip)
    end
end)

local function openSelectionMenu(tableId)
	local closePlayers = lib.getNearbyPlayers(cache.coords or GetEntityCoords(cache.ped), 5.0, false)

	if not closePlayers or #closePlayers == 0 then
		return exports['1x-hud']:sendNotification({
			type = 'ERROR',
			title = 'Ginklų ruletė',
			message = 'Nėra netoliese esančių žmonių su kuriais galėtumėte varžytis.',
			duration = 5000,
		})
	end

	local options = {}

	for _, player in pairs(closePlayers) do
		local serverId = GetPlayerServerId(player.id)
		table.insert(options, {
			value = serverId,
			label = 'Žaidėjas #'..serverId,
		})
	end

	local input = lib.inputDialog("Ginklų ruletė", {
        { type = 'number', label = "Įveskite sumą kurią norite statyti", min = 10000, required = true },
        { type = 'select', label = "Pasirinkite varžovą", options = options, required = true }
    })

	if not input or not input[1] or not input[2] then return end

	TriggerServerEvent('gunroulette:requestPlay', tableId, input[2], input[1])
end

local nearTables = {}
Citizen.CreateThread(function()
	for id, spotData in pairs(Config.RouletteSpots) do
		lib.points.new({
			coords = spotData.coords,
			distance = 50,
			onEnter = function()
				local newTable = CreateObject(Config.Prop, spotData.coords.x, spotData.coords.y, spotData.coords.z, false, true, false)
				PlaceObjectOnGroundProperly(newTable)

				ox_target:addLocalEntity(newTable, {
					{
						icon = 'fa-solid fa-gun',
						label = 'Žaisti ginklų ruletę',
						onSelect = function()
							openSelectionMenu(id)
						end
					}
				})

				nearTables[id] = newTable
			end,
			onExit = function()
				local tableToRemove = nearTables[id]
				if tableToRemove and DoesEntityExist(tableToRemove) then
					ox_target:removeLocalEntity(tableToRemove)
					DeleteEntity(tableToRemove)
				end
			end
		})
	end
end)

RegisterNetEvent("gunroulette:sendInvitation", function(tableId, theAmount)
	local input = lib.alertDialog({
		header = 'Ginklų ruletė',
		content = 'Ar sutinkate žaisti ginklų ruletę?\n\nStatymo syma: '..theAmount..'€',
		centered = true,
		cancel = true,
		labels = {
			confirm = "Patvirtinti",
			cancel = "Atšaukti"
		}
	})

	if input == "confirm" then
		TriggerServerEvent("gunroulette:startGame", tableId)
	else
		TriggerServerEvent("gunroulette:rejectInvitation", tableId)
	end
end)

local function triggerShot(isWinner, currentBullet)
	local model = `w_pi_revolver_g`

	lib.requestModel(model)

	weapon = CreateObject(model, 1.0, 1.0, 1.0, true, true, false)
	SetModelAsNoLongerNeeded(model)

	local xOffset = 0.159
	local yOffset = 0.07
	local zOffset = -0.010

	local xRot = -90.0
	local yRot = 0.0
	local zRot = 0.0

	AttachEntityToEntity(weapon, cache.ped, GetPedBoneIndex(cache.ped, 57005), xOffset, yOffset, zOffset, xRot, yRot, zRot, false, false, false, false, 2, true)
	SetEntityAsMissionEntity(weapon, true, true)
	SetEntityCompletelyDisableCollision(weapon, false, true)

	Wait(300)

	lib.playAnim(cache.ped, "mp_suicide", "pistol")

	Wait(700)

	local isBullet = false

	if not isWinner and currentBullet ~= 1 then
		isBullet = (math.random() * 100) > 50 or currentBullet == 3
	end

    if isBullet then
        SetEntityHealth(cache.ped, 0)

		DeleteEntity(weapon)
		weapon = nil

		SendNUIMessage({
			transactionType = "playSound",
			transactionFile = "thereisammo"
		})
        return true
    else
		DeleteEntity(weapon)
		weapon = nil

		StopAnimTask(cache.ped, "mp_suicide", "pistol", -8.0)

		SendNUIMessage({
			transactionType = "playSound",
			transactionFile = "thereisnotammo"
		})
        return false
    end
end

local gameEnded = false
RegisterNetEvent("gunroulette:startGame", function(placeType, tableId, isWinner)
	local rouletteSpot = Config.RouletteSpots[tableId][placeType]

	FreezeEntityPosition(cache.ped, true)
	SetEntityCoords(cache.ped, rouletteSpot.x, rouletteSpot.y, rouletteSpot.z, true, false, false, false)
	SetEntityHeading(cache.ped, rouletteSpot.w)
	Wait(2500)

	SendNUIMessage({
        uiName = "countdown",
        text = "3"
	})

	Wait(3000)

	local currentBullet = 1

	if placeType ~= 'front' then
		Wait(3000)
	end

	while currentBullet <= 3 and not gameEnded do
		local didShoot = triggerShot(isWinner, currentBullet)
		if didShoot then
			FreezeEntityPosition(cache.ped, false)
			TriggerServerEvent("gunroulette:endGame", tableId)
			break
		end

		currentBullet += 1
		Wait(6000)
	end

	FreezeEntityPosition(cache.ped, false)
end)

RegisterNetEvent("gunroulette:wonGame", function()
	local randomAnim = Config.WinAnimations[math.random(1, #Config.WinAnimations)]
	lib.playAnim(cache.ped, randomAnim.anim, randomAnim.dict)
	gameEnded = true
end)