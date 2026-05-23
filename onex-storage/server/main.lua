ESX = exports['es_extended']:getSharedObject()
local storages = {}

-- Initialize the database table with correct columns
CreateThread(function()
    -- First, create the table if it doesn't exist with all required columns
    MySQL.query([[
        CREATE TABLE IF NOT EXISTS `storages` (
            `id` INT AUTO_INCREMENT PRIMARY KEY,
            `type` VARCHAR(20) NOT NULL,
            `price` INT NOT NULL,
            `owner` VARCHAR(60) DEFAULT NULL,
            `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            KEY `owner` (`owner`),
            KEY `type` (`type`)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
    ]])
    
    -- Then check for and add any missing columns
    local columns = MySQL.query.await([[
        SELECT COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS 
        WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'storages'
    ]])
    
    local requiredColumns = {
        type = "ALTER TABLE `storages` ADD COLUMN `type` VARCHAR(20) NOT NULL AFTER `id`",
        price = "ALTER TABLE `storages` ADD COLUMN `price` INT NOT NULL AFTER `type`",
        owner = "ALTER TABLE `storages` ADD COLUMN `owner` VARCHAR(60) DEFAULT NULL AFTER `price`"
    }
    
    local existingColumns = {}
    for _, column in ipairs(columns) do
        existingColumns[column.COLUMN_NAME] = true
    end
    
    for columnName, alterStatement in pairs(requiredColumns) do
        if not existingColumns[columnName] then
            print(('[onex-storage] Adding missing column: %s'):format(columnName))
            MySQL.query.await(alterStatement)
        end
    end
    
    LoadStorages()
end)

function LoadStorages()
    local result = MySQL.query.await('SELECT * FROM storages')
    storages = result or {}
    print(('[onex-storages] Loaded %d storages'):format(#storages))
    
    for _, storage in pairs(storages) do
        if storage.owner and storage.owner ~= '' then
            RegisterStorage(storage.id, storage.type)
        end
    end
end

function RegisterStorage(id, type)
    local storageConfig = Config.Storages[type]
    if not storageConfig then return end
    
    exports.ox_inventory:RegisterStash(
        id..'-warehouse', 
        id..'-warehouse', 
        storageConfig.slots, 
        storageConfig.weight * 1000, 
        true
    )
end

-- Callbacks
lib.callback.register('onex-storages:getPrices', function(source)
    local prices = {}
    for type, data in pairs(Config.Storages) do
        table.insert(prices, {
            type = type,
            price = data.price,
            weight = data.weight,
            slots = data.slots
        })
    end
    return prices
end)

lib.callback.register('onex-storages:getSelfStorages', function(source)
    local xPlayer = ESX.GetPlayerFromId(source)
    local ownedStorages = {}
    
    for _, storage in pairs(storages) do
        if storage.owner == xPlayer.identifier then
            table.insert(ownedStorages, {
                id = storage.id,
                type = storage.type,
                price = storage.price
            })
        end
    end
    
    return ownedStorages
end)

lib.callback.register('onex-storage:getData', function(source, requiredVIP)
    if requiredVIP then
        local vipLevel = exports['peurost_vip']:GetVipLevel(source)

        if not vipLevel or vipLevel < requiredVIP then
            return 'not_vip'
        end
    end

    return true
end)


lib.callback.register('onex-storage:purchase', function(source, storageType)
    local xPlayer = ESX.GetPlayerFromId(source)
    local storageConfig = Config.Storages[storageType]
    
    if not storageConfig then
        return 'not_found', 'ERROR'
    end
    
    -- Check ownership limits
    local ownedCount = 0
    local typeCount = 0
    for _, storage in pairs(storages) do
        if storage.owner == xPlayer.identifier then
            ownedCount = ownedCount + 1
            if storage.type == storageType then
                typeCount = typeCount + 1
            end
        end
    end
    
    if ownedCount >= Config.MaxStorages.all then
        return 'over_the_limit', 'ERROR'
    end
    
    if typeCount >= Config.MaxStorages[storageType] then
        return 'same_type', 'ERROR'
    end
    
    if xPlayer.getMoney() < storageConfig.price then
        return 'no_money', 'ERROR'
    end
    
    -- Create new storage
    local id = MySQL.insert.await([[
        INSERT INTO storages (type, price, owner)
        VALUES (?, ?, ?)
    ]], {storageType, storageConfig.price, xPlayer.identifier})
    
    if not id then
        return 'couldnt_buy', 'ERROR'
    end
    
    -- Update local cache
    local newStorage = {
        id = id,
        type = storageType,
        price = storageConfig.price,
        owner = xPlayer.identifier
    }
    table.insert(storages, newStorage)
    
    -- Register stash and take money
    RegisterStorage(id, storageType)
    xPlayer.removeMoney(storageConfig.price)
    
    return 'bought_warehouse', 'SUCCESS'
end)

lib.callback.register('onex-storage:sell', function(source, storageId)
    local xPlayer = ESX.GetPlayerFromId(source)
    
    -- Find storage
    local storage, index
    for i, s in ipairs(storages) do
        if s.id == storageId then
            storage = s
            index = i
            break
        end
    end
    
    if not storage then
        return 'not_found'
    end
    
    if storage.owner ~= xPlayer.identifier then
        return 'no_access'
    end
    
    -- Calculate sell price
    local sellPrice = math.floor(storage.price * 0.7)
    
    -- Update database
    local success = MySQL.update.await([[
        UPDATE storages SET owner = NULL WHERE id = ?
    ]], {storageId})
    
    if not success then
        return 'coudnt_sell'
    end
    
    -- Update local cache
    storage.owner = nil
    
    -- Clear inventory and give money
    exports.ox_inventory:ClearInventory(storageId..'-warehouse')
    xPlayer.addMoney(sellPrice)
    
    return true
end)

lib.callback.register('onex-storages:openStorage', function(source, storageId)
    local xPlayer = ESX.GetPlayerFromId(source)
    
    for _, storage in pairs(storages) do
        if storage.id == storageId then
            if storage.owner == xPlayer.identifier then
                TriggerClientEvent('ox_inventory:openInventory', source, 'stash', storageId..'-warehouse')
                return true
            else
                return 'no_access'
            end
        end
    end
    
    return 'not_found'
end)