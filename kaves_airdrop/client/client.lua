local ox_inventory = exports.ox_inventory

local airDrops = {}
local progress = false

local function canOpenAirdrop()
    if IsEntityDead(cache.ped) or IsPedDeadOrDying(cache.ped) then
        return false
    end

    -- if not IsPedArmed(cache.ped, 4) then
    --     exports['1x-hud']:sendNotification({
    --         type = 'ERROR',
    --         title = 'Airdrop',
    --         message = 'Turite turėti ginklą rankose, kad galėtumėte atidaryti dėžę.',
    --         duration = 5000,
    --     })
    --     return false
    -- end

    if cache.vehicle then
        exports['1x-hud']:sendNotification({
            type = 'ERROR',
            title = 'Airdrop',
            message = 'Negalite sėdėti automobilyje jeigu norite atidaryti dėžę.',
            duration = 5000,
        })
        return false
    end

    return true
end

local function drawText(coords, text)
	coords = vector3(coords.x, coords.y, coords.z + 1.0)

	local camCoords = GetGameplayCamCoords()
	local distance = #(coords - camCoords)

	local scale = (1 / distance) * 2
	local fov = (1 / GetGameplayCamFov()) * 100
	scale = scale * fov

	SetTextScale(0.0 * scale, 0.55 * scale)
	SetTextFont(13)
	SetTextColour(255, 255, 255, 255)
	SetTextDropshadow(0, 0, 0, 0, 255)
	SetTextDropShadow()
	SetTextOutline()
	SetTextCentre(true)

	SetDrawOrigin(coords.x, coords.y, coords.z, 0)
	BeginTextCommandDisplayText('STRING')
	AddTextComponentSubstringPlayerName(text)
	EndTextCommandDisplayText(0.0, 0.0)
	ClearDrawOrigin()
end

local addTimer = function(dropId)
    Citizen.CreateThread(function()
        while airDrops[dropId] do
            local airdrop = airDrops[dropId]
            if airdrop.time and airdrop.time > 0 then
                airdrop.time -= 1000
            end
            Wait(1000)
        end
    end)
end

local secondsToClock = function(seconds)
	seconds = tonumber(seconds)
	if seconds <= 0 then
		return "00:00"
	else
		local mins = string.format("%02.f", math.floor(seconds / 60))
		local secs = string.format("%02.f", math.floor(seconds - mins * 60))
		return string.format("%s:%s", mins, secs)
	end
end

