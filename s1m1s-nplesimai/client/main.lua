Config = {}

local ox_inventory = exports.ox_inventory
local ox_target = exports.ox_target

local nearestHouse, nearestLoot, houseInterior, outsideHouse, houseResident
local lootPoints, inHousePoint, signalizationEntities = {}, nil, {}

local policeCount = nil

local function policeCountTimeout()
    SetTimeout(60000, function() policeCount = nil end)
end

local hackingSignalization = false
local function hackSignalization()
    if hackingSignalization or not nearestHouse then return end

    if not policeCount then
        policeCount = lib.callback.await('houserobbery:getPolice', false)
        policeCountTimeout()
    end

    if policeCount < 0 then
        exports['1x-hud']:sendNotification({
            type = 'ERROR',
            title = 'Namų plėšimas',
            message = 'Deja, nėra pakankamai pareigūnų, todėl plėšti namo šiuo metu negalite.',
            duration = 6000,
        })
        return
    end

    local hasLaptop = ox_inventory:GetItemCount('laptop') > 0
    if not hasLaptop then
        exports['1x-hud']:sendNotification({
            type = 'ERROR',
            title = 'Namų plėšimas',
            message = 'Deja, neturite nešiojamo kompiuterio, su kuriuo galėtumėte nulaužti signalizaciją.',
            duration = 6000,
        })
        return
    end

    local houseData = Config.Houses[nearestHouse]
    if not houseData then return end

    lib.requestAnimDict('mp_arresting')
    TaskPlayAnim(cache.ped, 'mp_arresting', 'a_uncuff', 8.0, -8.0, -1, 49, 0, false, false, false)

    local gameStatus = exports["CircuitBreakerMinigame"]:run(1, 1, 0.00085, 5000, 5000, 5000, 0, 10000, 3000, 30000)
    StopAnimTask(cache.ped, 'mp_arresting', 'a_uncuff', -8.0)
    if gameStatus ~= 1 then
        hackingSignalization = false
        return
    end

    hackingSignalization = false
    TriggerServerEvent('houserobbery:hackedSignalization', nearestHouse)
end

local function createHousePoint(houseId, coords, signalization)
    lib.points.new({
        coords = coords,
        distance = 10.0,
        nearby = function(self)
            DrawMarker(1, coords.x, coords.y, coords.z -1, 0,0,0,0,0,0, 1.5, 1.5, 1.5, 255, 255, 255, 120, false, false, 0, false, nil, nil, false)
            if self.isClosest and nearestHouse ~= houseId then
                nearestHouse = houseId
            end
        end,
        onExit = function()
            if signalizationEntities[houseId] then
                DeleteEntity(signalizationEntities[houseId])
                signalizationEntities[houseId] = nil
            end
            nearestHouse = nil
        end,
        onEnter = function()
            if signalization and not signalizationEntities[houseId] then
                lib.requestModel(`hei_prop_hei_keypad_01`)
                local entity = CreateObject(`hei_prop_hei_keypad_01`, signalization.x, signalization.y, signalization.z, false, true, false)
                while not DoesEntityExist(entity) do
                    Wait(100)
                end
                SetEntityHeading(entity, signalization.w)
                FreezeEntityPosition(entity, true)
                ox_target:addLocalEntity(entity, {
                    {
                        label = 'Nulaužti signalizaciją',
                        icon = 'fa-solid fa-unlock-keyhole',
                        distance = 2.0,
                        onSelect = function()
                            if not Config.HouseData[houseId]?.signalization then
                                hackSignalization()
                            end
                        end
                    }
                })
                signalizationEntities[houseId] = entity
            end
        end
    })
end

Citizen.CreateThread(function()
    while not ESX.IsPlayerLoaded() do Wait(500) end

    Config = lib.callback.await('houserobbery:getConfig', false)

    for houseId, data in pairs(Config.Houses) do
        createHousePoint(houseId, data.coords, data.signalization)
    end
end)

