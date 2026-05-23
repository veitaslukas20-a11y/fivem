local Modes = {
    easy = {count = 1, tries = 4},
    normal = {count = 2, tries = 2},
    medium = {count = 3, tries = 2},
    hard = {count = 4, tries = 1},
    vhard = {count = 6, tries = 1},

}

local Notified = false

local car_colours = {    --[[Black]]    { index = 0, label = 'black'},    { index = 1, label = 'black'},    { index = 2, label = 'black'},    { index = 3, label = 'grey'},    { index = 11, label = 'black'},    { index = 12, label = 'matte black'},    { index = 15, label = 'black'},    { index = 16, label = 'black'},    { index = 21, label = 'oil'},    { index = 147, label = 'carbon'},     --[[White]]    { index = 106, label = 'white'},    { index = 107, label = 'creme'},    { index = 111, label = 'white'},    { index = 112, label = 'white'},    { index = 113, label = 'beige'},    { index = 121, label = 'white'},    { index = 122, label = 'white'},    { index = 131, label = 'white'},    { index = 132, label = 'white'},    { index = 134, label = 'white'},    --[[Grey]]    { index = 4, label = 'silver'},    { index = 5, label = 'grey'},    { index = 6, label = 'grey'},    { index = 7, label = 'grey'},    { index = 8, label = 'grey'},    { index = 9, label = 'night'},    { index = 10, label = 'aluminum'},    { index = 13, label = 'grey'},    { index = 14, label = 'grey'},    { index = 17, label = 'grey'},    { index = 18, label = 'grey'},    { index = 19, label = 'silver'},    { index = 20, label = 'grey'},    { index = 22, label = 'grey'},    { index = 23, label = 'grey'},    { index = 24, label = 'grey'},    { index = 25, label = 'silver'},    { index = 26, label = 'titanium'},    { index = 66, label = 'grey'},    { index = 93, label = 'champagne'},    { index = 144, label = 'grey'},    { index = 156, label = 'grey'},    --[[Red]]    { index = 27, label = 'red'},    { index = 28, label = 'red'},    { index = 29, label = 'red'},    { index = 30, label = 'red'},    { index = 31, label = 'red'},    { index = 32, label = 'red'},    { index = 33, label = 'red'},    { index = 34, label = 'red'},    { index = 35, label = 'red'},    { index = 39, label = 'red'},    { index = 40, label = 'red'},    { index = 43, label = 'red'},    { index = 44, label = 'red'},    { index = 46, label = 'red'},    { index = 143, label = 'red'},    { index = 150, label = 'red'},    --[[Pink]]    { index = 135, label = 'pink'},    { index = 136, label = 'pink'},    { index = 137, label = 'pink'},    --[[Blue]]    { index = 54, label = 'blue'},    { index = 60, label = 'blue'},    { index = 61, label = 'blue'},    { index = 62, label = 'blue'},    { index = 63, label = 'blue'},    { index = 64, label = 'blue'},    { index = 65, label = 'blue'},    { index = 67, label = 'blue'},    { index = 68, label = 'blue'},    { index = 69, label = 'blue'},    { index = 70, label = 'blue'},    { index = 73, label = 'blue'},    { index = 74, label = 'blue'},    { index = 75, label = 'blue'},    { index = 77, label = 'blue'},    { index = 78, label = 'blue'},    { index = 79, label = 'blue'},    { index = 80, label = 'blue'},    { index = 82, label = 'blue'},    { index = 83, label = 'blue'},    { index = 84, label = 'blue'},    { index = 85, label = 'blue'},    { index = 86, label = 'blue'},    { index = 87, label = 'blue'},    { index = 127, label = 'blue'},    { index = 140, label = 'blue'},    { index = 141, label = 'blue'},    { index = 146, label = 'blue'},    { index = 157, label = 'blue'},    --[[Yellow]]    { index = 42, label = 'yellow'},    { index = 88, label = 'yellow'},    { index = 89, label = 'yellow'},    { index = 91, label = 'yellow'},    { index = 126, label = 'yellow'},    --[[Green]]    { index = 49, label = 'green'},    { index = 50, label = 'green'},    { index = 51, label = 'green'},    { index = 52, label = 'green'},    { index = 53, label = 'green'},    { index = 55, label = 'green'},    { index = 56, label = 'green'},    { index = 57, label = 'green'},    { index = 58, label = 'green'},    { index = 59, label = 'green'},    { index = 92, label = 'green'},    { index = 125, label = 'green'},    { index = 128, label = 'green'},    { index = 133, label = 'green'},    { index = 151, label = 'green'},    { index = 152, label = 'green'},    { index = 155, label = 'green'},    --[[Orange]]    { index = 36, label = 'orange'},    { index = 38, label = 'orange'},    { index = 41, label = 'orange'},    { index = 123, label = 'orange'},    { index = 124, label = 'orange'},    { index = 130, label = 'orange'},    { index = 138, label = 'orange'},    --[[Brown]]    { index = 45, label = 'copper'},    { index = 47, label = 'brown'},    { index = 48, label = 'brown'},    { index = 90, label = 'bronze'},    { index = 94, label = 'brown'},    { index = 95, label = 'brown'},    { index = 96, label = 'brown'},    { index = 97, label = 'brown'},    { index = 98, label = 'brown'},    { index = 99, label = 'beige'},    { index = 100, label = 'brown'},    { index = 101, label = 'brown'},    { index = 102, label = 'brown'},    { index = 103, label = 'brown'},    { index = 104, label = 'brown'},    { index = 105, label = 'brown'},    { index = 108, label = 'brown'},    { index = 109, label = 'brown'},    { index = 110, label = 'brown'},    { index = 114, label = 'brown'},    { index = 115, label = 'brown'},    { index = 116, label = 'beige'},    { index = 129, label = 'brown'},    { index = 153, label = 'brown'},    { index = 154, label = 'beige'},    --[[Purple]]    { index = 71, label = 'purple'},    { index = 72, label = 'purple'},    { index = 76, label = 'violet'},    { index = 81, label = 'purple'},    { index = 142, label = 'violet'},    { index = 145, label = 'purple'},    { index = 148, label = 'purple'},    { index = 149, label = 'purple'},    --[[Chrome]]    { index = 117, label = 'chrome'},    { index = 118, label = 'chrome'},    { index = 119, label = 'aluminum'},    --[[Metal]]    { index = 120, label = 'chrome'},    { index = 37, label = 'gold'},    { index = 158, label = 'gold'},    { index = 159, label = 'gold'},    { index = 160, label = 'gold'}}
local function GetVehicleColour(vehicle)
    local carcolour
    local primary, secondary = GetVehicleColours(vehicle)
    for t, u in pairs (car_colours) do
        if u.index == primary then
            carcolour = u.label
            break
        end
    end
    return carcolour
