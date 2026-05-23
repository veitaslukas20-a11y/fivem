local ESX = ESX
local function DGZ() return _G.dgz end
local function CFG() return _G.dgz and _G.dgz.cfg or {} end
local function nowMs() return DGZ() and DGZ().nowMs() or (os.time()*1000) end

local function ensureOwnerBoss(src, z)
    local x = ESX.GetPlayerFromId(src); if not x then return false, 'ESX' end
    if not z or x.job.name ~= (z.owners or '') then return false, 'Jūsų gauja nevaldo šios zonos.' end
    if (x.job.grade or 0) < (CFG().BossGrade or 3) then return false, 'Jūs nesate gaujos bosas, kad galėtumėte atlikti šį veiksmą.' end
    return true
end

-- ŠARVŲ UŽSIDĖJIMAS
lib.callback.register('d-gangzones:addArmour', function(src, zkey)
    local z = CFG().Zones[zkey]; if not z or not z.armour then return false end
    local x = ESX.GetPlayerFromId(src); if not x then return false end
    if x.job.name ~= (z.owners or '') then return false end

    local ident = x.getIdentifier()
    local row = MySQL.single.await([[
        SELECT used_today, reset_day, cooldown_until
          FROM d_gangzones_armour_claims
         WHERE identifier = ? AND zone_title = ?
    ]], { ident, z.title })

    local day = tonumber(os.date('%j'))
    local used, resetDay, cdUntil = 0, 0, 0
    if row then used = row.used_today or 0; resetDay = row.reset_day or 0; cdUntil = row.cooldown_until or 0 end
    if resetDay ~= day then used = 0; resetDay = day end
    if (z.armour.max or 0) > 0 and used >= z.armour.max then
        TriggerClientEvent('esx:showNotification', src, 'Pasiekėte dienos limitą.')
        return false
    end
    if cdUntil > os.time() then
        local left = cdUntil - os.time()
        TriggerClientEvent('esx:showNotification', src, ('Šarvų užsidėjimo cooldown dar %d s.'):format(left))
        return false
    end

    used = used + 1
    cdUntil = os.time() + (z.armour.cooldown or 0) * 60
    if row then
        MySQL.update.await([[
            UPDATE d_gangzones_armour_claims
               SET used_today=?, reset_day=?, cooldown_until=?
             WHERE identifier=? AND zone_title=?
        ]], { used, resetDay, cdUntil, ident, z.title })
    else
        MySQL.insert.await([[
            INSERT INTO d_gangzones_armour_claims (identifier, zone_title, used_today, reset_day, cooldown_until)
            VALUES (?,?,?,?,?)
        ]], { ident, z.title, used, resetDay, cdUntil })
    end
    return true
end)

-- JUODOJI RINKA
lib.callback.register('d-gangzones:buyItem', function(src, zkey, item, count)
    local z = CFG().Zones[zkey]; if not z or not z.blackmarket then return false end
    local ok, msg = ensureOwnerBoss(src, z); if not ok then TriggerClientEvent('esx:showNotification', src, msg) return false end
    count = math.max(1, tonumber(count or 1))

    local e = z.blackmarket[item]; if not e then return false end
    local level = math.floor((z.daysOwned or 0) / 7)
    if level < (e.week or 0) then
        TriggerClientEvent('esx:showNotification', src, 'Šis daiktas dar neprieinamas.')
        return false
    end

    local price = (e.price or 0) * count
    local x = ESX.GetPlayerFromId(src)
    if x.getAccount(CFG().Accounts.cash).money < price then
        TriggerClientEvent('esx:showNotification', src, 'Nepakanka grynųjų.')
        return false
    end

    x.removeAccountMoney(CFG().Accounts.cash, price)
    exports.ox_inventory:AddItem(src, item, count)
    TriggerClientEvent('esx:showNotification', src, ('Nupirkote %sx %s.'):format(count, e.label or item))
    return true
end)

