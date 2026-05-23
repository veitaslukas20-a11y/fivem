local Inventory = exports.ox_inventory
local equiped, oxygen, pressure = false, 100, 0

local safeDepth = -20.0
local maxDepth = -160.0

function OnEquip()
	Citizen.CreateThread(function()
		while equiped do
			if IsPedSwimming(cache.ped) or IsPedSwimmingUnderWater(cache.ped) then
				local currentDepth = GetEntityCoords(cache.ped).z

				if currentDepth < safeDepth then
					pressure = ((currentDepth - safeDepth) / (maxDepth - safeDepth)) * 100
					pressure = math.max(0, math.min(pressure, 100))
				else
					pressure = 0
				end

				oxygen -= 1

				lib.showTextUI(('Slėgis: %.1f%% Deguonis: %.1f%%'):format(pressure, oxygen / 6), {
					icon = 'water-ladder',
					position = 'bottom-center'
				})

				if oxygen <= 0 then
					equiped = false
				end
			else
				equiped = false
			end
			Wait(1000)
		end

		lib.hideTextUI()
		SetEnableScuba(cache.ped,false)
		SetPedMaxTimeUnderwater(cache.ped, 10.00)
		SetEnableScubaGearLight(cache.ped, false)

		TriggerEvent('skinchanger:getSkin', function(skin)
			ESX.TriggerServerCallback('esx_skin:getPlayerSkin', function(skin, hasSkin)
				if hasSkin then
					TriggerEvent('skinchanger:loadSkin', skin)
					TriggerEvent('esx:restoreLoadout')
				end
			end)
		end)
	end)
end

function ChangeOutfit()
	TriggerEvent('skinchanger:getSkin', function(skin)
		SetEnableScuba(cache.ped,true)
		SetPedMaxTimeUnderwater(cache.ped, 1500.00)
		SetEnableScubaGearLight(cache.ped, true)

		equiped = true
		oxygen = 300

		if skin.sex == 0 then
			local clothesSkin = {
				['tshirt_1'] = 261, ['tshirt_2'] = 0,
			}
			TriggerEvent('skinchanger:loadClothes', skin, clothesSkin)
		else
			local clothesSkin = {
				['tshirt_1'] = 153, ['tshirt_2'] = 0,
			}
			TriggerEvent('skinchanger:loadClothes', skin, clothesSkin)
		end

		OnEquip()
	end)
end

function PlayLoading()
	return lib.progressBar({
		duration = 5000,
		label = 'Užsidedate nardymo įrangą...',
		useWhileDead = false,
		allowSwimming = true,
		canCancel = false,
		disable = {
			car = true,
			move = true,
			combat = true,
		},
		anim = {
			dict = 'clothingshirt',
			clip = 'try_shirt_positive_d'
		},
	})
end

exports('oxtankas', function(data, slot)
	if equiped or (not IsPedSwimming(cache.ped) and not IsPedSwimmingUnderWater(cache.ped)) then
		exports['1x-hud']:sendNotification({
			type = 'ERROR',
			title = 'Nardymas',
			message = 'Jau esate užsidėjęs kostiumą, arba nesate vandenyje.',
			duration = 5000,
		})
		return
	end

	if not PlayLoading() then return end

	Inventory:useItem(data, function(data)
		if data then
			ChangeOutfit()
		end
	end)
end)
