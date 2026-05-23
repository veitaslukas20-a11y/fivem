local ESX, QBCore = nil, nil

if Config.Framework == 'esx' then
    ESX = exports['es_extended']:getSharedObject()
    Config.FrameWorkObj = ESX
elseif Config.Framework == 'qb' then
    QBCore = exports['qb-core']:GetCoreObject()
    Config.FrameWorkObj = QBCore
end

local getNearGarage = function(coords, dist)
    if not coords then coords = GetEntityCoords(PlayerPedId()) end
    for k,v in pairs(Config.Garages) do
        if #(vec3(v.coords.x, v.coords.y, v.coords.z) - coords) <= dist then
            return k,v
        end
    end
    return false, false
end

local getNearStorage = function(coords, dist)
    if coords == nil then coords = GetEntityCoords(PlayerPedId()) end
    for k,v in pairs(Config.Garages) do
        if v.storage and v.storage.x then
            if #(vec3(v.storage.x, v.storage.y, v.storage.z) - coords) <= dist then
                return k,v
            end
        end
    end
    return false, false
end

local PlayerPed = PlayerPedId()

local cache = {vehicle = 0, cam = 0, player = vec3(0,0,0)}
local export = {}
local take_out = false
local current_garage2 = ''

local ped_coords
local ped_time = Config.Management.DrawText3D.wait
local open = false
if Config.Management.DrawText3D.using then
    Citizen.CreateThread(function()
        while not Config.Garages do 
            Wait(100)
        end
        while true do
            local coords = GetEntityCoords(PlayerPed)
            local k,v = getNearGarage(coords, 3.0)
            if k then
                ped_time = 6
                DrawText3D(vector3(v.coords.x, v.coords.y, v.coords.z - 0.8), locale[Config.Basic.language]['draw_text'])
            else
                ped_time = Config.Management.DrawText3D.wait
            end 
            Wait(ped_time)
        end
    end)
end

if Config.Management.DrawText3D.using and Config.Commands.enable then
    RegisterCommand(Config.Commands.open.name, function()
        ped_time = Config.Management.DrawText3D.wait
        TriggerEvent('d-garagev2:openMenu')
    end)
    RegisterKeyMapping(Config.Commands.open.name, Config.Commands.open.description, 'keyboard', Config.Commands.open.key)
end

local time = Config.Marker.wait
local current_garage
local garage_coords
local garage_class
if not Config.Management.Target.storage then
    Citizen.CreateThread(function()
        Wait(5000)
        while true do
            PlayerPed = PlayerPedId()
            if IsPedInVehicle(PlayerPed, GetVehiclePedIsIn(PlayerPed, false), false) then
                local coords = GetEntityCoords(PlayerPed)
                local k,v = getNearStorage(coords, 10.0)

                if k and v.type ~= 'impound' then
                    current_garage = v 
                    garage_coords = vector3(current_garage.storage.x, current_garage.storage.y, current_garage.storage.z) 
                    garage_class = v.class
                    if current_garage ~= nil then
                        time = 6
                        DrawMarker(Config.Marker.type, vector3(garage_coords.x, garage_coords.y, garage_coords.z - 0.8), 0.0, 0.0, 0.0, 0, 0.0, 0.0, 4.0, 4.0, 4.0, Config.Marker.color.r, Config.Marker.color.g, Config.Marker.color.b, 100, false, true, 2, true, false, false, false)
                    else
                        time = Config.Marker.wait
                    end
                else
                    time = Config.Marker.wait
                end
            else
                time = Config.Marker.wait
            end
            Wait(time)
        end
    end)
end

if Config.Commands.enable then
    RegisterCommand(Config.Commands.store.name, function()
        local coords = GetEntityCoords(PlayerPedId())
        local k,v = getNearStorage(coords, 3.0)
        if k then
            SaveVeh(tostring(k))
        end
        time = Config.Marker.wait
    end)
    RegisterKeyMapping(Config.Commands.store.name, Config.Commands.store.description, 'keyboard', Config.Commands.store.key)
end

RegisterNUICallback('close', function(escape)
    open = false
    SendNUIMessage({
        show = false,
    })
    SetNuiFocus(false, false)
    HandleCamera(false, nil, export)
    if cache.vehicle and DoesEntityExist(cache.vehicle) then
		DeleteEntity(cache.vehicle)
	end
    if escape.escape then 
        export = {}
    end
    if not take_out then
        export = {}
    end
end)

RegisterNUICallback('savecolor', function(data)
    TriggerServerEvent('d-garagev2:saveColor', data.color)
end)

RegisterNUICallback('saveName', function(data)
    TriggerServerEvent('d-garagev2:saveName', data.plate, data.name)
end)

