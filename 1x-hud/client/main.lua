local seatbelt = false
local currentKm = 0.0
local lastPos = nil
local saveTimer = 0
local lastLockState = nil
local PlayerInZone = false
local serverPlayerCount = 0
local hudVisible = true
local hunger = 0
local thirst = 0

-- Register export immediately when file loads
local function updateSafeZone(state)
    if state == nil then
        PlayerInZone = not PlayerInZone
    elseif type(state) == "boolean" then
        PlayerInZone = state
    elseif type(state) == "number" then
        PlayerInZone = state > 0
    elseif type(state) == "string" then
        PlayerInZone = state:lower() == "true" or state == "1"
    else
        PlayerInZone = false
    end
    
    SendNUIMessage({ 
        action = "safeZone",
        safeZone = PlayerInZone 
    })
    
    TriggerEvent('onex-hud:safeZoneUpdated', PlayerInZone)
    return PlayerInZone
end

-- Register export immediately
exports('updateSafeZone', updateSafeZone)

-- Also register when resource starts (double assurance)
AddEventHandler('onClientResourceStart', function(resourceName)
    if resourceName == GetCurrentResourceName() then
        -- Re-register export to ensure it's available
        exports('updateSafeZone', updateSafeZone)
        
        CreateThread(function()
            Wait(1000)
            TriggerServerEvent('hud:requestPlayerCount')
        end)
    end
end)

CreateThread(function()
    Wait(5000)
    TriggerServerEvent('hud:requestPlayerCount')
end)

local function formatIcon(icon, defaultIcon)
    if not icon then return defaultIcon end
    if not icon:match("fa") then
        return "fas fa-" .. icon
    end
    return icon:gsub("fa%-solid", "fas")
end

local function normalizeNotifyPayload(payload, message, icon, duration)
    if type(payload) == 'table' then
        local notifyType = payload.type
        local defaultIcon = 'car'

        if notifyType == 'success' then
            defaultIcon = 'check'
        elseif notifyType == 'error' then
            defaultIcon = 'xmark'
        elseif notifyType == 'warning' then
            defaultIcon = 'triangle-exclamation'
        elseif notifyType == 'info' or notifyType == 'inform' then
            defaultIcon = 'circle-info'
        end

        return {
            title = tostring(payload.title or payload.label or 'PRANEŠIMAS'),
            message = tostring(payload.description or payload.message or payload.text or ''),
            icon = formatIcon(payload.icon, formatIcon(defaultIcon, 'fas fa-car')),
            duration = payload.duration or payload.length or 5000,
        }
    end

    return {
        title = tostring(payload or 'PRANEŠIMAS'),
        message = tostring(message or ''),
        icon = formatIcon(icon, 'fas fa-car'),
        duration = duration or 5000,
    }
end

RegisterNetEvent("twox-hud:send")
AddEventHandler("twox-hud:send", function(title, message, icon, duration)
    SendNUIMessage({
        action = 'showNotify',
        title = title,
        message = message,
        icon = formatIcon(icon, "fas fa-car"),
        duration = duration or 5000
    })
end)

exports("simpleNotification", function(title, message, icon, duration)
    SendNUIMessage({
        action = 'showNotify',
        title = title,
        message = message,
        icon = formatIcon(icon, "fas fa-car"),
        duration = duration or 5000
    })
end)

exports('sendNotification', function(payload, message, icon, duration)
    local data = normalizeNotifyPayload(payload, message, icon, duration)
    SendNUIMessage({
        action = 'showNotify',
        title = data.title,
        message = data.message,
        icon = data.icon,
        duration = data.duration
    })
end)

RegisterNetEvent('twox-hud:txAnnouncement', function(data)
    SendNUIMessage({
        action = 'showAnnouncement',
        title = data.title,
        message = data.message,
        icon = data.icon or "bullhorn",
        duration = data.duration or 10000
    })
end)

RegisterNetEvent('txAdmin:events:scheduledRestart')
AddEventHandler('txAdmin:events:scheduledRestart', function(data)
    SendNUIMessage({
        action = 'showAnnouncement',
        title = "SERVER RESTART",
        message = data.translatedMessage or data.message,
        icon = "clock",
        duration = 12000
    })
end)

RegisterNetEvent('txAdmin:events:announcement')
AddEventHandler('txAdmin:events:announcement', function(data)
    SendNUIMessage({
        action = 'showAnnouncement',
        title = data.title or "PRANEŠIMAS",
        message = data.message,
        icon = data.icon or "bullhorn",
        duration = data.duration or 10000
    })
end)

RegisterNetEvent('hud:updatePlayerCount', function(count)
    serverPlayerCount = count
end)

local function GetVehicleLockState(vehicle)
    if not vehicle or vehicle == 0 then return false end
    return GetVehicleDoorLockStatus(vehicle) >= 2
end

CreateThread(function()
    while true do
        Wait(1000)

        TriggerEvent('esx_status:getStatus', 'hunger', function(status)
            if status then
                hunger = math.floor(status.val / 10000)
            end
        end)

        TriggerEvent('esx_status:getStatus', 'thirst', function(status)
            if status then
                thirst = math.floor(status.val / 10000)
            end
        end)
    end
end)

CreateThread(function()
    local lastState = false

    while true do
        Wait(200)
        local isPaused = IsPauseMenuActive()

        if isPaused ~= lastState then
            lastState = isPaused
            hudVisible = not isPaused

            SendNUIMessage({
                action = "toggleHud",
                visible = hudVisible
            })
        end
    end
end)

