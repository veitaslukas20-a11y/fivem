local Job = {}
local TextPrompt = false

-- ===== Helpers: job =====
function GetJob()
    if Job.name then
        for i = 1, #Config.Jobs do
            if Job.name == Config.Jobs[i] then
                return true
            end
        end
    end
    return false
end

exports('GetJob', GetJob)

-- ===== ESX events =====
RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(xPlayer)
    if not xPlayer or not xPlayer.job then return end
    Job.grade = xPlayer.job.grade_name
    Job.name  = xPlayer.job.name

    if GetJob() then
        InitZones()
        InitTargets()
    end
end)

RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job)
    if not job then return end
    Job.grade = job.grade_name
    Job.name  = job.name

    if GetJob() then
        RemoveZones()
        InitZones()
        InitTargets()
    else
        RemoveActions()
        RemoveZones()
    end
end)

-- ===== Uniforms =====
function SetUniform(uniform)
    local status = lib.progressCircle({
        label = 'Apsirengiate uniformą...',
        duration = 2000,
        position = 'bottom',
        useWhileDead = false,
        canCancel = true,
        anim = { dict = 'clothingtie', clip = 'try_tie_positive_a' },
    })

    if not status then return end

    if uniform ~= 'citizen_wear' then
        TriggerEvent('skinchanger:getSkin', function(skin)
            local uniformObject
            if skin.sex == 0 then
                uniformObject = Config.Uniforms[uniform].male
                if Job.name == 'gauja5' then
                    uniformObject.bproof_1, uniformObject.bproof_2 = 74, 0
                elseif Job.name == 'gauja3' then
                    uniformObject.bproof_1, uniformObject.bproof_2 = 140, 1
                elseif Job.name == 'gauja6' then
                    uniformObject.bproof_1, uniformObject.bproof_2 = 75, 0
                elseif Job.name == 'gauja2' then
                    uniformObject.bproof_1, uniformObject.bproof_2 = 74, 2
                elseif Job.name == 'gauja1' then
                    uniformObject.bproof_1, uniformObject.bproof_2 = 131, 1
                elseif Job.name == 'cartel' then
                    uniformObject.bproof_1, uniformObject.bproof_2 = 143, 0
                elseif Job.name == 'yakuza' then
                    uniformObject.bproof_1, uniformObject.bproof_2 = 72, 1
                end
            else
                uniformObject = Config.Uniforms[uniform].female
            end

            if uniformObject then
                TriggerEvent('skinchanger:loadClothes', skin, uniformObject)
            end
        end)
    else
        ESX.TriggerServerCallback('esx_skin:getPlayerSkin', function(skin)
            TriggerEvent('skinchanger:loadSkin', skin)
        end)
    end
end

function OpenCloakroomMenu()
    lib.registerContext({
        id = 'gangs:clothing',
        title = 'Persirengimas',
        options = {
            { title = 'Civilio rūbai', description = 'Užsidėkite savo drabužius.', icon = 'fas fa-lg fa-tshirt',
              onSelect = function() SetUniform('citizen_wear') end },
            { title = 'Neperšaunami šarvai', description = 'Užsidėkite neperšaunamą liemenę.', icon = 'fas fa-lg fa-shield',
              onSelect = function() SetUniform('bullet_wear') end },
            { title = 'Šarvų meniu', description = 'Atidarykite šarvų meniu.', icon = 'fas fa-lg fa-shield',
              onSelect = function() exports['s1m1s-gangcredits']:openArmour() end },
        }
    })
    lib.showContext('gangs:clothing')
end

-- ===== Points / Zones =====
local Points = {}
local InsidePoint, CurrentPoint, PointInfo = false, nil, nil
local PointCoords = nil

