local isInTransitionState = false
local isSpectateEnabled = false
local spectatorReturnCoords, storedTargetPed, storedTargetPlayerId, storedTargetServerId

local function calculateSpectatorCoords(coords)
    return vec3(coords.x, coords.y, coords.z - 15.0)
end

---@diagnostic disable-next-line: undefined-global
local function prepareSpectatorPed(enabled)
    ---@diagnostic disable-next-line: undefined-global
    FreezeEntityPosition(cache.ped, enabled)
    ---@diagnostic disable-next-line: undefined-global
    SetEntityVisible(cache.ped, not enabled, false)

    if enabled then
        ---@diagnostic disable-next-line: undefined-global
        TaskLeaveAnyVehicle(cache.ped, 0, 16)
    end
end

local function collisionTpCoordTransition(coords)
    if not IsScreenFadedOut() then DoScreenFadeOut(500) end
    while not IsScreenFadedOut() do Wait(5) end

    RequestCollisionAtCoord(coords.x, coords.y, coords.z)
    ---@diagnostic disable-next-line: undefined-global
    SetEntityCoords(cache.ped, coords.x, coords.y, coords.z, false, false, false, false)

    local attempts = 0
    ---@diagnostic disable-next-line: undefined-global
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

    NetworkSetInSpectatorMode(false, 0)
    SetMinimapInSpectatorMode(false, 0)

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

local function selfServerId()
    ---@diagnostic disable-next-line: undefined-global
    if cache and cache.serverId then return cache.serverId end
    return GetPlayerServerId(PlayerId())
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
            local pedCoords = GetEntityCoords(storedTargetPed)
            local newSpectateCoords
            if storedTargetServerId == selfServerId() then
                newSpectateCoords = pedCoords
            else
                newSpectateCoords = calculateSpectatorCoords(pedCoords)
            end
            ---@diagnostic disable-next-line: undefined-global
            SetEntityCoords(cache.ped, newSpectateCoords.x, newSpectateCoords.y, newSpectateCoords.z, false, false, false, false)

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
        ---@diagnostic disable-next-line: undefined-global
        spectatorReturnCoords = GetEntityCoords(cache.ped)
    end

    -- Allow spectating self now (was previously blocked)

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

    local targetName = GetPlayerName(resolvedPlayerId)
    local selfTxt = (storedTargetServerId == selfServerId()) and ' (savęs)' or ''
    SendNUIMessage({
        type = 'text-ui',
        show = true,
        text = '<i class="fa-solid fa-eye text-[#48759F] animate-pulse"></i> Šiuo metu stebite <a class="text-[#48759F] font-bold">'..targetName..'</a>'..selfTxt..', norėdami nutraukti stebėjimą spauskite [E].',
    })
end

RegisterNetEvent('adminmenu:startSpectate', function(id)
    startSpectating(tonumber(id))
end)

RegisterNUICallback('spectate', function(data, cb)
    if data and data.player then
        startSpectating(tonumber(data.player))
    end
    if cb then cb({ ok = true }) end
end)

RegisterCommand("stopSpectate", function(_, args, raw)
    stopSpectating()
end, false)

RegisterKeyMapping("stopSpectate", "Baigti stebėjimą", "keyboard", "e")