local armour = false
local health = false

local allowedRecources = {
    ['es_extended'] = true,
    ['esx_basicneeds'] = true,
    ['s1m1s-gangcredits'] = true,
    ['s1m1s-gangzones'] = true,
    ['1X-ACIDTRIP'] = true,
    ['s1m1s-policejob'] = true,
    ['onex-deivuks-packaged'] = true,
    ['esx_ambulancejob'] = true,
}

exports('armour', function()
    if not allowedRecources[GetInvokingResource()] then return end
    armour = true
end)

exports('health', function()
    if not allowedRecources[GetInvokingResource()] then return end
    health = true 
end)

local larmour = 0
Citizen.CreateThread(function()
    while not ESX or not ESX.IsPlayerLoaded() do Wait(100) end 
    Wait(10000)
    larmour = GetPedArmour(cache.ped)

    while true do
        Wait(1000)
        if GetPedArmour(cache.ped) > larmour and not armour then
            TriggerServerEvent('deivuks-utils:verify', larmour, GetPedArmour(cache.ped))
            break
        end
        larmour = GetPedArmour(cache.ped)
        if armour then armour = false end
    end
end)

local lhealth = 0
Citizen.CreateThread(function()
    while not ESX or not ESX.IsPlayerLoaded() do Wait(100) end 
    Wait(10000)
    lhealth = GetEntityHealth(cache.ped)

    while true do 
        Wait(1000)
        if GetEntityHealth(cache.ped) > lhealth and not health then 
            TriggerServerEvent('deivuks-utils:verify', lhealth, GetEntityHealth(cache.ped))
            break
        end
        lhealth = GetEntityHealth(cache.ped)
        if health then health = false end
    end
end)