local lockpicking = false
local function lockpickHouse()
    local houseData = Config.Houses[nearestHouse]
    if not houseData then return false end

    if not policeCount then
        policeCount = lib.callback.await('houserobbery:getPolice', false)
        policeCountTimeout()
    end

    if houseData.isLuxury and (policeCount < 0) or (policeCount < 0) then
        exports['1x-hud']:sendNotification({
            type = 'ERROR',
            title = 'Namų plėšimas',
            message = 'Deja, nėra pakankamai pareigūnų, todėl plėšti namo šiuo metu negalite.',
            duration = 6000,
        })
        return false
    end

    local hasLockpick = ox_inventory:GetItemCount('lockpick') > 0
    if not hasLockpick then
        exports['1x-hud']:sendNotification({
            type = 'ERROR',
            title = 'Namų plėšimas',
            message = 'Deja, neturite visrakčio, su kuriuo galėtumėte atrakinti namų duris.',
            duration = 6000,
        })
        return false
    end

    lockpicking = true

    lib.requestAnimDict('mp_arresting')
    TaskPlayAnim(cache.ped, 'mp_arresting', 'a_uncuff', 8.0, -8.0, -1, 49, 0, false, false, false)

    if not houseData.isLuxury then
        local success = exports["t3_lockpick"]:startLockpick(0.5, 4, 5)
        StopAnimTask(cache.ped, 'mp_arresting', 'a_uncuff', -8.0)
        if not success then
            TriggerServerEvent('houserobbery:removeLockpick', nearestHouse)
            lockpicking = false
            return false
        end
    else
        local success = exports["onex-minigames"]:startMinigame('numbershacking')
        StopAnimTask(cache.ped, 'mp_arresting', 'a_uncuff', -8.0)
        if not success then
            TriggerServerEvent('houserobbery:removeLockpick', nearestHouse)
            lockpicking = false
            return false
        end
    end

    lockpicking = false
    return true
end

local function createLoot(lootId, coords)
    lootPoints[lootId] = lib.points.new({
        coords = coords,
        distance = 3,
        nearby = function(self)
            DrawMarker(0, coords.x, coords.y, coords.z, 0,0,0,0,0,0, 0.5, 0.5, 0.5, 255, 255, 255, 120, false, false, 0, false, nil, nil, false)
            if self.isClosest and nearestLoot ~= lootId then
                nearestLoot = lootId
            end
        end,
        onExit = function()
            if nearestLoot == lootId then
                nearestLoot = nil
            end
        end
    })
end

local function attackPlayer(ped)
    if not ped or not DoesEntityExist(ped) or IsPedAPlayer(ped) then return end

    if ped == houseResident then
        TriggerServerEvent('houserobbery:attackPlayer', outsideHouse)
    end

    Wait(500)

    NetworkRequestControlOfEntity(ped)
    SetEntityAsMissionEntity(ped, true, true)

    -- wake up: stop anim, unfreeze, allow AI
    ClearPedTasksImmediately(ped)
    FreezeEntityPosition(ped, false)
    SetBlockingOfNonTemporaryEvents(ped, false)
    SetEntityInvincible(ped, false)

    -- FIX: correct way to create/use relationship group
    local relGroupName = 'RESIDENT_ENEMY'
    local _, relGroupHash = AddRelationshipGroup(relGroupName)  -- returns (success, hash)
    SetPedRelationshipGroupHash(ped, relGroupHash)
    SetRelationshipBetweenGroups(5, relGroupHash, `PLAYER`)
    SetRelationshipBetweenGroups(5, `PLAYER`, relGroupHash)

    SetPedCombatAbility(ped, 2)
    SetPedCombatRange(ped, 2)
    SetPedCombatMovement(ped, 3)
    SetPedCombatAttributes(ped, 46, true)

    TaskCombatPed(ped, cache.ped, 0, 16)

    SetPedMaxHealth(ped, 350)
    SetEntityHealth(ped, 350)
    SetPedArmour(ped, 100)
    SetPedConfigFlag(ped, 14, true)
    SetPedSuffersCriticalHits(ped, false)
end

