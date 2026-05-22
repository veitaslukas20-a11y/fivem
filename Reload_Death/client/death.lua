local Config = {
    CameraSensitivity = {
        mouse = 8.0,
        controller = 1.5
    },
    CameraDistance = 1.5
}

local DeathState = {
    isDead = false,
    isReviving = false,
    diedFromHunger = false,
    resetTimeout = false,
    camera = nil,
    cameraAngles = { y = 0.0, z = 0.0 }
}

exports('diedFromFood', function()
    DeathState.diedFromHunger = true
end)

exports('getDead', function()
    return DeathState.isDead
end)

local function SetDeathState(dead)
    DeathState.isDead = dead
    ESX.SetPlayerData('dead', dead)
    TriggerServerEvent('reload_death:setDead', dead)
end

local function GetHealthyHealth()
    return GetPedMaxHealth(cache.ped) - 1
end

local function HandleDeathControls()
    CreateThread(function()
        local controls = {
            24, 257, 25, 263, 45, 44, 170, 120, 73, 59, 71, 72, 264, 140, 141, 142, 143, 75
        }

        while DeathState.isDead do
            local ped = cache.ped

            SetPedCanPlayGestureAnims(ped, false)
            SetPedCanPlayAmbientAnims(ped, false)
            SetPedCanPlayVisemeAnims(ped, false, false)

            for _, control in ipairs(controls) do
                DisableControlAction(0, control, true)
            end
            DisableControlAction(2, 36, true)
            DisableControlAction(27, 75, true)

            EnableControlAction(0, 18, true)
            EnableControlAction(0, 177, true)

            Wait(0)
        end
    end)
end

local function CreateDeathCamera()
    if DeathState.camera then return end

    ClearFocus()
    local pedCoords = GetEntityCoords(cache.ped)
    DeathState.camera = CreateCamWithParams("DEFAULT_SCRIPTED_CAMERA", pedCoords, 0.0, 0.0, 0.0, GetGameplayCamFov())
    SetCamActive(DeathState.camera, true)
    RenderScriptCams(true, true, 1000, true, false)

    CreateThread(function()
        while DeathState.camera and DeathState.isDead do
            ProcessCameraControls()
            Wait(25)
        end
    end)
end

local function DestroyDeathCamera()
    if not DeathState.camera then return end

    ClearFocus()
    RenderScriptCams(false, false, 0, true, false)
    DestroyCam(DeathState.camera, false)
    DeathState.camera = nil
end

function ProcessCameraControls()
    if not DeathState.camera then return end

    local playerCoords = GetEntityCoords(cache.ped)
    DisableFirstPersonCamThisFrame()

    local sensitivity = IsInputDisabled(0) and Config.CameraSensitivity.mouse or Config.CameraSensitivity.controller
    local mouseX = GetDisabledControlNormal(1, 1) * sensitivity
    local mouseY = GetDisabledControlNormal(1, 2) * sensitivity

    DeathState.cameraAngles.z = DeathState.cameraAngles.z - mouseX
    DeathState.cameraAngles.y = math.clamp(DeathState.cameraAngles.y + mouseY, -89.0, 89.0)

    local pCoords = GetEntityCoords(cache.ped)
    local normalCoords = vector3(pCoords.x, pCoords.y, pCoords.z + 0.5)

    local cosAngleY = math.cos(math.rad(DeathState.cameraAngles.y))
    local offset = vector3(
        math.cos(math.rad(DeathState.cameraAngles.z)) * cosAngleY * Config.CameraDistance,
        math.sin(math.rad(DeathState.cameraAngles.z)) * cosAngleY * Config.CameraDistance,
        math.sin(math.rad(DeathState.cameraAngles.y)) * 1.5
    )

    local behindCam = normalCoords + offset
    local rayHandle = StartShapeTestRay(
        normalCoords.x, normalCoords.y, normalCoords.z,
        behindCam.x, behindCam.y, behindCam.z,
        -1, cache.ped, 0
    )
    local _, hitBool, hitCoords = GetShapeTestResult(rayHandle)

    local maxRadius = hitBool and #(normalCoords - hitCoords) < 2.0 and #(normalCoords - hitCoords) or Config.CameraDistance
    offset = offset * (maxRadius / Config.CameraDistance)
    local finalPos = normalCoords + offset

    SetFocusArea(finalPos.x, finalPos.y, finalPos.z, 0.0, 0.0, 0.0)
    SetCamCoord(DeathState.camera, finalPos.x, finalPos.y, finalPos.z)
    PointCamAtCoord(DeathState.camera, playerCoords.x, playerCoords.y, playerCoords.z + 0.5)
end

local function StartDeath()
    if DeathState.isDead then return end

    exports['pma-voice']:removePlayerFromRadio()

    if DeathState.diedFromHunger then
        exports['esx_ambulancejob']:StartDiedHunger()
    else
        exports['esx_ambulancejob']:StartDeathTimer()
        exports['esx_ambulancejob']:StartDistressSignal()
    end

    SetDeathState(true)
    DeathState.isReviving = false

    HandleDeathControls()
    CreateDeathCamera()
    SetEntityHealth(cache.ped, 0)
end