RegisterNUICallback('takeout', function(data)
    take_out = true
    HandleCamera(false, nil, export)
    open = false
    SendNUIMessage({
        show = false,
    })    
    SetNuiFocus(false, false)  
    --[[local current = ''
    local class = '']]
    PlayerPed = PlayerPedId()
    --[[for k,v in pairs(Config.Garages) do
        if #(GetEntityCoords(PlayerPed) - vector3(v.coords.x, v.coords.y, v.coords.z)) < 4.5 then
            current = ''..k
            class = v.class
            break
        end
    end]]
    local k,v
    local current
    local class
    if not export.Spawnpoints then
        k,v = getNearGarage(coords, 4.5)
        current = ''..k
        class = v.class
    end
    if cache.vehicle and DoesEntityExist(cache.vehicle) then
		DeleteEntity(cache.vehicle)
	end
    Wait(100)
    if Config.Framework == 'esx' then
        if not export.Spawnpoints then
            ESX.TriggerServerCallback('d-garagev2:getVehicle', function(data)
                if data then 
                    print(data.model)
                    WaitForModel(data.model)
                    for k,v in pairs(Config.Garages[current]['slots']) do
                        if ESX.Game.IsSpawnPointClear(vector3(v.x, v.y, v.z), Config.Basic.RadiusBetweeen) then
                            if not IsModelValid(data.model) then
                                return
                            end
                            if Config.Basic.SpawnVehicles == 'server' then
                                ESX.TriggerServerCallback('d-garage:SpawnVehicle', function(vehicle, props)
                                    local car = NetToVeh(vehicle)
                                    while not DoesEntityExist(car) do
                                        Wait(100)
                                    end
                                    Wait(100)
                                    SetVehicleProperties(car, props)
                                    Wait(100)
                                    SetEntityAsMissionEntity(car, true)
                                    SetNetworkIdExistsOnAllMachines(vehicle, true)
                                    NetworkFadeInEntity(car, true, true) 
                                    if Config.Basic.TeleportForward then
                                        if GetVehicleClass(car) == 20 or GetVehicleClass(car) == 19 or GetVehicleClass(car) == 10 or GetVehicleClass(car) == 17 then
                                            FreezeEntityPosition(car, true)
                                            local coords = GetEntityCoords(car)
                                            local forward = GetEntityForwardVector(car)
                                            coords = (coords + forward * 2.0)
                                            FreezeEntityPosition(car, false)
                                            SetEntityCoords(car, coords.x, coords.y, coords.z, false, false, false)
                                        end
                                    end
                                    SetModelAsNoLongerNeeded(data.model)
                                    TaskWarpPedIntoVehicle(PlayerPedId(), car, -1)
                                    Wait(200)
                                    SetEntityAsMissionEntity(car, true, true)    
                                    SetVehicleHasBeenOwnedByPlayer(car, true)  
                                    local vehicle = GetVehiclePedIsIn(PlayerPedId(), false)
                                    if Config.Basic.LockVehicle then
                                        SetVehicleDoorsLocked(car, 1)
                                        SetVehicleDoorsLockedForAllPlayers(car, true) 
                                        if Config.Interactions.SQZKeys.using and GetResourceState(Config.Interactions.SQZKeys.resource) == 'started' then
                                            TriggerServerEvent('carkeys:RequestVehicleLock', VehToNet(vehicle or car), GetVehicleDoorLockStatus(vehicle or car), GetVehicleClass(vehicle or car))
                                        else
                                            TriggerServerEvent('d-garagev2:lockveh', VehToNet(vehicle or car), 2)
                                        end
                                    end
                                    if Config.Interactions.EngineToggle.using and GetResourceState(Config.Interactions.EngineToggle.resource) == 'started' then
                                        Wait(200)
                                        TriggerEvent('EngineToggle:Engine')
                                    else
                                        SetVehicleEngineOn(vehicle or car, true, true)
                                        Citizen.Wait(100)
                                        SetVehicleEngineOn(vehicle or car, true, true)
                                        Citizen.Wait(100)
                                        SetVehicleEngineOn(vehicle or car, true, true)
                                    end
                                    Wait(1000)
                                    notify(locale[Config.Basic.language]['taken_out'])
                                end, data, v)
                            elseif Config.Basic.SpawnVehicles == 'client' then
                                ESX.Game.SpawnVehicle(data.model, vector3(v.x, v.y, v.z), v.w, function(car)
                                    SetNetworkIdExistsOnAllMachines(VehToNet(car), true)
                                    SetVehicleProperties(car, data)
                                    NetworkFadeInEntity(car, true, true) 
                                    if Config.Basic.TeleportForward then
                                        if GetVehicleClass(car) == 20 or GetVehicleClass(car) == 19 or GetVehicleClass(car) == 10 or GetVehicleClass(car) == 17 then
                                            FreezeEntityPosition(car, true)
                                            local coords = GetEntityCoords(car)
                                            local forward = GetEntityForwardVector(car)
                                            coords = (coords + forward * 2.0)
                                            FreezeEntityPosition(car, false)
                                            SetEntityCoords(car, coords.x, coords.y, coords.z, false, false, false)
                                        end
                                    end
                                    SetModelAsNoLongerNeeded(data.model)
                                    TaskWarpPedIntoVehicle(PlayerPedId(), car, -1)
                                    Wait(200)
                                    SetEntityAsMissionEntity(car, true, true)    
                                    SetVehicleHasBeenOwnedByPlayer(car, true)  
                                    local vehicle = GetVehiclePedIsIn(PlayerPedId(), false)
                                    if Config.Basic.LockVehicle then
                                        SetVehicleDoorsLocked(car, 1)
                                        SetVehicleDoorsLockedForAllPlayers(car, true) 
                                        if Config.Interactions.SQZKeys.using and GetResourceState(Config.Interactions.SQZKeys.resource) == 'started' then
                                            TriggerServerEvent('carkeys:RequestVehicleLock', VehToNet(vehicle or car), GetVehicleDoorLockStatus(vehicle or car), GetVehicleClass(vehicle or car))
                                        else
                                            TriggerServerEvent('d-garagev2:lockveh', VehToNet(vehicle or car), 2)
                                        end
                                    end
                                    if Config.Interactions.EngineToggle.using and GetResourceState(Config.Interactions.EngineToggle.resource) == 'started' then
                                        Wait(200)
                                        TriggerEvent('EngineToggle:Engine')
                                    else
                                        SetVehicleEngineOn(vehicle or car, true, true)
                                        Citizen.Wait(100)
                                        SetVehicleEngineOn(vehicle or car, true, true)
                                        Citizen.Wait(100)
                                        SetVehicleEngineOn(vehicle or car, true, true)
                                    end
                                    Wait(1000)
                                    notify(locale[Config.Basic.language]['taken_out'])
                                end)
                            end
                            return false
                        else
                            if k == #Config.Garages[current]['slots'] then
                                notify(locale[Config.Basic.language]['place_occupied'])
                            end
                        end
                    end
                end
            end, data.plate, data.type == 'impound', current, class)
        else
            local exp = export
            take_out = false
            export = {}
            ESX.TriggerServerCallback('d-garagev2:getVehicleJob', function(data)
                if data then
                    WaitForModel(data.model)
                    for k,v in pairs(exp.Spawnpoints) do
                        if ESX.Game.IsSpawnPointClear(vector3(v.x, v.y, v.z), Config.Basic.RadiusBetweeen) then
                            if not IsModelValid(data.model) then
                                return
                            end
                            if Config.Basic.SpawnVehicles == 'server' then
                                ESX.TriggerServerCallback('d-garage:SpawnVehicle', function(vehicle, props)
                                    local car = NetToVeh(vehicle)
                                    SetVehicleProperties(car, props)
                                    Wait(100)
                                    while not DoesEntityExist(car) do
                                        Wait(100)
                                    end
                                    Wait(100)
                                    SetEntityAsMissionEntity(car, true)
                                    SetNetworkIdExistsOnAllMachines(vehicle, true)
                                    NetworkFadeInEntity(car, true, true) 
                                    if Config.Basic.TeleportForward then
                                        if GetVehicleClass(car) == 20 or GetVehicleClass(car) == 19 or GetVehicleClass(car) == 10 or GetVehicleClass(car) == 17 then
                                            FreezeEntityPosition(car, true)
                                            local coords = GetEntityCoords(car)
                                            local forward = GetEntityForwardVector(car)
                                            coords = (coords + forward * 2.0)
                                            FreezeEntityPosition(car, false)
                                            SetEntityCoords(car, coords.x, coords.y, coords.z, false, false, false)
                                        end
                                    end
                                    SetModelAsNoLongerNeeded(data.model)
                                    TaskWarpPedIntoVehicle(PlayerPedId(), car, -1)
                                    Wait(200)
                                    SetEntityAsMissionEntity(car, true, true)    
                                    SetVehicleHasBeenOwnedByPlayer(car, true)  
                                    local vehicle = GetVehiclePedIsIn(PlayerPedId(), false)
                                    if Config.Basic.LockVehicle then
                                        SetVehicleDoorsLocked(car, 1)
                                        SetVehicleDoorsLockedForAllPlayers(car, true) 
                                        if Config.Interactions.SQZKeys.using and GetResourceState(Config.Interactions.SQZKeys.resource) == 'started' then
                                            TriggerServerEvent('carkeys:RequestVehicleLock', VehToNet(vehicle or car), GetVehicleDoorLockStatus(vehicle or car), GetVehicleClass(vehicle or car))
                                        else
                                            TriggerServerEvent('d-garagev2:lockveh', VehToNet(vehicle or car), 2)
                                        end
                                    end
                                    if Config.Interactions.EngineToggle.using and GetResourceState(Config.Interactions.EngineToggle.resource) == 'started' then
                                        Wait(200)
                                        TriggerEvent('EngineToggle:Engine')
                                    else
                                        SetVehicleEngineOn(vehicle or car, true, true)
                                        Citizen.Wait(100)
                                        SetVehicleEngineOn(vehicle or car, true, true)
                                        Citizen.Wait(100)
                                        SetVehicleEngineOn(vehicle or car, true, true)
                                    end
                                    Wait(1000)
                                    notify(locale[Config.Basic.language]['taken_out'])
                                end, data, v)
                            elseif Config.Basic.SpawnVehicles == 'client' then
                                ESX.Game.SpawnVehicle(data.model, vector3(v.x, v.y, v.z), v.w, function(car)
                                    SetNetworkIdExistsOnAllMachines(VehToNet(car), true)
                                    SetVehicleProperties(car, data)
                                    NetworkFadeInEntity(car, true, true) 
                                    if Config.Basic.TeleportForward then
                                        if GetVehicleClass(car) == 20 or GetVehicleClass(car) == 19 or GetVehicleClass(car) == 10 or GetVehicleClass(car) == 17 then
                                            FreezeEntityPosition(car, true)
                                            local coords = GetEntityCoords(car)
                                            local forward = GetEntityForwardVector(car)
                                            coords = (coords + forward * 2.0)
                                            FreezeEntityPosition(car, false)
                                            SetEntityCoords(car, coords.x, coords.y, coords.z, false, false, false)
                                        end
                                    end
                                    SetModelAsNoLongerNeeded(data.model)
                                    TaskWarpPedIntoVehicle(PlayerPedId(), car, -1)
                                    Wait(200)
                                    SetEntityAsMissionEntity(car, true, true)    
                                    SetVehicleHasBeenOwnedByPlayer(car, true)  
                                    local vehicle = GetVehiclePedIsIn(PlayerPedId(), false)
                                    if Config.Basic.LockVehicle then
                                        SetVehicleDoorsLocked(car, 1)
                                        SetVehicleDoorsLockedForAllPlayers(car, true) 
                                        if Config.Interactions.SQZKeys.using and GetResourceState(Config.Interactions.SQZKeys.resource) == 'started' then
                                            TriggerServerEvent('carkeys:RequestVehicleLock', VehToNet(vehicle or car), GetVehicleDoorLockStatus(vehicle or car), GetVehicleClass(vehicle or car))
                                        else
                                            TriggerServerEvent('d-garagev2:lockveh', VehToNet(vehicle or car), 2)
                                        end
                                    end
                                    if Config.Interactions.EngineToggle.using and GetResourceState(Config.Interactions.EngineToggle.resource) == 'started' then
                                        Wait(200)
                                        TriggerEvent('EngineToggle:Engine')
                                    else
                                        SetVehicleEngineOn(vehicle or car, true, true)
                                        Citizen.Wait(100)
                                        SetVehicleEngineOn(vehicle or car, true, true)
                                        Citizen.Wait(100)
                                        SetVehicleEngineOn(vehicle or car, true, true)
                                    end
                                    Wait(1000)
                                    notify(locale[Config.Basic.language]['taken_out'])
                                end)
                            end
                            return false
                        else
                            if k == #exp.Spawnpoints then
                                notify(locale[Config.Basic.language]['place_occupied'])
                            end
                        end
                    end
                end
            end, data.plate, data.type == 'impound', exp)
        end
    elseif Config.Framework == 'qb' then
        local veh_plate = data.plate
        if not export.Spawnpoints then
            QBCore.Functions.TriggerCallback('d-garagev2:getVehicle', function(data)
                if data then
                    for k,v in pairs(Config.Garages[current]['slots']) do
                        if IsSpawnPointClear(vector3(v.x, v.y, v.z), Config.Basic.RadiusBetweeen) then
                            if Config.Basic.SpawnVehicles == 'server' then
                                QBCore.Functions.TriggerCallback('d-garage:SpawnVehicle', function(vehicle, props)
                                    local car = NetToVeh(vehicle)
                                    while not DoesEntityExist(car) do
                                        Wait(100)
                                    end
                                    Wait(100)
                                    SetVehicleProperties(car, props)
                                    Wait(100)
                                    SetEntityAsMissionEntity(car, true)
                                    SetNetworkIdExistsOnAllMachines(vehicle, true)
                                    NetworkFadeInEntity(car, true, true) 
                                    if Config.Basic.TeleportForward then
                                        if GetVehicleClass(car) == 20 or GetVehicleClass(car) == 19 or GetVehicleClass(car) == 10 or GetVehicleClass(car) == 17 then
                                            FreezeEntityPosition(car, true)
                                            local coords = GetEntityCoords(car)
                                            local forward = GetEntityForwardVector(car)
                                            coords = (coords + forward * 2.0)
                                            FreezeEntityPosition(car, false)
                                            SetEntityCoords(car, coords.x, coords.y, coords.z, false, false, false)
                                        end
                                    end
                                    SetModelAsNoLongerNeeded(data.model)
                                    TaskWarpPedIntoVehicle(PlayerPedId(), car, -1)
                                    Wait(200)
                                    SetEntityAsMissionEntity(car, true, true)    
                                    SetVehicleHasBeenOwnedByPlayer(car, true)  
                                    TriggerEvent("vehiclekeys:client:SetOwner", QBCore.Functions.GetPlate(car))
                                    if Config.Basic.LockVehicle then
                                        SetVehicleDoorsLocked(car, 1)
                                        SetVehicleDoorsLockedForAllPlayers(car, true) 
                                        if Config.Interactions.QBVehicleKeys.using and GetResourceState(Config.Interactions.QBVehicleKeys.resource) == 'started' then
                                            TriggerServerEvent('qb-vehiclekeys:server:setVehLockState', NetworkGetNetworkIdFromEntity(car), 2)
                                        else
                                            TriggerServerEvent('d-garagev2:lockveh', VehToNet(vehicle or car), 2)
                                        end
                                    end
                                    if Config.Basic.StartEngine then
                                        if Config.Interactions.EngineToggle.using and GetResourceState(Config.Interactions.EngineToggle.resource) == 'started' then
                                            Wait(200)
                                            TriggerEvent('EngineToggle:Engine')
                                        else
                                            SetVehicleEngineOn(vehicle or car, true, true)
                                            Citizen.Wait(100)
                                            SetVehicleEngineOn(vehicle or car, true, true)
                                            Citizen.Wait(100)
                                            SetVehicleEngineOn(vehicle or car, true, true)
                                        end
                                    end
                                    Wait(1000)
                                    notify(locale[Config.Basic.language]['taken_out'])
                                end, data, v)
                            elseif Config.Basic.SpawnVehicles == 'client' then
                                QBCore.Functions.SpawnVehicle(data.model, vector3(v.x, v.y, v.z), v.w, function(car)
                                    data.plate = veh_plate
                                    SetNetworkIdExistsOnAllMachines(VehToNet(car), true)
                                    SetVehicleProperties(car, data)
                                    NetworkFadeInEntity(car, true, true) 
                                    if Config.Basic.TeleportForward then
                                        if GetVehicleClass(car) == 20 or GetVehicleClass(car) == 19 or GetVehicleClass(car) == 10 or GetVehicleClass(car) == 17 then
                                            FreezeEntityPosition(car, true)
                                            local coords = GetEntityCoords(car)
                                            local forward = GetEntityForwardVector(car)
                                            coords = (coords + forward * 2.0)
                                            FreezeEntityPosition(car, false)
                                            SetEntityCoords(car, coords.x, coords.y, coords.z, false, false, false)
                                        end
                                    end
                                    SetModelAsNoLongerNeeded(data.model)
                                    TaskWarpPedIntoVehicle(PlayerPedId(), car, -1)
                                    Wait(200)
                                    SetEntityAsMissionEntity(car, true, true)    
                                    SetVehicleHasBeenOwnedByPlayer(car, true)  
                                    TriggerEvent("vehiclekeys:client:SetOwner", QBCore.Functions.GetPlate(car))
                                    if Config.Basic.LockVehicle then
                                        SetVehicleDoorsLocked(car, 1)
                                        SetVehicleDoorsLockedForAllPlayers(car, true) 
                                        if Config.Interactions.QBVehicleKeys.using and GetResourceState(Config.Interactions.QBVehicleKeys.resource) == 'started' then
                                            TriggerServerEvent('qb-vehiclekeys:server:setVehLockState', NetworkGetNetworkIdFromEntity(car), 2)
                                        else
                                            TriggerServerEvent('d-garagev2:lockveh', VehToNet(vehicle or car), 2)
                                        end
                                    end
                                    if Config.Basic.StartEngine then
                                        if Config.Interactions.EngineToggle.using and GetResourceState(Config.Interactions.EngineToggle.resource) == 'started' then
                                            Wait(200)
                                            TriggerEvent('EngineToggle:Engine')
                                        else
                                            SetVehicleEngineOn(vehicle or car, true, true)
                                            Citizen.Wait(100)
                                            SetVehicleEngineOn(vehicle or car, true, true)
                                            Citizen.Wait(100)
                                            SetVehicleEngineOn(vehicle or car, true, true)
                                        end
                                    end
                                    Wait(1000)
                                    notify(locale[Config.Basic.language]['taken_out'])
                                end)
                            end
                            return false
                        else
                            if k == #Config.Garages[current]['slots'] then
                                notify(locale[Config.Basic.language]['place_occupied'])
                            end
                        end
                    end
                end
            end, data.plate, data.type == 'impound', current)
        else
            local exp = export
            take_out = false
            export = {}
            QBCore.Functions.TriggerCallback('d-garagev2:getVehicle', function(data)
                if data then
                    for k,v in pairs(exp.Spawnpoints) do
                        if IsSpawnPointClear(vector3(v.x, v.y, v.z), Config.Basic.RadiusBetweeen) then
                            if Config.Basic.SpawnVehicles == 'server' then
                                QBCore.Functions.TriggerCallback('d-garage:SpawnVehicle', function(vehicle, props)
                                    local car = NetToVeh(vehicle)
                                    while not DoesEntityExist(car) do
                                        Wait(100)
                                    end
                                    Wait(100)
                                    SetVehicleProperties(car, props)
                                    Wait(100)
                                    SetEntityAsMissionEntity(car, true)
                                    SetNetworkIdExistsOnAllMachines(vehicle, true)
                                    NetworkFadeInEntity(car, true, true) 
                                    if Config.Basic.TeleportForward then
                                        if GetVehicleClass(car) == 20 or GetVehicleClass(car) == 19 or GetVehicleClass(car) == 10 or GetVehicleClass(car) == 17 then
                                            FreezeEntityPosition(car, true)
                                            local coords = GetEntityCoords(car)
                                            local forward = GetEntityForwardVector(car)
                                            coords = (coords + forward * 2.0)
                                            FreezeEntityPosition(car, false)
                                            SetEntityCoords(car, coords.x, coords.y, coords.z, false, false, false)
                                        end
                                    end
                                    SetModelAsNoLongerNeeded(data.model)
                                    TaskWarpPedIntoVehicle(PlayerPedId(), car, -1)
                                    Wait(200)
                                    SetEntityAsMissionEntity(car, true, true)    
                                    SetVehicleHasBeenOwnedByPlayer(car, true)  
                                    if Config.Basic.LockVehicle then
                                        SetVehicleDoorsLocked(car, 1)
                                        SetVehicleDoorsLockedForAllPlayers(car, true) 
                                        TriggerServerEvent('d-garagev2:lockveh', VehToNet(vehicle or car), 2)
                                    end
                                    if Config.Basic.StartEngine then
                                        if Config.Interactions.EngineToggle.using and GetResourceState(Config.Interactions.EngineToggle.resource) == 'started' then
                                            Wait(200)
                                            TriggerEvent('EngineToggle:Engine')
                                        else
                                            SetVehicleEngineOn(vehicle or car, true, true)
                                            Citizen.Wait(100)
                                            SetVehicleEngineOn(vehicle or car, true, true)
                                            Citizen.Wait(100)
                                            SetVehicleEngineOn(vehicle or car, true, true)
                                        end
                                    end
                                    Wait(1000)
                                    notify(locale[Config.Basic.language]['taken_out'])
                                end, data, v)
                            elseif Config.Basic.SpawnVehicles == 'client' then
                                QBCore.Functions.SpawnVehicle(data.model, vector3(v.x, v.y, v.z), v.w, function(car)
                                    data.plate = veh_plate
                                    SetNetworkIdExistsOnAllMachines(VehToNet(car), true)
                                    SetVehicleProperties(car, data)
                                    NetworkFadeInEntity(car, true, true) 
                                    if Config.Basic.TeleportForward then
                                        if GetVehicleClass(car) == 20 or GetVehicleClass(car) == 19 or GetVehicleClass(car) == 10 or GetVehicleClass(car) == 17 then
                                            FreezeEntityPosition(car, true)
                                            local coords = GetEntityCoords(car)
                                            local forward = GetEntityForwardVector(car)
                                            coords = (coords + forward * 2.0)
                                            FreezeEntityPosition(car, false)
                                            SetEntityCoords(car, coords.x, coords.y, coords.z, false, false, false)
                                        end
                                    end
                                    SetModelAsNoLongerNeeded(data.model)
                                    TaskWarpPedIntoVehicle(PlayerPedId(), car, -1)
                                    Wait(200)
                                    SetEntityAsMissionEntity(car, true, true)    
                                    SetVehicleHasBeenOwnedByPlayer(car, true)  
                                    if Config.Basic.LockVehicle then
                                        SetVehicleDoorsLocked(car, 1)
                                        SetVehicleDoorsLockedForAllPlayers(car, true) 
                                        TriggerServerEvent('d-garagev2:lockveh', VehToNet(vehicle or car), 2)
                                    end
                                    if Config.Interactions.EngineToggle.using and GetResourceState(Config.Interactions.EngineToggle.resource) == 'started' then
                                        Wait(200)
                                        TriggerEvent('EngineToggle:Engine')
                                    else
                                        SetVehicleEngineOn(vehicle or car, true, true)
                                        Citizen.Wait(100)
                                        SetVehicleEngineOn(vehicle or car, true, true)
                                        Citizen.Wait(100)
                                        SetVehicleEngineOn(vehicle or car, true, true)
                                    end
                                    Wait(1000)
                                    notify(locale[Config.Basic.language]['taken_out'])
                                end)
                            end
                            return false
                        else
                            if k == #exp.Spawnpoints then
                                notify(locale[Config.Basic.language]['place_occupied'])
                            end
                        end
                    end
                end
            end, data.plate, data.type == 'impound', exp)
        end
    end
end)

