local Vehicles, Identifier = {}, nil
local Target = exports.ox_target

local function currency(n)
    return tostring(math.floor(n)):reverse():gsub("(%d%d%d)","%1,"):gsub(",(%-?)$","%1"):reverse()..' €'
end

local function GetVehicleModPers(vehicle, mod)
    local count = GetNumVehicleMods(vehicle, mod)
    local modCount = (GetVehicleMod(vehicle, mod) + 1)
    return (count > 0 and modCount > 0) and ((modCount / count) * 100) or 0
end

local function OpenInfo(data)
    lib.registerContext({
        id = 's1m1s_autoinfo',
        title = 'Automobilio informacija',
        options = {
            {
                title = 'Pops&Bangs',
                description = 'Pops&Bangs - Išskirtinis automobilio garso efektas',
                progress = data.chip and 100 or 0,
            },
            {
                title = 'Variklis',
                description = 'Variklio galingumo lygis',
                progress = GetVehicleModPers(data.spawned, 11) or 0,
            },
            {
                title = 'Stabdžiai',
                description = 'Stabdžių galingumo lygis',
                progress = GetVehicleModPers(data.spawned, 12) or 0,
            },
            {
                title = 'Turbina',
                description = 'Turbinos galingumo lygis',
                progress = IsToggleModOn(data.spawned, 18) and 100 or 0,
            },
            {
                title = 'Pavarų dėžė',
                description = 'Pavarų dėžės galingumo lygis',
                progress = GetVehicleModPers(data.spawned, 13) or 0,
            },
            {
                title = 'Pakabos nuleidimas',
                description = 'Pakabos nuleidimo lygis',
                progress = GetVehicleModPers(data.spawned, 15) or 0,
            },
            {
                title = 'Automobilio apsauga',
                description = 'Automobilio apsauga lygis',
                progress = GetVehicleModPers(data.spawned, 16) or 0,
            },
            {
                title = 'Automobilio kaina',
                description = 'Automobilio kaina '..currency(data.price or 0),
            },
            {
                title = 'Savininko numeris',
                description = 'Telefono numeris: '..data.phone..'. Paspauskite, kad nukopijuotumėte telefono numerį.',
                onSelect = function()
                    lib.setClipboard(data.phone)
                end
            },
        }
    })
    lib.showContext('s1m1s_autoinfo')
end

local function OpenBuyMenu(data)
    lib.registerContext({
        id = 's1m1s_autoinfo2',
        title = 'Automobilio informacija',
        options = {
            {
                title = 'Pirkti automobilį',
                description = 'Pirkti ši automobilį už '..currency(data.price),
                onSelect = function()
                    lib.callback.await('s1m1s-aturgus:buyVehicle', false, data)
                end,
            },
        }
    })
    lib.showContext('s1m1s_autoinfo2')
end

local function openVehicleTesting(data)
    local alert = lib.alertDialog({
        header = 'Automobilio testavimas',
        content = 'Ar tikrai norite testuoti šį automobilį?',
        centered = true,
        cancel = true
    })
    if alert ~= 'confirm' then return end

    ExecuteVehicleTesting(data)
end

local function CreateLocalVehicle(id, data)
    local coords = s1m1s_autoturgus.Slots[id]

    if type(data.vehicle) == 'string' then
        data.vehicle = json.decode(data.vehicle)
    end

    local vehicle = lib.getClosestVehicle(vec3(coords), 2.0, false)
    if vehicle then
        TriggerServerEvent('s1m1s-aturgus:deleteVehicle', NetworkGetNetworkIdFromEntity(vehicle))
    end

    local locData = data.vehicle
    local model = locData.model
    if not IsModelValid(model) and not IsModelInCdimage(model) then
        return
    end
    lib.requestModel(model, 15000)

    local localVeh = CreateVehicle(model, coords.x, coords.y, coords.z, coords.w, false, true)
    while not DoesEntityExist(localVeh) do
        Wait(100)
    end

    local vehData = Vehicles[id]
    vehData.spawned = localVeh
    vehData.chip = (data.lambrachip == 'tunerchip3')

    exports['s1m1s-garagev3']:SetVehicleProperties(localVeh, locData)

    SetVehicleNumberPlateText(localVeh, locData.plate)
    FreezeEntityPosition(localVeh, true)

    if data.owner ~= Identifier then
        Target:addLocalEntity(localVeh, {
            {
                icon = "fa-solid fa-circle-info",
                label = "Automobilio informacija",
                distance = 2.0,
                onSelect = function()
                    OpenInfo(vehData)
                end
            },
            {
                icon = "fa-solid fa-money-bill-transfer",
                label = "Pirkti automobilį",
                distance = 2.0,
                onSelect = function()
                    OpenBuyMenu(vehData)
                end
            },
            {
                icon = "fa-solid fa-car-side",
                label = "Testuoti automobilį",
                distance = 2.0,
                onSelect = function()
                    openVehicleTesting(vehData)
                end
            },
        })
    else
        Target:addLocalEntity(localVeh, {
            {
                icon = "fa-solid fa-circle-info",
                label = "Automobilio informacija",
                distance = 2.0,
                onSelect = function()
                    OpenInfo(vehData)
                end
            },
            {
                icon = "fa-solid fa-money-bill-transfer",
                label = "Išimti automobilį iš turgaus",
                distance = 2.0,
                onSelect = function()
                    lib.callback.await('s1m1s-aturgus:takeOut', false, vehData)
                end
            },
        })
    end
