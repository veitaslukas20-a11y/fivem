local ESX = exports.es_extended:getSharedObject()
local disconnectRecords = {}

-- Event to handle player disconnections
AddEventHandler('playerDropped', function(reason)
    local source = source
    local xPlayer = ESX.GetPlayerFromId(source)
    
    if not xPlayer then return end

    -- Get player information
    local playerName = xPlayer.getName()
    local playerId = source
    local coords = GetEntityCoords(GetPlayerPed(source))
    local time = os.date("%H:%M:%S")
    
    -- Format the disconnect reason
    local formattedReason = reason
    if reason == "Disconnected." then
        formattedReason = "Atsijunge"
    elseif reason == "Timed out." then
        formattedReason = "Nutruko ryšys"
    elseif reason == "Exited" then
        formattedReason = "Išejo"
    elseif reason == "Kicked." then
        formattedReason = "Iškeltas"
    elseif reason == "Banned." then
        formattedReason = "Užblokuotas"
    end

    -- Broadcast to all nearby players
    TriggerClientEvent("showDisconnect", -1, playerName, playerId, formattedReason, time, coords)
    
    -- Store the disconnect record (optional for logging)
    disconnectRecords[#disconnectRecords + 1] = {
        name = playerName,
        id = playerId,
        reason = formattedReason,
        time = time,
        coords = coords,
        date = os.date("%Y-%m-%d")
    }
    
    -- Clean up old records (keep last 100)
    if #disconnectRecords > 100 then
        table.remove(disconnectRecords, 1)
    end
end)
