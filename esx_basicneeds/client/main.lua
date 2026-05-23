local IsAnimated = false

local notifications = {
	hunger = {
		[15] = { title = 'Pavalgyk', message = 'Jūsų pilvas pradeda gurgti, reiktų ko nors užkąsti.' },
		[30] = { title = 'Pavalgyk', message = 'Manau tau laikas pavalgyti ,paskubėk, tu labai alkanas.' }
	},
	thirst = {
		[15] = { title = 'Atsigerk', message = 'Manau tau laikas atsigerti ,paskubėk, tu labai ištroškęs.' },
		[30] = { title = 'Atsigerk', message = 'Jūsų gerklė išdžiūvusi, reiktų ko nors atsigerti.' }
	}
}

local function sendNotification(type, title, message, duration, icon)
	exports['1x-hud']:sendNotification({
		type = type,
		title = title,
		message = message,
		duration = duration,
		icon = icon
	})
end

RegisterNetEvent('esx_basicneeds:healPlayer', function()
	exports.esx_status:set('hunger', 1000000)
	exports.esx_status:set('thirst', 1000000)

	exports['deivuks-utils']:health()
	SetEntityHealth(cache.ped, GetEntityMaxHealth(cache.ped)-1)
end)

RegisterNetEvent('esx_basicneeds:armour', function()
	exports['deivuks-utils']:health()
	SetEntityHealth(cache.ped, GetEntityMaxHealth(cache.ped)-1)
	exports['deivuks-utils']:armour()
	SetPedArmour(cache.ped, 99)
end)

AddEventHandler('reload_death:onPlayerRevive', function()
	exports.esx_status:set('hunger', 500000)
	exports.esx_status:set('thirst', 500000)
end)

AddEventHandler('esx_status:loaded', function(status)
	exports.esx_status:registerStatus('hunger', 1000000, {
		remove = 100,
		whileDead = false,
	})

	exports.esx_status:registerStatus('thirst', 1000000, {
		remove = 75,
		whileDead = false,
	})
end)

AddEventHandler('esx_status:onTick', function(data)
	local prevHealth = GetEntityHealth(cache.ped)
	local health = prevHealth
	
	for _, status in pairs(data) do
		if status.percent == 0 then
			if status.name == 'hunger' or status.name == 'thirst' then
				health -= (prevHealth <= 150) and 5 or 1
				break
			end
		else
			local notification = notifications[status.name] and notifications[status.name][status.percent]
			if notification then
				sendNotification('WARNING', notification.title, notification.message, 6000, 'plate-wheat')
				break
			end
		end
	end
	
	if health ~= prevHealth then
		if health < 100 then
			exports['Reload_Death']:diedFromFood()
		end

		SetEntityHealth(cache.ped, health)
	end
end)