end

local function Spawnvehicles()
    for k,v in pairs(Vehicles) do
        CreateLocalVehicle(k, v)
    end
end

local function DeleteVehicles()
    for _, vehicle in pairs(Vehicles) do
        if vehicle.spawned then
            DeleteEntity(vehicle.spawned)
            vehicle.spawned = nil
        end
    end
end

local function RefreshVehicles()
    DeleteVehicles()
    Wait(1000)
    Spawnvehicles()
end

local function DrawText3d(coords, text, height)
    local font = 4
    if height then _z = height + 1 else _z = 1 end
	coords = vector3(coords.x, coords.y, coords.z + _z)

	local camCoords = GetGameplayCamCoords()
	local distance = #(coords - camCoords)

	if not font then font = 0 end

	local scale = (1 / distance) * 2
	local fov = (1 / GetGameplayCamFov()) * 100
	scale = scale * fov

	SetTextScale(0.0 * scale, 0.55 * scale)
	SetTextFont(13)
	SetTextColour(255, 255, 255, 255)
	SetTextDropshadow(0, 0, 0, 0, 255)
	SetTextDropShadow()
	SetTextOutline()
	SetTextCentre(true)

	SetDrawOrigin(coords, 0)
	BeginTextCommandDisplayText('STRING')
	AddTextComponentSubstringPlayerName(text)
	EndTextCommandDisplayText(0.0, 0.0)
	ClearDrawOrigin()
end

local Spawned = false
Citizen.CreateThread(function()
    while not ESX.IsPlayerLoaded() do Wait(500) end

    Vehicles, Identifier = lib.callback.await('s1m1s-aturgus:GetVehicles', false)

    lib.points.new({
        coords = s1m1s_autoturgus.Coords,
        distance = 100,
        onEnter = function()
            if Spawned then return end
            Spawnvehicles()
            Spawned = true
        end,
        onExit = function()
            if not Spawned then return end
            DeleteVehicles()
            Spawned = false
        end
    })

    lib.points.new({
        coords = s1m1s_autoturgus.Coords,
        distance = 10,
        nearby = function(self)
            if cache.vehicle then
                DrawText3d(self.coords, '[E] Pastatyti automobilį į turgų')
            end
        end,
    })
end)

Citizen.CreateThread(function()
    local blip = AddBlipForCoord(s1m1s_autoturgus.Coords)
    SetBlipSprite(blip, 227)
    SetBlipColour(blip, 32)
    SetBlipScale(blip, 0.8)
    SetBlipAsShortRange(blip, true)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString('<font face="Roboto">Automobilių turgus</font>')
    EndTextCommandSetBlipName(blip)
end)

local function InteractSellVehicle(success, call)
    if success then
        TriggerServerEvent('s1m1s-aturgus:deleteVehicle', NetworkGetNetworkIdFromEntity(cache.vehicle))
    elseif not call then
        exports['1x-hud']:sendNotification({
            type = 'ERROR',
            title = 'Automobilių turgus',
            message = 'Deja, nebeužtenka vietos šioje aikštelėje. Arba jau esate pastatęs savo automobilį turguje.',
            duration = 6000,
            icon = 'car'
        })
        return
    else
        exports['1x-hud']:sendNotification({
            type = 'ERROR',
            title = 'Automobilių turgus',
            message = 'Deja, automobilis nepriklauso jums.',
            duration = 6000,
            icon = 'car'
        })

        local playerInfo = exports['cd_dispatch']:GetPlayerInfo()
        TriggerServerEvent('cd_dispatch:AddNotification', {
            job_table = {'police'},
            coords = playerInfo.coords,
            title = '10-88 - Bandymas parduoti tr. priemonę be savininko leidimo',
            message = 'Asmuo kurio lytis ( '..playerInfo.sex..' ) bandė parduoti tr. priemonę be savininko leidimo '..playerInfo.street.. ' gatvėje. T.y automobilių turgus',
            flash = 0,
            unique_id = playerInfo.unique_id,
            sound = 2,
            blip = {
                sprite = 431,
                scale = 1.2,
                colour = 3,
                flashes = true,
                text = '<font face="Roboto">10-88 - Bandymas parduoti vogtą tr. priemonę</font>',
                time = 5,
                radius = 0,
            }
        })
    end
