ESX = exports["es_extended"]:getSharedObject()
local CrutchUsers = {}

lib.callback.register('d-ramentai:save', function(source, crutchTime)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then 
        print("[ERROR] Player not found: " .. tostring(source))
        return false 
    end

    local identifier = xPlayer.getIdentifier()
    print("[DEBUG] Saving crutch time for player: " .. identifier .. " | Time: " .. tostring(crutchTime))

    CrutchUsers[identifier] = crutchTime

    MySQL.Async.execute(
        'UPDATE crutch_users SET crutch_time = @crutch_time, last_used = @last_used WHERE identifier = @identifier',
        {
            ['@identifier'] = identifier,
            ['@crutch_time'] = crutchTime,
            ['@last_used'] = os.time()
        }
    )

    return true
end)

lib.callback.register('d-ramentai:removeFromDB', function(source)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then 
        print("[ERROR] Player not found for removal: " .. tostring(source))
        return false 
    end

    local identifier = xPlayer.getIdentifier()
    print("[DEBUG] Removing player from crutch database: " .. identifier)

    -- ✅ Remove player from database when crutch time expires
    MySQL.Async.execute('DELETE FROM crutch_users WHERE identifier = @identifier', {
        ['@identifier'] = identifier
    })

    -- ✅ Remove from cached list
    CrutchUsers[identifier] = nil

    return true
end)

lib.callback.register('d-ramentai:checkcrutch', function(source)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then 
        print("[ERROR] Player not found for checkcrutch:", source)
        return 0 
    end

    local identifier = xPlayer.getIdentifier()
    print("[DEBUG] Checking crutch time for:", identifier)

    if CrutchUsers[identifier] and type(CrutchUsers[identifier]) == "table" and CrutchUsers[identifier].time then
        print("[DEBUG] Loaded crutch time from memory:", CrutchUsers[identifier].time)
        return CrutchUsers[identifier].time
    end

    local result = MySQL.Sync.fetchScalar('SELECT crutch_time FROM crutch_users WHERE identifier = @identifier', {
        ['@identifier'] = identifier
    })

    if result then
        print("[DEBUG] Loaded crutch time from database:", result)
        CrutchUsers[identifier] = { time = result }
        return result
    else
        print("[DEBUG] No crutch time found in database.")
        return 0
    end
end)



RegisterNetEvent('d-ramentai:applyCrutch')
AddEventHandler('d-ramentai:applyCrutch', function(targetPlayer, crutchTime)
    local xTarget = ESX.GetPlayerFromId(targetPlayer)
    if not xTarget then
        print("[ERROR] Target player not found:", targetPlayer)
        return
    end

    print("[DEBUG] Applying crutch to player:", targetPlayer, "| Time:", crutchTime)

    MySQL.Async.execute(
        'INSERT INTO crutch_users (identifier, crutch_time, last_used) VALUES (@identifier, @crutch_time, @last_used) ' ..
        'ON DUPLICATE KEY UPDATE crutch_time = @crutch_time, last_used = @last_used',
        {
            ['@identifier'] = xTarget.getIdentifier(),
            ['@crutch_time'] = crutchTime,
            ['@last_used'] = os.time()
        }
    )

    print("[DEBUG] Triggering 'd-ramentai:equip' for Player ID:", targetPlayer)
    TriggerClientEvent('d-ramentai:equip', targetPlayer, crutchTime)
end)