local threadStarted = false
local checkNoise, playerNoise = true, 0
local function startHouseThread()
    if threadStarted then return end
    threadStarted = true

    checkNoise = true
    playerNoise = 0
    Citizen.CreateThread(function()
        while houseInterior and checkNoise do
            if IsPedShooting(cache.ped) then
                playerNoise += 100
            end

            local playerSpeed = GetEntitySpeed(cache.ped)

            if playerSpeed > 3.0 then
                playerNoise += 20
            elseif playerSpeed > 2.5 then
                playerNoise += 15
            elseif playerSpeed > 1.7 then
                playerNoise += 10
            end

            if playerNoise > 30 then
                attackPlayer(houseResident)
                break
            end

            playerNoise = math.max(playerNoise - 10, 0)

            if houseResident and DoesEntityExist(houseResident) and GetEntityHealth(houseResident) <= 0 then
                break
            end

            Wait(100)
        end

        threadStarted = false
    end)
end

local function setupResident()
    if not houseResident then return end

    -- (A) if your interior defines a bed/resident coordinate, snap him there once on client
    local h = outsideHouse and Config.Houses[outsideHouse]
    local interiorTbl = h and ((h.isLuxury and Config.LuxuryInteriors) or Config.Interiors)
    local interior = interiorTbl and interiorTbl[houseInterior]
    local bed = interior and (interior.resident or interior.bed)

    if bed then
        SetEntityCoordsNoOffset(houseResident, bed.x, bed.y, bed.z, false, false, false)
        if bed.w then SetEntityHeading(houseResident, bed.w) end
    end

    -- (B) play sleep anim and keep him frozen
    lib.requestAnimDict('timetable@tracy@sleep@')
    if not IsEntityPlayingAnim(houseResident, 'timetable@tracy@sleep@', 'idle_c', 1) then
        TaskPlayAnim(houseResident, 'timetable@tracy@sleep@', 'idle_c', 8.0, -8.0, -1, 1, 0, false, false, false)
    end

    SetPedMaxHealth(houseResident, 350)
    SetEntityHealth(houseResident, 350)
    SetPedArmour(houseResident, 100)
    SetEntityInvincible(houseResident, true)
    SetBlockingOfNonTemporaryEvents(houseResident, true)

    -- keep him in place on the bed until he wakes
    FreezeEntityPosition(houseResident, true)
end

local function setupLuxuryResidents(peds)
    for ped, _ in pairs(peds) do
        local residentExist = lib.waitFor(function()
            if NetworkDoesEntityExistWithNetworkId(ped) then
                return true
            end
        end, 'Unable to load ped', 30000)
        if not residentExist then return end
    end

    SetTimeout(1000, function()
        if not outsideHouse then return end

        local needsToTrigger = false
        for netId, _ in pairs(peds) do
            local entity = netId and NetworkGetEntityFromNetworkId(netId)
            if entity and not IsPedAPlayer(entity) then
                local entityModel = GetEntityModel(entity)
                if entityModel then lib.requestModel(entityModel) end
                SetEntityVisible(entity, true, false)
                if IsEntityVisible(entity) then
                    if GetPedRelationshipGroupHash(entity) ~= `RESIDENT_ENEMY` and not needsToTrigger then
                        TriggerServerEvent('houserobbery:attackPlayer', outsideHouse)
                        needsToTrigger = true
                    end

                    NetworkRequestControlOfNetworkId(netId)
                    attackPlayer(entity)
                end
            end
            Wait(200)
        end
    end)
end

