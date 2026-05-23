ESX = exports['es_extended']:getSharedObject()

-- Example vehicle outfit storage (replace with DB later)
local vehiclesWithOutfit = {
    ["ABC123"] = true,
    ["XYZ789"] = false,
}

-- Register ox_lib server callback
lib.callback.register('s1m1s-outfitveh:hasOutfit', function(source, plate)
    -- source is the player ID who called the callback
    return vehiclesWithOutfit[plate] or false
end)
