---@diagnostic disable: undefined-global

local disableToCarry = false
Pataisos = { jobs = 0, reason = '', admin = '' }

local zones = require('client.zones')
local questions = require('client.questions')
local ui = require('client.ui')

local pataisosCoords = vec3(926.2106, 37.1677, 113.5487)
local penaltyCenter = vec3(942.5313, 44.4457, 112.5526)

local function teleportTo(ped, coords, heading)
	SetEntityCoords(ped, coords.x, coords.y, coords.z, false, false, false, false)
	if heading then SetEntityHeading(ped, heading) end
end

local function returnToPataisos()
	while #(GetEntityCoords(cache.ped) - pataisosCoords) > 3.0 do
		teleportTo(cache.ped, pataisosCoords, 240.7028)
		Wait(500)
	end
end

exports('checkPataisos', function()
	return disableToCarry
end)

local function initPenalties()
	disableToCarry = true

	local fetchedQuestions = lib.callback.await('d-pataisos:getQuestions', false)
	questions.setQuestions(fetchedQuestions)
	local hasQuestions = questions.resetQuestions()

	if not hasQuestions then
		lib.notify({
			title = 'Pataisos',
			description = 'Klausimų nepavyko įkelti. Praneškite administratoriui.',
			type = 'error',
			duration = 6000
		})
	end

	zones.addZones()

	ui.showUI(Pataisos.jobs, Pataisos.reason, Pataisos.admin)

	lib.points.new({
		coords = penaltyCenter, 
		distance = 80,
		onExit = function()
			if Pataisos.jobs <= 0 then return end
			teleportTo(cache.ped, penaltyCenter, 240.7028)
			lib.notify({
				title = 'Pataisos',
				description = 'Na ir kur gi tu pabėgsi neklaužada... Dirbk toliau.',
				type = 'error',
				duration = 6000
			})
		end
	})

	CreateThread(function()
		while disableToCarry and Pataisos.jobs and Pataisos.jobs > 0 do
			local ped = cache.ped
			if ped and DoesEntityExist(ped) then
				local dist = #(GetEntityCoords(ped) - penaltyCenter)
				if dist > 80.0 then
					teleportTo(ped, penaltyCenter, 240.7028)
				end
			end
			Wait(10000) 
		end
	end)
end

local function removePenalties()
	disableToCarry = false
	ui.hideUI()
	SetEntityCoords(cache.ped, 191.2986, -851.5528, 31.1110, false, false, false, false)
	SetEntityHeading(cache.ped, 62.7621)

	zones.removeZones()
end

RegisterNetEvent("esx:playerLoaded")
AddEventHandler("esx:playerLoaded", function()
	Wait(500)

	local hasJobs, newPataisosJobs, reason, admin = lib.callback.await("d-pataisos:retrievePataisosJobs", false)

	if hasJobs then
		Pataisos.jobs = newPataisosJobs
		Pataisos.reason = reason
		Pataisos.admin = admin
		returnToPataisos()
		initPenalties()
	end
end)

RegisterNetEvent('d-pataisos:pataisosPlayer', function(newPataisosJobs, reason, admin)
	Pataisos.jobs = newPataisosJobs
	Pataisos.reason = reason
	Pataisos.admin = admin
	Wait(100)
	returnToPataisos()
	initPenalties()
end)

RegisterNetEvent('d-pataisos:unPataisosPlayer', function()
	Pataisos.jobs = 0
	Wait(1000)
	removePenalties()
end)

RegisterNetEvent('pataisos:editJobs', function(jobs)
	Pataisos.jobs = jobs or Pataisos.jobs
end)

AddEventHandler('esx:enteredVehicle', function(vehicle)
	if not disableToCarry then return end
	TaskLeaveVehicle(cache.ped, vehicle, 16)
end)

AddEventHandler('esx:onPlayerDeath', function()
	if not Pataisos then return end
    if Pataisos.jobs <= 0 then return end
	teleportTo(cache.ped, pataisosCoords, 240.7028)
	TriggerEvent('reload_death:revive')
end)

AddEventHandler('esx_skin:save', function()
	if not Pataisos then return end
    if Pataisos.jobs <= 0 then return end

	returnToPataisos()
end)


AddEventHandler('onResourceStop', function(resourceName)
	if GetCurrentResourceName() ~= resourceName then return end
	zones.removeZones()
end)

