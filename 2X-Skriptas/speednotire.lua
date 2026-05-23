--[[local Cruise, CruiseSpeed = false, 0

local vehCheck = 500
Citizen.CreateThread(function()
    while true do 
        if Cruise then 
            local Ped = PlayerPedId()
            local Vehicle = GetVehiclePedIsIn(Ped, false)
            SetVehicleMaxSpeed(Vehicle, CruiseSpeed) 
        end
        Wait(Cruise and 200 or 1000)
    end
end)

RegisterCommand('autopilotas', function(source, args)
    local Ped = PlayerPedId()
    local Vehicle = GetVehiclePedIsIn(Ped, false)
    Cruise = not Cruise
    if Cruise then
        if tonumber(args[1]) then
            CruiseSpeed = tonumber(args[1]) * 0.621371192
        else
            CruiseSpeed = GetEntitySpeed(Vehicle)
        end
	else
        SetVehicleMaxSpeed(Vehicle, 0.0) 
	end
end)

local tParams = {}
local speedLimit = 50.0
local justIn = false
local tParams = {tyresPopped = 0, isSpeedLimited = false, t0 = false, t1 = false, t4 = false, t5 = false}
local speedLimitTwoTires = 12.0  --Speed limit when 2 or more tires get bursted
local speedLimitOneTire = 17.0   --Speed limit when 1 tire gets bursted
local speedLimitDelay = 1000     --How long it takes (in milliseconds) for speed limit kicks in after tire bursts
local vehicleSpeedMax = 0


local bbznSleepas = 500
Citizen.CreateThread(function()

    while true do
        local me = GetPlayerPed(-1)
        local veh = GetVehiclePedIsIn(me, false)

        if veh ~= nil then
            bbznSleepas = 10
        else
            bbznSleepas = 500
        end
        
        if DoesEntityExist(veh) then
            vehicleSpeedMax = GetVehicleHandlingFloat(veh,"CHandlingData","fInitialDriveMaxFlatVel")
        --Left Front
            if IsVehicleTyreBurst(veh, 0, true)and tParams.t0 == false then
                tParams.t0 = true
                tParams.tyresPopped = tParams.tyresPopped + 1
            end
            --Right Front
            if IsVehicleTyreBurst(veh, 1, true) and tParams.t1 == false then
                tParams.t1 = true
                tParams.tyresPopped = tParams.tyresPopped + 1
            end
            --Left Rear
            if IsVehicleTyreBurst(veh, 4, true) and tParams.t4 == false then
                tParams.t4 = true
                tParams.tyresPopped = tParams.tyresPopped + 1
            end
            --Right Rear
            if IsVehicleTyreBurst(veh, 5, true) and tParams.t5 == false then
                tParams.t5 = true
                tParams.tyresPopped = tParams.tyresPopped + 1
            end

        end

        --Wheel id's on 6-wheeler: middle right - 3
        -------------------------- middle left - 2

        --If two or more tyres burst max drivavle speed is set to speedLimitTwoTires
        if tParams.tyresPopped >= 2 then
            local maxSpeedAfterBurst = speedLimitTwoTires
            Wait(speedLimitDelay)

            while speedLimit >= maxSpeedAfterBurst do
                SetVehicleMaxSpeed(veh, speedLimit)
                speedLimit = speedLimit - 4.0
                Wait(200)
            end

        --If one tire is burst max drivable speed set to speedLimitOneTire
        elseif tParams.tyresPopped > 0 then
            local maxSpeedAfterBurst = speedLimitOneTire

            Wait(speedLimitDelay)

            while speedLimit >= maxSpeedAfterBurst do
                SetVehicleMaxSpeed(veh, speedLimit)
                speedLimit = speedLimit - 3.0
                Wait(200)
            end

        else
            SetVehicleMaxSpeed(veh, vehicleSpeedMax)
        end

        --Refreshes variables when person gets to a new vehicle
        if IsPedInAnyVehicle(me, false) then
            if justIn == false then
                speedLimit = vehicleSpeedMax
                tParams.t0 = false
                tParams.t1 = false
                tParams.t4 = false
                tParams.t5 = false
                tParams.tyresPopped = 0
				justIn = true
            end
        else
            if justIn == true then
                justIn = false
            end
            bbznSleepas = 500
		end
        Wait(bbznSleepas)
    end
end)]]

local Veh
lib.onCache('vehicle', function(value)
    if value and not Veh then 
        MaxSpeed = GetVehicleHandlingFloat(veh,"CHandlingData","fInitialDriveMaxFlatVel")
        Veh = value 
        Tyres = {}


        while Veh do 
            Tyres = {}

            if IsVehicleTyreBurst(Veh, 0, true) and not Tyres[1] then
                Tyres[1] = true
            end
            --Right Front
            if IsVehicleTyreBurst(Veh, 1, true) and not Tyres[2] then
                Tyres[2] = true
            end
            --Left Rear
            if IsVehicleTyreBurst(Veh, 4, true) and not Tyres[3] then
                Tyres[3] = true
            end
            --Right Rear
            if IsVehicleTyreBurst(Veh, 5, true) and not Tyres[4] then
                Tyres[4] = true
            end


            if Tyres[1] or Tyres[2] or Tyres[3] or Tyres[4] then 
                SetVehicleMaxSpeed(Veh, 15.0)
            else 
                SetVehicleMaxSpeed(Veh, MaxSpeed)
            end

            Wait(500)
        end

    else 
        Veh = nil
    end
end)