-- PLOVIMAS
lib.callback.register('d-gangzones:plovimas', function(src, zkey, amount)
    local z = CFG().Zones[zkey]; if not z or z.type ~= 'plovimas' then return false end
    local ok, msg = ensureOwnerBoss(src, z); if not ok then TriggerClientEvent('esx:showNotification', src, msg) return false end

    amount = math.max(1, math.floor(tonumber(amount or 0)))
    local x = ESX.GetPlayerFromId(src)
    if x.getAccount(CFG().Accounts.black).money < amount then
        TriggerClientEvent('esx:showNotification', src, 'Nepakanka nelegalių pinigų.')
        return false
    end

    local percent = math.max(1, z.ppercent or 80)
    local clean = math.floor(amount * percent / 100)

    x.removeAccountMoney(CFG().Accounts.black, amount)
    x.addAccountMoney(CFG().Accounts.cash, clean)

    TriggerClientEvent('esx:showNotification', src, ('Išplauta %s € → gauta %s €'):format(amount, clean))
    return true
end)

-- NARKOTIKAI
lib.callback.register('d-gangzones:sellDrug', function(src, zkey, item, count)
    local z = CFG().Zones[zkey]; if not z or not z.drugdealer then return false end
    local x = ESX.GetPlayerFromId(src); if not x then return false end
    if x.job.name ~= (z.owners or '') or (x.job.grade or 0) < 3 then return false end

    count = math.max(1, tonumber(count or 1))
    local e = z.drugdealer[item]; if not e then return false end

    if exports.ox_inventory:Search(src, 'count', item) < count then
        TriggerClientEvent('esx:showNotification', src, 'Neturite pakankamai prekių.')
        return false
    end

    local price = e.price or 0
    if z.timesTaken and z.timesTaken >= 3 then price = math.floor(price * 1.3) end
    local total = price * count

    exports.ox_inventory:RemoveItem(src, item, count)
    x.addAccountMoney(CFG().Accounts.cash, total)
    TriggerClientEvent('esx:showNotification', src, ('Pardavėte %sx %s už %s €'):format(count, e.label or item, total))
    return true
end)

-- APDOVANOJIMAS
lib.callback.register('d-gangzones:claimReward', function(src, ztitle)
    local z = Config.Zones[string.lower(ztitle or '')]
    if not z then return false end

    local ok, msg = ensureOwnerBoss(src, z)
    if not ok then return 'not_boss' end

    local x = ESX.GetPlayerFromId(src)
    local ident = x.getIdentifier()

    -- Cooldown
    local last = MySQL.scalar.await(
        'SELECT last_claim_at FROM d_gangzones_rewards WHERE identifier=? AND zone_title=?',
        { ident, z.title }
    )
    local cd = (Config.Reward.cooldownHours or 24) * 3600
    if last and (os.time() - last) < cd then
        local left = cd - (os.time() - last)
        return 'timeout', left
    end

    -- ====== ČIA REDAGUOJI, KĄ IR KIEK DUOTI ======
    local rewards = {
        { item = 'armour',    amount = 15 },
        { item = 'ammunition_pistol', amount = 200 },
        { item = 'weapon_appistol',  amount = 2 },
        { item = 'black_money', amount = 50000 },
    }
    local fallbackMoney = 50000
    -- ==============================================

    local itemsIndex = exports.ox_inventory:Items() or {}
    local given = {}
    local givenCount = 0

    for _, r in ipairs(rewards) do
        local name = r.item
        local qty  = tonumber(r.amount) or 1

        -- duodam VISUS galimus iš sąrašo
        if itemsIndex[name] then
            local okAdd = exports.ox_inventory:AddItem(src, name, qty)
            if okAdd ~= false then
                table.insert(given, { item = name, amount = qty })
                givenCount = givenCount + 1
            end
        end
    end

    -- Jei nieko nepavyko duoti (pvz., neegzistuoja item'ai) – duodam pinigus
    local result
    if givenCount == 0 then
        x.addAccountMoney(Config.Accounts.cash, fallbackMoney)
        result = { money = { account = Config.Accounts.cash, amount = fallbackMoney }, items = {} }
    else
        result = { items = given }
    end

    -- Išsaugom cooldown
    local now = os.time()
    if last then
        MySQL.update.await(
            'UPDATE d_gangzones_rewards SET last_claim_at=? WHERE identifier=? AND zone_title=?',
            { now, ident, z.title }
        )
    else
        MySQL.insert.await(
            'INSERT INTO d_gangzones_rewards (identifier, zone_title, last_claim_at) VALUES (?,?,?)',
            { ident, z.title, now }
        )
    end

    -- gražinam, ką davėm (gali praversti notifui kliente)
    return 'ok', result
end)