RegisterCommand("apsirengti", function()
	ESX.TriggerServerCallback('esx_skin:getPlayerSkin', function(skin)
		TriggerEvent('skinchanger:loadSkin', skin)
	end)
	ESX.TriggerServerCallback('esx_service:isInService', function(isInService)
		if isInService then
			TriggerServerEvent('esx_service:notifyAllInService', notification, ESX.PlayerData.job.name)

			TriggerServerEvent('esx_service:disableService', ESX.PlayerData.job.name)
			
			exports['1x-hud']:sendNotification({
				type = 'ERROR',
				title = 'Persirengimas',
				message = 'Persirengėte civiliniais drabužiais todėl baigėte pamainą.',
				duration = 6000,
				icon = 'shirt'
			})

			local data = {
				['Log'] = ESX.PlayerData.job.name,
				['Title'] = 'Pabaigė darba',
				['Message'] = 'Žaidėjas pabaigė darba',
				['Color'] = 'yellow'
			}
	
			TriggerServerEvent('Boost-Logs:SendLog', data)
		end
	end, ESX.PlayerData.job.name)
	TriggerEvent('d-ambulance:isonduty', function(isonduty)
		if isonduty then
			local data = {
				['Log'] = 'ambulance',
				['Title'] = 'Baigė darbą',
				['Message'] = 'Žaidėjas baigė darbą',
				['Color'] = 'red'
			}

			TriggerServerEvent('Boost-Logs:SendLog', data)
			exports['1x-hud']:sendNotification({
				type = 'ERROR',
				title = 'Persirengimas',
				message = 'Persirengėte civiliniais drabužiais todėl baigėte pamainą.',
				duration = 6000,
				icon = 'shirt'
			})
			
		end
	end)
	TriggerEvent('d-mechanic:isonduty', function(uniform)
		if uniform then
			local data = {
				['Log'] = 'mechanic',
				['Title'] = 'Baigė darbą',
				['Message'] = 'Baigiau dirbti!',
				['Color'] = 'red'
			}
	
			TriggerServerEvent('Boost-Logs:SendLog', data)	
			exports['1x-hud']:sendNotification({
				type = 'ERROR',
				title = 'Persirengimas',
				message = 'Persirengėte civiliniais drabužiais todėl baigėte pamainą.',
				duration = 6000,
				icon = 'shirt'
			})
			
		end
	end)
end)	