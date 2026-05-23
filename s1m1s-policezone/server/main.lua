local ESX = exports['es_extended']:getSharedObject()

local Members = {}
local TimeLeft = 0        -- ms iki atrakina prieigą (Locked fazė)
local DeadlineLeft = 0    -- ms iki utilizacijos pabaigos po atrakininimo
local TimerThread = nil

local function isHighRankCop(src)
    local xPlayer = ESX.GetPlayerFromId(src)
    if not xPlayer or not xPlayer.job then return false end
    local grade = xPlayer.job.grade or 0
    return xPlayer.job.name == 'police' and grade >= 8
end

local function stopTimers()
    TimerThread = nil
    TimeLeft = 0
    DeadlineLeft = 0
end

local function clearStash()
    local ok, err = pcall(function()
        exports.ox_inventory:ClearInventory('policeutilization')
    end)
    if not ok then
        print(('[policezone] ClearInventory nepavyko: %s'):format(err or ''))
    end
end

-- Pabaigti utilizaciją ir pranešti klientams
local function endUtilization(broadcast)
    stopTimers()

    Config.Zone.started = nil
    Config.Zone.locked = nil
    Config.Zone.enabled = nil

    if broadcast ~= false then
        TriggerClientEvent('policezone:endUtilization', -1)
    end
end

-- Paleisti laikmačius (užrakinimo ir termino)
local function startTimers()
    -- nustatom likučius iš config
    TimeLeft = Config.Zone.lock_time_ms or 0
    DeadlineLeft = Config.Zone.deadline_ms or 0

    if TimerThread then return end

    TimerThread = CreateThread(function()
        -- 1 FAZĖ: zona užrakinta (Locked = true) – skaičiuojame TimeLeft
        while Config.Zone.started and Config.Zone.locked and TimeLeft > 0 do
            Wait(1000)
            TimeLeft = math.max(TimeLeft - 1000, 0)
        end

        -- Atrakinti prieigą, jei dar vis vyksta procesas
        if Config.Zone.started and Config.Zone.locked then
            Config.Zone.locked = nil
            -- Pranešti visiems klientams, kad galima prieiga
            TriggerClientEvent('policezone:enableAccess', -1)
        end

        -- 2 FAZĖ: zona atrakinta – skaičiuojame DeadlineLeft
        while Config.Zone.started and not Config.Zone.locked and DeadlineLeft > 0 do
            Wait(1000)
            DeadlineLeft = math.max(DeadlineLeft - 1000, 0)
        end

        -- Pabaiga
        if Config.Zone.started then
            endUtilization(true)
        end

        TimerThread = nil
    end)
end

-- ox_lib callback'ai
lib.callback.register('policezone:getConfig', function(source)
    return Config
end)

lib.callback.register('policezone:getInfo', function(source)
    return TimeLeft, DeadlineLeft, Config.Zone.locked and true or false
end)

-- Nariai (nebūtina, bet laikome kam įdomu)
RegisterNetEvent('policezone:addMember', function()
    local src = source
    Members[src] = true
end)

RegisterNetEvent('policezone:removeMember', function()
    local src = source
    Members[src] = nil
end)

-- Įjungti zoną (leidžia krauti daiktus į saugyklą)
RegisterNetEvent('policezone:enableZone', function()
    local src = source
    if not isHighRankCop(src) then
        return
    end
    if Config.Zone.started then return end
    Config.Zone.enabled = true
    TriggerClientEvent('policezone:enableZone', -1)
end)

-- Išjungti zoną (atšaukia krovimą, turi būti tuščia saugykla)
RegisterNetEvent('policezone:disableZone', function()
    local src = source
    if not isHighRankCop(src) then
        return
    end
    if Config.Zone.started then return end
    Config.Zone.enabled = nil
    TriggerClientEvent('policezone:disableZone', -1)
end)

-- Pradėti utilizaciją
RegisterNetEvent('policezone:startUtilization', function()
    local src = source
    if not isHighRankCop(src) then
        return
    end
    if not Config.Zone.enabled or Config.Zone.started then return end

    -- Užrakinti zoną pradžioje ir transliuoti
    Config.Zone.started = true
    Config.Zone.locked = true

    TriggerClientEvent('policezone:startUtilization', -1)

    -- Paleisti laikmačius
    startTimers()
end)

-- Administracinis eventas: rankiniu būdu nutraukti (jei reikėtų)
RegisterNetEvent('policezone:endUtilization', function()
    local src = source
    if not isHighRankCop(src) then
        return
    end
    endUtilization(true)
end)

-- Resource lifecycle


-- Vartotojo uziminejimo atšaukimas (mirtis / paliko zoną)
RegisterNetEvent('policezone:cancelTaking', function(reason)
    local src = source
    -- Galime pridėti validaciją, bet dabar tiesiog ištransliuojam klientams sustabdyti
    TriggerClientEvent('policezone:cancelTaking', -1)
end)
AddEventHandler('onResourceStart', function(resourceName)
    if (GetCurrentResourceName() ~= resourceName) then return end

    -- Užregistruoti saugyklą ox_inventory (jei dar neregistruota)
    local ok, err = pcall(function()
        local slots = (Config.Inventory and Config.Inventory.slots) or 50
        local weight = (Config.Inventory and Config.Inventory.weight) or 100000
        -- name, label, slots, weight, owner, groups, coords
        exports.ox_inventory:RegisterStash('policeutilization', 'Policijos utilizacijos saugykla', slots, weight, false)
    end)

    if not ok then
        print(('[policezone] Nepavyko užregistruoti saugyklos: %s'):format(err or 'nežinoma klaida'))
    end
end)

AddEventHandler('onResourceStop', function(resourceName)
    if (GetCurrentResourceName() ~= resourceName) then return end
    stopTimers()
end)
