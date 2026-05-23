local ESX = ESX
local function DGZ() return _G.dgz end
local function CFG() return _G.dgz and _G.dgz.cfg or {} end
local function ZONEMEM() return _G.dgz and _G.dgz.members or {} end
local function ACTIVE() return _G.dgz and _G.dgz.active or {} end
local function nowMs() return DGZ() and DGZ().nowMs() or (os.time()*1000) end

-- konfigai
local CANCEL_IF_EMPTY_FOR_MS = 5000  -- po 5s visiškai tuščios zonos - nutraukti
local START_GRACE_MS = 2000          -- 2s malonė starto sincam

-- ================= GEO =================
local function deg2rad(d) return (d or 0.0) * math.pi / 180.0 end
local function insideRotatedBox(p, center, size, rotationDeg)
    if not p or not center or not size then return false end
    local dx = (p.x or 0.0) - (center.x or 0.0)
    local dy = (p.y or 0.0) - (center.y or 0.0)
    local dz = math.abs((p.z or 0.0) - (center.z or 0.0))
    local r = -deg2rad(rotationDeg or 0.0)
    local cosr, sinr = math.cos(r), math.sin(r)
    local rx = dx * cosr - dy * sinr
    local ry = dx * sinr + dy * cosr
    local hx = (size.x or 0.0) / 2.0
    local hy = (size.y or 0.0) / 2.0
    local hz = (size.z or 0.0) / 2.0
    if hz <= 0.0 then hz = 100.0 end
    return (math.abs(rx) <= hx) and (math.abs(ry) <= hy) and (dz <= hz)
end

-- ========= SERVER-SIDE "mirties" tikrinimas be IsEntityDead =========
local function pedIsDead(ped)
    if not ped or ped == 0 then return true end
    if not DoesEntityExist(ped) then return true end
    local h = GetEntityHealth(ped)
    if h == nil then return false end
    return h <= 0
end

-- Kiek gyvų užpuolikų (pagal job) YRA ZONOJE
local function attackersCount(z, attackersJob)
    if not z or not attackersJob then return 0 end
    local count = 0
    for _, xp in pairs(ESX.GetExtendedPlayers('job', attackersJob) or {}) do
        local src = xp.source
        if src and GetPlayerPing(src) > 0 then
            local ped = GetPlayerPed(src)
            if ped and ped ~= 0 and DoesEntityExist(ped) and not pedIsDead(ped) then
                local pos = GetEntityCoords(ped)
                if insideRotatedBox(pos, z.coords, z.size, z.rotation) then
                    count = count + 1
                end
            end
        end
    end
    return count
end

local function broadcastStopped(zkey, stopped)
    for src, _ in pairs(ZONEMEM()[zkey] or {}) do
        TriggerClientEvent('d-gangzones:setStoped', src, stopped)
    end
end