function InitZones()
    local Station = Config.Stations[Job.name]
    if not Station then return end

    -- Clothing
    Points['clothing'] = {}
    for i=1, #Station.Cloakrooms do
        Points['clothing'][i] = lib.points.new({ coords = Station.Cloakrooms[i], distance = 3.0 })
        local point = Points['clothing'][i]

        function point:onExit()
            InsidePoint, CurrentPoint, PointCoords = false, nil, nil
        end

        function point:nearby()
            if self.isClosest and self.currentDistance < 1.0 then
                if not InsidePoint or CurrentPoint ~= 'clothing' then
                    InsidePoint, CurrentPoint, PointCoords = true, 'clothing', Station.Cloakrooms[i]
                end
            end
            DrawMarker(
                Config.MarkerType.Cloakrooms, self.coords,
                0.0,0.0,0.0, 0,0.0,0.0, 0.5,0.5,0.5,
                Config.MarkerColor.r, Config.MarkerColor.g, Config.MarkerColor.b, 100,
                false, true, 2, true, false, false, false
            )
        end
    end

    -- Stash
    Points['stash'] = {}
    for k, v in pairs(Station.Stash) do
        if k == 'boss' and Job.grade ~= 'boss' then goto continue end

        Points['stash'][k] = lib.points.new({ coords = v, distance = 3.0, name = 'stash_'..k })
        local point = Points['stash'][k]

        function point:onExit()
            InsidePoint, CurrentPoint, PointCoords = false, nil, nil
            if TextPrompt then TextPrompt = false lib.hideTextUI() end
        end

        function point:nearby()
            if self.isClosest and self.currentDistance < 1.0 then
                if not InsidePoint or CurrentPoint ~= self.name then
                    InsidePoint, CurrentPoint, PointCoords = true, self.name, v
                end
                if not TextPrompt then
                    TextPrompt = true
                    lib.showTextUI('[E] - Atidarykite saugyklą', { icon = 'fa-warehouse' })
                end
            elseif TextPrompt then
                TextPrompt = false
                lib.hideTextUI()
            end

            DrawMarker(2, v.x, v.y, v.z, 0.0,0.0,0.0, 0.0,0.0,0.0, 0.3,0.2,0.15, 30,30,150,222, false,false,0, true,false,false,false)
        end

        ::continue::
    end

    -- Boss actions
    if Job.grade == 'boss' then
        Points['bossactions'] = {}
        for i=1, #Station.BossActions do
            Points['bossactions'][i] = lib.points.new({ coords = Station.BossActions[i], distance = 3.0 })
            local point = Points['bossactions'][i]

            function point:onExit()
                InsidePoint, CurrentPoint, PointCoords = false, nil, nil
            end

            function point:nearby()
                if self.isClosest and self.currentDistance < 1.0 then
                    if not InsidePoint or CurrentPoint ~= 'bossactions' then
                        InsidePoint, CurrentPoint, PointCoords = true, 'bossactions', Station.BossActions[i]
                    end
                end
                DrawMarker(
                    Config.MarkerType.BossActions, self.coords,
                    0.0,0.0,0.0, 0.0,0.0,0.0, 1.0,1.0,1.0,
                    Config.MarkerColor.r, Config.MarkerColor.g, Config.MarkerColor.b, 100,
                    false, true, 2, true, false, false, false
                )
            end
        end
    end
end

function RemoveZones()
    for k,_ in pairs(Points) do
        for j,_ in pairs(Points[k]) do
            local point = Points[k][j]
            if point and point.remove then point:remove() end
        end
    end
    Points = {}
    InsidePoint, CurrentPoint, PointCoords = false, nil, nil
    if TextPrompt then TextPrompt = false lib.hideTextUI() end
end

-- ===== Keybind =====
lib.addKeybind({
    name = 'gangmenu',
    description = 'Gaujos meniu',
    defaultKey = 'E',
    onPressed = function(self)
        if not InsidePoint or not CurrentPoint or not PointCoords then return end
        if #(GetEntityCoords(cache.ped) - PointCoords) > 1.0 then return end

        if CurrentPoint == 'clothing' then
            OpenCloakroomMenu()
        elseif CurrentPoint == 'bossactions' then
            exports['s1m1s-bossmenu']:openMenu(true, true)
        elseif CurrentPoint == 'stash_boss' then
            exports.ox_inventory:openInventory('stash', Job.name..'_boss')
        elseif CurrentPoint == 'stash_regular' then
            exports.ox_inventory:openInventory('stash', Job.name)
        end
    end,
})

-- ===== Player target helpers (SEARCH FIX) =====
local function isDead(ped)
    if not ped or ped == 0 then return false end
    return IsPedFatallyInjured(ped)
        or IsPedDeadOrDying(ped, true)
        or (GetEntityHealth(ped) <= 0)
end

local function isHandsUp(ped)
    -- dažniausi „hands up“ animai; papildykite savo, jei naudojate kitus emote’us
    return IsEntityPlayingAnim(ped, 'missminuteman_1ig_2', 'handsup_enter', 3)
        or IsEntityPlayingAnim(ped, 'random@mugging3', 'handsup_standing_base', 3)
        or IsEntityPlayingAnim(ped, 'missheist_agency2aig_2', 'hands_up_loop', 3)
        or IsEntityPlayingAnim(ped, 'anim@mp_player_intupperhands_up', 'idle_a', 3)
        -- arba state-bag pavyzdys (jei turite):
        or (Entity(ped).state and Entity(ped).state.handsup == true)
end

local function withinDistance(a, b, dist)
    return #(GetEntityCoords(a) - GetEntityCoords(b)) <= (dist or 1.5)
end

