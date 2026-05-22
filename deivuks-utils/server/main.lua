local ESX = exports['es_extended']:getSharedObject()

-- List of resources that can set armour/health legitimately
local allowedResources = {
    ['es_extended'] = true,
    ['esx_basicneeds'] = true,
    ['s1m1s-gangcredits'] = true,
    ['s1m1s-gangzones'] = true,
    ['1X-ACIDTRIP'] = true,
    ['s1m1s-policejob'] = true,
    ['onex-deivuks-packaged'] = true,
    ['esx_ambulancejob'] = true,
}

-- Armour verification event
RegisterServerEvent('deivuks-utils:verify')
AddEventHandler('deivuks-utils:verify', function(oldValue, newValue)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    if not xPlayer then return end

    local resourceName = GetInvokingResource()
    
    if not allowedResources[resourceName] then
        if newValue > oldValue then
            print(('[ANTI-CHEAT] %s (%s) tried to add armour/health illegally. (%d ? %d) [Resource: %s]')
                :format(xPlayer.getName(), src, oldValue, newValue, resourceName or 'unknown'))

            -- Punishment: kick
            DropPlayer(src, "[ANTI-CHEAT] Illegal armour/health modification detected.")
        end
    end
end)

-- Health verification callback
lib.callback.register('deivuks-utils:unverify', function(src, oldHealth, newHealth)
    local xPlayer = ESX.GetPlayerFromId(src)
    if not xPlayer then return false end

    local resourceName = GetInvokingResource()

    if not allowedResources[resourceName] then
        if newHealth > oldHealth then
            print(('[ANTI-CHEAT] %s (%s) tried to add health illegally. (%d ? %d) [Resource: %s]')
                :format(xPlayer.getName(), src, oldHealth, newHealth, resourceName or 'unknown'))

            -- Punishment: kick
            DropPlayer(src, "[ANTI-CHEAT] Illegal health modification detected.")
            return false
        end
    end

    return true
end)

-- Debug log
AddEventHandler('onResourceStart', function(resourceName)
    if allowedResources[resourceName] then
        print(("[UTILS] Allowed resource loaded: %s"):format(resourceName))
    end
end)

print("[deivuks-utils] Server script loaded successfully")