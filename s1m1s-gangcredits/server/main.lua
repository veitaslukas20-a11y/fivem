local ESX = exports["es_extended"]:getSharedObject()

-- Utility: get society account (ESX Society required)
local function getSocietyAccount(job)
    local society = 'society_' .. job
    local account = nil
    TriggerEvent('esx_addonaccount:getSharedAccount', society, function(acc)
        account = acc
    end)
    return account
end

-- Get all current gang levels (for a player or for admin)
local function getGangLevels(job)
    local default = {armour = 1, rstash = 1, bstash = 1, garage = 1}
    local result = MySQL.query.await('SELECT * FROM dec4t_gangcredits WHERE job = ?', {job})
    if result and result[1] then
        local row = result[1]
        return {
            armour = row.armour or 1,
            rstash = row.rstash or 1,
            bstash = row.bstash or 1,
            garage = row.garage or 1
        }
    end
    return default
end

local function setGangLevel(job, levelType, value)
    local row = MySQL.query.await('SELECT * FROM dec4t_gangcredits WHERE job = ?', {job})
    if row and row[1] then
        MySQL.update.await('UPDATE dec4t_gangcredits SET '..levelType..' = ? WHERE job = ?', {value, job})
    else
        -- Insert row if not exists
        MySQL.insert.await('INSERT INTO dec4t_gangcredits (job, '..levelType..') VALUES (?, ?)', {job, value})
    end
end

local function getPlayerGang(source)
    local xPlayer = ESX.GetPlayerFromId(source)
    if xPlayer then
        return xPlayer.getJob().name
    end
end

-- ===== CALLBACK: Get levels for current player's gang
lib.callback.register('gangcredits:getlevels', function(source)
    local job = getPlayerGang(source)
    if not job then return {armour=1, rstash=1, bstash=1, garage=1} end
    return getGangLevels(job)
end)

-- ===== CALLBACK: Buy upgrade (levels)
lib.callback.register('gangcredits:buyLevel', function(source, type, level)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then return false end
    local job = xPlayer.getJob().name
    local current = getGangLevels(job)
    local config = Config[type]
    if not config or not config[level] then return false end
    if current[type] >= level then return false end
    local price = config[level].price or 0

    -- Charge society account
    local account = getSocietyAccount(job)
    if not account or account.money < price then
        TriggerClientEvent('esx:showNotification', source, 'Trūksta pinigų bendroje gaujos kasoje!')
        return false
    end

    account.removeMoney(price)
    setGangLevel(job, type, level)
    TriggerClientEvent('esx:showNotification', source, ('Nupirkote %s lygį už %s€'):format(type, price))
    return true
end)

-- ===== CALLBACK: Add armour (give to player)
lib.callback.register('gangcredits:addArmour', function(source, level)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then return false end
    local job = xPlayer.getJob().name
    local current = getGangLevels(job)
    if current.armour < level then return false end
    local config = Config.armour[level]
    if not config or config.amount == 0 then return false end
    if xPlayer.getMoney() < (config.bprice or 0) then
        TriggerClientEvent('esx:showNotification', source, 'Neturite pakankamai pinigų!')
        return false
    end
    xPlayer.removeMoney(config.bprice or 0)
    return config.amount
end)

-- ===== ADMIN: Return all gangs and their levels
lib.callback.register('gangcredits:returnAll', function(source)
    local rows = MySQL.query.await('SELECT * FROM dec4t_gangcredits')
    local data = {}
    for _, v in ipairs(rows or {}) do
        data[#data+1] = {
            job = v.job,
            levels = {
                armour = v.armour or 1,
                rstash = v.rstash or 1,
                bstash = v.bstash or 1,
                garage = v.garage or 1
            }
        }
    end
    return data
end)

-- ===== ADMIN: Edit gang level
lib.callback.register('gangcredits:editLevel', function(source, job, type, level)
    setGangLevel(job, type, level)
    return true
end)

-- ====== Ensure SQL Table ======
AddEventHandler('onResourceStart', function(res)
    if res == GetCurrentResourceName() then
        MySQL.query([[
            CREATE TABLE IF NOT EXISTS `dec4t_gangcredits` (
                `job` VARCHAR(50) NOT NULL,
                `armour` INT DEFAULT 1,
                `rstash` INT DEFAULT 1,
                `bstash` INT DEFAULT 1,
                `garage` INT DEFAULT 1,
                PRIMARY KEY (`job`)
            )
        ]])
    end
end)