function GetDisplayText(model)
    local displaytext = GetDisplayNameFromVehicleModel(model)
    local name = GetLabelText(displaytext)
    if (name == "NULL") then
        vehicleLabel = displaytext
    else
        vehicleLabel = name
    end
    return vehicleLabel
end

Citizen.CreateThread(function()
    TriggerServerEvent('d-garagev2:GetGarages')
    Wait(1000)
    while not Config.Garages do 
        Wait(100)
    end
    Wait(500)
    RefreshScript()
    PlayerPed = PlayerPedId()
end)

local peds = {}
local ped_props = {}
local blips = {}
local created = false
function RefreshScript()
    if Config.Garages ~= nil then 
        if cache.vehicle and DoesEntityExist(cache.vehicle) then
            DeleteEntity(cache.vehicle)
        end
        --[[for k,v in pairs(peds) do
            DeletePed(v)
        end
        for k,v in pairs(ped_props) do
            DeleteObject(v)
        end
        for k,v in pairs(blips) do
            RemoveBlip(v)
        end]]--
        for k,v in pairs(Config.Garages) do
            if Config.Management.Ped.loadped == 'default' then
                local hash = GetHashKey(Config.Management.Ped.model)
                RequestModel(hash)
                while not HasModelLoaded(hash) do
                    Citizen.Wait(100) 
                end
                local ped = CreatePed(28, hash, v.coords.x, v.coords.y, v.coords.z -1, 0.0, false, true)
                peds[k] = ped
                SetEntityHeading(ped, v.coords.w)
                FreezeEntityPosition(ped, true)
                SetEntityInvincible(ped, true)
                SetBlockingOfNonTemporaryEvents(ped, true)
                if Config.Management.Ped.default.enable then
                    playAnim(ped, Config.Management.Ped.default.dist, Config.Management.Ped.default.anim, -1, 1, Config.Management.Ped.default.props, k)
                    Wait(100)
                end
            end

            if v.class then
                local blip = AddBlipForCoord(v.coords.x, v.coords.y, v.coords.z)
                table.insert(blips, blip)
                SetBlipSprite(blip, Config.Blip[tostring(v.type)][v.class].spirite)
                SetBlipDisplay(blip, 4)
                SetBlipScale(blip, 0.4)
                SetBlipColour(blip, Config.Blip[tostring(v.type)][v.class].color)
                SetBlipAsShortRange(blip, true)
                BeginTextCommandSetBlipName("STRING")
                AddTextComponentString(locale[Config.Basic.language]['blip_'..tostring(v.type)..'_'..v.class])
                EndTextCommandSetBlipName(blip)
            end
        end
        if Config.Management.Target.using then
            if Config.Management.Target.resource ~= 'ox_target' then
                if created then
                    exports[Config.Management.Target.resource]:RemoveTargetEntity(GetHashKey(Config.Management.Ped), {
                        locale[Config.Basic.language]['open_garage'],
                        locale[Config.Basic.language]['open_store']
                    })
                end
                if Config.Management.Target.deleter then
                    exports[Config.Management.Target.resource]:AddTargetModel({GetHashKey(Config.Management.Ped.model)}, {
                        options = {
                            {
                                event = "d-garagev2:openMenu",
                                icon = "fa-solid fa-square-parking",
                                label = locale[Config.Basic.language]['open_garage'],
                            },
                            {
                                event = "d-garagev2:storeVeh",
                                icon = "fa-solid fa-arrow-right-to-bracket",
                                label = locale[Config.Basic.language]['open_store'],
                            },
                        },
                        distance = 2
                    })
                    created = true
                else
                    exports[Config.Management.Target.resource]:AddTargetModel({GetHashKey(Config.Management.Ped.model)}, {
                        options = {
                            {
                                event = "d-garagev2:openMenu",
                                icon = "fa-solid fa-square-parking",
                                label = locale[Config.Basic.language]['open_garage'],
                            },
                        },
                        distance = 2
                    })
                    created = true
                end
            else
                if created then
                    exports.ox_target:removeModel({GetHashKey(Config.Management.Ped)}, {
                        locale[Config.Basic.language]['open_garage'],
                        locale[Config.Basic.language]['open_store']
                    })
                end
                if Config.Management.Target.deleter then
                    exports.ox_target:addModel(GetHashKey(Config.Management.Ped.model), 
                        {
                            {
                                name = "ox_target:openMenu",
                                event = "d-garagev2:openMenu",
                                icon = "fa-solid fa-square-parking",
                                label = locale[Config.Basic.language]['open_garage'],
                                canInteract = function(entity, distance, coords, name, bone)
                                    return distance <= 2
                                end
                            },
                            {
                                name = "ox_target:storeVeh",
                                event = "d-garagev2:storeVeh",
                                icon = "fa-solid fa-arrow-right-to-bracket",
                                label = locale[Config.Basic.language]['open_store'],
                                canInteract = function(entity, distance, coords, name, bone)
                                    return distance <= 2
                                end
                            }
                        }
                    )
                    created = true
                else
                    exports.ox_target:addModel(GetHashKey(Config.Management.Ped.model), 
                        {
                            {
                                name = "ox_target:openMenu",
                                event = "d-garagev2:openMenu",
                                icon = "fa-solid fa-square-parking",
                                label = locale[Config.Basic.language]['open_garage'],
                                canInteract = function(entity, distance, coords, name, bone)
                                    return distance <= 2
                                end
                            },
                        }
                    )
                    created = true
                end
            end
        end
    end
