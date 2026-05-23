----------------------------------------------
-- External Vehicle Commands, Made by FAXES --
----------------------------------------------

RegisterCommand("bagazine", function(source, args, raw)
    local ped = GetPlayerPed(-1)
    local veh = GetVehiclePedIsUsing(ped)
    local vehLast = GetPlayersLastVehicle()
    local distanceToVeh = GetDistanceBetweenCoords(GetEntityCoords(ped), GetEntityCoords(vehLast), 1)
    local door = 5

    if IsPedInAnyVehicle(ped, false) then
        if GetVehicleDoorAngleRatio(veh, door) > 0 then
            SetVehicleDoorShut(veh, door, false)
            
            --ESX.ShowNotification("• Bagazine ~r~uzdaryta~s~! •")
        else	
            SetVehicleDoorOpen(veh, door, false, false)
            
            --ESX.ShowNotification("• Bagazine ~g~atidaryta~s~! •")
        end
    else
        if distanceToVeh < 6 then
            if GetVehicleDoorAngleRatio(vehLast, door) > 0 then
                SetVehicleDoorShut(vehLast, door, false)
                
                --ESX.ShowNotification("v Bagazine ~r~uzdaryta~s~! •")
            else
                SetVehicleDoorOpen(vehLast, door, false, false)
                
                --ESX.ShowNotification("• Bagazine ~g~atidaryta~s~! •")
            end
        else
            
            --ESX.ShowNotification("• Esi ~r~per toli~s~ nuo tr. priemones! •")
        end
    end
end)

RegisterCommand("kapotas", function(source, args, raw)
    local ped = GetPlayerPed(-1)
    local veh = GetVehiclePedIsUsing(ped)
    local vehLast = GetPlayersLastVehicle()
    local distanceToVeh = GetDistanceBetweenCoords(GetEntityCoords(ped), GetEntityCoords(vehLast), 1)
    local door = 4

    if IsPedInAnyVehicle(ped, false) then
        if GetVehicleDoorAngleRatio(veh, door) > 0 then
            SetVehicleDoorShut(veh, door, false)
            
            --ESX.ShowNotification("• Kapotas ~r~uzdarytas~s~! •")
			TriggerServerEvent('3dme:shareDisplay', ' uždaro kapotą ')
        else	
            SetVehicleDoorOpen(veh, door, false, false)
            
            --ESX.ShowNotification("• Kapotas ~g~atidarytas~s~! •")
			TriggerServerEvent('3dme:shareDisplay', ' atidaro kapotą ')
        end
    else
        if distanceToVeh < 4 then
            if GetVehicleDoorAngleRatio(vehLast, door) > 0 then
                SetVehicleDoorShut(vehLast, door, false)
                
                --ESX.ShowNotification("• Kapotas ~r~uzdarytas~s~! •")
				TriggerServerEvent('3dme:shareDisplay', ' uždaro kapotą ')
            else	
                SetVehicleDoorOpen(vehLast, door, false, false)
                
                --ESX.ShowNotification("• Kapotas ~g~atidarytas~s~! •")
				TriggerServerEvent('3dme:shareDisplay', ' atidaro kapotą ')
            end
        else
            
            --ESX.ShowNotification("• Esi ~r~per toli~s~ nuo tr. priemones! •")
        end
    end
end)

RegisterCommand("durys", function(source, args, raw)
    local ped = GetPlayerPed(-1)
    local veh = GetVehiclePedIsUsing(ped)
    local vehLast = GetPlayersLastVehicle()
    local distanceToVeh = GetDistanceBetweenCoords(GetEntityCoords(ped), GetEntityCoords(vehLast), 1)
    
    if args[1] == "1" then -- Front Left Door
        door = 0
    elseif args[1] == "2" then -- Front Right Door
        door = 1
    elseif args[1] == "3" then -- Back Left Door
        door = 2
    elseif args[1] == "4" then -- Back Right Door
        door = 3
    else
        door = nil
        --ESX.ShowNotification("Naudojimas: ~n~~HUD_COLOUR_PINK~/durys [kurios durys]")
        --ESX.ShowNotification("~y~Imanomos durys:")
        --ESX.ShowNotification("1(Priekine kairios durys), 2(Priekines desinios durys)")
        --ESX.ShowNotification("3(Galines kairios durys), 4(Galines desinios durys)")
    end

    if door ~= nil then
        if IsPedInAnyVehicle(ped, false) then
            if GetVehicleDoorAngleRatio(veh, door) > 0 then
                SetVehicleDoorShut(veh, door, false)
                
                --ESX.ShowNotification("• Durys ~r~uzdarytos~s~! •")
				TriggerServerEvent('3dme:shareDisplay', ' uždaro duris ')
            else	
                SetVehicleDoorOpen(veh, door, false, false)
                
                --ESX.ShowNotification("• Durys ~g~atidarytos~s~! •")
				TriggerServerEvent('3dme:shareDisplay', ' atidaro duris ')
            end
        else
            if distanceToVeh < 4 then
                if GetVehicleDoorAngleRatio(vehLast, door) > 0 then
                    SetVehicleDoorShut(vehLast, door, false)
                    
                    --ESX.ShowNotification("• Durys ~r~uzdarytos~s~! •")
					TriggerServerEvent('3dme:shareDisplay', ' uždaro duris ')
                else	
                    SetVehicleDoorOpen(vehLast, door, false, false)
                    
                    --ESX.ShowNotification("• Durys ~g~atidarytos~s~! •")
					TriggerServerEvent('3dme:shareDisplay', ' atidaro duris ')
                end
            else
                
                --ESX.ShowNotification("• Esi ~r~per toli~s~ nuo tr. priemones! •")
            end
        end
    end
end)

