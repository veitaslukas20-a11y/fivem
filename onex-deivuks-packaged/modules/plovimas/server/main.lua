local Places = {
    -- Example wash spots
    [1] = {
        coords = vec3(1136.55, -989.12, 46.11),
        occupied = false,
        progress = 0,
        time = 0,
        money = 0,
    },
    [2] = {
        coords = vec3(-1193.9927, -1573.8057, 4.6168),
        occupied = false,
        progress = 0,
        time = 0,
        money = 0,
    }
}

local washDuration = 60 * 1000 -- 1 min per wash

-- send places to client
lib.callback.register('moneywash:getPlaces', function(source)
    local result = {}
    for k, v in pairs(Places) do
        result[#result+1] = {
            coords = v.coords,
        }
    end
    return result
end)

-- return wash info
lib.callback.register('moneywash:getinfo', function(source, id)
    local place = Places[id]
    if not place then return nil end
    return {
        occupied = place.occupied,
        progress = place.progress,
        time = place.time,
    }
end)

-- start washing
lib.callback.register('moneywash:addmoney', function(source, id, amount)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then return end
    local place = Places[id]
    if not place or place.occupied then return end

    amount = tonumber(amount)
    if not amount or amount <= 0 then return end

    -- take black money
    local money = xPlayer.getAccount('black_money').money
    if money < amount then
        TriggerClientEvent('ox_lib:notify', source, {type = 'error', description = 'Neturite tiek pinigų'})
        return
    end
    xPlayer.removeAccountMoney('black_money', amount)

    -- set occupied
    place.occupied = true
    place.money = amount
    place.progress = 0
    place.time = washDuration

    -- start process
    CreateThread(function()
        local step = 5
        local interval = washDuration / (100 / step)
        while place.progress < 100 do
            Wait(interval)
            place.progress = place.progress + step
            place.time = place.time - interval
        end

        place.occupied = false
    end)
end)

-- take washed money out
lib.callback.register('moneywash:getout', function(source, id)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then return end
    local place = Places[id]
    if not place then return end
    if place.occupied then
        TriggerClientEvent('ox_lib:notify', source, {type = 'error', description = 'Procesas dar vyksta!'})
        return
    end
    if place.money <= 0 then return end

    -- give clean money (90% of washed)
    local payout = math.floor(place.money * 0.9)
    xPlayer.addAccountMoney('money', payout)

    place.money = 0
    place.progress = 0
    place.time = 0

    TriggerClientEvent('ox_lib:notify', source, {type = 'success', description = ('Išplovėte %s$'):format(payout)})
end)

-- Simple moneywash script, that helps you get money from black.