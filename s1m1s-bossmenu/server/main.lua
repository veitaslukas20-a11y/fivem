
-- s1m1s-bossmenu/server/main.lua (FIXED)
local ESX = exports['es_extended']:getSharedObject()

-- ==========================
-- Utils
-- ==========================
local SocietyAccounts = {}        -- cache esx_addonaccount
local SoftBalance     = {}        -- [job] = { amount, expiresMs }  (soft cache)

local function NormalizeJobArg(source, jobArg)
    -- leidžiam: nil, "police", "society_police", {name="police"}
    local job
    if type(jobArg) == 'table' then
        job = jobArg.name
    elseif type(jobArg) == 'string' then
        job = jobArg
    end
    if not job or job == '' then
        local x = ESX.GetPlayerFromId(source)
        job = (x and x.job and x.job.name) or 'unemployed'
    end
    job = tostring(job)
    if job:sub(1,8) == 'society_' then job = job:sub(9) end
    return job
end

local function GetSocietyAccount(jobName)
    if not jobName or jobName == '' then return nil end
    if not SocietyAccounts[jobName] then
        local done = false
        TriggerEvent('esx_addonaccount:getSharedAccount', 'society_' .. jobName, function(account)
            SocietyAccounts[jobName] = account
            done = true
        end)
        local timeout = GetGameTimer() + 2000
        while not done and GetGameTimer() < timeout do Wait(10) end
    end
    return SocietyAccounts[jobName]
end

local function SocietyBalance(acc)
    if not acc then return 0 end
    if type(acc.getMoney) == 'function' then
        local ok, val = pcall(acc.getMoney, acc)
        if ok and type(val) == 'number' then return val end
    end
    return tonumber(acc.money) or 0
end

local function SetSoftBalance(job, amount, ttlMs)
    SoftBalance[job] = { amount = amount, expiresMs = GetGameTimer() + (ttlMs or 15000) } -- 15s
end

local function GetEffectiveBalance(job, acc)
    local s = SoftBalance[job]
    if s and GetGameTimer() <= s.expiresMs then
        return s.amount
    end
    SoftBalance[job] = nil
    return SocietyBalance(acc)
end

local function SanitizeAmount(a)
    if type(a) == 'string' then
        a = a:gsub('[^%d%.,%-]', ''):gsub(',', '.')
    end
    local n = tonumber(a) or 0
    if n < 0 then n = 0 end
    return math.floor(n + 0.5)
end