end

if Config.Management.Ped.loadped == 'distance' then
    Citizen.CreateThread(function()
        while not Config.Garages do 
            Wait(100)
        end
        while true do
            local k,v = getNearGarage(GetEntityCoords(PlayerPedId()), 20.0)
            if k then
                if not peds[k] then
                    local hash = GetHashKey(Config.Management.Ped.model)
                    RequestModel(hash)
                    while not HasModelLoaded(hash) do
                        Citizen.Wait(100) 
                    end
                    local ped = CreatePed(28, hash, v.coords.x, v.coords.y, v.coords.z -1, 0.0, false, true)
                    peds[k] = ped
                    SetEntityHeading(ped, v.coords.w)
                    FreezeEntityPosition(ped, true)
                    SetEntityInvincible(ped, true)
                    SetBlockingOfNonTemporaryEvents(ped, true)
                    if Config.Management.Ped.default.enable then
                        playAnim(ped, Config.Management.Ped.default.dist, Config.Management.Ped.default.anim, -1, 1, Config.Management.Ped.default.props, k)
                        Wait(100)
                    end
                end
            else
                for _,ped in pairs(peds) do
                    if DoesEntityExist(ped) then
                        DeletePed(ped)
                    end
                end
                for _,prop in pairs(ped_props) do
                    if DoesEntityExist(prop) then
                        DeleteObject(prop)
                    end
                end
                peds = {}
                ped_props = {}
            end
            Wait(1200)
        end
    end)
end

function playAnim(ped, animDict, animName, duration, flag, props, garage)
	RequestAnimDict(animDict)
	while not HasAnimDictLoaded(animDict) do Citizen.Wait(100) end
	TaskPlayAnim(ped, animDict, animName, 1.0, -1.0, duration, flag, 1, false, false, false)
	RemoveAnimDict(animDict)

    if props then
        if props.prop then
            local c = GetEntityCoords(ped)
            local prop = GetHashKey(props.prop)
            while not HasModelLoaded(prop) do
                RequestModel(prop)
                Wait(100)
            end
            local prop = CreateObject(prop, c.x, c.y, c.z, false, true, false)
            ped_props[garage] = prop
            placement = props.placement
            AttachEntityToEntity(prop, ped, GetPedBoneIndex(ped, props.bone), placement[1] + 0.0, placement[2] + 0.0, placement[3] + 0.0, placement[4] + 0.0, placement[5] + 0.0, placement[6] + 0.0, true, true, false, true, 1, true)
        end
    end
end

RegisterNetEvent('d-garagev2:refreshScript', function(data)
    Config.Garages = data
    RefreshScript()
end)

RegisterNetEvent('d-garagev2:GetConfig', function(data)
    Config.Garages = data
end)

