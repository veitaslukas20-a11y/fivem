local Licenses = {}

local Config = {
    coords = {
        --vec3(-146.3080, 6303.5127, 31.5584),
        vec3(215.8357, -1389.8623, 30.5875)
    },
    spawnpoints = {
        --[[Paleto = {
            vec4(-163.5696, 6303.0791, 31.2012, 38.8363),
            vec4(-164.5130, 6288.2188, 31.4894, 43.7856),
            vec4(-139.2482, 6313.2480, 31.5325, 318.0649),
            vec4(-137.3006, 6310.5884, 31.5144, 316.1328),
            vec4(-140.6109, 6273.7920, 31.3393, 223.2102),
            vec4(-137.9232, 6276.2656, 31.3434, 219.5324),
            vec4(-135.5691, 6278.6064, 31.3468, 228.8149),
            vec4(-133.3684, 6281.0518, 31.3497, 230.8913),
            vec4(-131.0105, 6283.6523, 31.3528, 247.6593),
        },]]
        LosSantos = {
            vec4(224.9563, -1358.5391, 30.5575, 142.0037),
        },
        LosSantos2 = {
            vec4(222.4088, -1387.9813, 30.5421, 269.3538),
            vec4(218.8602, -1384.5022, 30.5715, 267.7627),
            vec4(216.1104, -1381.1890, 30.5656, 261.1279),
            vec4(214.2281, -1362.9904, 30.5869, 224.4986),
            vec4(216.4411, -1360.1274, 30.5858, 233.8289),
            vec4(218.8718, -1357.6893, 30.5875, 224.8953),
            vec4(220.9284, -1355.1138, 30.5875, 253.5132),
            vec4(223.1053, -1352.3795, 30.5867, 246.7294),
            vec4(237.3639, -1412.1477, 30.5850, 328.8419),
            vec4(240.5156, -1413.9406, 30.5855, 324.5554),
            vec4(243.5689, -1415.6133, 30.5859, 322.9464)
        },
    },
    ped = {
        --[[{
            coords = vec4(-146.3080, 6303.5127, 31.5584, 318.4523),
            register = nil,
        },]]
        {
            coords = vec4(215.8357, -1389.8623, 30.5875, 326.2267),
            register = nil,
        },
    },
    Vehicles = {
        ['A'] = `bati`,
        ['B'] = `blista`,
        ['C1'] = `mule`,
        ['CE'] = `phantom`,
        ['D'] = `coach`,
    },
    Blip = nil,
    BlipCoords = vec3(0,0,0),
    Laiko = vec3(0,0,0),
}