local function PlayersWithJob(jobName)
    local out, list = {}, ESX.GetPlayers()
    for i = 1, #list do
        local xP = ESX.GetPlayerFromId(list[i])
        if xP and xP.job and xP.job.name == jobName then out[#out+1] = list[i] end
    end
    return out
end

local function Broadcast(job, newBal)
    local ids = PlayersWithJob(job)
    for i = 1, #ids do
        local id = ids[i]
        TriggerClientEvent('d-bosmenu:balanceUpdated', id, job, newBal)
        TriggerClientEvent('d-bosmenu:forceRefresh',  id, job)
    end
end

local function ApplyAccountMoneyLocal(acc, newBal)
    -- kad acc objekte iškart matytųsi nauja suma (kai kurie build'ai rodo tik iš .money)
    if type(acc.setMoney) == 'function' then
        pcall(acc.setMoney, acc, newBal)
    else
        acc.money = newBal
    end
end

-- ===== Helper: universalus darbuotojo resolveris
local function ResolveEmployeeAny(arg)
    local function getId(x) return x and (x.identifier or (x.getIdentifier and x:getIdentifier())) or nil end
    local function norm(s) s=tostring(s or '') return s:gsub('%s+',' '):gsub('^%s+',''):gsub('%s+$',''):lower() end

    -- jei ateina objektas iš UI
    if type(arg) == 'table' then
        local ident = arg.identifier or arg.license or arg.identifier2
        local sid   = arg.id or arg.source or arg.playerId
        local name  = arg.name or arg.label
        if sid then
            local x = ESX.GetPlayerFromId(tonumber(sid))
            if x then return { identifier=getId(x), name=x.getName(), online=true, source=tonumber(sid) } end
        end
        if ident then
            -- online pagal identifier
            for _, id in ipairs(ESX.GetPlayers()) do
                local x = ESX.GetPlayerFromId(id)
                if x and getId(x) == ident then
                    return { identifier=getId(x), name=x.getName(), online=true, source=id }
                end
            end
            -- offline pagal DB
            local row = MySQL.single.await('SELECT identifier, firstname, lastname FROM users WHERE identifier = ? LIMIT 1', { ident })
            if row then return { identifier=row.identifier, name=(row.firstname or 'Nežinomas')..' '..(row.lastname or ''), online=false } end
        end
        if name then arg = name else arg = tostring(sid or '') end
    end

    -- dabar arg – string/number
    local pn = tostring(arg or '')

    -- 1) server ID
    do
        local asNum = tonumber(pn)
        if asNum then
            local x = ESX.GetPlayerFromId(asNum)
            if x then return { identifier=getId(x), name=x.getName(), online=true, source=asNum } end
        end
    end

    -- 2) pilnas identifier
    if pn:find(':', 1, true) then
        for _, id in ipairs(ESX.GetPlayers()) do
            local x = ESX.GetPlayerFromId(id)
            if x and getId(x) == pn then
                return { identifier=getId(x), name=x.getName(), online=true, source=id }
            end
        end
        local row = MySQL.single.await('SELECT identifier, firstname, lastname FROM users WHERE identifier = ? LIMIT 1', { pn })
        if row then return { identifier=row.identifier, name=(row.firstname or 'Nežinomas')..' '..(row.lastname or ''), online=false } end
    end

    -- 3) online pagal vardą
    local target = norm(pn)
    if target ~= '' then
        for _, id in ipairs(ESX.GetPlayers()) do
            local x = ESX.GetPlayerFromId(id)
            if x and x.getName and norm(x.getName()) == target then
                return { identifier=getId(x), name=x.getName(), online=true, source=id }
            end
        end
    end

    -- 4) offline pagal vardą (tikslus ir dalinis)
    do
        local f,l = pn:match('^%s*(%S+)%s+(.*%S)%s*$')
        local row
        if f and l then
            row = MySQL.single.await('SELECT identifier, firstname, lastname FROM users WHERE LOWER(firstname)=LOWER(?) AND LOWER(lastname)=LOWER(?) LIMIT 1', { f, l })
        end
        if not row and pn ~= '' then
            row = MySQL.single.await('SELECT identifier, firstname, lastname FROM users WHERE LOWER(CONCAT(firstname, " ", lastname))=LOWER(?) LIMIT 1', { pn })
        end
        if not row and pn ~= '' then
            row = MySQL.single.await('SELECT identifier, firstname, lastname FROM users WHERE firstname LIKE ? OR lastname LIKE ? LIMIT 1', { '%'..pn..'%', '%'..pn..'%' })
        end
        if row then
            return { identifier=row.identifier, name=(row.firstname or 'Nežinomas')..' '..(row.lastname or ''), online=false }
        end
    end

    return nil
end

-- ==========================
-- BALANCE (callbacks)
-- ==========================

-- getAccountMoney
lib.callback.register('d-bosmenu:getAccountMoney', function(source, job)
    job = NormalizeJobArg(source, job)
    local acc = GetSocietyAccount(job)
    return GetEffectiveBalance(job, acc)
end)

-- deposit
lib.callback.register('d-bosmenu:importMoney', function(source, amount, accountType)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then return { success=false, message='Žaidėjas nerastas.' } end

    local job = NormalizeJobArg(source, xPlayer and xPlayer.job and xPlayer.job.name)
    amount = SanitizeAmount(amount)
    if amount <= 0 then return { success=false, message='Netinkama suma.' } end

    accountType = accountType or 'money'
    local accData = xPlayer.getAccount(accountType)
    if not accData then return { success=false, message='Netinkamas sąskaitos tipas.' } end

    local society = GetSocietyAccount(job)
    if not society then return { success=false, message='Darbo fondas nerastas.' } end

    if accData.money < amount then
        xPlayer.showNotification('Neturite pakankamai pinigų.')
        return { success=false, message='Trūksta pinigų.', balance = GetEffectiveBalance(job, society) }
    end

    local oldBal = GetEffectiveBalance(job, society)
    xPlayer.removeAccountMoney(accountType, amount)
    society.addMoney(amount)

    local newBal = oldBal + amount
    SetSoftBalance(job, newBal)
    ApplyAccountMoneyLocal(society, newBal)

    xPlayer.showNotification(('Įdėjote %s€ į darbo fondą. Dabar: %s€'):format(amount, newBal))
    Broadcast(job, newBal)

    return { success=true, balance=newBal }
end)