local function loadHouse(interiorData, houseId)
    if not interiorData then return error('Invalid parameter of function \'loadHouse\': interiorData', 2) end

    if not interiorData.interiorId then return error('Unable to get interior id', 2) end

    local interior = (interiorData.isLuxury and Config.LuxuryInteriors or Config.Interiors)[interiorData.interiorId]
    if not interior then return error('Unable to get interior data, \'interiorId\': ' .. interiorData.interiorId, 2) end

    StartPlayerTeleport(cache.playerId, interior.coords.x, interior.coords.y, interior.coords.z, 0.0, false, true, true)

    local teleported = lib.waitFor(function()
        if not IsPlayerTeleportActive() then
            return true
        end
    end, 'Unable to teleport the player', 30000)
    if not teleported then return end

    if interiorData.ped then
        local residentExist = lib.waitFor(function()
            if NetworkDoesEntityExistWithNetworkId(interiorData.ped) then
                return true
            end
        end, 'Unable to load ped', 30000)
        if not residentExist then return end

        houseResident = interiorData.ped and NetworkGetEntityFromNetworkId(interiorData.ped)
        if houseResident and not IsPedAPlayer(houseResident) then
            SetEntityAsMissionEntity(houseResident, true, true)
            setupResident()
            startHouseThread()
        end
    end

    nearestHouse = nil
    houseInterior = interiorData.interiorId

    outsideHouse = houseId

    exports['1x-hud']:sendNotification({
        type = 'INFO',
        title = 'Namų plėšimas',
        message = 'Norėdami ieškoti daiktų spintelėse spauskite H raidę.',
        duration = 10000,
    })

    for lootId, coords in pairs(interior.loots) do
        if not interiorData.loots[lootId] then
            createLoot(lootId, coords)
        end
    end

    inHousePoint = lib.points.new({
        coords = interior.coords,
        distance = 5,
        nearby = function()
            DrawMarker(1, interior.coords.x, interior.coords.y, interior.coords.z -1, 0,0,0,0,0,0, 1.5, 1.5, 1.5, 255, 255, 255, 120, false, false, 0, false, nil, nil, false)
        end
    })

    DoScreenFadeIn(100)

    if interiorData.peds and type(interiorData.peds) == 'table' and next(interiorData.peds) then
        setupLuxuryResidents(interiorData.peds)
    end
end

local function leaveHouse(coords, kill)
    StartPlayerTeleport(cache.playerId, coords.x, coords.y, coords.z, 0.0, false, true, true)

    local teleported = lib.waitFor(function()
        if not IsPlayerTeleportActive() then
            return true
        end
    end, 'Unable to teleport the player', 30000)
    if not teleported then return end

    for _, point in pairs(lootPoints) do
        point:remove()
    end

    lootPoints = {}

    if inHousePoint then
        inHousePoint:remove()
    end

    inHousePoint = nil

    houseInterior = nil
    outsideHouse = nil
    DoScreenFadeIn(100)

    if kill then
        exports['deivuks-utils']:health()
        NetworkResurrectLocalPlayer(coords.x, coords.y, coords.z, 0.0, 1, false)
        SetEntityHealth(cache.ped, 0)
    end
end

local enteringHouse = false
lib.addKeybind({
    name = 'enterHouse',
    description = 'Enter house',
    defaultKey = 'E',
    onPressed = function()
        if enteringHouse or LocalPlayer.state.dead or not nearestHouse or lockpicking or cache.vehicle then return end

        local houseData = Config.Houses[nearestHouse]
        if not houseData then return end

        enteringHouse = true

        if houseData.isLuxury and not Config.HouseData[nearestHouse]?.signalization then
            exports['1x-hud']:sendNotification({
                type = 'ERROR',
                title = 'Namų plėšimas',
                message = 'Prieš pradėdami įsilaužimą į šį namą privalote nulaužti namo signalizacją.',
                duration = 10000,
            })
            enteringHouse = false
            return
        end

        if not Config.HouseData[nearestHouse]?.lockpicked then
            if not lockpickHouse() then
                enteringHouse = false
                return
            end
        end

        local interior = lib.callback.await('houserobbery:getHouse', false, nearestHouse)
        if not interior then
            enteringHouse = false
            return
        end

        DoScreenFadeOut(100)
        local success, errorMessage = pcall(loadHouse, interior, nearestHouse)
        if not success then
            DoScreenFadeIn(100)
            lib.print.error(errorMessage)
            TriggerServerEvent('houserobbery:leaveHouse', nearestHouse)
            leaveHouse(houseData.coords)
        end

        enteringHouse = false
    end,
})