RegisterNUICallback('interact', function(data)
    local Coords = GetEntityCoords(PlayerPedId())
    --[[local Place = 1
    for i=1, #Config.coords do 
        if #(Config.coords[i] - Coords) <= 20.0 then
            if i == 2 then Place = 2 end
            break
        end
    end]]
    if data.type == 'Theory' then 
        ESX.TriggerServerCallback('d-regitra:removeMoney', function(can)
            if can then
                SendNUIMessage({
                    show = true,
                    action = 'theory',
                })
                SetNuiFocus(true, true)
            else
                SendNUIMessage({
                    show = false,
                })
                SetNuiFocus(false, false)
                exports['1x-hud']:sendNotification({
                    type = 'ERROR',
                    title = 'Regitra',
                    message = 'Deja, neturite pinigų, kad galėtumėte laikyti šį egzaminą. Pinigus būtina turėti banko sąskaitoje.',
                    duration = 6000,
                    icon = 'book'
                })
                
            end
        end, 'theory')
    --elseif data.type == 'A' and Place == 1 then 
    elseif data.type == 'A' then 
        ESX.TriggerServerCallback('d-regitra:removeMoney', function(can)
            if can then
                SendNUIMessage({
                    show = false,
                })
                SetNuiFocus(false, false)
                Egzaminas('A')
            else
                SendNUIMessage({
                    show = false,
                })
                SetNuiFocus(false, false)
                exports['1x-hud']:sendNotification({
                    type = 'ERROR',
                    title = 'Regitra',
                    message = 'Deja, neturite pinigų, kad galėtumėte laikyti šį egzaminą. Pinigus būtina turėti banko sąskaitoje.',
                    duration = 6000,
                    icon = 'book'
                })
                
            end
        end, 'A')
    --elseif data.type == 'B' and Place == 1 then 
    elseif data.type == 'B' then 
        ESX.TriggerServerCallback('d-regitra:removeMoney', function(can)
            if can then
                SendNUIMessage({
                    show = false,
                })
                SetNuiFocus(false, false)
                Egzaminas('B')
            else
                SendNUIMessage({
                    show = false,
                })
                SetNuiFocus(false, false)
                exports['1x-hud']:sendNotification({
                    type = 'ERROR',
                    title = 'Regitra',
                    message = 'Deja, neturite pinigų, kad galėtumėte laikyti šį egzaminą. Pinigus būtina turėti banko sąskaitoje.',
                    duration = 6000,
                    icon = 'book'
                })
                
            end
        end, 'B')
    --elseif data.type == 'C1' and Place == 1 then 
    elseif data.type == 'C1' then 
        ESX.TriggerServerCallback('d-regitra:removeMoney', function(can)
            if can then
                SendNUIMessage({
                    show = false,
                })
                SetNuiFocus(false, false)
                Egzaminas('C1')
            else
                SendNUIMessage({
                    show = false,
                })
                SetNuiFocus(false, false)
                exports['1x-hud']:sendNotification({
                    type = 'ERROR',
                    title = 'Regitra',
                    message = 'Deja, neturite pinigų, kad galėtumėte laikyti šį egzaminą. Pinigus būtina turėti banko sąskaitoje.',
                    duration = 6000,
                    icon = 'book'
                })
                
            end
        end, 'C1')
    --elseif data.type == 'CE' and Place == 2 then 
    elseif data.type == 'CE' then 
        ESX.TriggerServerCallback('d-regitra:removeMoney', function(can)
            if can then
                SendNUIMessage({
                    show = false,
                })
                SetNuiFocus(false, false)
                Egzaminas('CE')
            else
                SendNUIMessage({
                    show = false,
                })
                SetNuiFocus(false, false)
                exports['1x-hud']:sendNotification({
                    type = 'ERROR',
                    title = 'Regitra',
                    message = 'Deja, neturite pinigų, kad galėtumėte laikyti šį egzaminą. Pinigus būtina turėti banko sąskaitoje.',
                    duration = 6000,
                    icon = 'book'
                })
                
            end
        end, 'CE')
    --elseif data.type == 'D' and Place == 2 then 
    elseif data.type == 'D' then 
        ESX.TriggerServerCallback('d-regitra:removeMoney', function(can)
            if can then
                SendNUIMessage({
                    show = false,
                })
                SetNuiFocus(false, false)
                Egzaminas('D')
            else
                SendNUIMessage({
                    show = false,
                })
                SetNuiFocus(false, false)
                exports['1x-hud']:sendNotification({
                    type = 'ERROR',
                    title = 'Regitra',
                    message = 'Deja, neturite pinigų, kad galėtumėte laikyti šį egzaminą. Pinigus būtina turėti banko sąskaitoje.',
                    duration = 6000,
                    icon = 'book'
                })
                
            end
        end, 'D')
    end

    --[[if Place == 1 then 
        if data.type == 'CE' or data.type == 'D' then
            SetNuiFocus(false, false)
        end
    end
    if Place == 2 and data.type ~= 'CE' and data.type ~= 'D' then 
        SetNuiFocus(false, false)
    end]]
end)

