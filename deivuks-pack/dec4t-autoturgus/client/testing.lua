local savedPlayerCoords, testTimer, testingVehicle
local playerCoords, vehicleCoords = vec3(2554.5798, 1641.0828, 29.0901), vec4(2554.0608, 1645.0668, 28.9727, 95.4672)

local function startTesting()
    Citizen.CreateThreadNow(function()
        testTimer = 2 * 60 * 1000

        SetPlayerInvincible(cache.playerId, true)
        while testTimer > 0 do
            testTimer -= 1000

            lib.showTextUI('Likęs testavimo laikas: '..math.floor(testTimer / 1000)..'s. Spauskite [E] norėdami nutraukti testavimą.', {
                position = 'top-center',
                icon = 'fa-solid fa-car-side',
            })

            Wait(1000)
        end
        SetPlayerInvincible(cache.playerId, false)

        lib.hideTextUI()

        if testingVehicle and DoesEntityExist(testingVehicle) then
            DeleteEntity(testingVehicle)
        end

        testingVehicle = nil

        if savedPlayerCoords then
            TriggerServerEvent('imports:setDimension')

            DoScreenFadeOut(100)
            StartPlayerTeleport(cache.playerId, savedPlayerCoords.x, savedPlayerCoords.y, savedPlayerCoords.z, 0.0, false, true, true)

            lib.waitFor(function()
                if not IsPlayerTeleportActive() then
                    return true
                end
            end, 'Unable to teleport the player', 10000)

            DoScreenFadeIn(100)
        end
    end)
end

RegisterCommand('stopVehMarketTesting', function()
    if testingVehicle then testTimer = 0 end
end, false)
RegisterKeyMapping('stopVehMarketTesting', 'Sustabdyti automobilio testavima', 'keyboard', 'e')

local tryingToTest = false
local function testVehicle(vehicleProperties)
    if tryingToTest or testingVehicle then return error("Cannot start vehicle testing while another test is still active.", 2) end
    tryingToTest = true
    local modelHash = lib.requestModel(vehicleProperties.model, 60000)

    StartPlayerTeleport(cache.playerId, playerCoords.x, playerCoords.y, playerCoords.z, 0.0, false, true, true)

    local teleported = lib.waitFor(function()
        if not IsPlayerTeleportActive() then
            return true
        end
    end, 'Unable to teleport the player', 10000)
    if not teleported then return end

    testingVehicle = CreateVehicle(modelHash, vehicleCoords.x, vehicleCoords.y, vehicleCoords.z, vehicleCoords.w, false, true)

    local doesExist = lib.waitFor(function()
        if DoesEntityExist(testingVehicle) then
            return true
        end
    end, 'Unable to spawn the vehicle', 10000)
    if not doesExist then return end

    TaskWarpPedIntoVehicle(cache.ped, testingVehicle, -1)

    local inVehicle = lib.waitFor(function()
        if IsPedInVehicle(cache.ped, testingVehicle, false) then
            return true
        end
    end, 'Unable to set player into the vehicle', 10000)
    if not inVehicle then return end

    tryingToTest = false

    local properties = vehicleProperties

    SetVehicleModKit(testingVehicle, 0)

    properties.fuelLevel = 100

    exports['s1m1s-garagev3']:SetVehicleProperties(testingVehicle, properties)

    SetVehicleEngineOn(testingVehicle, true, true, true)
    startTesting()
    DoScreenFadeIn(100)
end

function ExecuteVehicleTesting(data)
    if testingVehicle or cache.vehicle then return end

    local canOpen = lib.callback.await('s1m1s-garagev3:getDimension', false)
    if not canOpen then return end

    TriggerServerEvent('imports:setDimension')

    if not savedPlayerCoords then
        savedPlayerCoords = cache.coords or GetEntityCoords(cache.ped)
    end

    local success, errorMessage = pcall(testVehicle, data.vehicle)
    if not success then
        DoScreenFadeIn(100)
        testingVehicle = nil
        tryingToTest = false
        lib.print.error(errorMessage)
        TriggerServerEvent('imports:setDimension')
    end
end