RegisterCommand('langas', function()
    WindowsFront()
end, false)

local Windows1 = 0

function WindowsFront()
    print(Windows1)
    local playerPed = GetPlayerPed(-1)
    local playerVeh = GetVehiclePedIsIn(playerPed, false)
    if ( IsPedSittingInAnyVehicle( playerPed ) ) and Windows1 == 0 then
      RollUpWindow(playerVeh, 1)
      RollUpWindow(playerVeh, 0)
      Windows1 = 1
    else
        RollDownWindow(playerVeh, 1)
        RollDownWindow(playerVeh, 0)
        Windows1 = 0
    end
end

local Autopilot, MaxSpeed = false, 0

RegisterCommand('autopilotas', function(source, args)
    if not cache.vehicle or not DoesEntityExist(cache.vehicle) then return end
    Autopilot = not Autopilot 

    if Autopilot then
        local speed = GetEntitySpeed(cache.vehicle)
        MaxSpeed = GetVehicleMaxSpeed(cache.vehicle)
        args[1] = tonumber(args[1])
        if args[1] and type(args[1]) == 'number' then speed = args[1] / 3.6 end

        if speed < 10.0 then Autopilot = false return end
        if speed > MaxSpeed then speed = MaxSpeed end

        while Autopilot and cache.vehicle do
            SetVehicleMaxSpeed(cache.vehicle, speed)
            Wait(100)
        end
    else
        SetVehicleMaxSpeed(cache.vehicle, 0)
    end
end)