local kraunama = false
AddEventHandler('d-garagev2:openMenu', function(data)
    if not kraunama then
        kraunama = true
        open = true
        local type = 'garage'
        PlayerPed = PlayerPedId()
        local coords = GetEntityCoords(PlayerPed)
        local garazas = ''
        local class = ''
        for k,v in pairs(Config.Garages) do
            if #(coords - vector3(v.coords.x, v.coords.y, v.coords.z)) <= 4.0 then
                type = v.type
                garazas = '' ..k
                class = v.class
            end
        end
        if Config.Framework == 'esx' then
            ESX.TriggerServerCallback('d-garagev2:getVehicles', function(data, color)
                if #data[type] > 0 then
                    vehicles = data.garage
                    impound = data.impound
                    for i = 1, #vehicles do
                        local veh = json.decode(vehicles[i].vehicle) 
                        if veh and veh.model then
                            if vehicles[i].name == 'Unknown' or vehicles[i].name == 'Nerastas' then
                                local displaytext = GetDisplayNameFromVehicleModel(veh.model)
                                local name = GetLabelText(displaytext)
                                if (name == "NULL") then
                                    vehicles[i].name = displaytext
                                else
                                    vehicles[i].name = name
                                end
                                TriggerServerEvent('d-garagev2:saveName', vehicles[i].plate, vehicles[i].name)
                            end
                        end
                    end
                    for i = 1, #impound do
                        local veh = json.decode(impound[i].vehicle) 
                        if veh and veh.model then
                            if impound[i].name == 'Unknown' or impound[i].name == 'Nerastas' then
                                local displaytext = GetDisplayNameFromVehicleModel(veh.model)
                                local name = GetLabelText(displaytext)
                                if (name == "NULL") then
                                    impound[i].name = displaytext
                                else
                                    impound[i].name = name
                                end
                                TriggerServerEvent('d-garagev2:saveName', impound[i].plate, impound[i].name)
                            end
                        end
                    end
                    if Config.Management.Ped.default.speak.enable then
                        PlayPedAmbientSpeechNative(peds[garazas], Config.Management.Ped.default.speak.name, Config.Management.Ped.default.speak.param)
                        DeleteObject(ped_props[garazas])
                        playAnim(peds[garazas], Config.Management.Ped.default.speak.dist, Config.Management.Ped.default.speak.anim, 500, 1)
                        Wait(1500)
                        StopCurrentPlayingAmbientSpeech(peds[garazas])
                        if Config.Management.Ped.default.enable then
                            playAnim(peds[garazas], Config.Management.Ped.default.dist, Config.Management.Ped.default.anim, -1, 1, Config.Management.Ped.default.props, garazas)
                        end
                    end
                    zone, street = GetStreets() 
                    HandleCamera(true, coords, nil, class)
                    SendNUIMessage({
                        show = true,
                        vehicles = vehicles,
                        impound = impound,
                        Config = Config,
                        locale = locale,
                        type = type,
                        address = address,
                        street = street,
                        color = color,
                        class = class
                    })    
                    SetNuiFocus(true, true)   
                    kraunama = false 
                else
                    open = false
                    kraunama = false 
                    notify(locale[Config.Basic.language]['no_vehicles'])
                    if Config.Management.Ped.noveh.speak.enable then
                        PlayPedAmbientSpeechNative(peds[garazas], Config.Management.Ped.noveh.speak.name, Config.Management.Ped.noveh.speak.param)
                    end
                    DeleteObject(ped_props[garazas])
                    if Config.Management.Ped.noveh.anims.enable then
                        playAnim(peds[garazas], Config.Management.Ped.noveh.anims.dist, Config.Management.Ped.noveh.anims.anim, -1, 1)
                    end

                    Wait(5000)
                    StopCurrentPlayingAmbientSpeech(peds[garazas])
                    if Config.Management.Ped.default.enable then
                        playAnim(peds[garazas], Config.Management.Ped.default.dist, Config.Management.Ped.default.anim, -1, 1, Config.Management.Ped.default.props, garazas)
                    end
                end
            end, class)
        elseif Config.Framework == 'qb' then
            QBCore.Functions.TriggerCallback('d-garagev2:getVehicles', function(data, color)
                if #data[type] > 0 then
                    vehicles = data.garage
                    impound = data.impound
                    for i = 1, #vehicles do
                        local hash = GetHashKey(vehicles[i].vehicle)
                        if vehicles[i].name == 'Unknown' or vehicles[i].name == 'Nerastas' then
                            local displaytext = GetDisplayNameFromVehicleModel(hash)
                            local name = GetLabelText(displaytext)
                            if (name == "NULL") then
                                vehicles[i].name = displaytext
                            else
                                vehicles[i].name = name
                            end
                            TriggerServerEvent('d-garagev2:saveName', vehicles[i].plate, vehicles[i].name)
                        end
                    end
                    for i = 1, #impound do
                        local hash = GetHashKey(impound[i].vehicle)
                        if impound[i].name == 'Unknown' or impound[i].name == 'Nerastas' then
                            local displaytext = GetDisplayNameFromVehicleModel(hash)
                            local name = GetLabelText(displaytext)
                            if (name == "NULL") then
                                impound[i].name = displaytext
                            else
                                impound[i].name = name
                            end
                            TriggerServerEvent('d-garagev2:saveName', impound[i].plate, impound[i].name)
                        end
                    end
                    if Config.Management.Ped.default.speak.enable then
                        PlayPedAmbientSpeechNative(peds[garazas], Config.Management.Ped.default.speak.name, Config.Management.Ped.default.speak.param)
                        DeleteObject(ped_props[garazas])
                        playAnim(peds[garazas], Config.Management.Ped.default.speak.dist, Config.Management.Ped.default.speak.anim, 500, 1)
                        Wait(1500)
                        StopCurrentPlayingAmbientSpeech(peds[garazas])
                        if Config.Management.Ped.default.enable then
                            playAnim(peds[garazas], Config.Management.Ped.default.dist, Config.Management.Ped.default.anim, -1, 1, Config.Management.Ped.default.props, garazas)
                        end
                    end
                    zone, street = GetStreets() 
                    HandleCamera(true, coords, nil, class)
                    SendNUIMessage({
                        show = true,
                        vehicles = vehicles,
                        impound = impound,
                        Config = Config,
                        locale = locale,
                        type = type,
                        address = address,
                        street = street,
                        color = color,
                        class = class,
                    })    
                    SetNuiFocus(true, true)    
                    kraunama = false 
                else
                    open = false
                    kraunama = false 
                    notify(locale[Config.Basic.language]['no_vehicles'])
                    if Config.Management.Ped.noveh.speak.enable then
                        PlayPedAmbientSpeechNative(peds[garazas], Config.Management.Ped.noveh.speak.name, Config.Management.Ped.noveh.speak.param)
                    end
                    DeleteObject(ped_props[garazas])
                    if Config.Management.Ped.noveh.anims.enable then
                        playAnim(peds[garazas], Config.Management.Ped.noveh.anims.dist, Config.Management.Ped.noveh.anims.anim, -1, 1)
                    end

                    Wait(5000)
                    StopCurrentPlayingAmbientSpeech(peds[garazas])
                    if Config.Management.Ped.default.enable then
                        playAnim(peds[garazas], Config.Management.Ped.default.dist, Config.Management.Ped.default.anim, -1, 1, Config.Management.Ped.default.props, garazas)
                    end
                end
            end, class)
        end
    end
end)

