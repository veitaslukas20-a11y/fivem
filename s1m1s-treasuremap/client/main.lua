-- CLIENT SIDE --

local Config = {}
local Inventory = exports.ox_inventory
local Target = exports.ox_target
local Searching = false
local PlayerBusy = false
local Blip, Blip2, Zone

local Types = {
    'Labai šalta, ieškokite toliau',
    'Jau šilta, kažkur netoli',
    'Karštaaa, degam. Laikas kasti!!',
}

-- Animation helper
local function PlayAnimation(label, duration, anim, prop)
    return lib.progressBar({
        duration = duration,
        label = label,
        canCancel = true,
        useWhileDead = false,
        allowRagdoll = false,
        allowCuffed = false,
        allowFalling = false,
        allowSwimming = true,
        disable = {move=true, car=true, combat=true},
        anim = anim,
        prop = prop
    }) 
end

-- Wait until ESX player is loaded
Citizen.CreateThread(function()
    while not ESX.IsPlayerLoaded() do
        Wait(100)
    end

    -- Use the correct callback name
    Config = lib.callback.await('map:getConfig', false)
end)

-- Utility: Get ground Z coordinate
local function GetNormalGroundCoords(x, y, z)
    local found, newZ = GetGroundZFor_3dCoord(x, y, z, false)
    if found then return newZ end

    local startCoords = vector3(x, y, z + 100.0)
    local endCoords = vector3(x, y, z - 100.0)
    local raycast = StartExpensiveSynchronousShapeTestLosProbe(startCoords, endCoords, 1, 0, 0)
    local _, hit, hitCoords = GetShapeTestResult(raycast)
    if hit and hit ~= 0 then return hitCoords.z end
    return nil
end

-- Check if coordinate is reachable
local function IsCoordReachable(coords)
    local testPoints = {
        vector3(coords.x + 2.0, coords.y, coords.z),
        vector3(coords.x - 2.0, coords.y, coords.z),
        vector3(coords.x, coords.y + 2.0, coords.z),
        vector3(coords.x, coords.y - 2.0, coords.z)
    }

    for _, point in ipairs(testPoints) do
        local pointGroundZ = GetNormalGroundCoords(point.x, point.y, point.z)
        if pointGroundZ then
            if math.abs(coords.z - pointGroundZ) > 2.0 then
                return false
            end
        end
    end

    local startShapeTest = vector3(coords.x, coords.y, coords.z + 0.5)
    local endShapeTest = vector3(coords.x, coords.y, coords.z + 2.5)
    local shapeTestHandle = StartShapeTestCapsule(startShapeTest, endShapeTest, 0.8, 10, 0, 7)
    local _, hit, _, _, entityHit = GetShapeTestResult(shapeTestHandle)
    return not (hit and entityHit ~= 0)
end

-- Validate coords on the ground
local function ValidateGroundCoords(coords)
    local groundZ = GetNormalGroundCoords(coords.x, coords.y, coords.z)
    if not groundZ then return nil end
    local adjustedCoords = vector3(coords.x, coords.y, groundZ + 0.1)
    if IsCoordReachable(adjustedCoords) then return adjustedCoords end
    return nil
end

-- End digging
local function endDigging()
    Searching = false
    RemoveBlip(Blip)
    RemoveBlip(Blip2)
    if Zone then Target:removeZone(Zone) end
    Blip = nil
    Blip2 = nil
    Zone = nil
    PlayerBusy = false
end

-- Show treasure map
local function ShowTreasure()
    local UID = math.random(#Config.Locations)
    local Location = Config.Locations[UID]

    Blip = AddBlipForRadius(Location.coords.x, Location.coords.y, Location.coords.z, Location.radius)
    SetBlipDisplay(Blip, 2)
    SetBlipColour(Blip, 50)
    SetBlipAlpha(Blip, 100)
    SetBlipAsShortRange(Blip, false)

    Blip2 = AddBlipForCoord(Location.coords.x, Location.coords.y, Location.coords.z)
    SetBlipSprite(Blip2, 587)
    SetBlipDisplay(Blip2, 2)
    SetBlipScale(Blip2, 1.0)
    SetBlipColour(Blip2, 50)
    SetBlipAsShortRange(Blip2, false)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString('<font face="Roboto">Lobio vieta</font>')
    EndTextCommandSetBlipName(Blip2)

    local TargetCoords = nil
    local attempts = 0
    local maxAttempts = 100

    local maxDistance = Location.radius + 20.0
    while #(GetEntityCoords(cache.ped) - Location.coords) > maxDistance do
        Wait(250)
    end

    while not TargetCoords and attempts < maxAttempts do
        attempts = attempts + 1
        local angle = math.random() * 2 * math.pi
        local distance = math.random() * Location.radius * 0.8
        local randomX = Location.coords.x + math.cos(angle) * distance
        local randomY = Location.coords.y + math.sin(angle) * distance
        local newCoords = vector3(randomX, randomY, Location.coords.z)
        local validatedCoords = ValidateGroundCoords(newCoords)
        if validatedCoords and #(validatedCoords - Location.coords) < Location.radius then
            TargetCoords = validatedCoords
        end
        Wait(10)
    end

    if not TargetCoords then
        warn('Unable to generate coords for treasure')
        return
    end

    Zone = Target:addBoxZone({
        coords = TargetCoords,
        name = 'treasuremap',
        size = vec3(0.8, 0.8, 0.8),
        rotation = 0.0,
        drawSpirite = false,
        options = {
            {
                label = 'Iškasti lobį',
                icon = 'fa-solid fa-person-digging',
                distance = 2.0,
                onSelect = function()
                    if PlayerBusy then return end
                    PlayerBusy = true

                    if PlayAnimation('Kasate lobį...', Config.DigTime, {
                        dict = 'random@burial',
                        clip = 'a_burial',
                        flag = 1
                    }, {
                        model = `prop_tool_shovel`,
                        bone = 28422,
                        pos = vector3(0.0, 0.0, 0.24),
                        rot = vector3(0.0, 0.0, 0.0)
                    }) then

                        local result = lib.callback.await('map:startDigg', false, UID)
                        PlayerBusy = false
                        endDigging()

                        if not result or not result.success then
                            exports['1x-hud']:sendNotification({
                                type = 'ERROR',
                                title = 'Lobių žemėlapis',
                                message = 'Deja, šį kartą nepasisekė, pabandyk surasti kitą žemėlapį.',
                                duration = 5000,
                            })
                        end
                    else
                        PlayerBusy = false
                    end
                end
            }
        }
    })

    -- Show distance hints
    Citizen.CreateThread(function()
        local TextUi = nil
        while Searching do
            local coords = GetEntityCoords(cache.ped)
            local distance = #(TargetCoords - coords)
            local newText = nil

            if #(Location.coords - coords) < Location.radius then
                if distance > 20 then newText = Types[1]
                elseif distance > 5 then newText = Types[2]
                else newText = Types[3] end
            end

            if newText ~= TextUi then
                TextUi = newText
                if TextUi then
                    lib.showTextUI(TextUi, {position = 'bottom-center', icon = 'fa-solid fa-person-digging'})
                else
                    lib.hideTextUI()
                end
            end

            Wait(1000)
        end

        if TextUi then lib.hideTextUI() end
    end)
end

-- Expose function to use treasure map
exports('map', function(data)
    if Searching then return end

    Inventory:useItem(data, function(used)
        if used then
            ShowTreasure()
            Searching = true
        end
    end)
end)
