local Target = exports.ox_target

local currPed
local function createPed(model, coords, heading, animDict, animName)
	lib.requestModel(model)

    local ped = CreatePed(5, model, coords.x, coords.y, coords.z, heading, false, true)
	SetModelAsNoLongerNeeded(model)

	FreezeEntityPosition(ped, true)
	SetEntityInvincible(ped, true)
	SetBlockingOfNonTemporaryEvents(ped, true)
	NetworkFadeInEntity(ped, false)

	lib.RequestAnimDict(animDict)
	TaskPlayAnim(ped, animDict, animName, 8.0, 1.0, -1, 17, 0, false, false, false)

	Target:addLocalEntity(ped, {
		{
			label = 'Atsiimti algą',
			icon = 'fa-solid fa-receipt',
			distance = 2.0,
			onSelect = function()
				local paycheck = lib.callback.await('paycheck:getMoney', false)

				lib.registerContext({
					id = 'paycheck',
					title = 'Algos atsiėmimas',
					options = {
						{
							title = ('Jūs turima alga fonde %d€.'):format(paycheck),
							description = 'Paspauskite, kad atsiimtumėte algą.',
							icon = 'fa-solid fa-receipt',
							onSelect = function()
								local success = lib.progressCircle({
									duration = 5000,
									label = 'Gryninami pinigai...',
									position = 'bottom',
									useWhileDead = false,
									canCancel = true,
									disable = {
										move = true,
										combat = true,
										sprint = true,
									},
									anim = {
										scenario = 'WORLD_HUMAN_CLIPBOARD',
										clip = 'idle_a'
									},
								})

								if not success then return end
								lib.callback.await('paycheck:payout', false)
							end,
						}
					}
				})

				lib.showContext('paycheck')
			end
		}
	})

	currPed = ped
end

CreateThread(function()
	while not ESX.IsPlayerLoaded() do Wait(500) end

	for _, v in pairs(Config.NPCS) do
		lib.points.new({
			coords = v.coords,
			distance = 15.0,
			onEnter = function ()
				createPed(v.model, v.coords, v.heading, v.animDict, v.animName)
			end,
			onExit = function()
				if currPed then
					DeleteEntity(currPed)
					currPed = nil
				end
			end
		})
	end
end)