end

local function SellVehicle()
    local marketData = lib.callback.await('s1m1s-aturgus:getMarketData', false)
    local options = {}

    for _, data in pairs(marketData) do
        local days = data.hours / 24
        local daysText = ""

        if days == 1 then
            daysText = "dieną"
        elseif days > 1 and days < 10 then
            daysText = "dienas"
        elseif days < 1 then
            daysText = "dienos"
        else
            daysText = "dienų"
        end

        local formattedDays = string.format("%.2f", days)

        table.insert(options, {
            title = ('Pastatyti automobilį į turgų %d valandoms (%s %s)'):format(data.hours, formattedDays, daysText),
            description = ('Pastatyti automobilį į turgų %d valandoms (%s %s) už %d€'):format(data.hours, formattedDays, daysText, data.price),
            icon = "fa-solid fa-calendar-days",
            onSelect = function()
                if not cache.vehicle then return end
                local properties = exports['s1m1s-garagev3']:GetVehicleProperties(cache.vehicle) or {}

                local input = lib.inputDialog('Automobilio kaina', {'Įveskite kainą'})
                if not input then return end
                properties.price = input[1]

                local alert = lib.alertDialog({
                    header = 'Automobilių turgus',
                    content = ('Ar tikrai norite pastatyti automobilį į turgų %d valandoms (%s %s) sumokėdamas %d€. Jūsų nustatyta automobilio kaina %s.'):format(data.hours, formattedDays, daysText, data.price, currency(properties.price)),
                    centered = true,
                    cancel = true
                })

                if alert ~= 'confirm' then return end

                local success, call = lib.callback.await('s1m1s-aturgus:sellVehicle', false, data.id, properties)

                InteractSellVehicle(success, call)
            end
        })
    end

    lib.registerContext({
        id = 's1m1s_autoinfo2',
        title = 'Automobilių turgus',
        options = options
    })

    lib.showContext('s1m1s_autoinfo2')
end

lib.addKeybind({
    name = 'sellVehicleDC',
    description = 'Pastatyti automobili i auto turgu',
    defaultKey = 'E',
    onPressed = function(self)
        if not cache.coords then return end
        if #(cache.coords - s1m1s_autoturgus.Coords) > 3.0 then return end
        if GetVehicleClass(cache.vehicle) == 18 then return end
        SellVehicle()
    end,
})

local jobPoint, isInPoint = nil, false
local function initJobMenu()
    jobPoint = lib.points.new({
        coords = s1m1s_autoturgus.BossMenu,
        distance = 5,
        onEnter = function ()
            isInPoint = true
        end,
        onExit = function ()
            isInPoint = false
        end,
        nearby = function(self)
            DrawMarker(22, self.coords.x, self.coords.y, self.coords.z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0, 1.0, 1.0, 50, 50, 204, 100, false, true, 2, true, nil, nil, false)
        end
    })
end