local Notifies = {
	['permissions'] = 'Neturite tam reikalingų leidimų.',
	['offline'] = 'Žaidėjas nėra aktyvus.',
	['count'] = 'Įvedėte neteisingą viešų darbų skaičių.'
}

RegisterCommand('pataisos', function()
	local permissions = lib.callback.await('d-pataisos:permissions', false)
	if not permissions then
		lib.notify({
			title = 'Pataisos',
			description = 'Neturite leidimo naudoti šios komandos.',
			type = 'error',
			duration = 5000
		})
		return
	end
	local online = lib.alertDialog({
		header = 'Pasirinkite žaidėjo statusą',
		content = 'Ar žaidėjas yra aktyvus ar neaktyvus? Pasirinkite žaidėjo statusą paspausdami mygtuką apačioje.',
		centered = true,
		cancel = true,
		labels = {
			cancel = 'Neaktyvus',
			confirm = 'Aktyvus',
		}
	})

	if online == 'confirm' then
		local input = lib.inputDialog('Išsiųsti viešų', {
			{type = 'input', label = 'Žaidėjo ID', description = 'Žaidejas, kurį norite išsiųsti viešų darbų', required = true, icon = 'fa-solid fa-user'},
			{type = 'number', label = 'Viešų darbų skaičius', description = 'Viešų darbų skaičius, kurį žaidėjas turės atlikti', required = true, icon = 'fa-solid fa-business-time'},
			{type = 'input', label = 'Priežastis', description = 'Priežastis, kodėl norite išsiųsti žaidėją viešų', required = true, icon = 'fa-solid fa-note-sticky'},
		})

		if not input then return end

		local result = lib.callback.await('d-pataisos:bausti', false, true, input[1], input[2], input[3])
		if result then
			lib.notify({
				title = 'Pataisos',
				description = Notifies[result],
				type = 'info',
				duration = 6000
			})
		end
	elseif online == 'cancel' then
		local input = lib.inputDialog('Išsiųsti viešų (Neaktyvus)', {
			{type = 'input', label = 'License', description = 'Pvz: license:xxxxxxxx arba tik xxxxxxxx', required = true, icon = 'fa-solid fa-fingerprint'},
			{type = 'input', label = 'IP', description = '(Nebūtina) ip:xxxxxxxx', required = false, icon = 'fa-solid fa-server'},
			{type = 'input', label = 'Steam', description = '(Nebūtina) steam:xxxxxxxx', required = false, icon = 'fa-brands fa-steam'},
			{type = 'input', label = 'Discord', description = '(Nebūtina) discord:xxxxxxxx', required = false, icon = 'fa-brands fa-discord'},
			{type = 'number', label = 'Viešų darbų skaičius', description = 'Viešų darbų skaičius, kurį žaidėjas turės atlikti', required = true, icon = 'fa-solid fa-business-time'},
			{type = 'input', label = 'Priežastis', description = 'Priežastis, kodėl norite išsiųsti žaidėją viešų', required = true, icon = 'fa-solid fa-note-sticky'},
		})

		if not input then return end

		local license = input[1] and input[1]:gsub('%s+', '') or ''
		if license ~= '' and not license:find('^license:') then
			license = 'license:' .. license
		end
		local result = lib.callback.await('d-pataisos:bausti', false, false, {
			license = license,
			ip = input[2] ~= '' and input[2] or nil,
			steam = input[3] ~= '' and input[3] or nil,
			discord = input[4] ~= '' and input[4] or nil,
		}, input[5], input[6])
		if result then
			lib.notify({
				title = 'Pataisos',
				description = Notifies[result],
				type = 'info',
				duration = 6000
			})
		end
	end
end, false)

local unpataisosState = {
	filterType = nil,
	query = nil,
	page = 1,       
	pageSize = -1   
}

local function jobColor(j)
	if j >= 200 then return '#ff0000' end
	if j >= 100 then return '#ff6a00' end
	if j >= 50 then return '#ffaa00' end
	return '#ffffff'
end

