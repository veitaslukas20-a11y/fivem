local isDead = false
local opened = false
local mokama = false

function ShowBillsMenu(invoices)
	local baudos = {
		{
			title = 'Sumokėti visas baudas',
			description = 'Sumokėti visas baudas vieno mygtuko paspaudimu.',
			icon = 'fa-solid fa-file-invoice',
			onSelect = function()
				local success = lib.callback.await('esx_billing:payAllBills', false)
				if success then
					ShowBillsMenu(lib.callback.await('esx_billing:getBills', false))
				else
					ShowBillsMenu(invoices)
				end
			end,
		}
	}

	if #invoices > 0 then
		for k,v in pairs(invoices) do
			table.insert(baudos, {
				title = v.label,
				description = 'Susimokėkite šią baudą, kurios suma '..ESX.Math.GroupDigits(v.amount)..'€.',
				icon = 'fa-solid fa-file-invoice',
				onSelect = function()
					mokama = true
					local result = lib.callback.await('esx_billing:payBill', false, v.id)
					if result then
						table.remove(invoices, k)
					end

					mokama = false
					ShowBillsMenu(invoices)
				end,
			})
		end

		lib.registerContext({
			id = 'bills',
			title = 'Nesusimokėtos baudos',
			options = baudos,
			onExit = function()
				opened = false
			end
		})
		lib.showContext('bills')
		opened = true
	else
		exports['1x-hud']:sendNotification({
			type = 'ERROR',
			title = 'Sąskaitos',
			message = 'Deja, nebeturite daugiau jokių sąskaitų.',
			duration = 6000,
			icon = 'file-invoice'
		})
		opened = false
	end
end

RegisterCommand('showbills', function()
	if not isDead and not mokama and not opened then
		local invoices = lib.callback.await('esx_billing:getBills', false)
		ShowBillsMenu(invoices)
	end
end, false)

RegisterKeyMapping('showbills', _U('keymap_showbills'), 'keyboard', 'F7')

AddEventHandler('esx:onPlayerDeath', function() isDead = true end)
AddEventHandler('esx:onPlayerSpawn', function(spawn) isDead = false end)