local AiPilot = false
RegisterCommand('aipilot', function()
    if not cache.vehicle or not DoesEntityExist(cache.vehicle) then AiPilot = false return end
    if GetEntityModel(cache.vehicle) ~= `foxct` then AiPilot = false return end 

    AiPilot = not AiPilot

    if AiPilot then
        if not DoesBlipExist(GetFirstBlipInfoId(8)) then AiPilot = false return end
        local blip = GetFirstBlipInfoId(8)
        local bCoords = GetBlipCoords(blip)
        local Speed = 50 / 3.6
        ClearPedTasks(cache.ped)
        TaskVehicleDriveToCoord(cache.ped, cache.vehicle, bCoords, Speed, 0, GetEntityModel(cache.vehicle), 786603, 5.0, true)
        SetDriveTaskDrivingStyle(cache.ped, 786603)

        Citizen.CreateThread(function()
            while AiPilot and cache.vehicle do 
                local coords = GetEntityCoords(cache.vehicle)
                local retval, density, flags = GetVehicleNodeProperties(coords.x, coords.y, coords.z)
    
                if (flags == 66 or flags == 82) and Speed ~= (130 / 3.6) then 
                    Speed = (130 / 3.6)
                    TaskVehicleDriveToCoord(cache.ped, cache.vehicle, bCoords, Speed, 0, GetEntityModel(cache.vehicle), 786603, 5.0, true)
                elseif (flags == 10 or flags == 14 or flags == 42 or flags == 46) and Speed ~= (20 / 3.6) then 
                    Speed = (20 / 3.6)
                    TaskVehicleDriveToCoord(cache.ped, cache.vehicle, bCoords, Speed, 0, GetEntityModel(cache.vehicle), 786603, 5.0, true)
                elseif (flags == 2 or flags == 34 or flags == 64) and Speed ~= (80 / 3.6) then 
                    Speed = (80 / 3.6)
                    TaskVehicleDriveToCoord(cache.ped, cache.vehicle, bCoords, Speed, 0, GetEntityModel(cache.vehicle), 786603, 5.0, true)
                elseif flags == 11 and Speed ~= (90 / 3.6) then 
                    Speed = (90 / 3.6)
                    TaskVehicleDriveToCoord(cache.ped, cache.vehicle, bCoords, Speed, 0, GetEntityModel(cache.vehicle), 786603, 5.0, true)
                end
    
                if IsEntityInWater(cache.vehicle) or HasEntityCollidedWithAnything(cache.vehicle) then 
                    ClearPedTasks(cache.ped)
                    TurnSignals(true, true)
                    SetVehicleBrakeLights(cache.vehicle, true)
                    speed = GetEntitySpeed(cache.vehicle)
                    while speed > 0.0 do 
                        if IsEntityInAir(cache.vehicle) then break end
                        speed = GetEntitySpeed(cache.vehicle) - 1.0
                        SetVehicleForwardSpeed(cache.vehicle, speed)
                        DisableControlAction(0,32,true)
                        Wait(100)
                    end
                    AiPilot = false
                end

                local offset1 = GetOffsetFromEntityInWorldCoords(cache.vehicle, 0.0, 26.0, 0.0)
                local offset2 = GetOffsetFromEntityInWorldCoords(cache.vehicle, 0.0, -26.0, 0.0)

                local closest = lib.getClosestVehicle(offset1, 5.0, false)
                if closest then
                    if IsVehicleSirenOn(closest) then
                        ClearPedTasks(cache.ped)
                        TurnSignals(true, true)
                        SetVehicleBrakeLights(cache.vehicle, true)
                        speed = GetEntitySpeed(cache.vehicle)
                        while speed > 0.0 do 
                            if IsEntityInAir(cache.vehicle) then break end
                            speed = GetEntitySpeed(cache.vehicle) - 1.0
                            SetVehicleForwardSpeed(cache.vehicle, speed)
                            DisableControlAction(0,32,true)
                            Wait(100)
                        end
                        AiPilot = false
                    end
                end

                local closest2 = lib.getClosestVehicle(offset2, 5.0, false)
                if closest2 then
                    if IsVehicleSirenOn(closest2) then
                        ClearPedTasks(cache.ped)
                        TurnSignals(true, true)
                        SetVehicleBrakeLights(cache.vehicle, true)
                        speed = GetEntitySpeed(cache.vehicle)
                        while speed > 0.0 do 
                            if IsEntityInAir(cache.vehicle) then break end
                            speed = GetEntitySpeed(cache.vehicle) - 1.0
                            SetVehicleForwardSpeed(cache.vehicle, speed)
                            DisableControlAction(0,32,true)
                            Wait(100)
                        end
                        AiPilot = false
                    end
                end
    
                if not DoesBlipExist(GetFirstBlipInfoId(8)) then 
                    AiPilot = false
                    ClearPedTasks(cache.ped)
                    local speed = GetEntitySpeed(cache.vehicle)
                    while speed > 2.0 do 
                        if IsEntityInAir(cache.vehicle) then break end
                        speed -= 1.0
                        SetVehicleForwardSpeed(cache.vehicle, speed)
                        Wait(100)
                    end
                end
    
                Wait(200)
            end
        end)
    else
        ClearPedTasks(cache.ped)
    end
end)

local AvoidCrashes = false
RegisterCommand('avoidcrashes', function()
    if not cache.vehicle or not DoesEntityExist(cache.vehicle) then AvoidCrashes = false return end
    if GetEntityModel(cache.vehicle) ~= `foxct` then AvoidCrashes = false return end 

    AvoidCrashes = not AvoidCrashes
    AvoidVehicleCrashes()

    exports['1x-hud']:sendNotification({
        type = AvoidCrashes and 'INFO' or 'ERROR',
        title = 'Įvykių išvengimas',
        message = AvoidCrashes and 'Automatinė auto įvykių išvengimo sistema buvo įjungta.' or 'Automatinė auto įvykių išvengimo sistema buvo išjungta.',
        duration = 5000,
        icon = 'fa-solid fa-robot'
    })
end)

