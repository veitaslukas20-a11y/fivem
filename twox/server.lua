AddEventHandler('playerJoining', function()
    local src = source
    SetPlayerRoutingBucket(src, 0)
end)