RegisterNUICallback('theory', function(data)
    if data.done then 
        SendNUIMessage({
            show = false,
        })
        SetNuiFocus(false, false)
        ESX.TriggerServerCallback('d-regitra:giveLicense', function(can)
        end, 'Theory')
    else
        SendNUIMessage({
            show = false,
        })
        SetNuiFocus(false, false)
    end
end)

RegisterNUICallback('close', function()
    SendNUIMessage({
        show = false,
    })
    SetNuiFocus(false, false)
end)

RegisterNetEvent('d-regitra:open', function()
    local Coords = GetEntityCoords(PlayerPedId())
    for i=1, #Config.coords do 
        if #(Config.coords[i] - Coords) <= 20.0 then
            Config.Laiko = Config.coords[i]
            break
        end
    end

    ESX.TriggerServerCallback('d-regitra:checkLicense', function(licenses)
        Licenses = licenses
    end)
    Wait(500)
    local ownLicenses = {true, true, true, true, true, true}
    for i=1, #Licenses do
		if Licenses[i].type == 'dmv' then
            ownLicenses[1] = false
        elseif Licenses[i].type == 'B' then
            ownLicenses[2] = false
        elseif Licenses[i].type == 'A' then
            ownLicenses[3] = false
        elseif Licenses[i].type == 'C1' then
            ownLicenses[4] = false
        elseif Licenses[i].type == 'CE' then
            ownLicenses[5] = false
        elseif Licenses[i].type == 'D' then
            ownLicenses[6] = false
        end  
	end
    if ownLicenses[1] then 
        ownLicenses[2] = false
        ownLicenses[3] = false
        ownLicenses[4] = false
        ownLicenses[5] = false
        ownLicenses[6] = false
    end
    SendNUIMessage({
        show = true,
        Licenses = ownLicenses,
        action = '',
    })
    SetNuiFocus(true, true)
end)

Citizen.CreateThread(function()
    for i=1, #Config.coords do 
        Blip = AddBlipForCoord(Config.coords[i])
        SetBlipSprite(Blip, 545)
        SetBlipDisplay(Blip, 4)
        SetBlipScale(Blip, 0.7)
        SetBlipColour(Blip, 29)
        SetBlipAsShortRange(Blip, true)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString('Regitra')
        EndTextCommandSetBlipName(Blip)
    end
    
    while true do
        local Coords = GetEntityCoords(PlayerPedId())
        for i=1, #Config.coords do 
            if #(Config.coords[i] - Coords) <= 20.0 then
                CreateLocalPed(i)
            else
                if Config.ped[i].register then 
                    exports.qtarget:RemoveTargetEntity(Config.ped[i].register, {})
                    DeletePed(Config.ped[i].register)
                    Config.ped[i].register = nil
                end
            end
        end
        Wait(1000)
    end
end)

function CreateLocalPed(index)
    if not Config.ped[index].register then
        RequestModel(`u_m_o_finguru_01`)
        while not HasModelLoaded(`u_m_o_finguru_01`) do
            Wait(100)
        end
        Config.ped[index].register = CreatePed(4, `u_m_o_finguru_01`, Config.ped[index].coords.x, Config.ped[index].coords.y, Config.ped[index].coords.z -1.0, Config.ped[index].coords.w, false, true)
        FreezeEntityPosition(Config.ped[index].register, true)
        SetEntityInvincible(Config.ped[index].register, true)
        SetBlockingOfNonTemporaryEvents(Config.ped[index].register, true)
        NetworkFadeInEntity(Config.ped[index].register, true, true)
        --[[exports.ox_target:addLocalEntity(Config.ped.register, 
            {
                {
                    name = "d-regitra:open",
                    event = "d-regitra:open",
                    icon = "fa-solid fa-car-rear",
                    label = 'Kalbėtis su regitros instruktoriumi',
                    canInteract = function(entity, distance, coords, name, bone)
                        return distance <= 2.0
                    end
                },
            }
        )]]
        exports.qtarget:AddTargetEntity(Config.ped[index].register, {
            options = {
                {
                    event = "d-regitra:open",
                    icon = "fa-solid fa-car-rear",
                    label = "Kalbėtis su regitros instruktoriumi",
                },
            },
            distance = 2.0
        })
    end