exports('openGarage', function(job, type, params)
    if not kraunama then
        kraunama = true 
        export = params
        if Config.Framework == 'esx' then
            ESX.TriggerServerCallback('d-garagev2:getJobVehicles', function(data, color)
                if data[type] then
                    vehicles = data.garage
                    impound = data.impound
                    for i = 1, #vehicles do
                        if vehicles[i] then
                            local veh = json.decode(vehicles[i].vehicle) 
                            if vehicles[i].name == 'Unknown' or vehicles[i].name == 'Nerastas' then
                                local displaytext = GetDisplayNameFromVehicleModel(veh.model)
                                local name = GetLabelText(displaytext)
                                if (name == "NULL") then
                                    vehicles[i].name = displaytext
                                else
                                    vehicles[i].name = name
                                end
                                TriggerServerEvent('d-garagev2:saveName', vehicles[i].plate, vehicles[i].name)
                            end
                            if veh and veh.model then
                                if export.Type == 'land' then
                                    if GetVehicleClassFromName(veh.model) == 15 or GetVehicleClassFromName(veh.model) == 14 or GetVehicleClassFromName(veh.model) == 16 then
                                        table.remove(vehicles, i)
                                    end
                                elseif export.Type == 'sky' then
                                    if GetVehicleClassFromName(veh.model) ~= 15 or GetVehicleClassFromName(veh.model) ~= 16 then
                                        table.remove(vehicles, i)
                                    end
                                elseif export.Type == 'water' then
                                    if GetVehicleClassFromName(veh.model) ~= 14 then
                                        table.remove(vehicles, i)
                                    end
                                end
                            end
                        end
                    end
                    for i = 1, #impound do
                        if impound[i] then
                            if impound[i].name == 'Unknown' or impound[i].name == 'Nerastas' then
                                local displaytext = GetDisplayNameFromVehicleModel(veh.model)
                                local name = GetLabelText(displaytext)
                                if (name == "NULL") then
                                    impound[i].name = displaytext
                                else
                                    impound[i].name = name
                                end
                                TriggerServerEvent('d-garagev2:saveName', impound[i].plate, impound[i].name)
                            end
                            local veh = json.decode(impound[i].vehicle) 
                            if veh and veh.model then
                                if export.Type == 'land' then
                                    if GetVehicleClassFromName(veh.model) == 15 or GetVehicleClassFromName(veh.model) == 14 or GetVehicleClassFromName(veh.model) == 16 then
                                        table.remove(impound, i)
                                    end
                                elseif export.Type == 'sky' then
                                    if GetVehicleClassFromName(veh.model) ~= 15 or GetVehicleClassFromName(veh.model) ~= 16 then
                                        table.remove(impound, i)
                                    end
                                elseif export.Type == 'water' then
                                    if GetVehicleClassFromName(veh.model) ~= 14 then
                                        table.remove(impound, i)
                                    end
                                end
                            end
                        end
                    end
                    zone, street = GetStreets() 
                    HandleCamera(true, false, params, export.Type)
                    SendNUIMessage({
                        show = true,
                        vehicles = vehicles,
                        impound = impound,
                        Config = Config,
                        locale = locale,
                        type = type,
                        address = address,
                        street = street,
                        color = color,
                        class = export.Type,
                    })    
                    SetNuiFocus(true, true)   
                    kraunama = false 
                else
                    notify(locale[Config.Basic.language]['no_vehicles'])
                end
            end, job, type)
        elseif Config.Framework == 'qb' then
            QBCore.Functions.TriggerCallback('d-garagev2:getVehicles', function(vehicles, impound, color)
                if data[type] then
                    vehicles = data.garage
                    impound = data.impound
                    for i = 1, #vehicles do
                        if vehicles[i] then
                            local veh = json.decode(vehicles[i].vehicle) 
                            if vehicles[i].name == 'Unknown' or vehicles[i].name == 'Nerastas' then
                                local displaytext = GetDisplayNameFromVehicleModel(veh.model)
                                local name = GetLabelText(displaytext)
                                if (name == "NULL") then
                                    vehicles[i].name = displaytext
                                else
                                    vehicles[i].name = name
                                end
                                TriggerServerEvent('d-garagev2:saveName', vehicles[i].plate, vehicles[i].name)
                            end
                            if veh and veh.model then
                                if export.Type == 'land' then
                                    if GetVehicleClassFromName(veh.model) == 15 or GetVehicleClassFromName(veh.model) == 14 or GetVehicleClassFromName(veh.model) == 16 then
                                        table.remove(vehicles, i)
                                    end
                                elseif export.Type == 'sky' then
                                    if GetVehicleClassFromName(veh.model) ~= 15 or GetVehicleClassFromName(veh.model) ~= 16 then
                                        table.remove(vehicles, i)
                                    end
                                elseif export.Type == 'water' then
                                    if GetVehicleClassFromName(veh.model) ~= 14 then
                                        table.remove(vehicles, i)
                                    end
                                end
                            end
                        end
                    end
                    for i = 1, #impound do
                        if impound[i] then
                            if impound[i].name == 'Unknown' or impound[i].name == 'Nerastas' then
                                local displaytext = GetDisplayNameFromVehicleModel(veh.model)
                                local name = GetLabelText(displaytext)
                                if (name == "NULL") then
                                    impound[i].name = displaytext
                                else
                                    impound[i].name = name
                                end
                                TriggerServerEvent('d-garagev2:saveName', impound[i].plate, impound[i].name)
                            end
                            local veh = json.decode(impound[i].vehicle) 
                            if veh and veh.model then
                                if export.Type == 'land' then
                                    if GetVehicleClassFromName(veh.model) == 15 or GetVehicleClassFromName(veh.model) == 14 or GetVehicleClassFromName(veh.model) == 16 then
                                        table.remove(impound, i)
                                    end
                                elseif export.Type == 'sky' then
                                    if GetVehicleClassFromName(veh.model) ~= 15 or GetVehicleClassFromName(veh.model) ~= 16 then
                                        table.remove(impound, i)
                                    end
                                elseif export.Type == 'water' then
                                    if GetVehicleClassFromName(veh.model) ~= 14 then
                                        table.remove(impound, i)
                                    end
                                end
                            end
                        end
                    end
                    zone, street = GetStreets() 
                    HandleCamera(true, false, params, export.Type)
                    SendNUIMessage({
                        show = true,
                        vehicles = vehicles,
                        impound = impound,
                        Config = Config,
                        locale = locale,
                        type = type,
                        address = address,
                        street = street,
                        color = color,
                        class = export.Type,
                    })    
                    SetNuiFocus(true, true)    
                    kraunama = false 
                else
                    notify(locale[Config.Basic.language]['no_vehicles'])
                end
            end, job, type)
        end
    end
end)

AddEventHandler('d-garagev2:storeVeh', function()
    local vehicle = GetEntityCoords(GetLastDrivenVehicle())
    local coords = GetEntityCoords(PlayerPedId())
    local k,v = getNearGarage(GetEntityCoords(PlayerPedId()), 4.5)
    if k then 
        kraunama = false
        SaveVeh(tostring(k))
    end
    --[[for k,v in pairs(Config.Garages) do
        if #(coords - vector3(v.coords.x, v.coords.y, v.coords.z)) < 4.0 then
            if #(vehicle - coords) < 10.0 then
                SaveVeh(tostring(k))
            end
        end
    end]]
end)

local stored = false
function SaveVeh(garage)
    if not stored then
        local vehicle = GetVehiclePedIsIn(PlayerPedId(), false)

        if DoesEntityExist(vehicle) then
            local props = GetVehicleProperties(vehicle)
            if Config.Framework == 'esx' then
                ESX.TriggerServerCallback('d-garagev2:haveVehicle', function(owner)
                    if owner then
                        if Config.Basic.DeleteVehicles == 'client' then
                            SetEntityAsMissionEntity(vehicle, true, true) 
                            Wait(100)
                            DeleteVehicle(vehicle)
                            DeleteEntity(vehicle)
                            Wait(100)
                            if DoesEntityExist(vehicle) then
                                while DoesEntityExist(vehicle) do
                                    SetEntityAsMissionEntity(vehicle, true, true) 
                                    DeleteVehicle(vehicle)
                                    DeleteEntity(vehicle)
                                    Wait(100)
                                end
                            end
                        end
                        notify(locale[Config.Basic.language]['stored'])
                    else
                        notify(locale[Config.Basic.language]['not_owner'])
                    end
                end, props, garage, garage_class, VehToNet(vehicle))
            elseif Config.Framework == 'qb' then
                local props = GetVehicleProperties(vehicle)
                QBCore.Functions.TriggerCallback('d-garagev2:haveVehicle', function(owner)
                    if owner then
                        if Config.Basic.DeleteVehicles == 'client' then
                            SetEntityAsMissionEntity(vehicle, true, true) 
                            Wait(100)
                            DeleteVehicle(vehicle)
                            DeleteEntity(vehicle)
                            Wait(100)
                            if DoesEntityExist(vehicle) then
                                while DoesEntityExist(vehicle) do
                                    SetEntityAsMissionEntity(vehicle, true, true) 
                                    DeleteVehicle(vehicle)
                                    DeleteEntity(vehicle)
                                    Wait(100)
                                end
                            end
                        end
                        notify(locale[Config.Basic.language]['stored'])
                    else
                        notify(locale[Config.Basic.language]['not_owner'])
                    end
                end, props, garage, garage_class, VehToNet(vehicle))
            end
        end
        stored = true
        Wait(2000)
        stored = false
    end
end

exports('impound', function(distance, price)
    local coords = GetEntityCoords(PlayerPedId())
    if Config.Framework == 'esx' then
        local vehicle = ESX.Game.GetClosestVehicle(coords)
        local vehc = GetEntityCoords(vehicle)
        if #(vehc - coords) <= distance then
            local class = 'land'
            if GetVehicleClass(vehicle) == 15 or GetVehicleClass(vehicle) == 16 then
                class = 'sky'
            elseif GetVehicleClass(vehicle) == 14 then
                class = 'water'
            else
                class = 'land'
            end
            TriggerServerEvent('d-garagev2:impound', GetVehicleNumberPlateText(vehicle), price, class)
            ESX.Game.DeleteVehicle(vehicle)
        end
    elseif Config.Framework == 'qb' then
        local vehicle = QBCore.Functions.GetClosestVehicle(coords)
        local vehc = GetEntityCoords(vehicle)
        if #(vehc - coords) <= distance then
            local class = 'land'
            if GetVehicleClass(vehicle) == 15 or GetVehicleClass(vehicle) == 16 then
                class = 'sky'
            elseif GetVehicleClass(vehicle) == 14 then
                class = 'water'
            else
                class = 'land'
            end
            TriggerServerEvent('d-garagev2:impound', GetVehicleNumberPlateText(vehicle), price, class)
            QBCore.Functions.DeleteVehicle(vehicle)
        end
    end
end)

exports('transfer', function(target)
    local vehicle = GetVehiclePedIsIn(PlayerPedId(), false)
    if Config.Framework == 'esx' then
        if GetPedInVehicleSeat(vehicle, -1) == PlayerPedId() and GetPedInVehicleSeat(vehicle, 0) == GetPlayerPed(GetPlayerFromServerId(target)) then
            local class = 'land'
            if GetVehicleClass(vehicle) == 15 or GetVehicleClass(vehicle) == 16 then
                class = 'sky'
            elseif GetVehicleClass(vehicle) == 14 then
                class = 'water'
            else
                class = 'land'
            end
            TriggerServerEvent('d-garagev2:transfer', GetVehicleNumberPlateText(vehicle), target, class)
        end
    elseif Config.Framework == 'qb' then
        if GetPedInVehicleSeat(vehicle, -1) == PlayerPedId() and GetPedInVehicleSeat(vehicle, 0) == GetPlayerPed(GetPlayerFromServerId(target)) then
            local class = 'land'
            if GetVehicleClass(vehicle) == 15 or GetVehicleClass(vehicle) == 16 then
                class = 'sky'
            elseif GetVehicleClass(vehicle) == 14 then
                class = 'water'
            else
                class = 'land'
            end
            TriggerServerEvent('d-garagev2:transfer', GetVehicleNumberPlateText(vehicle), target, class)
        end
    end
end)

