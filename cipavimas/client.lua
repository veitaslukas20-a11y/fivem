-- cipavimas/client.lua - COMPLETELY FIXED VERSION
-- Fixed by: Assistant
-- Date: 2024
-- Fixes: ESX initialization, nil value errors, vehicle handling

local menu = false
local ESX = nil
local isESXReady = false

-- Proper ESX initialization
Citizen.CreateThread(function()
    -- Wait for ESX to be ready
    while ESX == nil do
        TriggerEvent('esx:getSharedObject', function(obj) 
            ESX = obj 
        end)
        Citizen.Wait(0)
    end
    
    -- Wait for player to be loaded
    while not ESX.IsPlayerLoaded() do
        Citizen.Wait(100)
    end
    
    isESXReady = true
    print("^2[cipavimas] ESX initialized successfully^7")
end)

-- Alternative ESX initialization method (backup)
Citizen.CreateThread(function()
    if ESX == nil then
        ESX = exports["es_extended"]:getSharedObject()
        if ESX then
            isESXReady = true
            print("^2[cipavimas] ESX initialized via export^7")
        end
    end
end)

-- Safe function to get vehicle plate
local function getVehiclePlate(veh)
    if not DoesEntityExist(veh) then
        return nil
    end
    
    -- Try ESX method first
    if ESX and ESX.Game and ESX.Game.GetVehicleProperties then
        local success, result = pcall(function()
            return ESX.Game.GetVehicleProperties(veh)
        end)
        if success and result and result.plate then
            return result.plate
        end
    end
    
    -- Fallback to native method
    local plateText = GetVehicleNumberPlateText(veh)
    if plateText and plateText ~= "" then
        return plateText
    end
    
    return nil
end

function getVehData(veh)
    if not DoesEntityExist(veh) then 
        return nil 
    end
    
    -- Safely get vehicle handling data
    local success, result = pcall(function()
        local lvehstats = {
            boost = GetVehicleHandlingFloat(veh, "CHandlingData", "fInitialDriveForce"),
            fuelmix = GetVehicleHandlingFloat(veh, "CHandlingData", "fDriveInertia"),
            braking = GetVehicleHandlingFloat(veh, "CHandlingData", "fBrakeBiasFront"),
            drivetrain = GetVehicleHandlingFloat(veh, "CHandlingData", "fDriveBiasFront"),
            brakeforce = GetVehicleHandlingFloat(veh, "CHandlingData", "fBrakeForce"),
            gearchange = 1.0 -- Default value
        }
        return lvehstats
    end)
    
    if success then
        return result
    else
        print("^3[cipavimas] Failed to get vehicle data^7")
        return nil
    end
end

function setVehData(veh, data)
    if not DoesEntityExist(veh) or not data then 
        print("^3[cipavimas] Invalid vehicle or data^7")
        return nil 
    end
    
    -- Safely set vehicle handling
    pcall(function()
        if data.boost then
            SetVehicleHandlingFloat(veh, "CHandlingData", "fInitialDriveForce", data.boost * 1.0)
        end
        if data.fuelmix then
            SetVehicleHandlingFloat(veh, "CHandlingData", "fDriveInertia", data.fuelmix * 1.0)
        end
        if data.gearchange then
            SetVehicleEnginePowerMultiplier(veh, data.gearchange * 1.0)
        end
        if data.braking then
            SetVehicleHandlingFloat(veh, "CHandlingData", "fBrakeBiasFront", data.braking * 1.0)
        end
        if data.drivetrain then
            SetVehicleHandlingFloat(veh, "CHandlingData", "fDriveBiasFront", data.drivetrain * 1.0)
        end
        if data.brakeforce then
            SetVehicleHandlingFloat(veh, "CHandlingData", "fBrakeForce", data.brakeforce * 1.0)
        end
    end)
end

