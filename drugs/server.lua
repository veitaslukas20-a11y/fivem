-- k-drugs-ox / server.lua

local ESX = exports['es_extended']:getSharedObject()

-- ==== CONFIG ====
local Config = {
    CooldownMs = 1500,

    Weed = {
        yieldMin = 8, yieldMax = 10,
        process = { input = 'cannabis', inCount = 6, output = 'marijuana', outCount = 2 },
        pickZone = vector3(-282.3546, -1631.6033, 31.8488),
        pickRadius = 80.0
    },

    -- *** COCO LINIJĄ PAKEIČIAU: renki TABAKAS, procesas į COKE ***
    Coco = {
        yieldMin = 1, yieldMax = 4,
        process = { input = 'tabakas', inCount = 6, output = 'coke', outCount = 3 },
        pickZone = vector3(-2944.9941, 3444.0764, 10.0907),
        pickRadius = 80.0
    },

    Process = {
        weed = { coords = vector3(-935.5188, -1523.1268, 5.2437), radius = 6.0 },
        coco = { coords = vector3(2433.6123, 4969.0181, 42.3475), radius = 6.0 }
    },

    Sell = {
        coords = vector3(-11.1338, -1428.1118, 31.1015),
        radius = 6.0,
        prices = { marijuana = 3700, coke = 4100 }, -- *** 'coke' vietoje 'cocaine' ***
        blackMoney = true
    }
}
-- ==============

-- rate limit per žaidėją ir veiksmą
local lastAction = {}

local function now() return GetGameTimer() end

local function cooldownOk(src, key)
    local t = lastAction[src] and lastAction[src][key] or 0
    if (now() - t) < Config.CooldownMs then return false end
    lastAction[src] = lastAction[src] or {}
    lastAction[src][key] = now()
    return true
end

local function near(src, target, radius)
    local ped = GetPlayerPed(src)
    if not ped or ped == 0 then return false end
    local p = GetEntityCoords(ped)
    return #(p - target) <= (radius or 3.0)
end

local function addItemSafe(xPlayer, name, amount)
    if xPlayer.canCarryItem and not xPlayer.canCarryItem(name, amount) then
        return false, 'inventory_full'
    end
    xPlayer.addInventoryItem(name, amount)
    return true
end

local function removeItemSafe(xPlayer, name, amount)
    local itm = xPlayer.getInventoryItem(name)
    local have = (itm and itm.count) or 0
    if have < amount then
        return false, 'not_enough'
    end
    xPlayer.removeInventoryItem(name, amount)
    return true
end

AddEventHandler('playerDropped', function()
    lastAction[source] = nil
end)

-- ======= PICK =======
RegisterNetEvent('k-drugs:pick', function(kind)
    local src = source
    if type(kind) ~= 'string' then return end
    if not cooldownOk(src, 'pick_'..kind) then return end

    local xPlayer = ESX.GetPlayerFromId(src)
    if not xPlayer then return end

    if kind == 'weed' then
        if not near(src, Config.Weed.pickZone, Config.Weed.pickRadius) then return end
        local qty = math.random(Config.Weed.yieldMin, Config.Weed.yieldMax)
        local ok = addItemSafe(xPlayer, 'cannabis', qty)
        if ok then xPlayer.showNotification(('Gavai %dx kanapės.'):format(qty)) end

    elseif kind == 'coco' then
        if not near(src, Config.Coco.pickZone, Config.Coco.pickRadius) then return end
        local qty = math.random(Config.Coco.yieldMin, Config.Coco.yieldMax)
        -- *** čia vietoje 'coco' duodam 'tabakas' ***
        local ok = addItemSafe(xPlayer, 'tabakas', qty)
        if ok then xPlayer.showNotification(('Gavai %dx tabako.'):format(qty)) end
    end
end)

-- ======= PROCESS =======
RegisterNetEvent('k-drugs:process', function(kind)
    local src = source
    if type(kind) ~= 'string' then return end
    if not cooldownOk(src, 'process_'..kind) then return end

    local xPlayer = ESX.GetPlayerFromId(src)
    if not xPlayer then return end

    if kind == 'weed' then
        if not near(src, Config.Process.weed.coords, Config.Process.weed.radius) then return end
        local inp = Config.Weed.process
        local itm = xPlayer.getInventoryItem(inp.input)
        local have = (itm and itm.count) or 0
        if have < inp.inCount then xPlayer.showNotification('Neturi pakankamai žaliavos.') return end
        if xPlayer.canCarryItem and not xPlayer.canCarryItem(inp.output, inp.outCount) then
            xPlayer.showNotification('Inventorius pilnas.') return
        end
        removeItemSafe(xPlayer, inp.input, inp.inCount)
        addItemSafe(xPlayer, inp.output, inp.outCount)
        xPlayer.showNotification('Sėkmingai išdžiovinai žolę.')

    elseif kind == 'coco' then
        if not near(src, Config.Process.coco.coords, Config.Process.coco.radius) then return end
        local inp = Config.Coco.process -- input: tabakas, output: coke
        local itm = xPlayer.getInventoryItem(inp.input)
        local have = (itm and itm.count) or 0
        if have < inp.inCount then xPlayer.showNotification('Neturi pakankamai žaliavos.') return end
        if xPlayer.canCarryItem and not xPlayer.canCarryItem(inp.output, inp.outCount) then
            xPlayer.showNotification('Inventorius pilnas.') return
        end
        removeItemSafe(xPlayer, inp.input, inp.inCount)
        addItemSafe(xPlayer, inp.output, inp.outCount)
        xPlayer.showNotification('Supakavote coke.')
    end
end)

-- ======= SELL =======
RegisterNetEvent('k-drugs:sell', function()
    local src = source
    if not cooldownOk(src, 'sell') then return end

    local xPlayer = ESX.GetPlayerFromId(src)
    if not xPlayer then return end
    if not near(src, Config.Sell.coords, Config.Sell.radius) then return end

    local money = 0

    local marItem = xPlayer.getInventoryItem('marijuana')
    local mar = (marItem and marItem.count) or 0

    local cokeItem = xPlayer.getInventoryItem('coke') -- *** buvo 'cocaine' ***
    local coc = (cokeItem and cokeItem.count) or 0

    if mar > 0 then
        money = money + mar * (Config.Sell.prices.marijuana or 0)
        xPlayer.removeInventoryItem('marijuana', mar)
    end
    if coc > 0 then
        money = money + coc * (Config.Sell.prices.coke or 0)
        xPlayer.removeInventoryItem('coke', coc)
    end

    if money > 0 then
        if Config.Sell.blackMoney then
            xPlayer.addAccountMoney('black_money', money)
        else
            xPlayer.addMoney(money)
        end
        xPlayer.showNotification(('Pardavei už $%s.'):format(money))
    else
        xPlayer.showNotification('Neturi ką parduoti.')
    end
end)
