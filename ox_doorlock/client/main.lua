if not LoadResourceFile(cache.resource, 'web/build/index.html') then
	error('Unable to load UI. Build ox_doorlock or download the latest release.\n	^3https://github.com/communityox/ox_doorlock/releases/latest/download/ox_doorlock.zip^0')
end

if not lib.checkDependency('ox_lib', '3.30.4', true) then return end

local math = require 'glm'
local doors = {}
_ENV.doors = doors

local GetEntityCoords = GetEntityCoords
local GetClosestObjectOfType = GetClosestObjectOfType
local IsModelValid = IsModelValid
local GetLabelText = GetLabelText
local GetNameOfZone = GetNameOfZone
local AddDoorToSystem = AddDoorToSystem
local DoorSystemSetDoorState = DoorSystemSetDoorState
local DoorSystemSetAutomaticRate = DoorSystemSetAutomaticRate
local DoorSystemSetHoldOpen = DoorSystemSetHoldOpen
local IsDoorClosed = IsDoorClosed
local GetGameTimer = GetGameTimer
local GetModelDimensions = GetModelDimensions
local GetEntityHeading = GetEntityHeading
local GetAspectRatio = GetAspectRatio
local SetDrawOrigin = SetDrawOrigin
local ClearDrawOrigin = ClearDrawOrigin
local DrawSprite = DrawSprite
local RequestStreamedTextureDict = RequestStreamedTextureDict
local vec3 = vec3
local Wait = Wait

local DOOR_STATE_UNLOCKED = 0
local DOOR_STATE_LOCKED = 1
local DOOR_STATE_FORCE_LOCKED = 4
local DEFAULT_DOOR_RATE = 10.0
local SOUND_DISTANCE_THRESHOLD = 20
local TRIGGER_COOLDOWN = 500
local UPDATE_INTERVAL = 5000
local DOOR_INTERVAL = 500
local UI_INTERVAL = 5

local nearbyDoors = {}
local ratio = GetAspectRatio(true)
local lastUpdate = 0
ClosestDoor = nil
local currentCoords = vec3(0, 0, 0)

local PI_OVER_180 = math.pi / 180

local function setupDoorSystem(hash, model, coords, state, doorRate, auto)
	AddDoorToSystem(hash, model, coords.x, coords.y, coords.z, false, false, false)
	DoorSystemSetDoorState(hash, DOOR_STATE_FORCE_LOCKED, false, false)
	DoorSystemSetDoorState(hash, state, false, false)

	if doorRate or not auto then
		DoorSystemSetAutomaticRate(hash, doorRate or DEFAULT_DOOR_RATE, false, false)
	end
end

local function createDoor(door)
	local oldDoor = doors[door.id]

	if oldDoor then
		lib.grid.removeEntry(oldDoor)
	end

	doors[door.id] = door
	door.zone = door.zone or GetLabelText(GetNameOfZone(door.coords.x, door.coords.y, door.coords.z))
	door.radius = door.maxDistance

	local double = door.doors

	if double then
		for i = 1, 2 do
			local doorData = double[i]
			setupDoorSystem(doorData.hash, doorData.model, doorData.coords, door.state, door.doorRate, door.auto)
		end
	else
		setupDoorSystem(door.hash, door.model, door.coords, door.state, door.doorRate, door.auto)
	end

	lib.grid.addEntry(door)
end

local function getDoorEntity(coords, model)
	local entity = GetClosestObjectOfType(coords.x, coords.y, coords.z, 1.0, model, false, false, false)

	if entity and entity ~= 0 then
		return entity
	end

	return nil
end

local hasNearbyDoors = false
local function updateDoorEntity(door)
	local double = door.doors
	if double then
		for i = 1, 2 do
			local dDoor = double[i]
			if not door.entity and dDoor.model and IsModelValid(dDoor.model) then
				local entity = getDoorEntity(dDoor.coords, dDoor.model)

				if entity then
					dDoor.entity = entity
					Entity(entity).state.doorId = door.id
				end
			end
		end
	else
		if not door.entity and door.model and IsModelValid(door.model) then
			local entity = getDoorEntity(door.coords, door.model)

			if entity then
				local dCoords = GetEntityCoords(entity)
				local min, max = GetModelDimensions(door.model)

				local center = vec3((min.x + max.x) / 2, (min.y + max.y) / 2, (min.z + max.z) / 2)
				local heading = GetEntityHeading(entity) * PI_OVER_180
				local sin, cos = math.sincos(heading)

				local rotatedX = cos * center.x - sin * center.y
				local rotatedY = sin * center.x + cos * center.y

				door.coords = vec3(dCoords.x + rotatedX, dCoords.y + rotatedY, dCoords.z + center.z)
				door.entity = entity
				Entity(entity).state.doorId = door.id
			end
		end
	end
end

