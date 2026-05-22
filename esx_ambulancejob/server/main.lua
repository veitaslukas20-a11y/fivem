local ESX = exports['es_extended']:getSharedObject()

local deadPlayers = {}

-- ===== Helpers: accounts-safe (veikia su skirtingomis ESX versijomis) =====
local function getAccountBalance(xPlayer, account)
    if not xPlayer then return 0 end
    if xPlayer.getAccount then
        local acc = xPlayer.getAccount(account)
        if acc and acc.money then return tonumber(acc.money) or 0 end
    end
    return 0
end

local function removeFromAccount(xPlayer, account, amount)
    if not xPlayer or (amount or 0) <= 0 then return false end
    local bal = getAccountBalance(xPlayer, account)
    if bal < amount then return false end

    if xPlayer.removeAccountMoney then
        xPlayer.removeAccountMoney(account, amount)
        return true
    elseif xPlayer.setAccountMoney then
        xPlayer.setAccountMoney(account, bal - amount)
        return true
    end
    return false
end

local function addToAccount(xPlayer, account, amount)
    if not xPlayer or (amount or 0) <= 0 then return false end
    if xPlayer.addAccountMoney then
        xPlayer.addAccountMoney(account, amount); return true
    elseif xPlayer.setAccountMoney then
        local bal = getAccountBalance(xPlayer, account)
        xPlayer.setAccountMoney(account, bal + amount); return true
    end
    return false
end

-- (naudojama tik kai reikia absolute cash operacijų)
local function removeCash(xPlayer, amount)
    if not xPlayer or (amount or 0) <= 0 then return false end
    if xPlayer.removeMoney then xPlayer.removeMoney(amount); return true end
    if xPlayer.getMoney and xPlayer.setAccountMoney then
        local cash = xPlayer.getMoney()
        xPlayer.setAccountMoney('money', math.max(0, (cash or 0) - amount))
        return true
    end
    return false
end

-- ===== Dead state =====
RegisterNetEvent('reload_death:setDead', function(state)
    local src = source
    if not src then return end
    deadPlayers[src] = state and true or false
end)

ESX.RegisterServerCallback('reload_death:getDeadStatus', function(source, cb)
    cb(deadPlayers[source] or false)
end)

-- ===== After RP death cleanup (palikta kaip buvo) =====
RegisterNetEvent('esx_ambulancejob:removeItemsAfterRPDeath', function()
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then return end

    -- Remove loadout
    local loadout = xPlayer.getLoadout() or {}
    for i = 1, #loadout do
        local w = loadout[i]
        if w and w.name then
            xPlayer.removeWeapon(w.name)
        end
    end

    -- Nunulinam cash (money) ir black_money jei naudojama
    if xPlayer.setMoney then
        xPlayer.setMoney(0)
    else
        if xPlayer.setAccountMoney then xPlayer.setAccountMoney('money', 0) end
    end
    if xPlayer.setAccountMoney then
        xPlayer.setAccountMoney('money', 0)
        if xPlayer.getAccount and xPlayer.getAccount('black_money') then
            xPlayer.setAccountMoney('black_money', 0)
        end
    end
end)

-- ===== EARLY RESPAWN FINE -> DEDUCT FROM BANK (NOT CASH) =====
RegisterNetEvent('esx_ambulancejob:payFine', function()
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then return end

    local fine = (Config and Config.EarlyRespawnFineAmount) or 100
    local bankBal = getAccountBalance(xPlayer, 'bank')

    if bankBal >= fine then
        removeFromAccount(xPlayer, 'bank', fine)
        -- (neprivaloma) pranešimas
        TriggerClientEvent('ox_lib:notify', xPlayer.source, {
            title = 'Ligoninė',
            description = ('Nuskaičiuota %s€ iš banko už ankstyvą prisikėlimą.'):format(fine),
            type = 'success'
        })
    else
        -- Jei reikia – galima daryti fallback į cash; bet pagal užklausą NE – tik iš banko.
        TriggerClientEvent('ox_lib:notify', xPlayer.source, {
            title = 'Ligoninė',
            description = 'Nepakanka lėšų banke ankstyvam prisikėlimui.',
            type = 'error'
        })
    end
end)

-- ===== Dispatch =====
RegisterNetEvent('cd_dispatch:AddNotification', function(notification)
    local jobs = (notification and notification.job_table) or {}
    local players = ESX.GetPlayers()

    for _, playerId in ipairs(players) do
        local xp = ESX.GetPlayerFromId(playerId)
        if xp and xp.job and xp.job.name then
            for _, jobName in ipairs(jobs) do
                if xp.job.name == jobName then
                    TriggerClientEvent('cd_dispatch:ReceiveNotification', playerId, notification)
                    break
                end
            end
        end
    end
end)

-- ===== UI balance check -> now checks BANK =====
ESX.RegisterServerCallback('esx_ambulancejob:checkBalance', function(source, cb)
    local xPlayer = ESX.GetPlayerFromId(source)
    cb(xPlayer and getAccountBalance(xPlayer, 'bank') or 0)
end)

-- ===== Mediko revive (palikta kaip buvo; reward – jei norite, galite pervesti į banką) =====
RegisterNetEvent('esx_ambulancejob:revive', function(playerId)
    local src = source
    playerId = tonumber(playerId)

    if (src == 0 or src == nil) and GetInvokingResource() == 'monitor' then
        if playerId then
            TriggerClientEvent('esx_ambulancejob:revive', playerId)
        end
        return
    end

    local xPlayer = ESX.GetPlayerFromId(src)
    if not xPlayer then return end

    if xPlayer.job and xPlayer.job.name == 'ambulance' then
        if playerId then
            local xTarget = ESX.GetPlayerFromId(playerId)
            if xTarget and deadPlayers[playerId] then
                if Config and (Config.ReviveReward or 0) > 0 then
                    -- jei norit – pakeiskit į addAccountMoney('bank', ...)
                    if not addToAccount(xPlayer, 'bank', Config.ReviveReward) then
                        -- fallback į cash, jei nėra account API
                        if xPlayer.addMoney then xPlayer.addMoney(Config.ReviveReward) end
                    end
                end
                TriggerClientEvent('esx_ambulancejob:revive', playerId)
            end
        end
    end
end)

RegisterNetEvent('esx_ambulancejob:heal', function(targetId, healType)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    local xTarget = ESX.GetPlayerFromId(tonumber(targetId) or -1)
    if not xPlayer or not xTarget then return end

    if not xPlayer.job or xPlayer.job.name ~= 'ambulance' then
        TriggerClientEvent('ox_lib:notify', src, {
            title = 'Greitoji',
            description = 'Tu negali gydyti kitų žaidėjų.',
            type = 'error'
        })
        return
    end

    TriggerClientEvent('esx_ambulancejob:heal', xTarget.source, healType, false)
    print(('[esx_ambulancejob] %s healed %s (%s)'):format(xPlayer.getName(), xTarget.getName(), tostring(healType)))
end)

ESX.RegisterCommand('revive', 'admin', function(xPlayer, args, showError)
    local target = args.playerId
    local targetId = (type(target) == 'table' and target.source) or tonumber(target)
    if targetId then
        TriggerClientEvent('esx_ambulancejob:revive', targetId)
    end
end, true, { help = (_U and _U('revive_help')) or 'Revive a player', validate = true, arguments = {
    { name = 'playerId', help = 'The player id', type = 'player' }
}})
