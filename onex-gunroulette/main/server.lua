ESX = exports['es_extended']:getSharedObject()

-- Table state storage
local activeTables = {}
local pendingInvites = {}

-- Config
local MAX_BULLETS = 3

-- Helper
local function getPlayerById(serverId)
    return ESX.GetPlayerFromId(serverId)
end

-- Player requests to play
RegisterNetEvent('gunroulette:requestPlay', function(tableId, targetServerId, amount)
    local src = source
    local sourcePlayer = getPlayerById(src)
    local targetPlayer = getPlayerById(targetServerId)

    if not sourcePlayer or not targetPlayer then
        return
    end

    amount = tonumber(amount)
    if not amount or amount <= 0 then
        TriggerClientEvent('1x-hud:sendNotification', src, {
            type = 'ERROR',
            title = 'Ginklų ruletė',
            message = 'Neteisinga suma.',
            duration = 5000
        })
        return
    end

    -- Check if both players have enough money
    if sourcePlayer.getMoney() < amount then
        TriggerClientEvent('1x-hud:sendNotification', src, {
            type = 'ERROR',
            title = 'Ginklų ruletė',
            message = 'Neturi pakankamai pinigų.',
            duration = 5000
        })
        return
    end

    if targetPlayer.getMoney() < amount then
        TriggerClientEvent('1x-hud:sendNotification', src, {
            type = 'ERROR',
            title = 'Ginklų ruletė',
            message = 'Kitas žaidėjas neturi pakankamai pinigų.',
            duration = 5000
        })
        return
    end

    -- Save pending invitation
    pendingInvites[tableId] = {
        from = src,
        to = targetServerId,
        amount = amount
    }

    -- Send invitation to target player
    TriggerClientEvent('gunroulette:sendInvitation', targetServerId, tableId, amount)
end)

-- Target accepts
RegisterNetEvent('gunroulette:startGame', function(tableId)
    local invite = pendingInvites[tableId]
    if not invite then return end

    local p1 = getPlayerById(invite.from)
    local p2 = getPlayerById(invite.to)
    local amount = invite.amount

    if not p1 or not p2 then
        pendingInvites[tableId] = nil
        return
    end

    -- Recheck money before starting
    if p1.getMoney() < amount or p2.getMoney() < amount then
        TriggerClientEvent('1x-hud:sendNotification', invite.from, {
            type = 'ERROR',
            title = 'Ginklų ruletė',
            message = 'Vienas žaidėjas neturi pakankamai pinigų.',
            duration = 5000
        })
        pendingInvites[tableId] = nil
        return
    end

    -- Take money from both players
    p1.removeMoney(amount)
    p2.removeMoney(amount)

    -- Mark table as active
    activeTables[tableId] = {
        player1 = invite.from,
        player2 = invite.to,
        amount = amount,
        currentBullet = 1,
        isWinner = nil
    }

    -- Notify both clients to start the game
    TriggerClientEvent('gunroulette:startGame', invite.from, 'front', tableId, false)
    TriggerClientEvent('gunroulette:startGame', invite.to, 'back', tableId, true)

    -- Remove pending invite
    pendingInvites[tableId] = nil
end)

-- Target rejects
RegisterNetEvent('gunroulette:rejectInvitation', function(tableId)
    local invite = pendingInvites[tableId]
    if not invite then return end

    TriggerClientEvent('1x-hud:sendNotification', invite.from, {
        type = 'ERROR',
        title = 'Ginklų ruletė',
        message = 'Žaidėjas atmetė kvietimą.',
        duration = 5000
    })

    pendingInvites[tableId] = nil
end)

-- End game
RegisterNetEvent('gunroulette:endGame', function(tableId)
    local tableData = activeTables[tableId]
    if not tableData then return end

    local winnerId = tableData.isWinner or tableData.player2
    local amount = tableData.amount

    local winner = getPlayerById(winnerId)
    if winner then
        local prize = amount * 2
        winner.addMoney(prize)

        TriggerClientEvent('gunroulette:wonGame', winnerId)
        TriggerClientEvent('1x-hud:sendNotification', winnerId, {
            type = 'SUCCESS',
            title = 'Ginklų ruletė',
            message = ('Laimėjai $%s!'):format(prize),
            duration = 6000
        })
    end

    activeTables[tableId] = nil
end)

-- Server callback: get active tables
lib.callback.register('gunroulette:getActiveTables', function(source)
    return activeTables
end)
