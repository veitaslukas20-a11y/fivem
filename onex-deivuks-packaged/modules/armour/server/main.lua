local Armour = exports['deivuks-utils']

lib.callback.register('onex-deivuks-packaged:usedArmour', function(source)
    local xPlayer = ESX.GetPlayerFromId(source)
    local hasArmour = xPlayer.getInventoryItem('armour')

    if hasArmour.count > 0 then
        xPlayer.removeInventoryItem('armour', 1)
        return true
    else
        return false
    end
end)