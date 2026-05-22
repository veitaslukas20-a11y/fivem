local ESX = exports['es_extended']:getSharedObject()

local PlayerStates = {}

-- When player loads in
RegisterNetEvent('esx:playerLoaded', function(playerId, xPlayer)
    PlayerStates[playerId] = PlayerStates[playerId] or {
        dead = false,
        inBed = false
    }
end)

-- When player disconnects
AddEventHandler('playerDropped', function()
    local src = source
    PlayerStates[src] = nil
end)

-- Set dead/alive state from client
RegisterNetEvent('reload_death:setDead', function(isDead)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    if not xPlayer then return end

    PlayerStates[src] = PlayerStates[src] or { dead = false, inBed = false }
    PlayerStates[src].dead = isDead

    -- Store to ESX player data
    xPlayer.set('dead', isDead)

    print(('[reload_death] %s (%s) isDead = %s'):format(xPlayer.getName(), src, tostring(isDead)))
end)

-- Get player's own death state (used on playerLoaded)
lib.callback.register('reload_death:getDead', function(source)
    local state = PlayerStates[source] or { dead = false, inBed = false }
    return state
end)

-- Set "in bed" state (used for hospital beds)
RegisterNetEvent('reload_death:setInBed', function(inBed)
    local src = source
    PlayerStates[src] = PlayerStates[src] or { dead = false, inBed = false }
    PlayerStates[src].inBed = inBed
end)

-- ✅ Check if another player is dead (used by ambulance revive)
lib.callback.register('reload_death:isPlayerDead', function(source, targetId)
    local xTarget = ESX.GetPlayerFromId(targetId)
    if not xTarget then return false end

    local state = PlayerStates[targetId]
    return state and state.dead or false
end)

-- ✅ Revive event (called from esx_ambulancejob when animation finishes)
RegisterNetEvent('reload_death:revive', function(targetId)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    if not xPlayer then return end

    -- Optional: restrict revive ability to medics
    if xPlayer.job.name ~= 'ambulance' then
        TriggerClientEvent('ox_lib:notify', src, {
            title = 'Revive',
            description = 'Tu negali prikelti žaidėjo.',
            type = 'error'
        })
        return
    end

    local xTarget = ESX.GetPlayerFromId(targetId)
    if not xTarget then
        TriggerClientEvent('ox_lib:notify', src, {
            title = 'Revive',
            description = 'Žaidėjas nepasiekiamas.',
            type = 'error'
        })
        return
    end

    -- Update state
    PlayerStates[targetId] = PlayerStates[targetId] or { dead = false, inBed = false }
    PlayerStates[targetId].dead = false
    xTarget.set('dead', false)

    -- 🔹 Actually revive target client
    TriggerClientEvent('reload_death:revive', targetId)

    -- 🔹 Optional notification for medic
    TriggerClientEvent('ox_lib:notify', src, {
        title = 'Revive',
        description = ('Tu prikėlei žaidėją: %s'):format(xTarget.getName()),
        type = 'success'
    })

    -- Log to console
    print(('[reload_death] %s revived %s'):format(xPlayer.getName(), xTarget.getName()))
end)