end

local laiko = false
local klaidos = 0
local Route = {}
local Category = nil
function Egzaminas(category)
    klaidos = 0
    Category = category
    print(Category ~= 'CE' or Category ~= 'D')
    if Category ~= 'CE' and Category ~= 'D' then
        Route = {
            {
                coords = vec3(227.5915, -1397.2928, 30.4876),
                text = 'Jūs pradėjote vairavimo egzaminą, pirma prisisekite diržą ir atlikite visus reikiamus veiksmus prieš pradedant važiuoti.',
            },
            {
                coords = vec3(218.6308, -1409.7299, 29.2921),
                text = 'Įsitikinkite, kad saugu sukti į dešinę ir tuomet važiuokite.',
            },
            {
                coords = vec3(178.4063, -1402.1902, 29.3416),
                text = 'Palaukite, kol užsidegs žalias šviesoforo signalas ir tęskite egzaminą.',
            },
            {
                coords = vec3(113.6907, -1364.8357, 29.3415),
                text = 'Važiuokite toliau.',
            },
            {
                coords = vec3(-74.5205, -1364.6302, 29.3975),
                text = 'Važiuokite tiesiai ir tęskite egzaminą.',
            },
            {
                coords = vec3(-208.1906, -1419.9075, 31.3446),
                text = 'Sukite į kairę ir pasiruoškite važiuoti į aikštelę.',
            },
            {
                coords = vec3(-207.8040, -1471.1908, 31.4383),
                text = 'Sukite į kairę ir tuomet prisiparkuokite aikštelėje galu.',
            },
            {
                coords = vec3(-219.6786, -1491.8671, 31.2657),
                actions = 'parkavimas',
                text = 'Priparkuokite automobilį galu.',
                heading = 321.9595,
            },
            {
                coords = vec3(-200.7688, -1483.5219, 31.3751),
                text = 'Sukite į dešinę ir tęskite egzaminą.',
            },
            {
                coords = vec3(-138.4019, -1524.0598, 34.2945),
                text = 'Palaukite, kol užsidegs žalias šviesoforo signalas ir sukite kairėn.',
            },
            {
                coords = vec3(-19.4830, -1465.0886, 30.6436),
                text = 'Važiuokite toliau.',
            },
            {
                coords = vec3(43.3629, -1493.4152, 29.2588),
                text = 'Palaukite, kol užsidegs žalias šviesoforo signalas ir tuomet sukite kairėn.',
            },
            {
                coords = vec3(102.0634, -1473.2535, 29.2387),
                text = 'Sukite kairėn ir aikštelėje priparkuokite automobilė priekiu.',
            },
            {
                coords = vec3(124.9319, -1471.3016, 29.1416),
                actions = 'parkavimas',
                text = 'Priparkuokite automobilį priekiu.',
                heading = 322.7670,
            },
            {
                coords = vec3(113.5015, -1468.0681, 29.2944),
                text = 'Sukite dešinėn ir tęskite kelionę.',
            },
            {
                coords = vec3(146.2528, -1420.8110, 29.2067),
                text = 'Palaukite kol užsidegs žalias šviesoforo signalas ir sukite dešinėn ir tęskite egzaminą.',
            },
            {
                coords = vec3(222.4880, -1440.3790, 29.3401),
                text = 'Sukite kairėn ir tęskite kelionę.',
            },
            {
                coords = vec3(222.4880, -1440.3790, 29.3401),
                text = 'Sukite kairėn ir tęskite kelionę.',
            },
            {
                coords = vec3(284.0005, -1397.9103, 30.2402),
                text = 'Sukite kairėn ir tęskite kelionę.',
            },
            {
                coords = vec3(270.0140, -1369.3966, 31.9330),
                text = 'Važiokite toliau.',
            },
            {
                coords = vec3(246.9637, -1339.4115, 31.7968),
                text = 'Važiokite toliau.',
            },
            {
                coords = vec3(219.5350, -1369.4318, 30.5506),
                text = 'Egzaminas baigtas, spauskite',
                key = 'E',
                text2 = ', kad užbaigtumėte egzaminą.',
                actions = 'end',
            }
        }
    else
        Route = {
            {
                coords = vec3(223.0973, -1383.7704, 30.5179),
                text = 'Jūs pradėjote vairavimo egzaminą, pirma prisisekite diržą ir atlikite visus reikiamus veiksmus prieš pradedant važiuoti.',
            },
            {
                coords = vec3(219.2460, -1410.3627, 29.2922),
                text = 'Įsitikinkite, kad saugu sukti į dešinę ir tuomet važiuokite.',
            },
            {
                coords = vec3(177.2776, -1406.4408, 29.3433),
                text = 'Palaukite, kol užsidegs žalias šviesoforo signalas ir sukite kairėn.',
            },
            {
                coords = vec3(115.6845, -1431.8376, 29.3412),
                text = 'Važiuokite tiesiai',
            },
            {
                coords = vec3(73.2741, -1490.2632, 29.3419),
                text = 'Palaukite, kol užsidegs žalias šviesoforo signalas ir tęskite egzaminą.',
            },
            {
                coords = vec3(-9.1953, -1586.8209, 29.3394),
                text = 'Palaukite, kol užsidegs žalias šviesoforo signalas ir sukite kairėn.',
            },
            {
                coords = vec3(24.9146, -1666.1770, 29.2734),
                text = 'Palaukite, kol užsidegs žalias šviesoforo signalas ir tęskite egzaminą.',
            },
            {
                coords = vec3(153.6627, -1769.1808, 28.9904),
                text = 'Palaukite, kol užsidegs žalias šviesoforo signalas ir sukite kairėn.',
            },
            {
                coords = vec3(189.6247, -1755.6843, 28.8234),
                text = 'Važiuokite tiesiai',
            },
            {
                coords = vec3(269.8071, -1684.0620, 29.2760),
                text = 'Sukite kairėn',
            },
            {
                coords = vec3(208.8823, -1602.3096, 29.1554),
                text = 'Palaukite, kol užsidegs žalias šviesoforo signalas ir važuokite toliau.',
            },
            {
                coords = vec3(300.8312, -1524.2142, 29.3415),
                text = 'Palaukite, kol užsidegs žalias šviesoforo signalas ir sukite kairėn.',
            },
            {
                coords = vec3(257.7601, -1447.4702, 29.2714),
                text = 'Palaukite, kol užsidegs žalias šviesoforo signalas ir sukite dešinėn.',
            },
            {
                coords = vec3(288.8966, -1391.3822, 30.7819),
                text = 'Sukite kairėn',
            },
            {
                coords = vec3(246.1580, -1405.5789, 30.5875),
                text = 'Priparkuokite tr. priemonę galu.',
                actions = 'parkavimas',
                heading = 324.1236,
            },
            {
                coords = vec3(224.1886, -1385.4117, 30.5085),
                text = 'Egzaminas baigtas, spauskite',
                key = 'E',
                text2 = ', kad užbaigtumėte egzaminą.',
                actions = 'end',
            }
        }
    end
    
    local sleep = 1000
    laiko = true
    RequestModel(Config.Vehicles[category])
    while not HasModelLoaded(Config.Vehicles[category]) do
        Wait(100)
    end
    local veh, clear, truckTrailer
    if Category ~= 'CE' and Category ~= 'D' then
        --[[for i=1, #Config.spawnpoints.Paleto do
            if ESX.Game.IsSpawnPointClear(vec3(Config.spawnpoints.Paleto[i].x, Config.spawnpoints.Paleto[i].y, Config.spawnpoints.Paleto[i].z), 2.0) then 
                RequestModel(Config.Vehicles[category])
                while not HasModelLoaded(Config.Vehicles[category]) do 
                    RequestModel(Config.Vehicles[category])
                    Wait(100)
                end
                veh = CreateVehicle(Config.Vehicles[category], Config.spawnpoints.Paleto[i].x, Config.spawnpoints.Paleto[i].y, Config.spawnpoints.Paleto[i].z, Config.spawnpoints.Paleto[i].w, true, true)
                TaskWarpPedIntoVehicle(PlayerPedId(), veh, -1)
                while not IsPedInAnyVehicle(PlayerPedId(), false) do
                    Wait(100)
                end
                TriggerServerEvent('d-giveTempKeys', GetPlayerServerId(PlayerId()), GetVehicleNumberPlateText(veh))
                clear = true
                break
            end
        end]]

        for i=1, #Config.spawnpoints.LosSantos2 do
            if ESX.Game.IsSpawnPointClear(vec3(Config.spawnpoints.LosSantos2[i].x, Config.spawnpoints.LosSantos2[i].y, Config.spawnpoints.LosSantos2[i].z), 2.0) then 
                RequestModel(Config.Vehicles[category])
                while not HasModelLoaded(Config.Vehicles[category]) do 
                    RequestModel(Config.Vehicles[category])
                    Wait(100)
                end
                veh = CreateVehicle(Config.Vehicles[category], Config.spawnpoints.LosSantos2[i].x, Config.spawnpoints.LosSantos2[i].y, Config.spawnpoints.LosSantos2[i].z, Config.spawnpoints.LosSantos2[i].w, true, true)
                TaskWarpPedIntoVehicle(PlayerPedId(), veh, -1)
                while not IsPedInAnyVehicle(PlayerPedId(), false) do
                    Wait(100)
                end
                --TriggerServerEvent('d-giveTempKeys', GetPlayerServerId(PlayerId()), GetVehicleNumberPlateText(veh))
                TriggerServerEvent('d-giveTempKeys', GetPlayerServerId(PlayerId()), NetworkGetNetworkIdFromEntity(veh))
                clear = true
                break
            end
        end
    else 
        for i=1, #Config.spawnpoints.LosSantos do
            if ESX.Game.IsSpawnPointClear(vec3(Config.spawnpoints.LosSantos[i].x, Config.spawnpoints.LosSantos[i].y, Config.spawnpoints.LosSantos[i].z), 2.0) then 
                RequestModel(Config.Vehicles[category])
                while not HasModelLoaded(Config.Vehicles[category]) do 
                    RequestModel(Config.Vehicles[category])
                    Wait(100)
                end
                veh = CreateVehicle(Config.Vehicles[category], Config.spawnpoints.LosSantos[i].x, Config.spawnpoints.LosSantos[i].y, Config.spawnpoints.LosSantos[i].z, Config.spawnpoints.LosSantos[i].w, true, true)
                TaskWarpPedIntoVehicle(PlayerPedId(), veh, -1)
                while not IsPedInAnyVehicle(PlayerPedId(), false) do
                    Wait(100)
                end
                --TriggerServerEvent('d-giveTempKeys', GetPlayerServerId(PlayerId()), GetVehicleNumberPlateText(veh))
                TriggerServerEvent('d-giveTempKeys', GetPlayerServerId(PlayerId()), NetworkGetNetworkIdFromEntity(veh))
                clear = true
                if Category == 'CE' then
                    RequestModel(`trailers2`)
                    while not HasModelLoaded(`trailers2`) do 
                        RequestModel(`trailers2`)
                        Wait(100)
                    end
                    truckTrailer = CreateVehicle(`trailers2`, 235.4320, -1345.4379, 30.5811, 139.5517, true, true)
                    Wait(1000)
                    AttachVehicleToTrailer(veh, truckTrailer, 10.0)
                end
                break
            end
        end
    end
    Wait(1000)
    if not clear then return end
    local LastVehicleHealth = GetEntityHealth(veh)
    Citizen.CreateThread(function()
        while laiko do 
            local Coords = GetEntityCoords(PlayerPedId())
            if not Route[1].actions then
                setBlip(Route[1].coords)
                if #(Route[1].coords - Coords) >= 10.0 then 
                    exports['s1m1s-ui']:keybingMenu(true, {
                        {text = 'Važiuokite iki kito taško.' .. ' Greitis: 80km/h'},
                        {text = 'Klaidų '..klaidos..'/5'}
                    })
                else
                    exports['s1m1s-ui']:keybingMenu(true, {
                        {text = Route[1].text .. ' Greitis: 80km/h'},
                        {text = 'Klaidų '..klaidos..'/5'}
                    })
                end
                if #(Route[1].coords - Coords) <= 3.0 then 
                    table.remove(Route, 1)
                end
            else
                setBlip(Route[1].coords)
                if Route[1].actions == 'parkavimas' then 
                    if #(Route[1].coords - Coords) >= 10.0 then
                        exports['s1m1s-ui']:keybingMenu(true, {
                            {text = 'Važiuokite iki kito taško.' .. ' Greitis: 20km/h'},
                            {text = 'Klaidų '..klaidos..'/5'}
                        })
                    else 
                        exports['s1m1s-ui']:keybingMenu(true, {
                            {text = Route[1].text .. ' Greitis: 20km/h'},
                            {text = 'Klaidų '..klaidos..'/5'}
                        })
                    end
                    if #(Route[1].coords - Coords) <= 1.0 and math.abs(Route[1].heading - GetEntityHeading(PlayerPedId())) <= 20.0 and GetVehicleCurrentGear(GetVehiclePedIsIn(PlayerPedId(), false)) == 0 then 
                        table.remove(Route, 1)
                    end
                end
                if Route[1].actions == 'end' then
                    if #(Route[1].coords - Coords) >= 10.0 then 
                        exports['s1m1s-ui']:keybingMenu(true, {
                            {text = 'Važiuokite iki kito taško. Greitis: 20km/h'},
                            {text = 'Klaidų '..klaidos..'/5'}
                        })
                    else
                        exports['s1m1s-ui']:keybingMenu(true, {
                            {text = Route[1].text .. ' Greitis: 20km/h'},
                            {text = 'Klaidų '..klaidos..'/5'}
                        })
                    end
                    if #(Route[1].coords - Coords) <= 3.0 then
                        exports['s1m1s-ui']:keybingMenu(true, {
                            {text = Route[1].text, key = Route[1].key, text2 = Route[1].text2},
                            {text = 'Klaidų '..klaidos..'/5'}
                        })
                    end
                end
            end
            if klaidos > 5 then
                if DoesBlipExist(Config.Blip) then
                    RemoveBlip(Config.Blip)
                    Config.Blip = nil
                    Config.BlipCoords = nil
                end
                if DoesEntityExist(GetVehiclePedIsIn(PlayerPedId(), false)) then
                    DeleteVehicle(GetVehiclePedIsIn(PlayerPedId(), false))
                    laiko = false
                end
                SetEntityCoords(PlayerPedId(), Config.Laiko.x, Config.Laiko.y, Config.Laiko.z, true, false, false, false)
                exports['s1m1s-ui']:keybingMenu(false)
                laiko = false
                break
            end

            if not IsPedInAnyVehicle(PlayerPedId(), false) then
                if DoesBlipExist(Config.Blip) then
                    RemoveBlip(Config.Blip)
                    Config.Blip = nil
                    Config.BlipCoords = nil
                end
                if DoesEntityExist(GetVehiclePedIsIn(PlayerPedId(), false)) then
                    DeleteVehicle(GetVehiclePedIsIn(PlayerPedId(), false))
                    laiko = false
                end
                SetEntityCoords(PlayerPedId(), Config.Laiko.x, Config.Laiko.y, Config.Laiko.z, true, false, false, false)
                exports['s1m1s-ui']:keybingMenu(false)
                laiko = false
                break
            end

            local health = GetEntityHealth(GetVehiclePedIsIn(PlayerPedId(), false))
            if health < LastVehicleHealth -10 then
                klaidos += 1
                LastVehicleHealth = health
            end
            Wait(200)
        end
    end)

    Citizen.CreateThread(function()
        while laiko do 
            local Coords = GetEntityCoords(PlayerPedId())
            if #(Route[1].coords - Coords) <= 20.0 then 
                sleep = 6
                DrawMarker(1, Route[1].coords.x, Route[1].coords.y, Route[1].coords.z -1.0, 0, 0, 0, 0, 0, 0, 3.0, 3.0, 1.0, 66, 151, 241, 100, false, false, 0, false, nil, nil, false)
                DrawMarker(2, Route[1].coords.x, Route[1].coords.y, Route[1].coords.z, 0, 0, 0, 0, 0, 0, 1.0, 1.0, 1.0, 66, 151, 241, 100, true, false, 0, true, nil, nil, false)
            else 
                sleep = 1000
            end
            Wait(sleep)
        end
    end)

    local Speed = false
    Citizen.CreateThread(function()
        while laiko do 
            if not Speed then
                if Route[1].actions == 'parkavimas' or Route[1].actions == 'end' then 
                    if math.floor(GetEntitySpeed(GetVehiclePedIsIn(PlayerPedId(), false)) * 3.6) > 30.0 then
                        klaidos += 1
                        Speed = true
                    end
                else
                    if math.floor(GetEntitySpeed(GetVehiclePedIsIn(PlayerPedId(), false)) * 3.6) > 85.0 then
                        klaidos += 1
                        Speed = true
                    end
                end
            end
            Wait(500)
        end
    end)

    Citizen.CreateThread(function()
        while laiko do 
            Speed = false
            Wait(6000)
        end
    end)

    Citizen.CreateThread(function()
        while laiko do 
            DisableControlAction(0, 23, true)
            DisableControlAction(0, 49, true)
            DisableControlAction(0, 75, true)
            DisableControlAction(0, 145, true)
            DisableControlAction(0, 185, true)
            DisableControlAction(0, 251, true)
            Wait(6)
        end
    end)