local function updateNearbyDoors()
	local currentTime = GetGameTimer()

	currentCoords = cache.coords or GetEntityCoords(cache.ped)
	nearbyDoors = lib.grid.getNearbyEntries(currentCoords)
	hasNearbyDoors = #nearbyDoors > 0

	if hasNearbyDoors then
		local newClosestDoor = nil
		local closestDistance = math.huge
		local shouldUpdate = (currentTime - lastUpdate) > UPDATE_INTERVAL

		if shouldUpdate then
			ratio = GetAspectRatio(true)
			lastUpdate = currentTime
		end

		for _, door in ipairs(nearbyDoors) do
			if not door or not door.coords or not door.maxDistance then
				goto continue
			end

			door.distance = #(currentCoords - door.coords)

			if shouldUpdate then
				updateDoorEntity(door)
			end

			if door.distance < door.maxDistance then
				if door.distance < closestDistance then
					newClosestDoor = door
					closestDistance = door.distance
				end
			end

			:: continue ::
		end

		ClosestDoor = newClosestDoor
	end
end

CreateThread(function()
	local lockDoor = locale('lock_door')
	local unlockDoor = locale('unlock_door')
	local showUI = nil
	local drawSprite = Config.DrawSprite
	local drawSpriteEnabled = drawSprite ~= nil
	local drawTextUI = Config.DrawTextUI

	if drawSpriteEnabled then
		local sprite1 = drawSprite[DOOR_STATE_UNLOCKED] and drawSprite[DOOR_STATE_UNLOCKED][1]
		local sprite2 = drawSprite[DOOR_STATE_LOCKED] and drawSprite[DOOR_STATE_LOCKED][1]

		if sprite1 then RequestStreamedTextureDict(sprite1, true) end
		if sprite2 then RequestStreamedTextureDict(sprite2, true) end
	end

	while true do
		local willShowUI = (ClosestDoor and not ClosestDoor.hideUi)

		if ClosestDoor and not ClosestDoor.hideUi and ClosestDoor.distance and ClosestDoor.maxDistance and ClosestDoor.distance <= ClosestDoor.maxDistance then
			if drawTextUI and ClosestDoor.state ~= showUI then
				lib.showTextUI(ClosestDoor.state == DOOR_STATE_UNLOCKED and lockDoor or unlockDoor)
				showUI = ClosestDoor.state
			end

			if drawSpriteEnabled and ClosestDoor.coords then
				local sprite = drawSprite[ClosestDoor.state]

				if sprite then
					SetDrawOrigin(ClosestDoor.coords.x, ClosestDoor.coords.y, ClosestDoor.coords.z)
					DrawSprite(sprite[1], sprite[2], sprite[3], sprite[4], sprite[5], sprite[6] * ratio, sprite[7], sprite[8], sprite[9], sprite[10], sprite[11])
					ClearDrawOrigin()
				end
			end
		elseif showUI then
			lib.hideTextUI()
			showUI = nil
		end

		Wait(willShowUI and UI_INTERVAL or DOOR_INTERVAL)
	end
end)

local lastTriggered = 0
lib.addKeybind({
    name = 'interactEntityDoors',
    description = 'Unlock/Lock doors',
    defaultKey = 'E',
    onPressed = function(self)
        if ClosestDoor and not PickingLock then
			local currentTime = GetGameTimer()

			if currentTime - lastTriggered > TRIGGER_COOLDOWN then
				lastTriggered = currentTime
				local newState = ClosestDoor.state == DOOR_STATE_LOCKED and DOOR_STATE_UNLOCKED or DOOR_STATE_LOCKED
				TriggerServerEvent('ox_doorlock:setState', ClosestDoor.id, newState)
			end
		end
    end,
})

lib.callback('ox_doorlock:getDoors', false, function(data)
	for _, door in pairs(data) do
		createDoor(door)
	end

	while true do
		updateNearbyDoors()
		Wait(DOOR_INTERVAL)
	end
end)

local function setDoorState(door, state)
	local double = door.doors

	if double then
		for i = 1, 2 do
			local doorHash = double[i].hash
			DoorSystemSetDoorState(doorHash, state, false, false)

			if door.holdOpen then
				DoorSystemSetHoldOpen(doorHash, state == DOOR_STATE_UNLOCKED)
			end
		end

		if state == DOOR_STATE_LOCKED then
			CreateThread(function()
				while not IsDoorClosed(double[1].hash) or not IsDoorClosed(double[2].hash) do
					Wait(50)
				end
			end)
		end
	else
		DoorSystemSetDoorState(door.hash, state, false, false)

		if door.holdOpen then
			DoorSystemSetHoldOpen(door.hash, state == DOOR_STATE_UNLOCKED)
		end

		if state == DOOR_STATE_LOCKED then
			CreateThread(function()
				while not IsDoorClosed(door.hash) do
					Wait(50)
				end
			end)
		end
	end
end