local function CompleteRevive()
    DeathState.diedFromHunger = false
    DeathState.isDead = false
    DeathState.isReviving = false

    DestroyDeathCamera()

    local coords = GetEntityCoords(cache.ped)
    local heading = GetEntityHeading(cache.ped)

    SetEntityCoordsNoOffset(cache.ped, coords.x, coords.y, coords.z, false, false, false, true)
    exports['deivuks-utils']:health()
    NetworkResurrectLocalPlayer(coords.x, coords.y, coords.z, heading, true, false)
    SetEntityHealth(cache.ped, GetHealthyHealth())

    StopScreenEffect('DeathFailOut')
    ClearPedTasksImmediately(cache.ped)
    SetEntityInvincible(cache.ped, false)
    ClearPedBloodDamage(cache.ped)
    EnableAllControlActions(0)

    TriggerEvent('reload_death:onPlayerRevive')
    TriggerServerEvent('esx:onPlayerSpawn')
    TriggerEvent('esx:onPlayerSpawn')
    TriggerEvent('playerSpawned')

    ESX.SetPlayerData('dead', false)
end

RegisterNetEvent('esx:onPlayerDeath', function(data)
    if not ESX.IsPlayerLoaded() then
        CompleteRevive()
        return
    end
    StartDeath()
end)

RegisterNetEvent('esx:playerLoaded', function(data)
    local playerData = lib.callback.await('reload_death:getDead', false)

    if playerData.dead then
        FreezeEntityPosition(cache.ped, true)
        Wait(8000)
        FreezeEntityPosition(cache.ped, false)

        DeathState.isDead = true
        DeathState.isReviving = false
        ESX.SetPlayerData('dead', true)

        SetEntityHealth(cache.ped, 0)

        exports['esx_ambulancejob']:StartDeathTimer()
        exports['esx_ambulancejob']:StartDistressSignal()
    end

    if playerData.inBed then
        TriggerEvent('esx_ambulancejob:toggleBed')
    end
end)

RegisterNetEvent('reload_death:startrev', function()
    DeathState.isReviving = true
end)

RegisterNetEvent('reload_death:revive', function()
    local coords = GetEntityCoords(cache.ped)

    DoScreenFadeOut(200)
    while IsScreenFadingOut() do Wait(100) end

    local formattedCoords = {
        x = ESX.Math.Round(coords.x, 1),
        y = ESX.Math.Round(coords.y, 1),
        z = ESX.Math.Round(coords.z, 1)
    }

    ESX.SetPlayerData('lastPosition', formattedCoords)
    TriggerServerEvent('esx:updateLastPosition', formattedCoords)

    CompleteRevive()
    TriggerServerEvent('reload_death:setDead', false)

    DoScreenFadeIn(3000)
    lib.playAnim(cache.ped, 'get_up@directional@movement@from_knees@action', 'getup_r_0')
end)

RegisterNetEvent('reload_death:reviveRPDeath', function()
    local coords = GetEntityCoords(cache.ped)

    DoScreenFadeOut(200)
    while IsScreenFadingOut() do Wait(100) end

    local formattedCoords = {
        x = ESX.Math.Round(coords.x, 1),
        y = ESX.Math.Round(coords.y, 1),
        z = ESX.Math.Round(coords.z, 1)
    }

    ESX.SetPlayerData('lastPosition', formattedCoords)
    TriggerServerEvent('esx:updateLastPosition', formattedCoords)

    CompleteRevive()
    TriggerServerEvent('reload_death:setDead', false)

    DoScreenFadeIn(3000)
    lib.playAnim(cache.ped, 'get_up@directional@movement@from_knees@action', 'getup_r_0')

    TriggerEvent('esx_ambulancejob:toggleBed')
end)

RegisterNetEvent('reload_death:fakeRevive', function()
    local coords = GetEntityCoords(cache.ped)

    DoScreenFadeOut(200)
    while IsScreenFadingOut() do Wait(100) end

    local formattedCoords = {
        x = ESX.Math.Round(coords.x, 1),
        y = ESX.Math.Round(coords.y, 1),
        z = ESX.Math.Round(coords.z, 1)
    }

    ESX.SetPlayerData('lastPosition', formattedCoords)
    TriggerServerEvent('esx:updateLastPosition', formattedCoords)

    DestroyDeathCamera()
    DeathState.isReviving = false

    StopScreenEffect('DeathFailOut')
    ClearPedTasksImmediately(cache.ped)
    DoScreenFadeIn(3000)

    TriggerServerEvent('esx:onPlayerSpawn')
    TriggerEvent('esx:onPlayerSpawn')
    TriggerEvent('playerSpawned')
end)

RegisterCommand('resetDeathLocation', function()
    if not DeathState.isDead or DeathState.isReviving or DeathState.resetTimeout then return end
    if exports.esx_ambulancejob:IsPlayerCrawling() then return end

    DeathState.resetTimeout = true
    local coords = GetEntityCoords(cache.ped)
    local heading = GetEntityHeading(cache.ped)

    FreezeEntityPosition(cache.ped, false)
    SetEntityCoordsNoOffset(cache.ped, coords.x, coords.y, coords.z, false, false, false, true)
    exports['deivuks-utils']:health()
    NetworkResurrectLocalPlayer(coords.x, coords.y, coords.z, heading, true, false)
    SetEntityHealth(cache.ped, 0)

    Wait(30000)
    DeathState.resetTimeout = false
end)
RegisterKeyMapping('resetDeathLocation', 'Reset Death Location', 'keyboard', 'e')