end

local function GetVehicleLabel(vehicle)
    local model = GetEntityModel(vehicle)
    local displaytext = GetDisplayNameFromVehicleModel(model)
    local name = GetLabelText(displaytext)
    if (name == "NULL") then
        vehicleLabel = displaytext
    else
        vehicleLabel = name
    end
    return vehicleLabel
end

local function NotifyPolice(vehicle)
    if Notified then return end
    local data = exports['cd_dispatch']:GetPlayerInfo()
    TriggerServerEvent('cd_dispatch:AddNotification', {
        job_table = {'police'}, 
        coords = data.coords,
        title = '10-89 - Automobilio vagystė',
        message = data.sex..' bando įsilaužti į automobilį '..data.street..' gatvėje. Automobilio numeriai: '..GetVehicleNumberPlateText(vehicle)..'. Automobilio spalva: '..GetVehicleColour(vehicle)..'. Automobilio markė: '..GetVehicleLabel(vehicle)..'. Apie tai pranešė praeiviai.',
        flash = 1,
        unique_id = math.random(1, 99999),
        sound = 2,
        blip = {
            sprite = 326, 
            scale = 1.0, 
            colour = 1,
            flashes = true, 
            text = '<font face="Roboto">10-89 - Automobilio vagystė</font>',
            time = 5,
            radius = 0,
        }
    })
    Notified = true
end