CreateThread(function()
    while true do
        Wait(500)
        local ped = PlayerPedId()
        local veh = GetVehiclePedIsIn(ped, false)
        if veh ~= 0 then
            local locked = GetVehicleLockState(veh)
            if locked ~= lastLockState then
                lastLockState = locked
                SendNUIMessage({ vehicleHud = { inVehicle = true, locked = locked } })
            end
        else
            lastLockState = nil
        end
    end
end)

CreateThread(function()
    DecorRegister("VehicleMileage", 1)
end)

CreateThread(function()
    while true do
        Wait(1000)
        local ped = PlayerPedId()
        local coords = GetEntityCoords(ped)
        local streetHash = GetStreetNameAtCoord(coords.x, coords.y, coords.z)
        local streetName = GetStreetNameFromHashKey(streetHash)
        if not streetName or streetName == "" then streetName = "Unknown" end
        SendNUIMessage({ location = streetName })
    end
end)

CreateThread(function()
    while true do
        Wait(1000)
        local ped = PlayerPedId()
        local veh = GetVehiclePedIsIn(ped, false)

        if veh ~= 0 and GetPedInVehicleSeat(veh, -1) == ped then
            local pos = GetEntityCoords(veh)
            if not lastPos then
                lastPos = pos
                TriggerServerEvent('hud:getMileage', GetVehicleNumberPlateText(veh))
            else
                local dist = #(pos - lastPos)
                if dist < 80 then
                    currentKm += (dist / 1000.0)
                    DecorSetFloat(veh, "VehicleMileage", currentKm)
                end
                lastPos = pos
            end

            saveTimer += 1
            if saveTimer >= 30 then
                saveTimer = 0
                TriggerServerEvent('hud:saveMileage', GetVehicleNumberPlateText(veh), currentKm)
            end
        else
            lastPos = nil
            saveTimer = 0
        end
    end
end)

RegisterNetEvent('hud:setMileage', function(km)
    currentKm = km or 0.0
end)

RegisterCommand('seatbelt', function()
    seatbelt = not seatbelt
end, false)
RegisterKeyMapping('seatbelt', 'Uzsisegti saugos dirza', 'keyboard', 'y')

local function GetVehicleLightState(veh)
    if not veh or veh == 0 then return 'off' end

    local engineRunning = GetIsVehicleEngineRunning(veh)
    if not engineRunning then return 'off' end

    local lightsOff, lowBeams, highBeams = GetVehicleLightsState(veh)

    if highBeams == 1 then
        return 'high'
    elseif lowBeams == 1 then
        return 'low'
    else
        return 'off'
    end
end

CreateThread(function()
    while true do
        Wait(100)

        if not hudVisible then
            Wait(200)
            goto continue
        end

        local ped = PlayerPedId()
        local veh = GetVehiclePedIsIn(ped, false)
        local vehData = { inVehicle = false }

        if veh ~= 0 and GetPedInVehicleSeat(veh, -1) == ped then
            local lights = GetVehicleLightState(veh)

            vehData = {
                inVehicle = true,
                speed = math.floor(GetEntitySpeed(veh) * 3.6),
                fuel = Entity(veh).state.fuel or 0,
                engine = math.floor(GetVehicleEngineHealth(veh) / 10),
                locked = GetVehicleDoorLockStatus(veh) >= 2,
                lights = lights,
                seatbelt = seatbelt,
                mileage = currentKm
            }
        end

        SendNUIMessage({
            showHud = true,
            health = GetEntityHealth(ped) - 100,
            armor = GetPedArmour(ped),
            hunger = hunger,
            thirst = thirst,
            playerId = GetPlayerServerId(PlayerId()),
            pcount = serverPlayerCount,
            showSpeed = vehData.inVehicle,
            speed = vehData.speed or 0,
            vehicleHud = vehData
        })

        ::continue::
    end
end)

function GetMinimapAnchor()
    local safezone = GetSafeZoneSize()
    local safezone_x = 1.0 / 20.0
    local safezone_y = 1.0 / 20.0
    local aspect_ratio = GetAspectRatio(false)
    local res_x, res_y = GetActiveScreenResolution()
    local xscale = 1.0 / res_x
    local yscale = 1.0 / res_y
    local Minimap = {}
    Minimap.width = xscale * (res_x / (4 * aspect_ratio))
    Minimap.height = yscale * (res_y / 5.674)
    Minimap.left_x = xscale * (res_x * (safezone_x * ((math.abs(safezone - 1.0)) * 10)))
    Minimap.bottom_y = 1.0 - yscale * (res_y * (safezone_y * ((math.abs(safezone - 1.10 )) * 2)))
    Minimap.right_x = Minimap.left_x + Minimap.width
    Minimap.top_y = Minimap.bottom_y - Minimap.height
    Minimap.x = Minimap.left_x
    Minimap.y = Minimap.top_y
    Minimap.xunit = xscale
    Minimap.yunit = yscale
    return Minimap
end

Citizen.CreateThread(function()
    while true do
        Wait(1000)
        local mm = GetMinimapAnchor()
        SendNUIMessage({
            action = 'minimapAnchor',
            left_x = mm.left_x * 100,
            right_x = mm.right_x * 100,
            y = mm.y * 100,
            height = mm.height * 100
        })
    end
end)

-- Final assurance: Re-register after a short delay
Citizen.CreateThread(function()
    Wait(2000)
    exports('updateSafeZone', updateSafeZone)
    print("^2[onex-hud] Export 'updateSafeZone' registered successfully")
end)