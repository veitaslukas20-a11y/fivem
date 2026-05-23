local ESX = exports["es_extended"]:getSharedObject()

local CASE_CONFIGS = {
    case1_new = Config.Case1Prizes,
    case2_new = Config.Case2Prizes,
    case3_new = Config.Case3Prizes
}

lib.callback.register('onex-caseopening:checkKey', function(source, keyItem)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then return false end

    local item = xPlayer.getInventoryItem(keyItem)
    if item and item.count > 0 then
        xPlayer.removeInventoryItem(keyItem, 1)
        return true
    end

    return false
end)

lib.callback.register('onex-caseopening:requestSpin', function(source, caseId)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then return false end

    local prizes = CASE_CONFIGS[caseId]
    if not prizes then
        print("[ERROR] Invalid case ID: " .. tostring(caseId))
        return false
    end

    local totalWeight = 0
    for _, prize in ipairs(prizes) do
        totalWeight = totalWeight + prize.weight
    end

    local randomNum = math.random() * totalWeight
    local cumulative = 0
    local wonPrize

    for _, prize in ipairs(prizes) do
        cumulative = cumulative + prize.weight
        if randomNum <= cumulative then
            wonPrize = prize
            break
        end
    end

    if not wonPrize then
        return false
    end

    local prizeId = wonPrize.id

    CreateThread(function()
        Wait(6000) -- 6s
        local xp = ESX.GetPlayerFromId(source)
        if xp then
            xp.addInventoryItem(wonPrize.spawn, wonPrize.count)
        end
    end)

    return prizeId
end)