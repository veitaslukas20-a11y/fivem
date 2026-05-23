
local ESX = exports['es_extended']:getSharedObject()

-- Utility: check for lighter
local function hasLighter(xPlayer)
    local item = xPlayer.getInventoryItem(Config.LighterItem)
    return (item and item.count or 0) > 0
end

-- ############ FX RELAY EVENTS ############
-- Cigarette
RegisterNetEvent('devcore_smoke:eff_lighter', function(lightNetId)
    TriggerClientEvent('devcore_smoke:c_eff_lighter', -1, lightNetId)
end)

RegisterNetEvent('devcore_smoke:eff_cigarette', function(cigNetId)
    TriggerClientEvent('devcore_smoke:c_eff_cigarette', -1, cigNetId)
end)

RegisterNetEvent('devcore_smoke:eff_smokes', function(pedNetId)
    TriggerClientEvent('devcore_smoke:c_eff_smokes', -1, pedNetId)
end)

-- Cigar
RegisterNetEvent('devcore_smoke:eff_lighter_cigar', function(lightNetId)
    TriggerClientEvent('devcore_smoke:c_eff_lighter_cigar', -1, lightNetId)
end)

RegisterNetEvent('devcore_smoke:eff_cigar', function(cigarNetId)
    TriggerClientEvent('devcore_smoke:c_eff_cigar', -1, cigarNetId)
end)

RegisterNetEvent('devcore_smoke:eff_smokes_cigar', function(pedNetId)
    TriggerClientEvent('devcore_smoke:c_eff_smokes_cigar', -1, pedNetId)
end)

-- Joint
RegisterNetEvent('devcore_smoke:eff_lighter_joint', function(lightNetId)
    TriggerClientEvent('devcore_smoke:c_eff_lighter_joint', -1, lightNetId)
end)

RegisterNetEvent('devcore_smoke:eff_joint', function(jointNetId)
    TriggerClientEvent('devcore_smoke:c_eff_joint', -1, jointNetId)
end)

RegisterNetEvent('devcore_smoke:eff_smokes_joint', function(pedNetId)
    TriggerClientEvent('devcore_smoke:c_eff_smokes_joint', -1, pedNetId)
end)

-- ############ USABLE ITEMS ############
-- Helper to consume one item (if desired)
local function tryRemove(xPlayer, itemName, amount)
    amount = amount or 1
    if itemName and amount > 0 then
        xPlayer.removeInventoryItem(itemName, amount)
    end
end

-- Cigarettes (single)
for _, itemName in ipairs(Config.ItemCigarette or {}) do
    ESX.RegisterUsableItem(itemName, function(source)
        local xPlayer = ESX.GetPlayerFromId(source)
        if not xPlayer then return end
        if not hasLighter(xPlayer) then
            TriggerClientEvent('esx:showNotification', source, 'You need a lighter.')
            return
        end
        -- consume one cigarette (comment out the next line if you do NOT want to remove it)
        tryRemove(xPlayer, itemName, 1)
        TriggerClientEvent('devcore_smoke:CigarettesLightingAnim', source)
    end)
end

-- Cigarette pack -> gives multiple cigarettes
for _, pack in ipairs(Config.CigarettePack or {}) do
    local packItem = pack.PackItem
    local outItem  = pack.CigaretteItem
    local amount   = tonumber(pack.Amount) or 20
    if packItem and outItem then
        ESX.RegisterUsableItem(packItem, function(source)
            local xPlayer = ESX.GetPlayerFromId(source)
            if not xPlayer then return end
            -- remove pack
            tryRemove(xPlayer, packItem, 1)
            -- give cigarettes
            xPlayer.addInventoryItem(outItem, amount)
            TriggerClientEvent('devcore_smoke:CigarettesPackAnim', source)
        end)
    end
end

-- Cigars
for _, itemName in ipairs(Config.ItemCigar or {}) do
    ESX.RegisterUsableItem(itemName, function(source)
        local xPlayer = ESX.GetPlayerFromId(source)
        if not xPlayer then return end
        if not hasLighter(xPlayer) then
            TriggerClientEvent('esx:showNotification', source, 'You need a lighter.')
            return
        end
        tryRemove(xPlayer, itemName, 1)
        TriggerClientEvent('devcore_smoke:CigarLightingAnim', source)
    end)
end

