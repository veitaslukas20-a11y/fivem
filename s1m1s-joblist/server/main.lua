local usingOxMySQL = GetResourceState('oxmysql') == 'started'
local ESX

-- ===== ESX =====
CreateThread(function()
    while not ESX do
        local ok, obj = pcall(function() return exports['es_extended']:getSharedObject() end)
        if ok and obj then ESX = obj end
        Wait(200)
    end
    print('[joblist] ESX attached.')
end)

-- ===== In-memory fallback (jei nėra oxmysql ar DB tuščia) =====
local mem = {
    salaries = {},   -- [job] = { [grade] = {hourly=0, bonus=0} }
    settings = {},   -- [job] = {autopay=false, min_hours=0}
}

-- ===== Helperiai =====
local function isBoss(xPlayer)
    return xPlayer and xPlayer.job and (xPlayer.job.grade_name == 'boss' or xPlayer.job.grade == (#(ESX.Jobs[xPlayer.job.name] and ESX.Jobs[xPlayer.job.name].grades or {}) - 1))
end

local function ensureJobTables(job)
    mem.salaries[job] = mem.salaries[job] or {}
    mem.settings[job] = mem.settings[job] or {autopay=false, min_hours=0}
end

local function fetchSalaries(job, cb)
    ensureJobTables(job)
    if usingOxMySQL then
        exports.oxmysql:execute('SELECT grade, hourly, bonus FROM job_salaries WHERE job = ?', { job }, function(rows)
            local map = {}
            for _, r in ipairs(rows or {}) do
                map[tostring(r.grade)] = { valandinis = tonumber(r.hourly) or 0, premija = tonumber(r.bonus) or 0 }
            end
            -- jei DB tuščia – užpildom nuliais pagal ESX.Jobs
            if not rows or #rows == 0 then
                local jobDef = ESX.Jobs[job]
                if jobDef and jobDef.grades then
                    for g,_ in pairs(jobDef.grades) do
                        map[tostring(g)] = { valandinis = 0, premija = 0 }
                    end
                end
            end
            cb(map)
        end)
    else
        local out = {}
        local jobDef = ESX.Jobs[job]
        if jobDef and jobDef.grades then
            for grade, data in pairs(jobDef.grades) do
                local s = mem.salaries[job][grade]
                out[tostring(grade)] = { valandinis = s and s.hourly or 0, premija = s and s.bonus or 0 }
            end
        end
        cb(out)
    end
end

local function saveSalary(job, grade, hourly, bonus)
    ensureJobTables(job)
    if usingOxMySQL then
        exports.oxmysql:execute('INSERT INTO job_salaries (job, grade, hourly, bonus) VALUES (?, ?, ?, ?) ON DUPLICATE KEY UPDATE hourly = VALUES(hourly), bonus = VALUES(bonus)',
            { job, grade, hourly, bonus })
    else
        mem.salaries[job][grade] = {hourly=hourly, bonus=bonus}
    end
end

local function fetchSettings(job, cb)
    ensureJobTables(job)
    if usingOxMySQL then
        exports.oxmysql:execute('SELECT autopay, min_hours FROM job_settings WHERE job = ? LIMIT 1', { job }, function(rows)
            local s = rows and rows[1]
            if s then
                cb( (s.autopay == 1), tonumber(s.min_hours) or 0 )
            else
                cb(false, 0)
            end
        end)
    else
        local s = mem.settings[job]
        cb(s.autopay or false, s.min_hours or 0)
    end
end

local function saveSettings(job, autopay, min_hours)
    ensureJobTables(job)
    if usingOxMySQL then
        exports.oxmysql:execute('INSERT INTO job_settings (job, autopay, min_hours) VALUES (?, ?, ?) ON DUPLICATE KEY UPDATE autopay = VALUES(autopay), min_hours = VALUES(min_hours)',
            { job, autopay and 1 or 0, min_hours or 0 })
    else
        mem.settings[job].autopay = autopay and true or false
        mem.settings[job].min_hours = tonumber(min_hours) or 0
    end
end

local function notify(src, type, msg)
    TriggerClientEvent('ox_lib:notify', src, {type=type, title='Algalapis', description=msg, duration=5000})
end

-- ===== joblist:getSalaries (grąžina salaries[, autopay, hours]) =====
lib.callback.register('joblist:getSalaries', function(source)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then return {}, false, 0 end
    local job = xPlayer.job.name

    local p = promise.new()
    fetchSalaries(job, function(sals) p:resolve(sals) end)
    local salaries = Citizen.Await(p)

    local p2 = promise.new()
    fetchSettings(job, function(autopay, minHours) p2:resolve({autopay, minHours}) end)
    local st = Citizen.Await(p2)
    local autopay, minHours = st[1], st[2]

    -- Klientas kartais pasiima tik pirmą grąžinimo reikšmę (salaries), o kartais – visas 3.
    return salaries, autopay, minHours
end)

-- ===== joblist:setSalary (tik boss) =====
lib.callback.register('joblist:setSalary', function(source, grade, hourly, bonus)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then return end
    if not isBoss(xPlayer) then
        notify(source, 'error', 'Neturite teisės keisti atlyginimų.')
        return
    end

    hourly = math.max(0, tonumber(hourly) or 0)
    bonus  = math.max(0, tonumber(bonus) or 0)

    saveSalary(xPlayer.job.name, tonumber(grade), hourly, bonus)
    notify(source, 'success', ('Atnaujinta pareigai %s: valandinis %d, premija %d'):format(tostring(grade), hourly, bonus))
end)

-- ===== joblist:setAutoPay / joblist:setMinHours (tik boss) =====
lib.callback.register('joblist:setAutoPay', function(source, enabled)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then return end
    if not isBoss(xPlayer) then
        notify(source, 'error', 'Neturite teisės.')
        return
    end
    local _, minHours = joblist_getSettingsSync(xPlayer.job.name) -- helper žemiau
    saveSettings(xPlayer.job.name, enabled and true or false, minHours)
    notify(source, 'success', 'Automatinis išmokėjimas atnaujintas.')
end)

lib.callback.register('joblist:setMinHours', function(source, hours)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then return end
    if not isBoss(xPlayer) then
        notify(source, 'error', 'Neturite teisės.')
        return
    end
    hours = math.max(0, tonumber(hours) or 0)
    local autopay, _ = joblist_getSettingsSync(xPlayer.job.name)
    saveSettings(xPlayer.job.name, autopay, hours)
    notify(source, 'success', ('Minimalios valandos: %d'):format(hours))
end)

-- sync helper
function joblist_getSettingsSync(job)
    local p = promise.new()
    fetchSettings(job, function(a, h) p:resolve({a,h}) end)
    local st = Citizen.Await(p)
    return st[1], st[2]
end

-- ===== joblist:getList (visų to paties darbo darbuotojų sąrašas) =====
-- Grąžina map'ą: [identifier] = { name=..., label=gradeLabel, grade=grade, job=job }
lib.callback.register('joblist:getList', function(source)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then return {} end
    local job = xPlayer.job.name

    local result = {}

    -- Online žaidėjai
    for _, xp in pairs(ESX.GetExtendedPlayers() or {}) do
        if xp.job and xp.job.name == job then
            local identifier = xp.identifier
            local grade = xp.job.grade
            local label = xp.job.grade_label or (ESX.Jobs[job] and ESX.Jobs[job].grades[grade] and ESX.Jobs[job].grades[grade].label) or ('Grade '..grade)
            result[identifier] = {
                name = xp.getName and xp.getName() or xp.name or identifier,
                label = label,
                grade = grade,
                job = job,
            }
        end
    end

    -- Offline (DB) – optional
    if usingOxMySQL then
        local rows = MySQL.sync.execute or exports.oxmysql.executeSync -- kompat.
        local execSync = exports.oxmysql and exports.oxmysql.executeSync
        local users = execSync and execSync('SELECT identifier, firstname, lastname, job, job_grade FROM users WHERE job = ?', { job }) or {}
        for _, u in ipairs(users or {}) do
            if not result[u.identifier] then
                local grade = tonumber(u.job_grade) or 0
                local label = (ESX.Jobs[job] and ESX.Jobs[job].grades[grade] and ESX.Jobs[job].grades[grade].label) or ('Grade '..grade)
                result[u.identifier] = {
                    name = ((u.firstname or '') .. ' ' .. (u.lastname or '')):gsub('^%s*(.-)%s*$', '%1'),
                    label = label,
                    grade = grade,
                    job = job,
                }
            end
        end
    end

    return result
end)

-- ===== joblist:salary (mokėjimas darbuotojui iš darbdavio meniu) =====
-- Tikimės, kad NUI perduos: data.identifier (gavėjas), data.type ('hourly' arba 'bonus') ir data.amount arba paskaičiuosim iš nustatymų.
lib.callback.register('joblist:salary', function(source, data)
    local xBoss = ESX.GetPlayerFromId(source)
    if not xBoss then return end
    if not isBoss(xBoss) then
        notify(source, 'error', 'Neturite teisės mokėti algų.')
        return
    end

    data = data or {}
    local identifier = data.identifier
    if not identifier then
        notify(source, 'error', 'Nenurodytas darbuotojas.')
        return
    end

    -- Tik online gavėjas (paprastai)
    local target
    for _, xp in pairs(ESX.GetExtendedPlayers() or {}) do
        if xp.identifier == identifier then target = xp break end
    end
    if not target then
        notify(source, 'error', 'Darbuotojas neprisijungęs.')
        return
    end

    if target.job.name ~= xBoss.job.name then
        notify(source, 'error', 'Darbuotojas nedirba jūsų įmonėje.')
        return
    end

    -- Pasiimam nustatymus ir tarifus
    local p = promise.new()
    fetchSalaries(xBoss.job.name, function(sals) p:resolve(sals) end)
    local salaries = Citizen.Await(p)
    local tGrade = tostring(target.job.grade)
    local conf = salaries[tGrade] or {valandinis=0, premija=0}

    local payType = data.type or 'hourly'   -- 'hourly' / 'bonus'
    local amount  = tonumber(data.amount)

    if not amount then
        if payType == 'hourly' then amount = conf.valandinis or 0
        else amount = conf.premija or 0 end
    end
    amount = math.max(0, math.floor(amount))

    if amount <= 0 then
        notify(source, 'error', 'Neteisinga suma.')
        return
    end

    -- Iš „society“ balanso
    local societyAccount
    TriggerEvent('esx_addonaccount:getSharedAccount', ('society_%s'):format(xBoss.job.name), function(acc) societyAccount = acc end)
    if not societyAccount then
        notify(source, 'error', 'Nerasta įmonės sąskaita.')
        return
    end
    if societyAccount.money < amount then
        notify(source, 'error', 'Neužtenka lėšų įmonės sąskaitoje.')
        return
    end

    societyAccount.removeMoney(amount)
    target.addAccountMoney('bank', amount)

    notify(source, 'success', ('Išmokėta %s: $%d'):format(target.getName and target.getName() or identifier, amount))
    notify(target.source, 'success', ('Gavote išmoką: $%d (%s)'):format(amount, payType == 'hourly' and 'Valandinis' or 'Premija'))
end)