-- ================= START / END =================
local function endTakeover(z, zkey, won)
    local tk = ACTIVE()[zkey]
    ACTIVE()[zkey] = nil
    z.takers = nil

    if won then
        z.owners = tk.attackers
        z.owned_since = math.floor(os.time())
        z.timesTaken = (z.timesTaken or 0) + 1
        z.next_take_at = math.floor(os.time()) + (z.cooldown or 12) * 3600

        -- BETS pot išdalinimas tik realiai zonoje esantiems gyviems laimėtojams
        if z.betPot and z.betPot > 0 then
            local winners = {}
            for _, xp in pairs(ESX.GetExtendedPlayers('job', tk.attackers) or {}) do
                local ped = GetPlayerPed(xp.source)
                if ped and ped ~= 0 and DoesEntityExist(ped) and not pedIsDead(ped) then
                    local pos = GetEntityCoords(ped)
                    if insideRotatedBox(pos, z.coords, z.size, z.rotation) then
                        winners[#winners+1] = xp.source
                    end
                end
            end
            local each = (#winners > 0) and math.floor(z.betPot / #winners) or 0
            for _, src in ipairs(winners) do
                local xp = ESX.GetPlayerFromId(src)
                if xp and each > 0 then
                    xp.addAccountMoney(CFG().Accounts.cash, each)
                    TriggerClientEvent('esx:showNotification', src, ('Laimėjote %s € už zonos mūšį.'):format(each))
                end
            end
        end
    else
        z.next_take_at = math.floor(os.time()) + (z.cooldown or 12) * 3600
    end

    z.betPot = nil
    DGZ().saveZone(z)
    DGZ().broadcastZone(z)
end

local function startTakeover(z, zkey, attackersJob)
    ACTIVE()[zkey] = {
        attackers  = attackersJob,
        remaining  = (z.time or 15) * 60 * 1000,
        deadline   = CFG().Take.pauseDeadlineMs,
        stopped    = false,
        startedAt  = nowMs(),
        emptySince = nil,
        firstSeen  = nil,
        lastNotify = nil
    }
    z.takers = { attackers = attackersJob }
    DGZ().broadcastZone(z)
end

-- ================= TICKER =================
CreateThread(function()
    while true do
        Wait(1000)
        local active = ACTIVE()
        for zkey, tk in pairs(active) do
            local z = CFG().Zones[zkey]
            if not z then
                active[zkey] = nil
            else
                local now = nowMs()
                local sinceStart = now - (tk.startedAt or now)

                local count = attackersCount(z, tk.attackers)

                -- starto grace
                if not tk.firstSeen then
                    if sinceStart < START_GRACE_MS then
                        count = math.max(count, 1)
                    end
                    if count > 0 then
                        tk.firstSeen = now
                    end
                end

                if count <= 0 then
                    if not tk.emptySince then tk.emptySince = now end
                    local emptyFor = now - tk.emptySince
                    local msLeft = CANCEL_IF_EMPTY_FOR_MS - emptyFor
                    local secLeft = math.max(0, math.ceil(msLeft / 1000))

                    if msLeft > 0 then
                        if tk.lastNotify ~= secLeft then
                            tk.lastNotify = secLeft
                            for _, xp in pairs(ESX.GetExtendedPlayers('job', tk.attackers) or {}) do
                                TriggerClientEvent('esx:showNotification', xp.source,
                                    ('Grįžk į zoną per %ds, kitaip užėmimas bus atšauktas.'):format(secLeft))
                            end
                        end
                    end

                    if emptyFor >= CANCEL_IF_EMPTY_FOR_MS then
                        endTakeover(z, zkey, false)
                        active[zkey] = nil
                    else
                        if not tk.stopped then
                            tk.stopped = true
                            broadcastStopped(zkey, true)
                        end
                        tk.deadline = math.max(0, (tk.deadline or CFG().Take.pauseDeadlineMs) - 1000)
                    end
                else
                    tk.emptySince = nil
                    tk.lastNotify = nil
                    if tk.stopped then
                        tk.stopped = false
                        broadcastStopped(zkey, false)
                    end

                    tk.remaining = math.max(0, (tk.remaining or 0) - 1000)
                    if tk.remaining <= 0 then
                        endTakeover(z, zkey, true)
                        active[zkey] = nil
                    else
                        if (tk.deadline or CFG().Take.pauseDeadlineMs) < (CFG().Take.pauseDeadlineMs) then
                            tk.deadline = math.max(0, (tk.deadline or CFG().Take.pauseDeadlineMs) - 1000)
                        end
                    end
                end
            end
        end
    end
end)

-- ================= CALLBACK'ai =================
lib.callback.register('d-gangzones:takingZone', function(src, zkey)
    local tk = ACTIVE()[zkey]
    if not tk then return nil end
    return tk.remaining, tk.deadline, tk.stopped
end)

-- ================= EVENTS =================
RegisterNetEvent('d-gangzones:takeZone', function(title, betEnemyJob, betAmount)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src); if not xPlayer then return end
    local job = xPlayer.job and xPlayer.job.name or nil
    local key = string.lower(title or '')
    local z = CFG().Zones[key]; if not z then return end

    if not CFG().GangsList[job] then return end

    local isOff = CFG().GangsList[job] and CFG().GangsList[job].official or false
    if z.official ~= isOff then
        return TriggerClientEvent('esx:showNotification', src, 'Šią zoną gali imti tik '..(z.official and 'oficialios' or 'neoficialios')..' gaujos.')
    end
    if z.owners and z.owners == job then
        return TriggerClientEvent('esx:showNotification', src, 'Jūsų gauja jau valdo šią zoną.')
    end
    if (z.next_take_at or 0) > math.floor(os.time()) then
        local left = z.next_take_at - math.floor(os.time())
        return TriggerClientEvent('esx:showNotification', src, ('Zonos užėmimo cooldown dar tęsiasi %d s.'):format(left))
    end
    if ACTIVE()[key] then
        return TriggerClientEvent('esx:showNotification', src, 'Zonos užėmimas jau vyksta.')
    end

    -- BETS atvejis
    if z.type == 'bets' then
        local enemyJob = betEnemyJob
        local amount = tonumber(betAmount or 0) or 0
        if not enemyJob or not CFG().GangsList[enemyJob] then
            return TriggerClientEvent('esx:showNotification', src, 'Neteisingai pasirinkta gauja statymui.')
        end
        if amount <= 0 then
            return TriggerClientEvent('esx:showNotification', src, 'Statymo suma turi būti didesnė nei 0.')
        end
        if xPlayer.getAccount(CFG().Accounts.cash).money < amount then
            return TriggerClientEvent('esx:showNotification', src, 'Neturite pakankamai grynųjų statymui.')
        end

        z.pendingBet = { attackers = job, amount = amount, requester = src, requestedAt = nowMs(), target = enemyJob }
        for _, pid in pairs(ESX.GetExtendedPlayers('job', enemyJob) or {}) do
            TriggerClientEvent('d-gangzones:betsZoneActivation', pid.source, key, job, amount)
        end
        return
    end

    startTakeover(z, key, job)
end)

RegisterNetEvent('d-gangzones:acceptedFight', function(zkey)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src); if not xPlayer then return end
    local z = CFG().Zones[zkey]; if not z or not z.pendingBet then return end

    local defenderJob = xPlayer.job.name
    local pending = z.pendingBet
    if defenderJob ~= pending.target then return end

    local reqPlayer = ESX.GetPlayerFromId(pending.requester)
    if not reqPlayer then
        z.pendingBet = nil
        return TriggerClientEvent('esx:showNotification', src, 'Pasiūlęs kovą žaidėjas atsijungė.')
    end
    if reqPlayer.getAccount(CFG().Accounts.cash).money < pending.amount then
        z.pendingBet = nil
        return TriggerClientEvent('esx:showNotification', src, 'Pasiūlęs kovą nebeturi pinigų.')
    end
    if xPlayer.getAccount(CFG().Accounts.cash).money < pending.amount then
        z.pendingBet = nil
        return TriggerClientEvent('esx:showNotification', src, 'Neturite pakankamai pinigų statymui.')
    end

    reqPlayer.removeAccountMoney(CFG().Accounts.cash, pending.amount)
    xPlayer.removeAccountMoney(CFG().Accounts.cash, pending.amount)
    z.betPot = (pending.amount * 2)
    z.pendingBet = nil

    startTakeover(z, zkey, pending.attackers)
end)

RegisterNetEvent('d-gangzones:canceledFight', function(zkey)
    local z = CFG().Zones[zkey]; if not z or not z.pendingBet then return end
    z.pendingBet = nil
end)

AddEventHandler('onResourceStop', function(res)
    if GetCurrentResourceName() ~= res then return end
    local active = ACTIVE()
    for k in pairs(active) do active[k] = nil end
end)