Citizen.CreateThread(function()
    local tuningfuncs = {
        boost = "fInitialDriveForce",
        fuelmix = "fDriveInertia", 
        braking = "fBrakeBiasFront",
        drivetrain = "fDriveBiasFront",
        brakeforce = "fBrakeForce"
    }
    local lastveh = nil
    
    while true do
        Citizen.Wait(0)
        
        -- Wait for ESX to be ready
        if not isESXReady then
            Citizen.Wait(1000)
            goto continue
        end
        
        local ped = PlayerPedId()
        local veh = GetVehiclePedIsIn(ped, false)
        
        if veh ~= 0 and veh ~= lastveh then
            local plate = getVehiclePlate(veh)
            
            if plate then
                ESX.TriggerServerCallback("tuning:getTuning", function(t)
                    if t then
                        local success, tuning = pcall(json.decode, t)
                        if success and tuning then
                            for type, value in pairs(tuning) do
                                pcall(function()
                                    if type == "gearchange" then
                                        SetVehicleEnginePowerMultiplier(veh, value * 1.0)
                                    else
                                        SetVehicleHandlingFloat(veh, "CHandlingData", tuningfuncs[type], value * 1.0)
                                    end
                                end)
                            end
                        end
                    end
                end, plate)
                
                lastveh = veh
            end
        elseif veh == 0 then
            lastveh = nil
        end
        
        ::continue::
    end
end)

function toggleMenu(b, send)
    menu = b
    SetNuiFocus(b, b)
    
    local ped = PlayerPedId()
    local veh = GetVehiclePedIsIn(ped, false)
    
    if veh == 0 or GetPedInVehicleSeat(veh, -1) ~= ped then
        print("^3[cipavimas] Not in vehicle or not driver^7")
        return
    end
    
    local vehData = getVehData(veh)
    
    if send then 
        SendNUIMessage({
            type = "togglemenu", 
            state = b, 
            data = vehData or {
                boost = 1.0,
                fuelmix = 1.0,
                braking = 0.5,
                drivetrain = 0.5,
                brakeforce = 1.0,
                gearchange = 1.0
            }
        })
    end
end

RegisterNUICallback("togglemenu", function(data, cb)
    toggleMenu(data.state, false)
    cb('ok')
end)

RegisterNUICallback("save", function(data, cb)
    local ped = PlayerPedId()
    local veh = GetVehiclePedIsIn(ped, false)
    
    -- Validate player is in vehicle and is driver
    if veh == 0 or GetPedInVehicleSeat(veh, -1) ~= ped then
        print("^3[cipavimas] Not in vehicle or not driver^7")
        cb('error')
        return
    end
    
    -- Get plate safely
    local plate = getVehiclePlate(veh)
    if not plate then
        print("^3[cipavimas] Could not get vehicle plate^7")
        cb('error')
        return
    end
    
    -- Apply vehicle data
    setVehData(veh, data)
    
    -- Save to server
    local success, encoded = pcall(json.encode, data)
    if success then
        TriggerServerEvent("tuning:saveVehicleModifications", encoded, plate)
    end
    
    cb('ok')
end)

RegisterNetEvent("tuning:useLaptop")
AddEventHandler("tuning:useLaptop", function()
    -- Wait for ESX to be ready
    if not isESXReady then
        print("^3[cipavimas] ESX not ready yet^7")
        return
    end
    
    if not menu then
        local ped = PlayerPedId()
        local veh = GetVehiclePedIsIn(ped, false)
        
        -- Check if in vehicle and is driver
        if veh == 0 or GetPedInVehicleSeat(veh, -1) ~= ped then
            print("^3[cipavimas] You must be the driver of a vehicle^7")
            return
        end
        
        Citizen.Wait(0)
        toggleMenu(true, true)
        
        -- Wait while in vehicle
        while IsPedInAnyVehicle(ped, false) and GetPedInVehicleSeat(GetVehiclePedIsIn(ped, false), -1) == ped do
            Citizen.Wait(100)
        end
        
        -- Close menu when leaving vehicle
        toggleMenu(false, true)
    end
end)

RegisterNetEvent("tuning:closeMenu")
AddEventHandler("tuning:closeMenu", function()
    toggleMenu(false, true)
end)

-- Add cleanup on resource stop
AddEventHandler('onResourceStop', function(resourceName)
    if GetCurrentResourceName() == resourceName then
        if menu then
            toggleMenu(false, true)
        end
    end
end)

print("^2[cipavimas] Client script loaded successfully^7")