local function playDoorSound(door, state)
	if not door.distance or door.distance >= SOUND_DISTANCE_THRESHOLD then return end

	if Config.NativeAudio then
		CreateThread(function()
			RequestScriptAudioBank('dlc_oxdoorlock/oxdoorlock', false)
			local sound = state == DOOR_STATE_UNLOCKED and door.unlockSound or door.lockSound or 'door_bolt'
			local soundId = GetSoundId()

			PlaySoundFromCoord(soundId, sound, door.coords.x, door.coords.y, door.coords.z, 'DLC_OXDOORLOCK_SET', false, 0, false)
			ReleaseSoundId(soundId)
			ReleaseNamedScriptAudioBank('dlc_oxdoorlock/oxdoorlock')
		end)
	else
		local volume = math.min(1.0, (0.01 * GetProfileSetting(300)) / (door.distance * 0.5))
		local sound = state == DOOR_STATE_UNLOCKED and door.unlockSound or door.lockSound or 'door-bolt-4'

		SendNUIMessage({
			action = 'playSound',
			data = {
				sound = sound,
				volume = volume
			}
		})
	end
end

RegisterNetEvent('ox_doorlock:setState', function(id, state, source, data)
	if not doors then return end

	if data then
		createDoor(data)

		if NuiHasLoaded then
			SendNuiMessage(json.encode({
				action = 'updateDoorData',
				data = data
			}))
		end
	end

	if Config.Notify and source == cache.serverId then
		CreateThread(function()
			lib.notify({
				type = 'success',
				icon = state == DOOR_STATE_UNLOCKED and 'unlock' or 'lock',
				description = state == DOOR_STATE_UNLOCKED and locale('unlocked_door') or locale('locked_door')
			})
		end)
	end

	local door = data or doors[id]
	if not door then return end

	door.state = state
	setDoorState(door, state)
	playDoorSound(door, state)
end)

RegisterNetEvent('ox_doorlock:editDoorlock', function(id, data)
	if source == '' then return end

	local door = doors[id]
	if not door then return end

	CreateThread(function()
		local double = door.doors
		local doorState = data and data.state or DOOR_STATE_UNLOCKED

		lib.grid.removeEntry(door)

		if data then
			data.zone = door.zone or GetLabelText(GetNameOfZone(door.coords.x, door.coords.y, door.coords.z))
			data.radius = data.maxDistance

			if door.distance and door.distance < SOUND_DISTANCE_THRESHOLD then
				door.distance = 80
			end

			lib.grid.addEntry(data)
		elseif ClosestDoor and ClosestDoor.id == id then
			ClosestDoor = nil
		end

		if double then
			for i = 1, 2 do
				local doorHash = double[i].hash

				if data then
					if data.doorRate or door.doorRate or not data.auto then
						DoorSystemSetAutomaticRate(doorHash, data.doorRate or (door.doorRate and 0.0 or DEFAULT_DOOR_RATE), false, false)
					end

					DoorSystemSetDoorState(doorHash, doorState, false, false)

					if data.holdOpen then
						DoorSystemSetHoldOpen(doorHash, doorState == DOOR_STATE_UNLOCKED) 
					end
				else
					DoorSystemSetDoorState(doorHash, DOOR_STATE_FORCE_LOCKED, false, false)
					DoorSystemSetDoorState(doorHash, DOOR_STATE_UNLOCKED, false, false)

					if double[i].entity then
						Entity(double[i].entity).state.doorId = nil
					end
				end
			end
		else
			if data then
				if data.doorRate or door.doorRate or not data.auto then
					DoorSystemSetAutomaticRate(door.hash, data.doorRate or (door.doorRate and 0.0 or DEFAULT_DOOR_RATE), false, false)
				end

				DoorSystemSetDoorState(door.hash, doorState, false, false)

				if data.holdOpen then
					DoorSystemSetHoldOpen(door.hash, doorState == DOOR_STATE_UNLOCKED) 
				end
			else
				DoorSystemSetDoorState(door.hash, DOOR_STATE_FORCE_LOCKED, false, false)
				DoorSystemSetDoorState(door.hash, DOOR_STATE_UNLOCKED, false, false)

				if door.entity then
					Entity(door.entity).state.doorId = nil
				end
			end
		end

		doors[id] = data

		if NuiHasLoaded then
			SendNuiMessage(json.encode({
				action = 'updateDoorData',
				data = data or id
			}))
		end
	end)
end)

lib.callback.register('ox_doorlock:inputPassCode', function()
	return ClosestDoor?.passcode and lib.inputDialog(locale('door_lock'), {
		{
			type = 'input',
			label = locale('passcode'),
			password = true,
			icon = 'lock'
		},
	})?[1]
end)

local function useClosestDoor()
	if not ClosestDoor then return false end

	local gameTimer = GetGameTimer()

	if gameTimer - lastTriggered > TRIGGER_COOLDOWN then
		lastTriggered = gameTimer
		local newState = ClosestDoor.state == DOOR_STATE_LOCKED and DOOR_STATE_UNLOCKED or DOOR_STATE_LOCKED
		TriggerServerEvent('ox_doorlock:setState', ClosestDoor.id, newState)
		return true
	end

	return false
end

exports('useClosestDoor', useClosestDoor)
exports('getClosestDoor', function() return ClosestDoor end)