-- Joints
for _, itemName in ipairs(Config.ItemJoint or {}) do
    ESX.RegisterUsableItem(itemName, function(source)
        local xPlayer = ESX.GetPlayerFromId(source)
        if not xPlayer then return end
        if not hasLighter(xPlayer) then
            TriggerClientEvent('esx:showNotification', source, 'You need a lighter.')
            return
        end
        tryRemove(xPlayer, itemName, 1)
        TriggerClientEvent('devcore_smoke:JointLightingAnim', source)
    end)
end

-- Optional: crafting joints from weed + rolling paper (simple example)
-- Requires one rolling paper + one weed bag -> gives one random joint from Config.ItemJoint
RegisterNetEvent('devcore_smoke:roll_joint', function(weedItem)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    if not xPlayer then return end

    local papers = xPlayer.getInventoryItem(Config.Rollingpaper)
    local weed   = xPlayer.getInventoryItem(weedItem)

    if (papers and papers.count or 0) <= 0 then
        TriggerClientEvent('esx:showNotification', src, 'You need rolling paper.')
        return
    end
    if (weed and weed.count or 0) <= 0 then
        TriggerClientEvent('esx:showNotification', src, 'You need weed.')
        return
    end

    -- consume inputs
    tryRemove(xPlayer, Config.Rollingpaper, 1)
    tryRemove(xPlayer, weedItem, 1)

    -- choose joint output
    local jointList = Config.ItemJoint or {}
    local out = jointList[math.random(1, #jointList)]
    if out then xPlayer.addInventoryItem(out, 1) end
    TriggerClientEvent('esx:showNotification', src, 'You rolled a joint.')
end)

-- ############ BASIC ANTI-SPAM (cooldown) ############
local lastUse = {}
local cooldownMs = 1000

AddEventHandler('esx:playerDropped', function(playerId)
    lastUse[playerId] = nil
end)

-- Wrap FX relay with simple cooldown to avoid spam/network abuse
local function wrapCooldown(eventName)
    local orig = handlers and handlers[eventName]
    RegisterNetEvent(eventName)
    AddEventHandler(eventName, function(...)
        local src = source
        local now = os.time() * 1000
        if (lastUse[src] or 0) + cooldownMs > now then return end
        lastUse[src] = now
        -- immediately pass through to corresponding client event
        local args = {...}
        local map = {
            ['devcore_smoke:eff_lighter'] = 'devcore_smoke:c_eff_lighter',
            ['devcore_smoke:eff_cigarette'] = 'devcore_smoke:c_eff_cigarette',
            ['devcore_smoke:eff_smokes'] = 'devcore_smoke:c_eff_smokes',
            ['devcore_smoke:eff_lighter_cigar'] = 'devcore_smoke:c_eff_lighter_cigar',
            ['devcore_smoke:eff_cigar'] = 'devcore_smoke:c_eff_cigar',
            ['devcore_smoke:eff_smokes_cigar'] = 'devcore_smoke:c_eff_smokes_cigar',
            ['devcore_smoke:eff_lighter_joint'] = 'devcore_smoke:c_eff_lighter_joint',
            ['devcore_smoke:eff_joint'] = 'devcore_smoke:c_eff_joint',
            ['devcore_smoke:eff_smokes_joint'] = 'devcore_smoke:c_eff_smokes_joint'
        }
        local clientEvent = map[eventName]
        if clientEvent then
            TriggerClientEvent(clientEvent, -1, table.unpack(args))
        end
    end)
end

-- If you prefer to enable the cooldown wrapper, comment out the earlier RegisterNetEvent blocks and enable this list:
-- for _, ev in ipairs({
--     'devcore_smoke:eff_lighter',
--     'devcore_smoke:eff_cigarette',
--     'devcore_smoke:eff_smokes',
--     'devcore_smoke:eff_lighter_cigar',
--     'devcore_smoke:eff_cigar',
--     'devcore_smoke:eff_smokes_cigar',
--     'devcore_smoke:eff_lighter_joint',
--     'devcore_smoke:eff_joint',
--     'devcore_smoke:eff_smokes_joint',
-- }) do
--     wrapCooldown(ev)
-- end

-- ############ VERSION PRINT ############
CreateThread(function()
    print('^2[devcore_smoke]^7 server.lua loaded. Items/FX registered.')
end)
