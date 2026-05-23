local ESX = exports['es_extended']:getSharedObject()

-- Store worker assignments {identifier, name, location}
local Workers = {}

-- 🌱 Plant pickup -> give items
lib.callback.register('drugs:pickupPlant', function(source, item, amount)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then return false end

    if not xPlayer.canCarryItem(item, amount) then
        return false
    end

    xPlayer.addInventoryItem(item, amount)
    return true
end)

-- 🧪 Processing tables -> consume required, give result
lib.callback.register('drugs:process:addItem', function(source, object, tableUID)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then return false end

    local cfg = ConfigDrugs.Tables[tableUID]
    if not cfg then return false end

    -- check required
    for _, req in ipairs(cfg.Required) do
        if xPlayer.getInventoryItem(req.name).count < req.count then
            return false
        end
    end

    -- remove required
    for _, req in ipairs(cfg.Required) do
        xPlayer.removeInventoryItem(req.name, req.count)
    end

    -- give processed items
    for _, it in ipairs(cfg.Items) do
        if xPlayer.canCarryItem(it.name, it.max) then
            xPlayer.addInventoryItem(it.name, math.random(1, it.max))
        end
    end

    return true
end)

-- 📦 Packing / Unpacking drugs
RegisterNetEvent('drugs:pack', function(drugType)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then return end

    if drugType == "weed" then
        if xPlayer.getInventoryItem("weed_proc").count >= 5 then
            xPlayer.removeInventoryItem("weed_proc", 5)
            xPlayer.addInventoryItem("weed_package", 1)
        end
    elseif drugType == "coke" then
        if xPlayer.getInventoryItem("coke_proc").count >= 5 then
            xPlayer.removeInventoryItem("coke_proc", 5)
            xPlayer.addInventoryItem("coke", 1)
        end
    elseif drugType == "heroin" then
        if xPlayer.getInventoryItem("heroin").count >= 5 then
            xPlayer.removeInventoryItem("heroin", 5)
            xPlayer.addInventoryItem("heroin_pack", 1)
        end
    end
end)

RegisterNetEvent('drugs:unpack', function(drugType)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then return end

    if drugType == "weed" then
        if xPlayer.getInventoryItem("weed_package").count > 0 then
            xPlayer.removeInventoryItem("weed_package", 1)
            xPlayer.addInventoryItem("weed_proc", 5)
        end
    elseif drugType == "coke" then
        if xPlayer.getInventoryItem("coke").count > 0 then
            xPlayer.removeInventoryItem("coke", 1)
            xPlayer.addInventoryItem("coke_proc", 5)
        end
    elseif drugType == "heroin" then
        if xPlayer.getInventoryItem("heroin_pack").count > 0 then
            xPlayer.removeInventoryItem("heroin_pack", 1)
            xPlayer.addInventoryItem("heroin", 5)
        end
    end
end)

-- 💉 Heroin syringes
RegisterNetEvent('drugs:heroin:syringe', function()
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then return end

    if xPlayer.getInventoryItem("heroin").count >= 5 then
        xPlayer.removeInventoryItem("heroin", 5)
        xPlayer.addInventoryItem("heroin_syringe", 1)
    end
end)

-- 👥 Worker system
lib.callback.register('drugs:addWorker', function(source, targetId, location)
    local boss = ESX.GetPlayerFromId(source)
    local worker = ESX.GetPlayerFromId(targetId)
    if not boss or not worker then return false end

    Workers[worker.identifier] = {workerName = worker.getName(), workerIdentifier = worker.identifier, locationName = location}
    TriggerClientEvent('drugs:addSelf', targetId)
    return true
end)

lib.callback.register('drugs:removeWorker', function(source, identifier)
    Workers[identifier] = nil
    local target = ESX.GetPlayerFromIdentifier(identifier)
    if target then
        TriggerClientEvent('drugs:removeSelf', target.source)
    end
    return true
end)

lib.callback.register('drugs:editWorker', function(source, identifier, newLocation)
    if Workers[identifier] then
        Workers[identifier].locationName = newLocation
        local target = ESX.GetPlayerFromIdentifier(identifier)
        if target then
            TriggerClientEvent('drugs:addSelf', target.source)
        end
    end
    return true
end)

lib.callback.register('drugs:returnWorkers', function(source)
    local result = {}
    for _, data in pairs(Workers) do
        table.insert(result, data)
    end
    return result
end)

lib.callback.register('drugs:returnSelfData', function(source)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then return end
    return Workers[xPlayer.identifier]
end)

for i, plant in pairs(ConfigDrugs.Plants) do
    for j, loc in pairs(plant.Locations or {}) do
        if not loc.Range then
            loc.Range = 5.0 -- default range
        end
    end
end

for i, tableData in pairs(ConfigDrugs.Tables) do
    for j, loc in pairs(tableData.Locations or {}) do
        if not loc.Range then
            loc.Range = 3.0 -- default range for tables
        end
    end
end

-- Give config to clients
lib.callback.register('drugs:getConfig', function(source)
    return ConfigDrugs
end)