local function canSearchPed(target)
    if not target or target == cache.ped then return false end
    if GetEntityType(target) ~= 1 or not IsPedAPlayer(target) then return false end
    if not withinDistance(cache.ped, target, 1.5) then return false end
    if IsEntityAttachedToEntity(target, cache.ped) then return false end
    -- LEIDŽIAM jeigu miręs ARBA iškeltos rankos
    return isDead(target) or isHandsUp(target)
end

-- paprastas „ar galima zipinti“ (jei turite savo – galite pakeisti)
local function canZippPed(target)
    if not target or target == cache.ped then return false end
    if GetEntityType(target) ~= 1 or not IsPedAPlayer(target) then return false end
    if not withinDistance(cache.ped, target, 1.5) then return false end
    if IsEntityAttachedToEntity(target, cache.ped) then return false end
    if isDead(target) then return false end
    return true
end

-- ===== Targets =====
local Targets = false

function InitTargets()
    if Targets then return end
    Targets = true

    exports.ox_target:addGlobalPlayer({
        {
            name = 'gang:cuff',
            icon = "fa-solid fa-handcuffs",
            label = "Surišti asmenį",
            distance = 1.5,
            items = 'zipties',
            canInteract = function(entity)
                return canZippPed(entity) and not IsPedCuffed(entity) and not IsEntityAttachedToEntity(entity, cache.ped)
            end,
            onSelect = function(data)
                local ped = data and data.entity
                if not ped or GetEntityType(ped) ~= 1 or not IsPedAPlayer(ped) then return end
                if canZippPed(ped) and withinDistance(cache.ped, ped, 1.5) and not IsPedCuffed(ped) and not IsEntityAttachedToEntity(ped, cache.ped) then
                    zippPlayer(ped)
                end
            end
        },
        {
            name = 'gang:uncuff',
            icon = "fa-solid fa-handcuffs",
            label = "Atrišti asmenį",
            items = {
                WEAPON_SWITCHBLADE = 1,
                WEAPON_KNIFE = 1,
                WEAPON_MACHETE = 1,
                zirkles = 1,
            },
            anyItem = true,
            distance = 1.5,
            canInteract = function(entity)
                return IsPedCuffed(entity) and not IsEntityAttachedToEntity(entity, cache.ped)
            end,
            onSelect = function(data)
                if data and data.entity then zippPlayer(data.entity) end
            end
        },
        {
            name = 'gang:escort',
            icon = "fas fa-hands-bound",
            label = "Vestis su savimi",
            distance = 1.5,
            canInteract = function(entity)
                return IsPedCuffed(entity) and not IsEntityAttachedToEntity(entity, cache.ped)
            end,
            onSelect = function(data)
                if data and data.entity then escortPlayer(data.entity) end
            end
        },
    })

    -- ==== VEHICLE TARGETS (fixed logic & names) ====
    exports.ox_target:addGlobalVehicle({
        {
            name = 'gang:incar_left',
            icon = "fa-solid fa-car",
            label = "Pasodinti į kairę galinę",
            distance = 2.5,
            bones = { 'door_dside_r', 'seat_dside_r' },
            canInteract = function(entity)
                return escorting ~= nil
                    and not IsPedInAnyVehicle(cache.ped, false)
                    and IsVehicleSeatFree(entity, 2) -- galinė kairė
            end,
            onSelect = function(data)
                SetIntoVehicle(data.entity, 2)
            end
        },
        {
            name = 'gang:incar_right',
            icon = "fa-solid fa-car",
            label = "Pasodinti į dešinę galinę",
            distance = 2.5,
            bones = { 'door_pside_r', 'seat_pside_r' },
            canInteract = function(entity)
                return escorting ~= nil
                    and not IsPedInAnyVehicle(cache.ped, false)
                    and IsVehicleSeatFree(entity, 3) -- galinė dešinė
            end,
            onSelect = function(data)
                SetIntoVehicle(data.entity, 3)
            end
        },
        {
            name = 'gang:outcar_right',
            icon = "fa-solid fa-car",
            label = "Išlaipinti iš automobilio",
            distance = 2.5,
            bones = { 'door_dside_r', 'door_pside_r', 'seat_dside_r', 'seat_pside_r' },
            canInteract = function(entity)
                return escorting ~= nil
            end,
            onSelect = function(data)
                SetOutVehicle(data.entity)
            end
        }
    })
end

function RemoveActions()
    if not Targets then return end
    Targets = false
    exports.ox_target:removeGlobalPlayer({ "gang:search", "gang:cuff", "gang:uncuff", "gang:escort" })
    exports.ox_target:removeGlobalVehicle({ "gang:incar_left", "gang:incar_right", "gang:outcar_right" })
end