function AvoidVehicleCrashes()
    Citizen.CreateThread(function()
        while AvoidCrashes and cache.vehicle do 
            local offset1 = GetOffsetFromEntityInWorldCoords(cache.vehicle, 0.0, 26.0, 0.0)
            local offset2 = GetOffsetFromEntityInWorldCoords(cache.vehicle, 3.0, 25.0, 0.0)
            local offset3 = GetOffsetFromEntityInWorldCoords(cache.vehicle, -3.0, 25.0, 0.0)

            if IsAnyObjectNearPoint(offset1.x, offset1.y, offset1.z, 2.5, false) then
                speed = GetEntitySpeed(cache.vehicle)
                SetVehicleBrakeLights(cache.vehicle, true)
                TurnSignals(true, true)
                DisableDrive(true)
                while speed > 0.0 do 
                    speed = GetEntitySpeed(cache.vehicle) - 10.0
                    if speed < 0 then speed = 0 end
                    SetVehicleForwardSpeed(cache.vehicle, speed)
                    Wait(100)
                end
                DisableDrive(false)
                Wait(1000)
                TurnSignals(false, false)
            end
            if IsAnyObjectNearPoint(offset2.x, offset2.y, offset2.z, 1.5, false) then
                TaskVehicleTempAction(cache.ped, cache.vehicle, 4, 200)
            end
            if IsAnyObjectNearPoint(offset3.x, offset3.y, offset3.z, 1.5, false) then
                TaskVehicleTempAction(cache.ped, cache.vehicle, 5, 200)
            end

            if IsAnyPedNearPoint(offset1.x, offset1.y, offset1.z, 2.5) then
                speed = GetEntitySpeed(cache.vehicle)
                SetVehicleBrakeLights(cache.vehicle, true)
                TurnSignals(true, true)
                DisableDrive(true)
                while speed > 0.0 do 
                    speed = GetEntitySpeed(cache.vehicle) - 10.0
                    if speed < 0 then speed = 0 end
                    SetVehicleForwardSpeed(cache.vehicle, speed)
                    Wait(100)
                end
                DisableDrive(false)
                Wait(1000)
                TurnSignals(false, false)
            end
            if IsAnyPedNearPoint(offset2.x, offset2.y, offset2.z, 1.5) then
                TaskVehicleTempAction(cache.ped, cache.vehicle, 4, 200)
            end
            if IsAnyPedNearPoint(offset3.x, offset3.y, offset3.z, 1.5) then
                TaskVehicleTempAction(cache.ped, cache.vehicle, 5, 200)
            end

            if IsAnyVehicleNearPoint(offset1.x, offset1.y, offset1.z, 2.5) then
                speed = GetEntitySpeed(cache.vehicle)
                SetVehicleBrakeLights(cache.vehicle, true)
                TurnSignals(true, true)
                DisableDrive(true)
                while speed > 0.0 do 
                    speed = GetEntitySpeed(cache.vehicle) - 10.0
                    if speed < 0 then speed = 0 end
                    SetVehicleForwardSpeed(cache.vehicle, speed)
                    Wait(100)
                end
                DisableDrive(false)
                Wait(1000)
                TurnSignals(false, false)
            end
            if IsAnyVehicleNearPoint(offset2.x, offset2.y, offset2.z, 1.5) then
                TaskVehicleTempAction(cache.ped, cache.vehicle, 4, 200)
            end
            if IsAnyVehicleNearPoint(offset3.x, offset3.y, offset3.z, 1.5) then
                TaskVehicleTempAction(cache.ped, cache.vehicle, 5, 200)
            end

            Wait(1)
        end

        AvoidCrashes = false
    end)
end

local hazard = false
local keybind = lib.addKeybind({
    name = 'hazard',
    description = 'Avarinis posukio signalas',
    defaultKey = 'DOWN',
    onPressed = function(self)
        hazard = not hazard
        TurnSignals(hazard, hazard)
    end,
})

local right = false
local keybind = lib.addKeybind({
    name = 'right',
    description = 'Avarinis posukio signalas',
    defaultKey = 'RIGHT',
    onPressed = function(self)
        right = not right
        TurnSignals(right, false)
    end,
})

local left = false
local keybind = lib.addKeybind({
    name = 'left',
    description = 'Avarinis posukio signalas',
    defaultKey = 'LEFT',
    onPressed = function(self)
        left = not left
        TurnSignals(false, left)
    end,
})

function TurnSignals(right, left)
    SetVehicleIndicatorLights(cache.vehicle, 1, left)
    Wait(10)
    SetVehicleIndicatorLights(cache.vehicle, 0, right)
end

function DisableDrive(value)
    Citizen.CreateThread(function()
        while value do 
            DisableControlAction(0,32,true)
            Wait(10)
        end
    end)
end