local dropCrate = function(coords, dropId, allowed)
    if not airDrops[dropId] then return end
    airDrops[dropId].dropped = true

    local crateModel = Config.crateModel

    lib.requestModel(crateModel)

    local crate = CreateObject(crateModel, coords.x, coords.y, coords.z, false, false, false)
    airDrops[dropId].crate = crate

    SetEntityLodDist(crate, 9999)
    PlaceObjectOnGroundProperly(crate)
    FreezeEntityPosition(crate, true)

    local smoke = StartParticleFxLoopedAtCoord("exp_grd_flare", coords.x, coords.y, coords.z + 0.2, 0.0, 0.0, 0.0, 2.0, false, false, false, false)
    SetParticleFxLoopedAlpha(smoke, 0.8)
    SetParticleFxLoopedColour(smoke, 0.0, 0.0, 0.0, false)

    local soundID = GetSoundId()
    PlaySoundFromEntity(soundID, "Crate_Beeps", crate, "MP_CRATE_DROP_SOUNDS", true, 0)
    airDrops[dropId].soundID = soundID

    local crateBlip = airDrops[dropId].crateBlip
    if not DoesBlipExist(crateBlip) and allowed then
        local crateBlips = Config.crateBlips
        if not airDrops[dropId].needsItem then
            crateBlip = AddBlipForCoord(coords.x, coords.y, coords.z)
            SetBlipSprite(crateBlip, crateBlips.sprite)
            SetBlipColour(crateBlip, crateBlips.color)
            SetBlipScale(crateBlip, 1.0)
            SetBlipFlashes(crateBlip, true)
            SetBlipFlashInterval(crateBlip, 250)
        else
            local blipCoords
            repeat
                local randomX = coords.x + math.random(-100, 100)
                local randomY = coords.y + math.random(-100, 100)

                local newCoords = vector3(randomX, randomY, coords.z)

                if #(newCoords - coords) < 100 then
                    blipCoords = vector3(newCoords.x, newCoords.y, coords.z)
                end

            until blipCoords

            local color = airDrops[dropId].color == 'red' and 1 or crateBlips.color

            crateBlip = AddBlipForCoord(blipCoords.x, blipCoords.y, coords.z)
            SetBlipSprite(crateBlip, crateBlips.sprite)
            SetBlipColour(crateBlip, color)
            SetBlipScale(crateBlip, 1.0)
            SetBlipFlashes(crateBlip, true)
            SetBlipFlashInterval(crateBlip, 250)

            local crateArea = AddBlipForRadius(blipCoords.x, blipCoords.y, coords.z, 100.0)
            SetBlipSprite(crateArea, 9)
            SetBlipColour(crateArea, color)
            SetBlipAlpha(crateArea, 100)
            SetBlipAsShortRange(crateArea, false)

            airDrops[dropId].crateArea = crateArea
        end

        airDrops[dropId].crateBlip = crateBlip

        SetBlipAsShortRange(crateBlip, false)
        BeginTextCommandSetBlipName("STRING")
    	AddTextComponentString('<font face="Roboto">Airdrop dėžė</font>')
    	EndTextCommandSetBlipName(crateBlip)
    end

    Citizen.CreateThread(function()
        if not airDrops[dropId].needsItem and not allowed then return end

        local crateCoords = GetEntityCoords(airDrops[dropId].crate)

        airDrops[dropId].point = lib.points.new({
            coords = crateCoords,
            distance = 30,
            nearby = function(self)
                if self.currentDistance < 3.0 and airDrops[dropId].unlocked then
                    drawText(crateCoords, '[E] Atidaryti dėzę')
                    if IsControlJustPressed(0, 38) and canOpenAirdrop() and not progress then
                        progress = true
                        if exports['onex-minigames']:startMinigame('cylinders') and airDrops[dropId] then
                            TriggerServerEvent("kaves_airdrop:server:openCrate", dropId)
                        end
                        progress = false
                    end
                elseif self.currentDistance < 15.0 then
                    drawText(crateCoords, ("%s"):format(secondsToClock(airDrops[dropId].time / 1000)))
                end
            end
        })
    end)

end

