local Camera, currentVeh, LockMenu = nil, nil, false

Garage = {}

Garage.Vehicles = {}

local function CreateCamera(heading, distance)
    if not Camera and currentVeh then
        local forward = GetOffsetFromEntityInWorldCoords(currentVeh, -0.0, distance, 0.0)

        Camera = CreateCam("DEFAULT_SCRIPTED_CAMERA", true)
        RenderScriptCams(true, true, 500, 1, 0)
        SetCamActive(Camera, true)
        SetCamRot(Camera, -3.0, 0.0, heading - 180)
        SetCamFov(Camera, 60.0)
        SetCamCoord(Camera, forward.x, forward.y, forward.z + 0.5)
    end
end

local function ClearCamera()
    if Camera then
        DestroyCam(Camera)
        RenderScriptCams(false, true, 500, 1, 0)
        Camera = nil
    end
end

local function EditCamera(heading, distance)
    if Camera then
        local forward = GetOffsetFromEntityInWorldCoords(currentVeh, -0.0, distance, 0.0)
        SetCamRot(Camera, -3.0, 0.0, heading - 180)
        SetCamFov(Camera, 60.0)
        SetCamCoord(Camera, forward.x, forward.y, forward.z + 0.5)
    end
end

local function SpawnPreview(model, coords)
    if LockMenu then return end
    LockMenu = true
    local distance = 8.0

	local heading = coords.w 
	local coords = vec3(coords.x, coords.y, coords.z)

    if currentVeh or DoesEntityExist(currentVeh) then
        ESX.Game.DeleteVehicle(currentVeh)
    end

    if not lib.requestModel(model, 600000) then
        lib.showContext('jobgarage:shop')
        LockMenu = false
        return
    end

    ESX.Game.SpawnLocalVehicle(model, coords, heading, function(vehicle) 
        currentVeh = vehicle
        while not DoesEntityExist(currentVeh) do 
            LockMenu = true
            lib.showTextUI('Palaukite, kol automobilis bus užkrautas', {
                position = 'top-center',
                icon = 'fa-solid fa-car',
                iconColor = '#3E81FF',
            })
            Wait(100)
        end
        if LockMenu then 
            if lib.getOpenContextMenu() ~= 'jobgarage:showveh' then 
                lib.hideContext(false)
                lib.showContext('jobgarage:showveh')
            end
        end
        LockMenu = false
        lib.hideTextUI()
        SetEntityCoords(currentVeh, coords, false, false, false, false)
        PlaceObjectOnGroundProperly(currentVeh)
        FreezeEntityPosition(currentVeh, true)
        SetEntityCollision(currentVeh, false)
        SetVehicleEngineOn(currentVeh, true, true, true)
        SetVehicleLights(currentVeh, 2)

        CreateCamera(heading, distance)
        EditCamera(heading, distance)
    end)
end

local function CloseMenu(onExit)
    if currentVeh or DoesEntityExist(currentVeh) then
        ESX.Game.DeleteVehicle(currentVeh)
    end

    ClearCamera()
end

function Garage.OpenMenu(data)
	lib.registerContext({
		id = 'jobgarage:main',
		title = 'Darbo garažas',
		options = {
			{
				title = 'Atidaryti garažą',
				description = 'Peržiūrėkite savo turimas transporto priemones',
				icon = 'warehouse',
				onSelect = function()
					Garage.OpenGarage(data.type, data.spawns)
				end,
			},
			{
				title = 'Pastatyti automobilį',
				description = 'Pastatykite savo transporto priemonę į garažą',
				icon = 'eraser',
				onSelect = function()
					Garage.StoreVehicle()
				end,
			},
			{
				title = 'Nusipirkti darbinę tr. priemonę',
				description = 'Nusipirkite naują darbinę tr. priemonę.',
				icon = 'cart-shopping',
				onSelect = function()
					Garage.OpenShop(data.type, data.coords, data.vehicles)
				end,
			},
		}
	})

	lib.showContext('jobgarage:main')
end

function Garage.OpenShop(type, coords, vehicles)
	if not vehicles or #vehicles == 0 then return lib.showContext('jobgarage:main') end 

	local Options = {}

	for _, vehicle in ipairs(vehicles) do
		if IsModelValid(vehicle.model) and IsModelInCdimage(vehicle.model) then
			local vehicleLabel = GetDisplayNameFromVehicleModel(vehicle.model)

			table.insert(Options, {
				title = vehicleLabel,
				description = 'Tr. priemonės kaina '..vehicle.price..'€.',
				icon = type,
				onSelect = function()
					lib.registerContext({
						id = 'jobgarage:showveh',
						menu = 'jobgarage:shop',
						title = vehicleLabel,
						options = {
							{
								title = 'Pirkti '..vehicleLabel,
								description = 'Pirkti '..vehicleLabel..' tr. priemonę už '..vehicle.price..'€.',
								icon = 'cart-shopping',
								onSelect = function()
									local alert = lib.alertDialog({
										header = 'Ar esate tuom tikras?',
										content = 'Ar tikrai norite pirkti '..vehicleLabel..' už '..vehicle.price..'€.',
										centered = true,
										cancel = true
									})

									lib.showContext('jobgarage:shop')

									if alert == 'confirm' then
										if not currentVeh then return end 
										local props = exports['dec4t-garagev3']:GetVehicleProperties(currentVeh)
										props.plate = exports['dec4t-vehicleshop']:generatePlate('Land')
										
										if not props.plate then
											exports['onex-hud']:advancedNotification({
												title = 'Darbinis garažas',
												message = 'Įvyko klaida bandant įsigyti t. priemonę, bandykite išnaujo.',
												duration = 5000,
												icon = 'warehouse'
											})
										end

										local data = lib.callback.await('dec4t-jobgarage:buyvehicle', false, {vehicle = vehicle, type = type, props = props})
										if data then
											exports['onex-hud']:advancedNotification({
												title = 'Darbinis garažas',
												message = string.format('Sėkmingai nusipirkote automobilį su numeriais %s.', data),
												duration = 5000,
												icon = 'warehouse'
											})
										else
											exports['onex-hud']:advancedNotification({
												title = 'Darbinis garažas',
												message = 'Deja, neturite pakankamai pinigų nusipirkti šiai tr. priemonei',
												duration = 5000,
												icon = 'warehouse'
											})
										end								
									end
								end,
							},
						},
						onExit = function()
							CloseMenu(true)
						end,
						onBack = function()
							CloseMenu(true)
						end,
					})
					lib.showContext('jobgarage:showveh')
					SpawnPreview(vehicle.model, coords)
				end,
			})
		end
	end

	if #Options > 0 then
		lib.registerContext({
			id = 'jobgarage:shop',
			title = 'Tr. priemonių parduotuvė',
			menu = 'jobgarage:main',
			options = Options,
			onExit = function()
				CloseMenu(true)
			end,
			onBack = function()
				CloseMenu(true)
			end,
		})
	
		lib.showContext('jobgarage:shop')
	else
		lib.showContext('jobgarage:main')
	end