local function openEditMenu()
    local marketData = lib.callback.await('s1m1s-aturgus:getMarketData', false)
    local options = {
        {
            title = 'Pridėti naują pasirinkimą',
            description = 'Pridėkite naują stovėjimo laiko ir kainos pasirinkimą',
            icon = "fa-solid fa-plus",
            onSelect = function()
                local input = lib.inputDialog('Nustatyti parametrus', {
                    {type = 'number', label = 'Stovėjimo laikas valandomis', description = 'Įveskite norimą stovėjimo laiką valandomis', required = true, icon = 'fa-solid fa-clock'},
                    {type = 'number', label = 'Stovėjimo kaina', description = 'Įveskite norimą stovėjimo kainą', required = true, icon = 'fa-solid fa-coins'},
                })

                if not input or not input[1] or not input[2] then return lib.showContext('vehiclemarket_edit') end
                TriggerServerEvent('s1m1s-aturgus:addData', input[1], input[2])
                openEditMenu()
            end
        }
    }

    for _, data in pairs(marketData) do
        local days = data.hours / 24
        local daysText = ""

        if days == 1 then
            daysText = "dieną"
        elseif days > 1 and days < 10 then
            daysText = "dienas"
        elseif days < 1 then
            daysText = "dienos"
        else
            daysText = "dienų"
        end

        local formattedDays = string.format("%.2f", days)

        table.insert(options, {
            title = ('Automobilio stovėjimo laikas %d valandoms (%s %s)'):format(data.hours, formattedDays, daysText),
            description = ('Automobilio stovėjimo laikas %d valandoms (%s %s). Kaina %d€'):format(data.hours, formattedDays, daysText, data.price),
            icon = "fa-solid fa-pencil",
            onSelect = function()
                local input = lib.inputDialog('Pakeisti parametrus', {
                    {type = 'number', label = 'Stovėjimo laikas valandomis', description = 'Įveskite norimą stovėjimo laiką valandomis', required = true, icon = 'fa-solid fa-clock', default = data.hours},
                    {type = 'number', label = 'Stovėjimo kaina', description = 'Įveskite norimą stovėjimo kainą', required = true, icon = 'fa-solid fa-coins', default = data.price},
                    {type = 'checkbox', label = 'Panaikinti šį pasirinkimą', required = false, checked = false,},
                })

                if not input or not input[1] or not input[2] then return lib.showContext('vehiclemarket_edit') end
                TriggerServerEvent('s1m1s-aturgus:changeData', data.id, input[1], input[2], input[3])
                lib.showContext('vehiclemarket_edit')
            end
        })
    end

    lib.registerContext({
        id = 'vehiclemarket_edit',
        menu = 'vehiclemarket_boss',
        title = 'Automobilių turgaus įkainiai',
        options = options
    })

    lib.showContext('vehiclemarket_edit')
end

lib.addKeybind({
    name = 'openVehicleMarketBossMenu',
    description = 'Atidaryti boso meniu',
    defaultKey = 'E',
    onPressed = function(self)
        if not cache.coords then return end
        if #(cache.coords - s1m1s_autoturgus.BossMenu) > 3.0 or not isInPoint then return end

        local money = lib.callback.await('d-bossmenu:getAccountMoney', false, 'vehiclemarket')

        lib.registerContext({
            id = 'vehiclemarket_boss',
            title = 'Automobilių turgus',
            options = {
                {
                    title = 'Išimti iš fondo',
                    description = 'Išimti pinigus iš fondo',
                    icon = 'fa-solid fa-money-bill-transfer',
                    metadata = {
                        {label = 'Fondo pajamos', value = ESX.Math.GroupDigits(money)..'€'},
                    },
                    onSelect = function()
                        local input = lib.inputDialog('Išimti pinigus iš fondo', {
                            {type = 'number', label = 'Pinigų suma', description = 'Įveskite norimą pinigų sumą, kurią išimsite iš fondo', required = true, icon = 'fa-solid fa-money-bill-transfer'},
                            {type = 'select', label = 'Sąskaita į kur pervesti pinigus', description = 'Pasirinkite grynais ar pavedimu', required = true, options = {
                                {value = 'money', label = 'Grynaisiais'},
                                {value = 'bank', label = 'Pavedimu (banku)'},
                            }, default = 'money'},
                        })

                        if not input or not input[1] or not input[2] then return lib.showContext('vehiclemarket_boss') end
                        lib.callback.await('d-bosmenu:takeMoney', false, input[1], input[2])
                        lib.showContext('vehiclemarket_boss')
                    end,
                },
                {
                    title = 'Koreguoti įkainius',
                    description = 'Koreguoti įkainius už stovėjimą auto aikštelėje',
                    icon = 'fa-solid fa-pencil',
                    onSelect = function()
                        openEditMenu()
                    end,
                },
            }
        })

        lib.showContext('vehiclemarket_boss')
    end,
})

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(xPlayer)
	if xPlayer.job.name == 'vehiclemarket' then
		initJobMenu()
	end
end)

RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job)
	if job.name == 'vehiclemarket' then
		if not jobPoint then initJobMenu() end
	else
		if jobPoint then jobPoint:remove() end
	end
end)

RegisterNetEvent('s1m1s-aturgus:takeoutVehicle', function(plate)
    if Spawned then
        DeleteVehicles()
    end

    for k,v in pairs(Vehicles) do
        if v.plate == plate then
            table.remove(Vehicles, k)
        end
    end

    if Spawned then
        Spawnvehicles()
    end
end)

RegisterNetEvent('s1m1s-aturgus:insertVehicle', function(vehicle)
    table.insert(Vehicles, vehicle)

    if Spawned then
        RefreshVehicles()
    end
end)

AddEventHandler('onResourceStop', function(resourceName)
    if (GetCurrentResourceName() == resourceName) then
        DeleteVehicles()
    end
end)