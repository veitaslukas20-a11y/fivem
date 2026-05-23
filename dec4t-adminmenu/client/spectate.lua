local isInTransitionState = false
local isSpectateEnabled = false
local spectatorReturnCoords, storedTargetPed, storedTargetPlayerId, storedTargetServerId

local function calculateSpectatorCoords(coords)
    return vec3(coords.x, coords.y, coords.z - 15.0)
end

local function prepareSpectatorPed(enabled)
    FreezeEntityPosition(cache.ped, enabled)
    SetEntityVisible(cache.ped, not enabled, 0)

    if enabled then
        TaskLeaveAnyVehicle(cache.ped, 0, 16)
    end
end

local function collisionTpCoordTransition(coords)
    if not IsScreenFadedOut() then DoScreenFadeOut(500) end
    while not IsScreenFadedOut() do Wait(5) end

    RequestCollisionAtCoord(coords.x, coords.y, coords.z)
    SetEntityCoords(cache.ped, coords.x, coords.y, coords.z)

    local attempts = 0
    while not HasCollisionLoadedAroundEntity(cache.ped) do
        Wait(5)
        attempts = attempts + 1
        if attempts > 1000 then
            return false
        end
    end

    return true
end

local function stopSpectating()
    if not isSpectateEnabled then return end
    isSpectateEnabled = false
    isInTransitionState = true

    DoScreenFadeOut(500)
    while not IsScreenFadedOut() do Wait(5) end

    NetworkSetInSpectatorMode(false, nil)
    SetMinimapInSpectatorMode(false, nil)

    if spectatorReturnCoords then
        collisionTpCoordTransition(spectatorReturnCoords)
    end

    prepareSpectatorPed(false)

    storedTargetPed = nil
    storedTargetPlayerId = nil
    storedTargetServerId = nil
    spectatorReturnCoords = nil

    DoScreenFadeIn(500)
    while IsScreenFadingIn() do Wait(5) end
    isInTransitionState = false

    SendNUIMessage({
        type = 'text-ui',
        show = false,
    })

    TriggerServerEvent('adminmenu:spectateEnded')
end

local function createSpectatorTeleportThread()
    CreateThread(function()
        local initialTargetServerid = storedTargetServerId
        while isSpectateEnabled and storedTargetServerId == initialTargetServerid do
            if not DoesEntityExist(storedTargetPed) then
                local newPed = GetPlayerPed(storedTargetPlayerId)
                if newPed > 0 then
                    storedTargetPed = newPed
                else
                    stopSpectating()
                    break
                end
            end

            local newSpectateCoords = calculateSpectatorCoords(GetEntityCoords(storedTargetPed))
            SetEntityCoords(cache.ped, newSpectateCoords.x, newSpectateCoords.y, newSpectateCoords.z, true, false, false, false)

            Wait(500)
        end
    end)
end

local function startSpectating(targetServerId)
    if isInTransitionState then
        stopSpectating()
    end

    if not targetServerId then return end

    if not spectatorReturnCoords then
        spectatorReturnCoords = GetEntityCoords(cache.ped)
    end

    if targetServerId == cache.serverId then
        return
    end

    isInTransitionState = true

    storedTargetPed = nil
    storedTargetPlayerId = nil
    storedTargetServerId = nil

    local coords = lib.callback.await('adminmenu:playerCoords', false, targetServerId)

    if not coords then
        stopSpectating()
        return
    end

    prepareSpectatorPed(true)

    if not collisionTpCoordTransition(coords) then
        stopSpectating()
        return
    end

    local targetResolveAttempts = 0
    local resolvedPlayerId = -1
    local resolvedPed = 0
    while (resolvedPlayerId <= 0 or resolvedPed <= 0) and targetResolveAttempts < 300 do
        targetResolveAttempts = targetResolveAttempts + 1
        resolvedPlayerId = GetPlayerFromServerId(targetServerId)
        resolvedPed = GetPlayerPed(resolvedPlayerId)
        Wait(50)
    end

    if (resolvedPlayerId <= 0 or resolvedPed <= 0) then
        if not collisionTpCoordTransition(spectatorReturnCoords) then
            return
        end

        prepareSpectatorPed(false)

        DoScreenFadeIn(500)
        while IsScreenFadedOut() do Wait(5) end

        isInTransitionState = false
        spectatorReturnCoords = nil
        return
    end

    storedTargetPed = resolvedPed
    storedTargetPlayerId = resolvedPlayerId
    storedTargetServerId = targetServerId

    NetworkSetInSpectatorMode(true, resolvedPed)
    SetMinimapInSpectatorMode(true, resolvedPed)

    isSpectateEnabled = true
    isInTransitionState = false

    createSpectatorTeleportThread()

    DoScreenFadeIn(500)
    while IsScreenFadedOut() do Wait(5) end

    SendNUIMessage({
        type = 'text-ui',
        show = true,
        text = '<i class="fa-solid fa-eye text-[#48759F] animate-pulse"></i> Šiuo metu stebite <a class="text-[#48759F] font-bold">'..GetPlayerName(resolvedPlayerId)..'</a>, norėdami nutraukti stebėjimą spauskite [E].',
    })
end

RegisterNUICallback('spectate', function(data)
    startSpectating(tonumber(data.player))
end)

RegisterCommand("stopSpectate", function()
	stopSpectating()
end)

RegisterKeyMapping("stopSpectate", "Baigti stebėjimą", "keyboard", "e")