local function showMainContext()
	lib.registerContext({
		id = 'unpataisos_main',
		title = 'UNPataisos Valdymas',
		options = {
			{ title = 'Rodyti visus', icon = 'list', description = 'Rodyti visus žaidėjus su pataisomis', event = 'unpataisos:selectFilter', args = { filter = 'all' } },
			{ title = 'Paieška pagal License', icon = 'fingerprint', event = 'unpataisos:selectFilter', args = { filter = 'license' } },
			{ title = 'Paieška pagal Steam', icon = 'steam', event = 'unpataisos:selectFilter', args = { filter = 'steam' } },
			{ title = 'Paieška pagal Discord', icon = 'discord', event = 'unpataisos:selectFilter', args = { filter = 'discord' } },
			{ title = 'Paieška pagal Admin vardą', icon = 'user-shield', event = 'unpataisos:selectFilter', args = { filter = 'admin' } },
			{ title = 'Uždaryti', icon = 'xmark', event = '', args = {} },
		}
	})
	lib.showContext('unpataisos_main')
end

local function showListContext()
	local payload = lib.callback.await('d-pataisos:searchPenalties', false, unpataisosState.filterType, unpataisosState.query, 1, unpataisosState.pageSize)
	local total = payload and payload.total or 0
	local list = payload and payload.rows or {}
	if not list or #list == 0 then
		lib.notify({ title = 'Pataisos', description = 'Nerasta įrašų.', type = 'error' })
		showMainContext()
		return
	end
	local options = {
		{ title = string.format('Grįžti (viso: %d)', total), event = 'unpataisos:back', args = {} },
	}
	for _, row in ipairs(list) do
		options[#options+1] = {
			title = ("%s (%d)"):format(row.license, row.jobs),
			description = (row.reason or 'Be priežasties') .. ' | Admin: ' .. (row.admin or 'Nežinomas'),
			icon = 'id-card',
			event = 'unpataisos:selectLicense',
			args = { license = row.license, jobs = row.jobs, reason = row.reason, admin = row.admin }
		}
	end
	lib.registerContext({
		id = 'unpataisos_list',
		title = 'Pataisos sąrašas (Visi)',
		options = options
	})
	lib.showContext('unpataisos_list')
end

AddEventHandler('unpataisos:selectFilter', function(data)
	unpataisosState.filterType = data.filter
	if unpataisosState.filterType ~= 'all' then
		local input = lib.inputDialog('Paieška: '..unpataisosState.filterType, {
			{ type = 'input', label = 'Reikšmė', required = true }
		})
		if input then unpataisosState.query = input[1] end
	else
		unpataisosState.query = nil
	end
	showListContext()
end)

AddEventHandler('unpataisos:back', function()
	showMainContext()
end)

AddEventHandler('unpataisos:prev', function() showListContext() end)
AddEventHandler('unpataisos:next', function() showListContext() end)

AddEventHandler('unpataisos:selectLicense', function(data)
	local picked = data
	local confirm = lib.alertDialog({
		header = 'Nuimti pataisas',
		content = ('License: %s\nDarbai: %d\nPriežastis: %s\nAdmin: %s\n\nAr tikrai nuimti pataisas?'):format(picked.license, picked.jobs, picked.reason or 'Be priežasties', picked.admin or 'Nežinomas'),
		centered = true,
		cancel = true,
		labels = { cancel = 'Ne', confirm = 'Taip' }
	})
	if confirm == 'confirm' then
		local ok = lib.callback.await('d-pataisos:unPataisosByLicense', false, picked.license)
		if ok then
			lib.notify({ title = 'Pataisos', description = 'Pataisos nuimtos.', type = 'success' })
		else
			lib.notify({ title = 'Pataisos', description = 'Veiksmas nepavyko.', type = 'error' })
		end
	end
	showListContext()
end)

local function openUnPataisosMenu()
	local permissions = lib.callback.await('d-pataisos:permissions', false)
	if not permissions then
		lib.notify({
			title = 'Pataisos',
			description = 'Neturite leidimo naudoti šios komandos.',
			type = 'error',
			duration = 5000
		})
		return
	end
	showMainContext()
end

RegisterCommand('unpataisos', function()
	openUnPataisosMenu()
end, false)

RegisterNetEvent('d-pataisos:teleportAfterUnpataisos', function()
	local coords = vec3(191.2986, -851.5528, 31.1110)
	SetEntityCoords(cache.ped, coords.x, coords.y, coords.z, false, false, false, false)
end)