AddEventHandler('onResourceStop', function(resourceName)
    if (GetCurrentResourceName() == resourceName) then
        if Config.Management.Target.resource ~= 'ox_target' then
            exports[Config.Management.Target.resource]:RemoveTargetEntity(GetHashKey(Config.Management.Ped), {
                locale[Config.Basic.language]['open_garage'],
                locale[Config.Basic.language]['open_store']
            })
        else
            exports.ox_target:removeModel({GetHashKey(Config.Management.Ped)}, {
                locale[Config.Basic.language]['open_garage'],
                locale[Config.Basic.language]['open_store']
            })
        end
        for k,v in pairs(peds) do
            DeletePed(v)
        end
        for k,v in pairs(ped_props) do
            DeleteObject(v)
        end
    end
end)

RegisterNUICallback('spawnlocal', function(data)
    local class = data.class
    if Config.Framework == 'esx' then
        ESX.TriggerServerCallback('d-garagev2:getLocalVehicle', function(data)
            if data then
                SpawnLocalVehicle(data, class)
            end
        end, data.plate, data.class)
    elseif Config.Framework == 'qb' then
        QBCore.Functions.TriggerCallback('d-garagev2:getLocalVehicle', function(data)
            if data then
                SpawnLocalVehicle(data, class)
            end
        end, data.plate, data.class)
    end
end)


function SetVehicleProperties(vehicle, props)
    if Config.Framework == 'esx' then
        ESX.Game.SetVehicleProperties(vehicle, props)

        --[[SetVehicleEngineHealth(vehicle, props.engineHealth and props.engineHealth + 0.0 or 1000.0)
        SetVehicleBodyHealth(vehicle, props.bodyHealth and props.bodyHealth + 0.0 or 1000.0)

        if Config.Interactions.LegacyFuel.using then
            exports[Config.Interactions.LegacyFuel.resource]:SetFuel(vehicle, tonumber(props.fuelLevel))
        else
            SetVehicleFuelLevel(vehicle, props.fuelLevel)
        end

        if props.windows then
            for windowId = 1, 8 do
                if not props.windows[windowId] then
                    SmashVehicleWindow(vehicle, windowId - 1)
                end
            end
        end

        if props.tyres then
            for tyreId = 1, 7 do
                if props.tyres[tyreId] then
                    SetVehicleTyreBurst(vehicle, tyreId, true, 1000)
                end
            end
        end

        if props.doors then
            for doorId = 0, 5 do
                if props.doors[doorId] then
                    SetVehicleDoorBroken(vehicle, doorId - 1, true)
                end
            end
        end

        SetVehicleLivery(vehicle, props.livery)
        SetVehicleRoofLivery(vehicle, props.rooflivery)]]

    elseif Config.Framework == 'qb' then
        QBCore.Functions.SetVehicleProperties(vehicle, props)

        SetVehicleEngineHealth(vehicle, props.engineHealth and props.engineHealth + 0.0 or 1000.0)
        SetVehicleBodyHealth(vehicle, props.bodyHealth and props.bodyHealth + 0.0 or 1000.0)

        if Config.Interactions.LegacyFuel.using then
            exports[Config.Interactions.LegacyFuel.resource]:SetFuel(vehicle, tonumber(props.fuelLevel))
        else
            SetVehicleFuelLevel(vehicle, props.fuelLevel)
        end

        if props.windows then
            for windowId = 1, 8 do
                if not props.windows[windowId] then
                    SmashVehicleWindow(vehicle, windowId - 1)
                end
            end
        end

        if props.tyres then
            for tyreId = 1, 7 do
                if props.tyres[tyreId] then
                    SetVehicleTyreBurst(vehicle, tyreId, true, 1000)
                end
            end
        end

        if props.doors then
            for doorId = 0, 5 do
                if props.doors[doorId] then
                    SetVehicleDoorBroken(vehicle, doorId - 1, true)
                end
            end
        end

        SetVehicleLivery(vehicle, props.livery)
        SetVehicleRoofLivery(vehicle, props.rooflivery)
        
    end
end

