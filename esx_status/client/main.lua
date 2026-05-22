local Status = {}
local playerState = LocalPlayer.state
local IsActive = true
local Inventory = exports.ox_inventory

local function GetStatusData()
	local data = {}

	for _, status in pairs(Status) do
		data[status.name] = status.val
	end

	return data
end

local function StatusTick()
	Citizen.CreateThread(function()
		while true do
			Wait(Config.TickTime)

			local data = {}

			for _, status in pairs(Status) do
				status:onTick(playerState.dead, IsActive)

				data[#data + 1] = {
					name = status.name,
					val = status.val,
					percent = status:getPercent()
				}
			end

			TriggerEvent('esx_status:onTick', data)
		end
	end)

	Citizen.CreateThread(function()
		while true do
			IsActive = false
			if IsPedSprinting(cache.ped) then
				IsActive = true
			end

			if IsPedSwimming(cache.ped) then
				IsActive = true
			end

			if IsPedShooting(cache.ped) then
				IsActive = true
			end

			if NetworkIsPlayerTalking(cache.playerId) then
				IsActive = true
			end

			-- FIX: Safe check for GetPlayerWeight export
			if Inventory and Inventory.GetPlayerWeight then
				local weight = Inventory:GetPlayerWeight()
				if weight and weight >= 30000 then
					IsActive = true
				end
			else
				-- Fallback if export doesn't exist
				print("^1[esx_status] Warning: ox_inventory GetPlayerWeight export not found^0")
			end

			Wait(1000)
		end
	end)
end

exports('registerStatus', function(name, default, settings)
	local status = CreateStatus(name, default, settings)
	table.insert(Status, status)
end)

RegisterNetEvent('esx_status:load')
AddEventHandler('esx_status:load', function(data)
	TriggerEvent('esx_status:loaded')

	for _, status in pairs(Status) do
		local value = data[status.name]
		if value then
			status:set(value)
		end
	end

	StatusTick()
end)

local function setStatus(name, val)
	for _, status in pairs(Status) do
		if status.name == name then
			status:set(val)
			return
		end
	end
end

exports('set', setStatus)
RegisterNetEvent('esx_status:set', setStatus)

local function addStatus(name, val)
	for _, status in pairs(Status) do
		if status.name == name then
			status:add(val)
			return
		end
	end
end

exports('add', addStatus)
RegisterNetEvent('esx_status:add', addStatus)


local function removeStatus(name, val)
	for _, status in pairs(Status) do
		if status.name == name then
			status:remove(val)
			return
		end
	end
end

exports('remove', removeStatus)
RegisterNetEvent('esx_status:remove', removeStatus)

local function getStatus(name)
	for _, status in pairs(Status) do
		if status.name == name then
			return status
		end
	end
end

exports('get', getStatus)
RegisterNetEvent('esx_status:getStatus', function(name, cb)
	for _, status in pairs(Status) do
		if status.name == name then
			cb(status)
			return
		end
	end
end)

Citizen.CreateThread(function()
	while not ESX.IsPlayerLoaded() do 
		Wait(100)
	end

	while true do
		Wait(Config.UpdateInterval)

		local payload = msgpack.pack_args(GetStatusData())
		local payloadLen = #payload

		TriggerServerEventInternal('esx_status:update', payload, payloadLen) 
	end
end)