-- withdraw
lib.callback.register('d-bosmenu:takeMoney', function(source, amount, accountType)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then return { success=false, message='Žaidėjas nerastas.' } end

    local job = NormalizeJobArg(source, xPlayer and xPlayer.job and xPlayer.job.name)
    amount = SanitizeAmount(amount)
    if amount <= 0 then return { success=false, message='Netinkama suma.' } end

    accountType = accountType or 'money'

    local society = GetSocietyAccount(job)
    if not society then return { success=false, message='Darbo fondas nerastas.' } end

    local oldBal = GetEffectiveBalance(job, society)
    if oldBal < amount then
        xPlayer.showNotification(('Fonde nėra pakankamai pinigų. Dabar: %s€'):format(oldBal))
        return { success=false, message='Fonde trūksta pinigų.', balance=oldBal }
    end

    society.removeMoney(amount)
    local newBal = oldBal - amount
    if newBal < 0 then newBal = 0 end
    SetSoftBalance(job, newBal)
    ApplyAccountMoneyLocal(society, newBal)

    xPlayer.addAccountMoney(accountType, amount)
    xPlayer.showNotification(('Išėmėte %s€. Liko fonde: %s€'):format(amount, newBal))
    Broadcast(job, newBal)

    return { success=true, balance=newBal }
end)

-- salary (FIX: naudoja ResolveEmployeeAny ir veikia su table/string/id)
lib.callback.register('d-bosmenu:giveSalary', function(source, playerRef, amount)
    local xBoss = ESX.GetPlayerFromId(source)
    if not xBoss or not xBoss.job then return { success=false, message='Bosą neradau' } end

    local job = NormalizeJobArg(source, xBoss.job.name)
    amount = SanitizeAmount(amount)
    if amount <= 0 then return { success=false, message='Netinkama suma' } end

    local society = GetSocietyAccount(job)
    if not society then return { success=false, message='Darbo fondas nerastas' } end

    local oldBal = GetEffectiveBalance(job, society)
    if oldBal < amount then
        xBoss.showNotification(('Fonde trūksta pinigų (%s€ / reik %s€)'):format(oldBal, amount))
        return { success=false, message='Trūksta pinigų', balance=oldBal }
    end

    local employee = ResolveEmployeeAny(playerRef)
    if not employee then
        xBoss.showNotification('Darbuotojas nerastas.')
        return { success=false, message='Darbuotojas nerastas', balance=oldBal }
    end

    society.removeMoney(amount)
    local newBal = oldBal - amount
    if newBal < 0 then newBal = 0 end
    SetSoftBalance(job, newBal)
    ApplyAccountMoneyLocal(society, newBal)

    if employee.online and employee.source then
        local xTarget = ESX.GetPlayerFromId(employee.source)
        if xTarget then
            xTarget.addAccountMoney('bank', amount)
            if xTarget.showNotification then xTarget.showNotification(('Jūs gavote algą: %s€'):format(amount)) end
        end
    elseif employee.identifier then
        MySQL.update.await('UPDATE users SET bank = bank + ? WHERE identifier = ?', {amount, employee.identifier})
    end

    xBoss.showNotification(('Išmokėjote %s€ %s. Liko fonde: %s€'):format(amount, employee.name or 'darbuotojui', newBal))
    Broadcast(job, newBal)

    return { success=true, balance=newBal }
end)

