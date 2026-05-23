
local spawnedWeeds, spawnedCoco = 0, 0
local weedPlants, cocoPlants = {}, {}
local lastTrigger = 0
local triggerCooldown = 1500

local Config = {
    Weed = {
        center = vector3(-282.3546, -1631.6033, 31.8488),
        radius = 40.0,
        maxPlants = 10,
        model = `prop_weed_02`
    },
    Coco = {
        center = vector3(-2944.9941, 3444.0764, 10.0907),
        radius = 40.0,
        maxPlants = 10,
        model = `prop_plant_01a`
    },
    Zones = {
        processWeed = { coords = vector3(-935.5188, -1523.1268, 5.2437), radius = 1.6 },
        processCoco = { coords = vector3(2433.6123, 4969.0181, 42.3475), radius = 1.6 },
        sell = { coords = vector3(-11.1338, -1428.1118, 31.1015), radius = 2.0 }
    }
}

local function canTrigger()
    local t = GetGameTimer()
    if (t - lastTrigger) < triggerCooldown then return false end
    lastTrigger = t
    return true
end

local function progress(label, ms)
    return lib.progressBar({
        duration = ms,
        label = label,
        useWhileDead = false,
        canCancel = false,
        disable = { move = true, car = true, combat = true }
    })
end

-- ===== Spawn helperiai =====
local function addPlantTarget(entity, kind)
    local labelText
    if kind == 'weed' then
        labelText = 'Rinkti žolę'
    else
        labelText = 'Rinkti koką'
    end

    exports.ox_target:addLocalEntity(entity, {
        {
            name = 'kdrugs_pick_' .. kind,
            icon = 'fa-solid fa-hand',
            label = labelText,
            distance = 1.6,
            onSelect = function(data)
                if not canTrigger() then return end
                TaskStartScenarioInPlace(cache.ped, 'WORLD_HUMAN_GARDENER_PLANT', 0, true)
                local ok = progress(kind == 'weed' and 'Renki žolę...' or 'Renki koką...', kind == 'weed' and 4000 or 5000)
                ClearPedTasksImmediately(cache.ped)
                if ok then
                    DeleteObject(entity)
                    if kind == 'weed' then
                        spawnedWeeds = spawnedWeeds - 1
                        weedPlants[entity] = nil
                    else
                        spawnedCoco = spawnedCoco - 1
                        cocoPlants[entity] = nil
                    end
                    TriggerServerEvent('k-drugs:pick', kind)
                end
            end
        }
    })
end

local function spawnWeedPlants()
    while spawnedWeeds < Config.Weed.maxPlants do
        Wait(0)
        local x = Config.Weed.center.x + math.random(-10, 10)
        local y = Config.Weed.center.y + math.random(-10, 10)
        local found, z = GetGroundZFor_3dCoord(x + 0.0, y + 0.0, 1000.0, false)
        if found then
            local obj = CreateObject(Config.Weed.model, x, y, z, false, false, false)
            PlaceObjectOnGroundProperly(obj)
            FreezeEntityPosition(obj, true)
            spawnedWeeds = spawnedWeeds + 1
            weedPlants[obj] = true
            addPlantTarget(obj, 'weed')
        end
    end
end

local function spawnCocoPlants()
    while spawnedCoco < Config.Coco.maxPlants do
        Wait(0)
        local x = Config.Coco.center.x + math.random(-10, 10)
        local y = Config.Coco.center.y + math.random(-10, 10)
        local found, z = GetGroundZFor_3dCoord(x + 0.0, y + 0.0, 1000.0, false)
        if found then
            local obj = CreateObject(Config.Coco.model, x, y, z, false, false, false)
            PlaceObjectOnGroundProperly(obj)
            FreezeEntityPosition(obj, true)
            spawnedCoco = spawnedCoco + 1
            cocoPlants[obj] = true
            addPlantTarget(obj, 'coco')
        end
    end
end

-- ===== Dinaminis spawn pagal artumą =====
CreateThread(function()
    while true do
        Wait(1000)
        local p = GetEntityCoords(cache.ped)
        if #(p - Config.Weed.center) < Config.Weed.radius then
            spawnWeedPlants()
        end
        if #(p - Config.Coco.center) < Config.Coco.radius then
            spawnCocoPlants()
        end
    end
end)

-- ===== ox_target ZONOS: process & sell =====
CreateThread(function()
    -- Process Weed
    exports.ox_target:addSphereZone({
        coords = Config.Zones.processWeed.coords,
        radius = Config.Zones.processWeed.radius,
        debug = false,
        options = {
            {
                name = 'kdrugs_process_weed',
                icon = 'fa-solid fa-seedling',
                label = 'Džiovinti žolę',
                onSelect = function()
                    if not canTrigger() then return end
                    TaskStartScenarioInPlace(cache.ped, 'WORLD_HUMAN_BUM_BIN', 0, true)
                    local ok = progress('Džiovini žolę...', 6000)
                    ClearPedTasksImmediately(cache.ped)
                    if ok then TriggerServerEvent('k-drugs:process', 'weed') end
                end
            }
        }
    })

    -- Process Coco
    exports.ox_target:addSphereZone({
        coords = Config.Zones.processCoco.coords,
        radius = Config.Zones.processCoco.radius,
        debug = false,
        options = {
            {
                name = 'kdrugs_process_coco',
                icon = 'fa-solid fa-box',
                label = 'Pakuoti koką',
                onSelect = function()
                    if not canTrigger() then return end
                    TaskStartScenarioInPlace(cache.ped, 'WORLD_HUMAN_BUM_BIN', 0, true)
                    local ok = progress('Pakuoji koką...', 10000)
                    ClearPedTasksImmediately(cache.ped)
                    if ok then TriggerServerEvent('k-drugs:process', 'coco') end
                end
            }
        }
    })

    -- Sell
    exports.ox_target:addSphereZone({
        coords = Config.Zones.sell.coords,
        radius = Config.Zones.sell.radius,
        debug = false,
        options = {
            {
                name = 'kdrugs_sell',
                icon = 'fa-solid fa-dollar-sign',
                label = 'Parduoti narkotikus',
                onSelect = function()
                    if not canTrigger() then return end
                    TriggerServerEvent('k-drugs:sell')
                end
            }
        }
    })
end)
