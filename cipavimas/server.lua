ESX = exports["es_extended"]:getSharedObject()

-- Lentelės pavadinimas duomenų bazėje
local tableName = "vehicle_tuning"

-- Sukuriame lentelę, jei jos dar nėra
MySQL.ready(function()
    MySQL.query(string.format([[
        CREATE TABLE IF NOT EXISTS `%s` (
            `plate` VARCHAR(50) NOT NULL PRIMARY KEY,
            `tuning` LONGTEXT NULL
        )
    ]], tableName))
    print("[TUNING] Lentelė '"..tableName.."' paruošta.")
end)

-- Gauti tuning duomenis pagal numerį
ESX.RegisterServerCallback("tuning:getTuning", function(source, cb, plate)
    MySQL.query("SELECT tuning FROM "..tableName.." WHERE plate = ?", {plate}, function(result)
        if result and #result > 0 then
            cb(result[1].tuning)
        else
            cb(nil)
        end
    end)
end)

-- Išsaugoti tuning pakeitimus
RegisterServerEvent("tuning:saveVehicleModifications")
AddEventHandler("tuning:saveVehicleModifications", function(data, plate)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    if not xPlayer then return end
    if not plate or not data then return end

    MySQL.query("SELECT plate FROM "..tableName.." WHERE plate = ?", {plate}, function(result)
        if result and #result > 0 then
            -- atnaujinti egzistuojančią eilutę
            MySQL.update("UPDATE "..tableName.." SET tuning = ? WHERE plate = ?", {data, plate})
        else
            -- įrašyti naują eilutę
            MySQL.insert("INSERT INTO "..tableName.." (plate, tuning) VALUES (?, ?)", {plate, data})
        end
    end)
end)

-- Jei nori, kad laptopas būtų naudojamas kaip item
ESX.RegisterUsableItem("tuning_laptop", function(source)
    local xPlayer = ESX.GetPlayerFromId(source)
    if xPlayer then
        TriggerClientEvent("tuning:useLaptop", source)
    end
end)

print("[TUNING] server.lua įkeltas sėkmingai.")