function GetVehicleProperties(vehicle)
    if Config.Framework == 'esx' then
        if DoesEntityExist(vehicle) then
            local props = ESX.Game.GetVehicleProperties(vehicle)

            --[[props.tyres = {}
            props.windows = {}
            props.doors = {}

            for id = 1, 7 do
                local tyreId = IsVehicleTyreBurst(vehicle, id, false)
            
                if tyreId then
                    props.tyres[#props.tyres + 1] = tyreId
            
                    if tyreId == false then
                        tyreId = IsVehicleTyreBurst(vehicle, id, true)
                        props.tyres[#props.tyres] = tyreId
                    end
                else
                    props.tyres[#props.tyres + 1] = false
                end
            end

            for id = 0, 7 do
                local windowId = IsVehicleWindowIntact(vehicle, id)
                if windowId ~= nil then
                    props.windows[#props.windows + 1] = windowId
                else
                    props.windows[#props.windows + 1] = true
                end
            end
            
            for id = 0, 5 do
                local doorId = IsVehicleDoorDamaged(vehicle, id)
            
                if doorId then
                    props.doors[#props.doors + 1] = doorId
                else
                    props.doors[#props.doors + 1] = false
                end
            end

            props.engineHealth = GetVehicleEngineHealth(vehicle)
            props.bodyHealth = GetVehicleBodyHealth(vehicle)
            props.fuelLevel = GetVehicleFuelLevel(vehicle)

            props.livery = GetVehicleLivery(vehicle)
            props.rooflivery = GetVehicleRoofLivery(vehicle)]]

            return props
        end
    elseif Config.Framework == 'qb' then
        if DoesEntityExist(vehicle) then
            local props = QBCore.Functions.GetVehicleProperties(vehicle)

            props.tyres = {}
            props.windows = {}
            props.doors = {}

            for id = 1, 7 do
                local tyreId = IsVehicleTyreBurst(vehicle, id, false)
            
                if tyreId then
                    props.tyres[#props.tyres + 1] = tyreId
            
                    if tyreId == false then
                        tyreId = IsVehicleTyreBurst(vehicle, id, true)
                        props.tyres[#props.tyres] = tyreId
                    end
                else
                    props.tyres[#props.tyres + 1] = false
                end
            end

            for id = 0, 7 do
                local windowId = IsVehicleWindowIntact(vehicle, id)
                if windowId ~= nil then
                    props.windows[#props.windows + 1] = windowId
                else
                    props.windows[#props.windows + 1] = true
                end
            end
            
            for id = 0, 5 do
                local doorId = IsVehicleDoorDamaged(vehicle, id)
            
                if doorId then
                    props.doors[#props.doors + 1] = doorId
                else
                    props.doors[#props.doors + 1] = false
                end
            end

            props.engineHealth = GetVehicleEngineHealth(vehicle)
            props.bodyHealth = GetVehicleBodyHealth(vehicle)
            props.fuelLevel = GetVehicleFuelLevel(vehicle)

            props.livery = GetVehicleLivery(vehicle)
            props.rooflivery = GetVehicleRoofLivery(vehicle)

            return props
        end
    end
end

AddStateBagChangeHandler('deivuks-garagev2:setVehicleProperties', nil, function(bagName, key, props)
	if props then
        local NetId = tonumber(bagName:gsub('entity:', ''), 10)
        local Vehicle = NetworkGetEntityFromNetworkId(NetId)

        if NetworkGetEntityOwner(Vehicle) == PlayerId() then
            SetVehicleProperties(Vehicle, props)
        end
	end
end)

function GetStreets() 
    coords = GetEntityCoords(PlayerPedId())
    local var1, var2 = GetStreetNameAtCoord(coords.x, coords.y, coords.z)
    address = GetStreetNameFromHashKey(var1)
    local zone = GetNameOfZone(coords.x, coords.y, coords.z)
    local street = GetLabelText(zone)
    return zone, street
end

function SpawnLocalVehicle(data, class)
	WaitForModel(data.model)

	if DoesEntityExist(cache.vehicle) then
		DeleteEntity(cache.vehicle)
	end

    if Config.Framework == 'esx' then
        if export.Cam then
            local coords = export.Cam.vehicle
            ESX.Game.SpawnLocalVehicle(data.model, vec3(coords.x, coords.y, coords.z), coords.w, function(vehicle)
                cache.vehicle = vehicle
                SetVehicleLights(vehicle, 2)
                FreezeEntityPosition(vehicle, true)
                SetEntityCollision(vehicle, false, true)
    
                SetVehicleProperties(vehicle, data)
                SetModelAsNoLongerNeeded(data.model)
            end)
        elseif not Config.Basic.OneCamera and not export.Cam then
            local coords = Config.Garages[current_garage2].Cam.vehicle
            ESX.Game.SpawnLocalVehicle(data.model, vec3(coords.x, coords.y, coords.z), coords.w, function(vehicle)
                cache.vehicle = vehicle
                SetVehicleLights(vehicle, 2)
                FreezeEntityPosition(vehicle, true)
                SetEntityCollision(vehicle, false, true)
    
                SetVehicleProperties(vehicle, data)
                SetModelAsNoLongerNeeded(data.model)
            end)
        elseif Config.Basic.OneCamera or not export.Cam then
            print(json.encode(data))
            ESX.Game.SpawnLocalVehicle(data.model, vec3(Config.LocalVehicle[class].Vehicle.coords.x, Config.LocalVehicle[class].Vehicle.coords.y, Config.LocalVehicle[class].Vehicle.coords.z), Config.LocalVehicle[class].Vehicle.coords.w, function(vehicle)
                cache.vehicle = vehicle
                SetVehicleLights(vehicle, 2)
                FreezeEntityPosition(vehicle, true)
                SetEntityCollision(vehicle, false, true)
    
                SetVehicleProperties(vehicle, data)
                SetModelAsNoLongerNeeded(data.model)
            end)
        end
    elseif Config.Framework == 'qb' then
        if export.Cam then
            local coords = export.Cam.vehicle
            local vehicle = CreateVehicle(data.model, coords.x, coords.y, coords.z, coords.w, false, true)
            cache.vehicle = vehicle
            SetVehicleLights(vehicle, 2)
            FreezeEntityPosition(vehicle, true)
            SetEntityCollision(vehicle, false, true)

            SetVehicleProperties(vehicle, data)
            SetModelAsNoLongerNeeded(data.model)
        elseif not Config.Basic.OneCamera and not export.Cam then
            local coords = Config.Garages[current_garage2].Cam.vehicle
            local vehicle = CreateVehicle(data.model, coords.x, coords.y, coords.z, coords.w, false, true)
            cache.vehicle = vehicle
            SetVehicleLights(vehicle, 2)
            FreezeEntityPosition(vehicle, true)
            SetEntityCollision(vehicle, false, true)

            SetVehicleProperties(vehicle, data)
            SetModelAsNoLongerNeeded(data.model)
        elseif Config.Basic.OneCamera or not export.Cam then
            local vehicle = CreateVehicle(data.model, Config.LocalVehicle[class].Vehicle.coords.x, Config.LocalVehicle[class].Vehicle.coords.y, Config.LocalVehicle[class].Vehicle.coords.z, Config.LocalVehicle[class].Vehicle.coords.w, false, true)
            cache.vehicle = vehicle
            SetVehicleLights(vehicle, 2)
            FreezeEntityPosition(vehicle, true)
            SetEntityCollision(vehicle, false, true)

            SetVehicleProperties(vehicle, data)
            SetModelAsNoLongerNeeded(data.model)
        end
    end
end

local inmenu = false
function HandleCamera(toggle, coords, export, class)
    if not export then export = {} end
    if Config.Basic.OneCamera and not export.Type then
        DisRadar() 
        inmenu = toggle
        DisableHud(toggle)
        if not toggle then
            FreezeEntityPosition(PlayerPedId(), false)
            SetEntityVisible(PlayerPedId(), true)
            SetEntityCoords(PlayerPedId(), cache.player.x, cache.player.y, cache.player.z, true, false, false, false)

            if cache.cam then
                DestroyCam(cache.cam)
            end
            
            if DoesEntityExist(cache.vehicle) then
                DeleteEntity(cache.vehicle)
            end

            RenderScriptCams(false, false, 0, 1, 0)

            return
        else
            cache.player = GetEntityCoords(PlayerPedId())
            Wait(100)
            SetEntityCoords(PlayerPedId(), Config.LocalVehicle[class].Player.coords.x, Config.LocalVehicle[class].Player.coords.y, Config.LocalVehicle[class].Player.coords.z, true, false, false, false)
            Wait(100)
            FreezeEntityPosition(PlayerPedId(), true)
            SetEntityVisible(PlayerPedId(), false)
        end

        if cache.cam then
            DestroyCam(cache.cam)
        end

        cache.cam = CreateCam("DEFAULT_SCRIPTED_CAMERA", true)

        local Pos = Config.LocalVehicle[class].Cam.coords
        local Rot = Config.LocalVehicle[class].Cam.rotation

        SetCamCoord(cache.cam, Pos.x, Pos.y, Pos.z)
        SetCamRot(cache.cam, Rot.x, Rot.y, Rot.z)
        SetCamActive(cache.cam, true)

        RenderScriptCams(true, false, 0, 1, 1)
    elseif not Config.Basic.OneCamera and not export.Type then
        if #export < 1 then
            DisRadar() 
            inmenu = toggle
            DisableHud(toggle)
            if not toggle then

                if cache.cam then
                    DestroyCam(cache.cam)
                end
                
                if DoesEntityExist(cache.vehicle) then
                    DeleteEntity(cache.vehicle)
                end

                RenderScriptCams(false, false, 0, 1, 0)

                return
            end

            current_garage2 = ''
            for k,v in pairs(Config.Garages) do
                if #(coords - vector3(v.coords.x, v.coords.y, v.coords.z)) <= 3 then
                    current_garage2 = ''..k
                    break
                end
            end
            local Pos = Config.Garages[current_garage2].Cam.coords
            local Rot = Config.Garages[current_garage2].Cam.rotation

            if cache.cam then
                DestroyCam(cache.cam)
            end

            cache.cam = CreateCam("DEFAULT_SCRIPTED_CAMERA", true)

            SetCamCoord(cache.cam, Pos.x, Pos.y, Pos.z)
            SetCamRot(cache.cam, Rot.x, Rot.y, Rot.z)
            SetCamActive(cache.cam, true)

            RenderScriptCams(true, false, 0, 1, 1)
        end
    elseif export.Type then
        if export.Cam then
            DisRadar() 
            inmenu = toggle
            DisableHud(toggle)
            if not toggle then
                if cache.cam then
                    DestroyCam(cache.cam)
                end
                
                if DoesEntityExist(cache.vehicle) then
                    DeleteEntity(cache.vehicle)
                end

                RenderScriptCams(false, false, 0, 1, 0)

                return
            end

            local Pos = export.Cam.position
            local Rot = export.Cam.rotation

            if cache.cam then
                DestroyCam(cache.cam)
            end

            cache.cam = CreateCam("DEFAULT_SCRIPTED_CAMERA", true)

            SetCamCoord(cache.cam, Pos.x, Pos.y, Pos.z)
            SetCamRot(cache.cam, Rot.x, Rot.y, Rot.z)
            SetCamActive(cache.cam, true)

            RenderScriptCams(true, false, 0, 1, 1)
        else 
            local Pos = Config.LocalVehicle[export.Type].Cam.coords
            local Rot = Config.LocalVehicle[export.Type].Cam.rotation
            DisRadar() 
            inmenu = toggle
            DisableHud(toggle)
            if not toggle then
                FreezeEntityPosition(PlayerPedId(), false)
                SetEntityVisible(PlayerPedId(), true)
                SetEntityCoords(PlayerPedId(), cache.player.x, cache.player.y, cache.player.z, true, false, false, false)

                if cache.cam then
                    DestroyCam(cache.cam)
                end
                
                if DoesEntityExist(cache.vehicle) then
                    DeleteEntity(cache.vehicle)
                end

                RenderScriptCams(false, false, 0, 1, 0)

                return
            else
                cache.player = GetEntityCoords(PlayerPedId())
                SetEntityCoords(PlayerPedId(), Config.LocalVehicle[class].Player.coords.x, Config.LocalVehicle[class].Player.coords.y, Config.LocalVehicle[class].Player.coords.z, true, false, false, false)
                Wait(100)
                FreezeEntityPosition(PlayerPedId(), true)
                SetEntityVisible(PlayerPedId(), false)
            end

            if cache.cam then
                DestroyCam(cache.cam)
            end

            cache.cam = CreateCam("DEFAULT_SCRIPTED_CAMERA", true)

            SetCamCoord(cache.cam, Pos.x, Pos.y, Pos.z)
            SetCamRot(cache.cam, Rot.x, Rot.y, Rot.z)
            SetCamActive(cache.cam, true)

            RenderScriptCams(true, false, 0, 1, 1)
        end
    end

	Citizen.Wait(500)
end

function DisRadar() 
    if Config.DisableRadar then
        Citizen.CreateThread(function()
            while inmenu do
                HideHudAndRadarThisFrame()
                Wait(0)
            end
        end)
    end
end

function DrawText3D(coords, text)
    local font = 4
	coords = vector3(coords.x, coords.y, coords.z + 1)

	local camCoords = GetGameplayCamCoords()
	local distance = #(coords - camCoords)

	if not font then font = 0 end

	local scale = (1 / distance) * 2
	local fov = (1 / GetGameplayCamFov()) * 100
	scale = scale * fov

	SetTextScale(0.0 * scale, 0.55 * scale)
	SetTextFont(font)
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

RegisterNetEvent('d-garagev2:nofity', function(message, type)
    notify(message, type)
end)

function GetVehicles() -- Leave the function for compatibility
	return GetGamePool('CVehicle')
end

function EnumerateEntitiesWithinDistance(entities, isPlayerEntities, coords, maxDistance)
	local nearbyEntities = {}

	if coords then
		coords = vector3(coords.x, coords.y, coords.z)
	else
		local playerPed = ESX.PlayerData.ped
		coords = GetEntityCoords(playerPed)
	end

	for k,entity in pairs(entities) do
		local distance = #(coords - GetEntityCoords(entity))

		if distance <= maxDistance then
			nearbyEntities[#nearbyEntities + 1] = isPlayerEntities and k or entity
		end
	end

	return nearbyEntities
end

function GetVehiclesInArea(coords, maxDistance)
	return EnumerateEntitiesWithinDistance(GetVehicles(), false, coords, maxDistance)
end

function IsSpawnPointClear(coords, maxDistance)
	return #GetVehiclesInArea(coords, maxDistance) == 0
end

function WaitForModel(model)
    if not IsModelValid(model) then
        notify(locale[Config.Basic.language]['does_not_exist'])
		return
    end

	if not HasModelLoaded(model) then
		RequestModel(model)
	end

	while not HasModelLoaded(model) do
        SendNUIMessage({
            show = true,
            loading = true,
        }) 
        Wait(100)
	end
    SendNUIMessage({
        show = true,
        loading = false,
    }) 
end