end

function Garage.OpenGarage(type, spawns)
	local vehicles = lib.callback.await('dec4t-jobgarages:returnJobVeh', false, type)

	if not vehicles then
		exports['onex-hud']:advancedNotification({
			title = 'Darbinis garažas',
			message = 'Deja, neturite jokių automobilių darbiniame garaže.',
			duration = 6000,
			icon = 'warehouse'
		})
		return
	end

	local Options = {}
	for _, vehicle in pairs(vehicles) do 
		local props = json.decode(vehicle.vehicle)
		if IsModelValid(props.model) and IsModelInCdimage(props.model) then
			local vehicleLabel = GetDisplayNameFromVehicleModel(props.model)
			table.insert(Options, {
				title = vehicleLabel,
				description = 'Išsitraukite '..vehicleLabel..' tr. priemonę. Numeriai: '..props.plate,
				icon = (type == 'car' and 'car' or 'helicopter'),
				onSelect = function()
					for _, v in pairs(spawns) do 
						if not IsAnyVehicleNearPoint(v.coords.x, v.coords.y, v.coords.z, v.radius) then
							DoScreenFadeOut(0)
							local netid = lib.callback.await('dec4t-jobgarages:spawnVehicle', false, type, props.plate, v.coords)
							if not netid then
								DoScreenFadeIn(0)
								return
							end

							local veh = NetworkGetEntityFromNetworkId(netid)
							while not DoesEntityExist(veh) do
								veh = NetworkGetEntityFromNetworkId(netid)
								Wait(100)
							end

							SetVehicleNumberPlateText(veh, props.plate)

							while GetVehiclePedIsIn(cache.ped, false) ~= veh do
								Wait(100)
							end

							SetTimeout(1000, function()
								SetVehicleOnGroundProperly(veh)
								SetEntityCollision(veh, true, true)
								FreezeEntityPosition(veh, false)
								SetEntityVisible(veh, true, false)

								DoScreenFadeIn(0)

								table.insert(Garage.Vehicles, NetworkGetNetworkIdFromEntity(veh))
							end)
							break
						end
					end
				end,
			})
		end
	end

	if #Options > 0 then
		lib.registerContext({
			id = 'jobgarage:garage',
			title = 'Tr. priemonių parduotuvė',
			menu = 'jobgarage:main',
			options = Options
		})
	
		lib.showContext('jobgarage:garage')
	else
		lib.showContext('jobgarage:main')
	end
end

function Garage.StoreVehicle()
	if #Garage.Vehicles < 1 then
		exports['onex-hud']:advancedNotification({
			title = 'Garažas',
			message = 'Deja, nesate ištraukęs jokių automobilių.',
			duration = 6000,
			icon = 'warehouse'
		})
		return
	end

	local Deleted = 0
	local ToDelete = {}
	local coords = GetEntityCoords(cache.ped)
	for k, vehicle in pairs(Garage.Vehicles) do 
		vehicle = NetworkGetEntityFromNetworkId(vehicle)
		if DoesEntityExist(vehicle) then
			if #(coords - GetEntityCoords(vehicle)) <= 15.0 then
				TriggerServerEvent('dec4t-jobgarages:deleteveh', NetworkGetNetworkIdFromEntity(vehicle))
				Deleted += 1
			end
		else 
			table.insert(ToDelete, k)
		end
	end

	for _, v in pairs(ToDelete) do 
		table.remove(Garage.Vehicles, v)
	end

	if Deleted > 0 then
		exports['onex-hud']:advancedNotification({
			title = 'Garažas',
			message = 'Sėkmingai pastatėte jūsų ištrauktus automobilius.',
			duration = 6000,
			icon = 'warehouse'
		})
	else
		exports['onex-hud']:advancedNotification({
			title = 'Garažas',
			message = 'Deja, nėra jokių automobilių esančių šalia jūsų, kuriuos būtumėte ištraukęs.',
			duration = 6000,
			icon = 'warehouse'
		})
	end
end

exports('initGarages', function()
	return Garage
end)