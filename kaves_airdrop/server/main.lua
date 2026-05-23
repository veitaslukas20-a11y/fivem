local ox_inventory = exports.ox_inventory
local activeDrops = {}

-- ===== Framework detect =====
local Framework = (Config and Config.Framework or "esx")

local ESX = nil
local QBCore = nil

if Framework == "esx" or Framework == "oldesx" then
    local ok, obj = pcall(function()
        return exports["es_extended"]:getSharedObject()
    end)
    if ok then ESX = obj end
elseif Framework == "qbcore" or Framework == "oldqb" then
    local ok, obj = pcall(function()
        return exports["qb-core"]:GetCoreObject()
    end)
    if ok then QBCore = obj end
end

local function getPlayer(source)
    if ESX then
        return ESX.GetPlayerFromId(source), "esx"
    elseif QBCore then
        return QBCore.Functions.GetPlayer(source), "qb"
    end
    return nil, nil
end

-- ===== Helper: safe random =====
local function rnd(min, max)
    return math.random(min, max)
end

-- ===== Helper: choose random from list =====
local function randomFrom(list)
    return list[rnd(1, #list)]
end

-- ===== Jobs allowed to matyti blip'ą, kai needsItem == false =====
-- Jei nori pakeisti – redaguok čia (arba persikelk į config, jei patogu).
local AllowedJobs = {
    police = false,
    gauja1 = true,
    gauja2 = true,
    gauja3 = true,
    gauja4 = true,
    gauja5 = true,
    gauja6 = true,
    gauja7 = true,
    gauja8 = true,
}

-- ===== Rewards =====
local function giveReward(src, entry)
    -- entry: { name, min, max }
    local count = rnd(entry.min, entry.max)
    local name = entry.name

    local xPlayer, fw = getPlayer(src)
    if not xPlayer then return end

    -- Pinigai per ESX/QB sąskaitas
    if name == "black_money" then
        if fw == "esx" then
            xPlayer.addAccountMoney("black_money", count)
        else
            xPlayer.Functions.AddItem("black_money", count) -- fallback
        end
        TriggerClientEvent("ox_lib:notify", src, {
            type = "success",
            title = "AirDrop",
            description = ("Gavote $%s nešvarių pinigų."):format(count),
            duration = 5000
        })
        return
    end

    -- Dalis serverių nori duoti ginklus kaip item'us (ox_inventory palaiko WEAPON_* kaip item)
    -- Jei tavo serveris nori per ESX addWeapon - gali perjungti čia:
    if name:find("^WEAPON_") then
        -- Kaip item (ox_inventory)
        ox_inventory:AddItem(src, name, 1)
        if count > 1 then
            -- jeigu cfg prašo >1, įdėsim tiek kartų
            for i=2, count do
                ox_inventory:AddItem(src, name, 1)
            end
        end
        TriggerClientEvent("ox_lib:notify", src, {
            type = "success",
            title = "AirDrop",
            description = ("Ginklas: %s x%s"):format(name, count),
            duration = 5000
        })
        return
    end

    -- Kita – tiesiog item'ai per ox_inventory
    local ok, reason = ox_inventory:AddItem(src, name, count)
    if not ok then
        -- Jei inventorius pilnas – galime numesti ant žemės arba duoti piniginį ekvivalentą
        -- Čia paprastai pranešam, kad nepavyko:
        TriggerClientEvent("ox_lib:notify", src, {
            type = "error",
            title = "AirDrop",
            description = ("Nepavyko pridėti %sx %s (%s)"):format(count, name, tostring(reason)),
            duration = 6000
        })
    else
        TriggerClientEvent("ox_lib:notify", src, {
            type = "success",
            title = "AirDrop",
            description = ("Gavote %sx %s"):format(count, name),
            duration = 5000
        })
    end
end

local function rewardPlayer(src, dropData)
    local pool = dropData.needsItem and Config.civilDropItems or Config.dropItems
    if not pool or #pool == 0 then return end

    local tier = randomFrom(pool)           -- parenkam atsitiktinį „tier“
    if not tier or #tier == 0 then return end

    -- Duok visus iš parinkto tier (kaip tavo config struktūra ir numano client)
    for _, entry in ipairs(tier) do
        giveReward(src, entry)
    end
end

-- ===== Drop lifecycle =====
local function makeJobsTable()
    -- Konvertuojam į { [job]=true } masyvą, kurį naudoja client allowed logika
    local t = {}
    for job, v in pairs(AllowedJobs) do
        if v then t[job] = true end
    end
    return t
end

local function newDropId()
    local id
    repeat
        id = tostring(math.random(100000, 999999))
    until not activeDrops[id]
    return id
end

local function broadcastCreateDrop(data)
    -- data: coords, time, needsItem, jobs, color, dropId
    TriggerClientEvent("kaves_airdrop:client:createDrop", -1, data)
end

local function createDrop(opts)
    -- opts: needsItem (bool), color (string|nil)
    local dropId = newDropId()
    local pos = randomFrom(Config.dropCoords).coords
    local timeMs = (Config.unlockCooldown or 7) * 60 * 1000

    activeDrops[dropId] = {
        coords = pos,
        needsItem = opts.needsItem or false,
        color = opts.color,
        unlocked = false,
        collected = false,
        expiresAt = GetGameTimer() + timeMs
    }

    local payload = {
        dropId = dropId,
        coords = pos,
        time = timeMs,
        needsItem = activeDrops[dropId].needsItem,
        color = opts.color,
        jobs = makeJobsTable()
    }

    -- Pasakome visiems
    broadcastCreateDrop(payload)

    -- Po „cooldown“ atrakinam
    SetTimeout(timeMs, function()
        local d = activeDrops[dropId]
        if d and not d.collected then
            d.unlocked = true
            TriggerClientEvent("kaves_airdrop:client:dropUnlocked", -1, dropId)
        end
    end)

    -- Grąžinam id, jei kas naudos
    return dropId
end

-- ===== Public commands (admin) =====
-- /airdrop -> policijos (be item), mėlynas
RegisterCommand("airdrop", function(src)
    -- Paprastai ribok komanda adminams; čia paprasta patikra
    if src ~= 0 then
        local xPlayer = ESX and ESX.GetPlayerFromId(src)
        if xPlayer and xPlayer.getGroup and xPlayer.getGroup() ~= "dev" and xPlayer.getGroup() ~= "owner" then
            TriggerClientEvent("ox_lib:notify", src, {
                type = "error",
                title = "AirDrop",
                description = "Neturite leidimo.",
                duration = 4000
            })
            return
        end
    end

    local id = createDrop({ needsItem = false, color = "blue" })
    print(("[AirDrop] Policijos drop sukurtas. ID: %s"):format(id))
end)

-- /airdropcivil -> civilinis (reikia item 'airdrop_locator'), raudonas
RegisterCommand("airdropcivil", function(src)
    if src ~= 0 then
        local xPlayer = ESX and ESX.GetPlayerFromId(src)
        if xPlayer and xPlayer.getGroup and xPlayer.getGroup() ~= "admin" and xPlayer.getGroup() ~= "superadmin" then
            TriggerClientEvent("ox_lib:notify", src, {
                type = "error",
                title = "AirDrop",
                description = "Neturite leidimo.",
                duration = 4000
            })
            return
        end
    end

    local id = createDrop({ needsItem = true, color = "red" })
    print(("[AirDrop] Civilinis drop sukurtas. ID: %s"):format(id))
end)

-- ===== Open crate (from client) =====
RegisterNetEvent("kaves_airdrop:server:openCrate", function(dropId)
    local src = source
    local d = activeDrops[dropId]
    if not d then
        TriggerClientEvent("ox_lib:notify", src, {
            type = "error",
            title = "AirDrop",
            description = Config.Locales and Config.Locales["drop-not-found"] or "Drop nerastas.",
            duration = 4000
        })
        return
    end

    if not d.unlocked then
        TriggerClientEvent("ox_lib:notify", src, {
            type = "warning",
            title = "AirDrop",
            description = Config.Locales and Config.Locales["time-is-not-up"] or "Reikia dar palaukti...",
            duration = 4000
        })
        return
    end

    if d.collected then
        TriggerClientEvent("ox_lib:notify", src, {
            type = "error",
            title = "AirDrop",
            description = "Ši dėžė jau paimta.",
            duration = 4000
        })
        return
    end

    -- Rewards
    rewardPlayer(src, d)

    -- Pažymim kaip „collected“ ir informuojam visus, kad išvalytų objektus/blipus
    d.collected = true
    TriggerClientEvent("kaves_airdrop:client:dropCollected", -1, dropId)

    -- Išvalom iš server atminties po trumpo laiko
    SetTimeout(1000, function()
        activeDrops[dropId] = nil
    end)
end)

-- ===== Optional: paleidimo metu (restart) – išvalom, jei kas buvo =====
AddEventHandler("onResourceStart", function(resName)
    if resName ~= GetCurrentResourceName() then return end
    activeDrops = {}
    print("[AirDrop] server.lua paleistas.")
end)