lib.addKeybind({
    name = 'leaveHouse',
    description = 'Leave house',
    defaultKey = 'E',
    onPressed = function()
        if not outsideHouse or not houseInterior then return end

        local houseData = Config.Houses[outsideHouse]
        if not houseData then return end

        local interior = (houseData.isLuxury and Config.LuxuryInteriors or Config.Interiors)[houseInterior]
        if not interior then return end

        local coords = cache.coords or GetEntityCoords(cache.ped)

        if #(coords - interior.coords) > 2.0 then return end

        TriggerServerEvent('houserobbery:leaveHouse', outsideHouse)

        DoScreenFadeOut(100)
        local success, errorMessage = pcall(leaveHouse, houseData.coords)
        if not success then
            DoScreenFadeIn(100)
            lib.print.error(errorMessage)
        end
    end,
})

local looting = false
lib.addKeybind({
    name = 'lootHouse',
    description = 'Loot house',
    defaultKey = 'H',
    onPressed = function()
        if not outsideHouse or not houseInterior or looting or not nearestLoot then return end

        local houseData = Config.Houses[outsideHouse]
        if not houseData then return end

        looting = true

        lib.requestAnimDict('missexile3')
        TaskPlayAnim(cache.ped, 'missexile3', 'ex03_dingy_search_case_base_michael', 8.0, -8.0, -1, 1, 0, false, false, false)

        if not houseData.isLuxury then
            local success = exports["t3_lockpick"]:startLockpick(0.5, 2, 4)
            if not success then
                StopAnimTask(cache.ped, 'missexile3', 'ex03_dingy_search_case_base_michael', -8.0)
                looting = false
                return
            end
        end

        local lootItems = lib.callback.await('houserobbery:getLoot', false, outsideHouse, nearestLoot)
        if not lootItems then
            looting = false
            return
        end

        local success = exports["onex-minigames"]:startMinigame('loothouse', {
            items = lootItems
        })
        StopAnimTask(cache.ped, 'missexile3', 'ex03_dingy_search_case_base_michael', -8.0)
        if not success then
            looting = false
            return
        end

        TriggerServerEvent('houserobbery:updateLoot', outsideHouse, nearestLoot)

        looting = false
    end,
})

RegisterNetEvent('esx:onPlayerDeath')
AddEventHandler('esx:onPlayerDeath', function()
    if not outsideHouse or not houseInterior then return end

    local houseData = Config.Houses[outsideHouse]
    if not houseData then return end

    TriggerServerEvent('houserobbery:leaveHouse', outsideHouse)

    DoScreenFadeOut(100)
    local success, errorMessage = pcall(leaveHouse, houseData.coords, true)
    if not success then
        DoScreenFadeIn(100)
        lib.print.error(errorMessage)
    end
end)

RegisterNetEvent('houserobbery:resetHouses', function(houses)
    if type(houses) ~= 'table' then return end

    local isInside = false
    for _, houseId in pairs(houses) do
        --lib.print.info('Reseting house with id:'..houseId)
        if not isInside and outsideHouse == houseId then
            isInside = true
        end

        Config.HouseData[houseId] = {}
    end

    if not isInside or not outsideHouse or not houseInterior then return end

    local houseData = Config.Houses[outsideHouse]
    if not houseData then return end

    DoScreenFadeOut(100)
    local success, errorMessage = pcall(leaveHouse, houseData.coords)
    if not success then
        DoScreenFadeIn(100)
        lib.print.error(errorMessage)
    end
end)

RegisterNetEvent('houserobbery:updateLoot', function(lootId)
    local loot = lootPoints[lootId]
    if loot then
        loot:remove()
        lootPoints[lootId] = nil

        if nearestLoot == lootId then nearestLoot = nil end
    end
end)

RegisterNetEvent('houserobbery:updateHouse', function(houseId, statusType)
    if not houseId then return end

    local houseData = Config.HouseData[houseId]
    if type(houseData) ~= 'table' then
        Config.HouseData[houseId] = {}
        houseData = Config.HouseData[houseId]
    end

    if statusType == 'lockpicked' then
        houseData.lockpicked = true
    elseif statusType == 'signalization' then
        houseData.signalization = true
    end
end)
