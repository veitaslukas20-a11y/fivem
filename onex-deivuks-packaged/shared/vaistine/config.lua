Vaistine = {}

-- Pharmacy locations
Vaistine.Pharmacies = {
    { x = -492.1534, y = -341.2672, z = 42.3206, w = 0.0 },
    { x = 1820.0547, y = 3664.6487, z = 34.2768, w = 0.0 },
    -- Add more pharmacies here
}

-- Prices for items
Vaistine.Prices = {
    medikitas = 4000,  -- Price for first aid kit
    bandage = 2000     -- Price for bandages
}

lib.callback.register('vaistine:getConfig', function()
    return Vaistine
end)