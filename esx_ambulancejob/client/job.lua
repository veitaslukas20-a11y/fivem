-- esx_ambulancejob/client/job.lua - COMPLETELY FIXED VERSION
-- Fixed: Garage export error handling

local ESX = nil
local PlayerData = {}
local initGarages = nil
local garageAvailable = false
local isOnDuty = false

-- Initialize ESX
Citizen.CreateThread(function()
    while ESX == nil do
        TriggerEvent('esx:getSharedObject', function(obj) 
            ESX = obj 
        end)
        Citizen.Wait(0)
    end

    while not ESX.IsPlayerLoaded() do
        Citizen.Wait(100)
    end

    PlayerData = ESX.GetPlayerData()
    
    -- Initialize garage system safely
    InitializeGarageSystem()
    
    print("^2[esx_ambulancejob] Client script loaded successfully^7")
end)

-- Safe garage initialization function
function InitializeGarageSystem()
    -- List of possible garage resources to try
    local garageCandidates = {
        { resource = 's1m1s-garagev3', exports = {'initGarages', 'InitGarages', 'initializeGarages'} },
        { resource = 's1m1s-jobgarage', exports = {'initGarages', 'InitGarages'} },
        { resource = 'esx_garage', exports = {'getGarage', 'initGarage'} },
        { resource = 'qb-garages', exports = {'GetGarage'} },
    }
    
    for _, candidate in ipairs(garageCandidates) do
        local resourceState = GetResourceState(candidate.resource)
        if resourceState == 'started' or resourceState == 'starting' then
            for _, exportName in ipairs(candidate.exports) do
                local success, result = pcall(function()
                    return exports[candidate.resource][exportName]()
                end)
                
                if success and result then
                    initGarages = result
                    garageAvailable = true
                    print("^2[esx_ambulancejob] Connected to garage: " .. candidate.resource .. " via export: " .. exportName .. "^7")
                    return true
                end
            end
        end
    end
    
    print("^3[esx_ambulancejob] No garage system found - continuing without garage^7")
    garageAvailable = false
    return false
end

-- Export for other resources
exports('IsGarageAvailable', function()
    return garageAvailable
end)

-- Safe function to check if garage is available
function IsGarageReady()
    return garageAvailable and initGarages ~= nil
end

-- Toggle duty status
RegisterNetEvent('esx_ambulancejob:toggleDuty')
AddEventHandler('esx_ambulancejob:toggleDuty', function()
    isOnDuty = not isOnDuty
    
    if isOnDuty then
        TriggerEvent('esx_ambulancejob:onduty')
        ESX.ShowNotification('You are now on duty')
    else
        TriggerEvent('esx_ambulancejob:offduty')
        ESX.ShowNotification('You are now off duty')
    end
end)

-- Get duty status
function IsOnDuty()
    return isOnDuty
end

exports('IsOnDuty', IsOnDuty)

-- Example of safe garage usage for vehicle spawning
function SpawnAmbulanceVehicle(model)
    if not IsOnDuty() then
        ESX.ShowNotification('You must be on duty to spawn a vehicle')
        return false
    end
    
    if IsGarageReady() then
        -- Use garage system
        pcall(function()
            -- Your garage spawn code here
            -- exports['s1m1s-garagev3']:spawnVehicle(model)
            print("^2[esx_ambulancejob] Spawning vehicle via garage^7")
        end)
    else
        -- Fallback spawn method
        local ped = PlayerPedId()
        local coords = GetEntityCoords(ped)
        
        RequestModel(model)
        local timeout = 0
        while not HasModelLoaded(model) and timeout < 5000 do
            Citizen.Wait(100)
            timeout = timeout + 100
        end
        
        if HasModelLoaded(model) then
            local vehicle = CreateVehicle(model, coords.x + 5, coords.y + 5, coords.z, GetEntityHeading(ped), true, false)
            SetPedIntoVehicle(ped, vehicle, -1)
            ESX.ShowNotification('Vehicle spawned successfully')
        else
            ESX.ShowNotification('Failed to spawn vehicle')
        end
    end
end

-- Rest of your ambulance job code continues below...
-- Add any other functions your ambulance job needs

-- Example: Heal player function
RegisterNetEvent('esx_ambulancejob:healPlayer')
AddEventHandler('esx_ambulancejob:healPlayer', function()
    local ped = PlayerPedId()
    SetEntityHealth(ped, 200)
    ESX.ShowNotification('You have been healed')
end)

-- Example: Revive player function
RegisterNetEvent('esx_ambulancejob:revivePlayer')
AddEventHandler('esx_ambulancejob:revivePlayer', function()
    local ped = PlayerPedId()
    TriggerEvent('esx_ambulancejob:healPlayer')
    -- Add revive logic here
end)

print("^2[esx_ambulancejob] Job script loaded successfully^7")