local createPlane = function(coords, dropId, allowed)
    if not airDrops[dropId] then return end

    local planeModel = Config.planeModels[math.random(1, #Config.planeModels)]
    local pilotModel = Config.pilotModel

    lib.requestModel(planeModel)
    lib.requestModel(pilotModel)

    local planeSpawnCoords = Config.planeSpawnCoords

    local plane = CreateVehicle(planeModel, planeSpawnCoords.x, planeSpawnCoords.y, planeSpawnCoords.z, planeSpawnCoords.w, false, false)
    airDrops[dropId].plane = plane

    SetEntityCollision(plane, false, true)
    SetVehicleDoorsLocked(plane, 2)
    SetVehicleEngineOn(plane, true, true, false)
    SetHeliBladesFullSpeed(plane)
    SetPlaneMinHeightAboveTerrain(plane, 150.0)
    SetBlockingOfNonTemporaryEvents(plane, true)
    SetEntityProofs(plane, true, true, true, true, true, true, true, true)
    SetEntityInvincible(plane, true)
    ControlLandingGear(plane, 3)

    local pilot = CreatePedInsideVehicle(plane, 1, pilotModel, -1, false, false)
    airDrops[dropId].pilot = pilot

    SetEntityProofs(pilot, true, true, true, true, true, true, true, true)
    SetEntityInvincible(pilot, true)
    SetPedRandomComponentVariation(pilot, 0)
    SetPedKeepTask(pilot, true)
    TaskVehicleDriveToCoord(pilot, plane, coords.x, coords.y, coords.z, 500.0, 0, planeModel, 262144, 15.0, -1.0)

    if not DoesBlipExist(airDrops[dropId].planeBlip) and allowed then
        local blip = AddBlipForEntity(airDrops[dropId].plane)
        SetBlipSprite(blip, Config.planeBlips.sprite)
        SetBlipColour(blip, Config.planeBlips.color)
        SetBlipAsShortRange(blip, false)
        SetBlipScale(blip, 1.0)
        BeginTextCommandSetBlipName("STRING")
    	AddTextComponentString('<font face="Roboto">Lėktuvas</font>')
    	EndTextCommandSetBlipName(blip)
        airDrops[dropId].planeBlip = blip
    end

    Citizen.CreateThread(function()
        while airDrops[dropId] and not airDrops[dropId].dropped do
            if not DoesEntityExist(plane) or not DoesEntityExist(pilot) then
                dropCrate(vector3(coords.x, coords.y, coords.z), dropId, allowed)
                break
            end

            local planeCoords = GetEntityCoords(airDrops[dropId].plane)
            if #(planeCoords.xy - coords.xy) < 30 then
                dropCrate(vector3(coords.x, coords.y, coords.z), dropId, allowed)
                break
            end

            Wait(250)
        end

        if DoesEntityExist(plane) and DoesEntityExist(pilot) then
            local returnCoords = Config.planeReturnCoords
            TaskVehicleDriveToCoord(pilot, plane, returnCoords.x, returnCoords.y, returnCoords.z, 500.0, 0, planeModel, 262144, 15.0, -1.0)

            SetTimeout(30000, function()
                if DoesEntityExist(pilot) then DeleteEntity(pilot) end
                if DoesEntityExist(plane) then DeleteEntity(plane) end
            end)
        end
    end)

end

RegisterNetEvent("kaves_airdrop:client:createDrop", function(data)
    if airDrops[data.dropId] then
        return
    end

    local allowed = false

    if not data.needsItem then
        local jobName = ESX.GetPlayerData().job.name

        allowed = data.jobs[jobName]
    else
        allowed = ox_inventory:GetItemCount('airdrop_locator') > 0
    end

    airDrops[data.dropId] = {
        coords = data.coords,
        time = data.time,
        needsItem = data.needsItem,
        unlocked = false,
        spawned = false,
        color = data.color
    }

    if allowed then
        exports['1x-hud']:sendNotification({
            type = 'INFO',
            title = 'Air Drop',
            message = 'Air Drop skraidinantis lėktuvas pajudėjo link išmetimo vietos, stebėkite žemėlapį ir būkite pasiruošę veikti.',
            duration = 15000,
            icon = 'parachute-box'
        })
    end

    if data.needsItem or allowed then
        addTimer(data.dropId)
    end

    SetTimeout(5 * 1000, function()
        createPlane(data.coords, data.dropId, allowed)
    end)
end)

RegisterNetEvent("kaves_airdrop:client:dropUnlocked", function(dropId)
    local airdrop = airDrops[dropId]

    if not airdrop then return end
    airdrop.unlocked = true
    StopSound(airdrop.soundID)
    ReleaseSoundId(airdrop.soundID)
end)

RegisterNetEvent("kaves_airdrop:client:dropCollected", function(dropId)
    local airdrop = airDrops[dropId]

    if not airdrop then return end

    if DoesEntityExist(airdrop.crate) then
        DeleteEntity(airdrop.crate)
    end

    if airdrop.smoke then
        StopParticleFxLooped(airdrop.smoke, false)
    end

    if DoesBlipExist(airdrop.crateBlip) then
        RemoveBlip(airdrop.crateBlip)
    end

    if DoesBlipExist(airdrop.crateArea) then
        RemoveBlip(airdrop.crateArea)
    end

    StopSound(airdrop.soundID)
    ReleaseSoundId(airdrop.soundID)

    if airdrop.point then
        airdrop.point:remove()
    end

    airDrops[dropId] = nil
end)