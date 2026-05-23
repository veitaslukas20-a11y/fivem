local Inventory = exports.ox_inventory
local Armour = exports['deivuks-utils']

local function PlayLoading(label, time, anim)
    return lib.progressBar({
        duration = time,
        label = label,
        useWhileDead = false,
        canCancel = true,
        disable = {
            car = true,
            move = true,
            sprint = true,
            combat = true,
        },
        anim = anim,
    })
end

exports('armour', function(data, slot)
    if cache.vehicle or GetPedArmour(cache.ped) >= 50 then return end

    if PlayLoading('Užsidedate šarvus', 5000, {
        dict = "clothingtie",
        clip = "try_tie_negative_a"
    }) then
        Inventory:useItem(data, function(data)
            if data then
                Armour:armour()
                SetPedArmour(cache.ped, 50)
            end
        end)
    end
end)

exports('heavy_armour', function(data, slot)
    if cache.vehicle or GetPedArmour(cache.ped) >= 99 then return end

    if PlayLoading('Užsidedate sunkius šarvus', 10000, {
        dict = "clothingtie",
        clip = "try_tie_negative_a"
    }) then
        Inventory:useItem(data, function(data)
            if data then
                Armour:armour()
                SetPedArmour(cache.ped, 99)
            end
        end)
    end
end)