ESX = exports["es_extended"]:getSharedObject()

ESX.RegisterServerCallback('d-regitra:giveLicense', function(source, cb, licenseType)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then
        print("[ERROR] Could not retrieve ESX player for source:", source)
        cb(false)
        return
    end

    print("[DEBUG] Adding license", licenseType, "to player:", xPlayer.identifier)

    -- Add the license and refresh player's licenses
    TriggerEvent('esx_license:addLicense', source, licenseType, function()
        TriggerEvent('esx_license:getLicenses', source, function(licenses)
            TriggerClientEvent('esx_dmvschool:loadLicenses', source, licenses)
        end)

        print("[SUCCESS] License", licenseType, "added to player:", xPlayer.identifier)
        cb(true) -- Return success
    end)
end)

-- Check Player's Licenses
ESX.RegisterServerCallback('d-regitra:checkLicense', function(source, cb)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then
        cb({})
        return
    end

    TriggerEvent('esx_license:getLicenses', source, function(licenses)
        cb(licenses)
        print("[DEBUG] Sent license data to client for:", xPlayer.identifier)
    end)
end)

-- Remove Money from Player (Checks if player has enough money)
ESX.RegisterServerCallback('d-regitra:removeMoney', function(source, cb, category)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then
        cb(false)
        return
    end

local licensePrices = {
    ["theory"] = 500,  -- ✅ pridėta
    ["dmv"] = 500,  
    ["A"] = 1500, 
    ["B"] = 2500, 
    ["C1"] = 5000, 
    ["CE"] = 7500, 
    ["D"] = 10000
}

    local price = licensePrices[category] or 0

    if price == 0 then
        print("[ERROR] Invalid category for license fee:", category)
        cb(false)
        return
    end

    if xPlayer.getAccount('bank').money >= price then
        xPlayer.removeAccountMoney('bank', price)
        print("[DEBUG] Removed", price, "from player:", xPlayer.identifier)
        cb(true)
    else
        print("[ERROR] Player", xPlayer.identifier, "does not have enough money for license:", category)
        cb(false)
    end
end)

-- Automatically Load Licenses When Player Joins
AddEventHandler('esx:playerLoaded', function(source)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then return end

    TriggerEvent('esx_license:getLicenses', source, function(licenses)
        TriggerClientEvent('esx_dmvschool:loadLicenses', source, licenses)
    end)
end)