end

RegisterCommand('endRegitra', function()
    local Coords = GetEntityCoords(PlayerPedId())
    if laiko and Route[1].actions == 'end' and #(Route[1].coords - Coords) <= 3.0 then
        exports['s1m1s-ui']:keybingMenu(false)
        if DoesEntityExist(GetVehiclePedIsIn(PlayerPedId(), false)) then
            if DoesBlipExist(Config.Blip) then
                RemoveBlip(Config.Blip)
                Config.Blip = nil
                Config.BlipCoords = nil
            end
            DeleteVehicle(GetVehiclePedIsIn(PlayerPedId(), false))
            laiko = false
            if klaidos <= 5 then
                ESX.TriggerServerCallback('d-regitra:giveLicense', function(can)
                end, Category)
            end
        end
        laiko = false
    end
end)
RegisterKeyMapping('endRegitra', 'Pristatyti automobili', 'keyboard', 'e')

function setBlip(coords)
    if not Config.Blip then
        Config.Blip = AddBlipForCoord(coords)
        SetBlipSprite(Config.Blip, 162)
        SetBlipRoute(Config.Blip, true)
        SetBlipColour(Config.Blip, 29)
        SetBlipRouteColour(Config.Blip, 29)
        Config.BlipCoords = coords
    else 
        if DoesBlipExist(Config.Blip) and Config.BlipCoords ~= coords then
            RemoveBlip(Config.Blip)
            Config.Blip = nil
            Config.BlipCoords = nil
        end
    end
end