exports('lockpick', function()
    local coords = GetEntityCoords(cache.ped)
    if exports['1X-NCZ']:inZone() then 
        exports['1x-hud']:sendNotification({
            type = 'ERROR',
            title = 'Automobilio spynos išlaužimas',
            message = 'Deja, šioje vietoje negalima to daryti.',
            duration = 5000,
        })
        return
    end
    
    local Vehicle
    if not cache.vehicle then
        Vehicle = lib.getClosestVehicle(coords, 3.0, true)
        if not Vehicle then
            exports['1x-hud']:sendNotification({
                type = 'ERROR',
                title = 'Automobilio spynos išlaužimas',
                message = 'Deja, automobilis nebuvo rastas.',
                duration = 5000,
            })
            return
        end

        if GetVehicleDoorLockStatus(Vehicle) ~= 2 then 
            exports['1x-hud']:sendNotification({
                type = 'ERROR',
                title = 'Automobilio spynos išlaužimas',
                message = 'Automobilis neužrakintas, kam laužyt tą spyną...',
                duration = 5000,
            })
            return
        end 
    else 
        Vehicle = cache.vehicle
        if GetIsVehicleEngineRunning(cache.vehicle) then
            exports['1x-hud']:sendNotification({
                type = 'ERROR',
                title = 'Automobilio spynos išlaužimas',
                message = 'Automobilio variklis jau užkurtas, ką tu dar nori užkurti?',
                duration = 5000,
            })
            return
        end
    end

    local vehicleState = Entity(Vehicle)?.state

    if vehicleState and vehicleState.vehicleFromContainer then
        exports['1x-hud']:sendNotification({
            type = 'ERROR',
            title = 'Automobilio spynos išlaužimas',
            message = 'Šis automobilis negali būti užkurtas arba atrakintas naudojant paprastus įrankius.',
            duration = 5000,
        })
        return
    end

    local Plate = ESX.Math.Trim(GetVehicleNumberPlateText(Vehicle))
    if not Plate then
        exports['1x-hud']:sendNotification({
            type = 'ERROR',
            title = 'Automobilio spynos išlaužimas',
            message = 'Deja, įvyko klaida bandant atrakinti ar užkurti automobilį.',
            duration = 5000,
        })
        return
    end

    if not cache.vehicle then
        lib.playAnim(cache.ped, 'anim@amb@clubhouse@tutorial@bkr_tut_ig3@', 'machinic_loop_mechandplayer', 1.0, -1.0, -1, 49, 1, false, false, false)
    end

    local announce, difficulty = lib.callback.await('s1m1s-signalizacija:getData', false, Plate)

    if not difficulty then
        exports['1x-hud']:sendNotification({
            type = 'ERROR',
            title = 'Automobilio spynos išlaužimas',
            message = 'Deja, įvyko klaida bandant atrakinti ar užkurti automobilį.',
            duration = 5000,
        })
        return
    end

    local NetID = NetworkGetNetworkIdFromEntity(Vehicle)

    local minigame = Modes[difficulty]
    for i=1, minigame.count do
        local success = exports['lockpick']:startLockpick(minigame.tries)
        if not success then
            exports['1x-hud']:sendNotification({
                type = 'ERROR',
                title = 'Automobilio spynos išlaužimas',
                message = 'Deja, nepavyko atrakinti automobilio.',
                duration = 5000,
            })

            if not cache.vehicle then
                ClearPedTasksImmediately(cache.ped)
            end

            TriggerServerEvent('s1m1s-signalizacija:removeLockpick')

            if announce then
                NotifyPolice(Vehicle)
        
                SetVehicleAlarm(Vehicle, true)
                StartVehicleAlarm(Vehicle)
            end

            return
        end
    end

    if announce then
        NotifyPolice(Vehicle)

        SetVehicleAlarm(Vehicle, true)
        StartVehicleAlarm(Vehicle)
    end

    if not cache.vehicle then
        lib.progressCircle({
            duration = 3000,
            position = 'bottom',
            useWhileDead = false,
            canCancel = false,
            label = 'Automobilis atrakinamas...',
            disable = {
                move = true,
                car = true, 
                combat = true, 
                sprint = true, 
                mouse = true,
            }
        })

        ClearPedTasksImmediately(cache.ped)
        SetVehicleDoorsLockedForAllPlayers(Vehicle, false)

        Notified = false
        TriggerServerEvent('s1m1s-signalizacija:unlockVehicle', NetID)
    else
        lib.progressCircle({
            duration = 3000,
            position = 'bottom',
            useWhileDead = false,
            canCancel = false,
            label = 'Automobilis užkuriamas...',
            disable = {
                move = true,
                car = true, 
                combat = true, 
                sprint = true, 
                mouse = true,
            }
        })

        TriggerEvent('EngineToggle:Engine')

        Notified = false
        TriggerServerEvent('s1m1s-signalizacija:startEngine', NetID)
    end
end)

RegisterNetEvent('s1m1s-signalization:install', function()
    lib.progressCircle({
        duration = 10000,
        position = 'bottom',
        useWhileDead = false,
        canCancel = false,
        label = 'Instaliuojama signalizacija į automobilį...',
        disable = {
            move = true,
            car = true, 
            combat = true, 
            sprint = true, 
            mouse = true,
        }
    })
end)

local Blips = {}
RegisterNetEvent('s1m1s-signalization:setBlips', function(NewBlips)
    for k,v in pairs(Blips) do 
        RemoveBlip(v)
    end

    for k,v in pairs(NewBlips) do 
        blip = AddBlipForCoord(v.x, v.y, v.z)
        SetBlipSprite(blip, 326)
        SetBlipDisplay(blip, 2)
        SetBlipScale(blip, 1.0)
        SetBlipColour(blip, 1)
        SetBlipFlashes(blip, true)
        SetBlipFlashInterval(blip, 200)
        SetBlipAsShortRange(blip, true)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString('<font face="Roboto">Pavogtas automobilis</font>')
        EndTextCommandSetBlipName(blip)

        table.insert(Blips, blip)
    end
end)

local Vehicles = {}

exports('insertVehicle', function(plates, netid)
    Vehicles[plates] = netid
end)

exports('removeVehicle', function(plates)
    if Vehicles[plates] then
        Vehicles[plates] = nil
    end
end)

exports('getVehicle', function(plates)
    return Vehicles[plates]
end)

local Timeout = false
exports('setWaypoint', function(plates)
    if Timeout then return false end
    Timeout = true
    local netid = Vehicles[plates]
    local coords = lib.callback.await('s1m1s-signalization:getVehicleCoords', false, netid, plates)

    if coords then
        SetNewWaypoint(coords.x, coords.y)
    else
        Vehicles[plates] = nil
    end
    SetTimeout(15000, function()
        Timeout = false
    end)

    return true
end)