-- ==========================
-- Employees
-- ==========================
lib.callback.register('d-bosmenu:getNames', function(source, nearby)
    local Players = {}
    for _, v in pairs(nearby or {}) do
        local xP = ESX.GetPlayerFromId(v.id)
        if xP then Players[#Players+1] = { id=v.id, name=xP.getName() } end
    end
    return Players
end)

lib.callback.register('d-bosmenu:addEmployee', function(source, targetId)
    local xBoss   = ESX.GetPlayerFromId(source)
    local xTarget = ESX.GetPlayerFromId(targetId)

    if not xBoss or not xTarget then
        return { success=false, message='Žaidėjas nerastas arba atsijungęs.' }
    end

    if source == targetId then
        return { success=false, message='Negalite įdarbinti savęs.' }
    end

    local jobName = xBoss.job and xBoss.job.name
    if not jobName then
        return { success=false, message='Nepavyko nustatyti direktoriaus darbo.' }
    end

    if (xBoss.job.grade_name or '') ~= 'boss' then
        return { success=false, message='Jūs nesate šio darbo direktorius.' }
    end

    if ESX.DoesJobExist and not ESX.DoesJobExist(jobName, 0) then
        return { success=false, message=('Darbas "%s" neegzistuoja arba neturi 0 rango.'):format(jobName) }
    end

    xTarget.setJob(jobName, 0)

    local identifier = xTarget.identifier or (xTarget.getIdentifier and xTarget:getIdentifier()) or nil
    if identifier then
        MySQL.update.await(
            'UPDATE users SET job = ?, job_grade = ? WHERE identifier = ?',
            { jobName, 0, identifier }
        )
    end

    xBoss.showNotification(('Įdarbinote %s į darbą: %s'):format(xTarget.getName(), jobName))
    xTarget.showNotification(('Jus įdarbino į darbą: %s!'):format(jobName))

    Citizen.SetTimeout(300, function()
        for _, id in ipairs(PlayersWithJob(jobName)) do
            TriggerClientEvent('d-bosmenu:forceRefresh', id, jobName)
        end
    end)

    return { success=true, message=('Darbuotojas %s įdarbintas į darbą "%s"'):format(xTarget.getName(), jobName) }
end)

lib.callback.register('d-bosmenu:getEmployees', function(source)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer or not xPlayer.job then return {} end

    local job = xPlayer.job.name
    local jobData = ESX.Jobs and ESX.Jobs[job] or nil

    -- FIX: NEBEBREAK'inam kai nėra ESX.Jobs[job]; grąžinam sąrašą su generiniais label'ais
    local employees = MySQL.query.await('SELECT identifier, firstname, lastname, job, job_grade FROM users WHERE job = ?', {job}) or {}
    local online = PlayersWithJob(job)
    local onlineById = {}

    for _, pid in ipairs(online) do
        local xP = ESX.GetPlayerFromId(pid)
        if xP and xP.identifier then onlineById[xP.identifier] = xP end
    end

    local jobGrades = (jobData and jobData.grades) or {}
    local result = {}

    for _, v in ipairs(employees) do
        local gradeKey   = tostring(v.job_grade or 0)
        local gradeLabel = (jobGrades[gradeKey] and jobGrades[gradeKey].label) or ('Laipsnis ' .. (v.job_grade or 0))
        result[#result+1] = {
            identifier = v.identifier,
            name  = (v.firstname or 'Nežinomas') .. ' ' .. (v.lastname or ''),
            job   = v.job,
            grade = gradeLabel,
            grade_id = v.job_grade or 0,
            online = onlineById[v.identifier] and true or false
        }
        onlineById[v.identifier] = nil
    end

    for identifier, xP in pairs(onlineById) do
        local g = xP.job.grade or 0
        local gradeKey   = tostring(g)
        local gradeLabel = (jobGrades[gradeKey] and jobGrades[gradeKey].label) or ('Laipsnis ' .. g)
        result[#result+1] = {
            identifier = identifier,
            name  = xP.getName(),
            job   = job,
            grade = gradeLabel,
            grade_id = g,
            online = true
        }
    end

    return result
end)

lib.callback.register('d-bosmenu:returnGrades', function(source)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer or not xPlayer.job then return {} end
    local job = xPlayer.job.name
    local out, jobDef = {}, ESX.Jobs[job]
    if jobDef and jobDef.grades then
        for grade, data in pairs(jobDef.grades) do
            out[grade] = { label = data.label or ('Grade '..grade), grade = grade }
        end
    end
    return out
end)

lib.callback.register('d-bosmenu:getEmployeeInfo', function(source, player)
    return {
        bills = math.random(0, 15),
        bills_money = math.random(100, 2000),
        hours = math.random(1, 20),
        minutes = math.random(0, 59),
        healed = math.random(0, 5)
    }
end)

-- ===== PATAISYTAS: keitimas (paaukštinimas)
lib.callback.register('d-bosmenu:changeGrade', function(source, playerRef, grade)
    local xBoss = ESX.GetPlayerFromId(source)
    if not xBoss or not xBoss.job then return false end
    if (xBoss.job.grade_name or '') ~= 'boss' then return false end

    local jobName = xBoss.job.name
    local g = tonumber(grade or 0) or 0

    local gradeOk = true
    if ESX.DoesJobExist then
        gradeOk = ESX.DoesJobExist(jobName, g)
    else
        local jd = ESX.Jobs and ESX.Jobs[jobName]
        gradeOk = jd and jd.grades and jd.grades[tostring(g)] ~= nil
    end
    if not gradeOk then
        if xBoss.showNotification then xBoss.showNotification(('Neteisingas rangas: %s'):format(g)) end
        return false
    end

    local emp = ResolveEmployeeAny(playerRef)
    if not emp then
        if xBoss.showNotification then xBoss.showNotification('Darbuotojas nerastas.') end
        return false
    end

    if emp.online and emp.source then
        local xTarget = ESX.GetPlayerFromId(emp.source)
        if xTarget then
            xTarget.setJob(jobName, g)
            if xTarget.showNotification then xTarget.showNotification(('Jūsų pareigos pakeistos į laipsnį %s'):format(g)) end
        end
    end

    if emp.identifier then
        MySQL.update.await('UPDATE users SET job = ?, job_grade = ? WHERE identifier = ?', { jobName, g, emp.identifier })
    end

    Citizen.SetTimeout(200, function()
        for _, id in ipairs(PlayersWithJob(jobName)) do
            TriggerClientEvent('d-bosmenu:forceRefresh', id, jobName)
        end
    end)

    if xBoss.showNotification then xBoss.showNotification(('Pakeitėte %s pareigas į laipsnį %s'):format(emp.name or emp.identifier or 'darbuotoją', g)) end
    return true
end)

-- ===== PATAISYTA: atleidimas (veikia su table/string/id)
lib.callback.register('d-bosmenu:unemployePlayer', function(source, playerRef)
    local xBoss = ESX.GetPlayerFromId(source)
    if not xBoss then return false end

    local emp = ResolveEmployeeAny(playerRef)
    if not emp then
        if xBoss.showNotification then xBoss.showNotification('Darbuotojas nerastas.') end
        return false
    end

    local oldJob = emp.job
    if not oldJob and emp.identifier then
        local row = MySQL.single.await('SELECT job FROM users WHERE identifier = ?', { emp.identifier })
        oldJob = row and row.job or nil
    end

    if emp.online and emp.source then
        local xTarget = ESX.GetPlayerFromId(emp.source)
        if xTarget then
            xTarget.setJob('unemployed', 0)
            if xTarget.showNotification then xTarget.showNotification('Buvote atleistas iš darbo.') end
        end
    end

    if emp.identifier then
        MySQL.update.await('UPDATE users SET job = ?, job_grade = ? WHERE identifier = ?', {'unemployed', 0, emp.identifier})
    end

    Citizen.SetTimeout(200, function()
        if oldJob then
            for _, id in ipairs(PlayersWithJob(oldJob)) do
                TriggerClientEvent('d-bosmenu:forceRefresh', id, oldJob)
            end
        end
    end)

    if xBoss.showNotification then xBoss.showNotification(('Atleidote darbuotoją: %s'):format(emp.name or '')) end
    return true
end)

AddEventHandler('onResourceStart', function(res)
    if res == GetCurrentResourceName() then
        print('^2[s1m1s-bossmenu]^7 server callbacks registered (normalize + soft balance + local set).')
    end
end)