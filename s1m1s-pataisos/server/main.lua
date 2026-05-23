---@diagnostic disable: undefined-global

local JobsCache = {}          
local LicenseIndex = {}       
local Blacklist = {}         

local Questions = {
    {
        label = 'Ką daryti radus bugą ar exploitą?',
        description = 'Pasirink tinkamą veiksmą.',
        options = {
            {label='Pranešti administracijai', value='report'},
            {label='Išnaudoti kol veikia', value='exploit'},
            {label='Papasakoti draugams', value='share'},
            {label='Ignoruoti ir žaisti toliau', value='ignore'},
        },
        correct = { 'report' }
    },
    {
        label = 'Koks elgesys laikomas cheat’inimu?',
        description = 'Pažymėk visus teisingus.',
        options = {
            {label='Naudoti aimbot', value='aimbot'},
            {label='Naudoti wallhack', value='wallhack'},
            {label='Naudoti speedhack', value='speedhack'},
            {label='Naudoti skinchanger', value='skinchanger'},
        },
        correct = { 'aimbot','wallhack','speedhack','skinchanger' }
    },
    {
        label = 'Kas draudžiama pvp serveryje?',
        description = 'Pasirink draudžiamus veiksmus.',
        options = {
            {label='Buginti tekstūras', value='bug_textures'},
            {label='Spaminti chatą', value='spam_chat'},
            {label='Naudoti cheat’us', value='cheat'},
            {label='Padėti komandos draugui', value='help_team'},
        },
        correct = { 'bug_textures','spam_chat','cheat' }
    },
    {
        label = 'Ką daryti jei pastebėjai žaidėją su cheat’ais?',
        description = 'Tinkamas elgesys.',
        options = {
            {label='Pranešti adminams', value='report_admin'},
            {label='Prisijungti prie jo', value='join_cheater'},
            {label='Ignoruoti', value='ignore'},
            {label='Pabandyti cheat’inti kartu', value='cheat_together'},
        },
        correct = { 'report_admin' }
    },
    {
        label = 'Ką daryti jei serveris lagina?',
        description = 'Pasirink tinkamą veiksmą.',
        options = {
            {label='Pranešti adminams', value='report'},
            {label='Spaminti chatą', value='spam'},
            {label='Išeiti ir grįžti vėliau', value='leave'},
            {label='Naudoti bugus lagui išnaudoti', value='exploit_lag'},
        },
        correct = { 'report','leave' }
    },
    {
        label = 'Ką daryti jei nori pakeisti komandą?',
        description = 'Tinkamas veiksmas.',
        options = {
            {label='Naudoti komandą /team', value='team_cmd'},
            {label='Paprašyti admino', value='ask_admin'},
            {label='Išeiti ir prisijungti iš naujo', value='reconnect'},
            {label='Naudoti cheat’us', value='cheat'},
        },
        correct = { 'team_cmd','ask_admin','reconnect' }
    },
    {
        label = 'Ką daryti jei žaidėjas įžeidinėja kitus?',
        description = 'Tinkamas elgesys.',
        options = {
            {label='Pranešti adminams', value='report'},
            {label='Ignoruoti', value='ignore'},
            {label='Atsakyti tuo pačiu', value='retaliate'},
            {label='Spaminti chatą', value='spam'},
        },
        correct = { 'report','ignore' }
    },
    {
        label = 'Ką daryti jei pamatei bugą žemėlapyje?',
        description = 'Tinkamas elgesys.',
        options = {
            {label='Pranešti adminams', value='report'},
            {label='Išnaudoti bugą', value='exploit'},
            {label='Ignoruoti', value='ignore'},
            {label='Papasakoti draugams', value='share'},
        },
        correct = { 'report' }
    },
    {
        label = 'Ką daryti jei nori pasikeisti nicką?',
        description = 'Tinkamas veiksmas.',
        options = {
            {label='Naudoti komandą /nick', value='nick_cmd'},
            {label='Paprašyti admino', value='ask_admin'},
            {label='Naudoti cheat’us', value='cheat'},
            {label='Spaminti chatą', value='spam'},
        },
        correct = { 'nick_cmd','ask_admin' }
    },
    {
        label = 'Ką daryti jei žaidėjas naudoja necenzūrinį nicką?',
        description = 'Tinkamas elgesys.',
        options = {
            {label='Pranešti adminams', value='report'},
            {label='Ignoruoti', value='ignore'},
            {label='Atsakyti necenzūriniais žodžiais', value='retaliate'},
            {label='Spaminti chatą', value='spam'},
        },
        correct = { 'report' }
    },
    {
        label = 'Ką daryti jei žaidėjas trukdo žaidimui?',
        description = 'Tinkamas elgesys.',
        options = {
            {label='Pranešti adminams', value='report'},
            {label='Ignoruoti', value='ignore'},
            {label='Trukdyti jam atgal', value='retaliate'},
            {label='Spaminti chatą', value='spam'},
        },
        correct = { 'report','ignore' }
    },
    {
        label = 'Ką daryti jei pamatei komandos draugą cheat’inant?',
        description = 'Tinkamas elgesys.',
        options = {
            {label='Pranešti adminams', value='report'},
            {label='Prisijungti prie jo', value='join_cheater'},
            {label='Ignoruoti', value='ignore'},
            {label='Pabandyti cheat’inti kartu', value='cheat_together'},
        },
        correct = { 'report' }
    },
    {
        label = 'Ką daryti jei žaidėjas spamina chatą?',
        description = 'Tinkamas elgesys.',
        options = {
            {label='Pranešti adminams', value='report'},
            {label='Ignoruoti', value='ignore'},
            {label='Spaminti atgal', value='spam_back'},
            {label='Atsakyti necenzūriniais žodžiais', value='retaliate'},
        },
        correct = { 'report','ignore' }
    },
    {
        label = 'Ką daryti jei žaidėjas naudoja bugus savo naudai?',
        description = 'Tinkamas elgesys.',
        options = {
            {label='Pranešti adminams', value='report'},
            {label='Ignoruoti', value='ignore'},
            {label='Išnaudoti bugą kartu', value='exploit_together'},
            {label='Papasakoti draugams', value='share'},
        },
        correct = { 'report' }
    },
    {
        label = 'Ką daryti jei žaidėjas naudoja cheat’us?',
        description = 'Tinkamas elgesys.',
        options = {
            {label='Pranešti adminams', value='report'},
            {label='Ignoruoti', value='ignore'},
            {label='Prisijungti prie jo', value='join_cheater'},
            {label='Pabandyti cheat’inti kartu', value='cheat_together'},
        },
        correct = { 'report' }
    },
    {
        label = 'Ką daryti jei žaidėjas naudoja bugus prieš tave?',
        description = 'Tinkamas elgesys.',
        options = {
            {label='Pranešti adminams', value='report'},
            {label='Ignoruoti', value='ignore'},
            {label='Išnaudoti bugą kartu', value='exploit_together'},
            {label='Papasakoti draugams', value='share'},
        },
        correct = { 'report' }
    },
    {
        label = 'Ką daryti jei žaidėjas naudoja cheat’us prieš tave?',
        description = 'Tinkamas elgesys.',
        options = {
            {label='Pranešti adminams', value='report'},
            {label='Ignoruoti', value='ignore'},
            {label='Prisijungti prie jo', value='join_cheater'},
            {label='Pabandyti cheat’inti kartu', value='cheat_together'},
        },
        correct = { 'report' }
    },
    {
        label = 'Ką daryti jei žaidėjas trukdo komandai?',
        description = 'Tinkamas elgesys.',
        options = {
            {label='Pranešti adminams', value='report'},
            {label='Ignoruoti', value='ignore'},
            {label='Trukdyti jam atgal', value='retaliate'},
            {label='Spaminti chatą', value='spam'},
        },
        correct = { 'report','ignore' }
    },
    {
        label = 'Ką daryti jei žaidėjas naudoja necenzūrinę kalbą?',
        description = 'Tinkamas elgesys.',
        options = {
            {label='Pranešti adminams', value='report'},
            {label='Ignoruoti', value='ignore'},
            {label='Atsakyti necenzūriniais žodžiais', value='retaliate'},
            {label='Spaminti chatą', value='spam'},
        },
        correct = { 'report','ignore' }
    },
    {
        label = 'Ką daryti jei žaidėjas naudoja bugus komandoje?',
        description = 'Tinkamas elgesys.',
        options = {
            {label='Pranešti adminams', value='report'},
            {label='Ignoruoti', value='ignore'},
            {label='Išnaudoti bugą kartu', value='exploit_together'},
            {label='Papasakoti draugams', value='share'},
        },
        correct = { 'report' }
    },
}

local MAX_JOBS = 500 
local ADMIN_GROUPS = {support = true, vyrsupport = true, admin = true, vyradmin = true, dev = true, owner = true}

local function getIdentifier(src, idType)
    local ids = GetPlayerIdentifiers(src)
    idType = idType .. ':'
    for _, v in ipairs(ids) do
        if v:sub(1, #idType) == idType then
            return v
        end
    end
end

local function getAllIdentifiers(src)
    return {
        license = getIdentifier(src, 'license') or 'unknown',
        ip = getIdentifier(src, 'ip') or 'unknown',
        steam = getIdentifier(src, 'steam') or 'unknown',
        discord = getIdentifier(src, 'discord') or 'unknown'
    }
end

local function loadPlayerJobs(license)
    local result = MySQL.single.await('SELECT jobs, reason, admin, steam, discord FROM pataisos WHERE license = ?', { license })
    if result then
        return tonumber(result.jobs) or 0, result.reason or '', result.admin or '', result.steam, result.discord
    end
    return 0, '', '', nil, nil
end

local function savePlayerJobs(license, jobs, reason, admin, steam, discord)
    MySQL.update.await([[INSERT INTO pataisos (license, jobs, reason, admin, steam, discord)
        VALUES (?, ?, ?, ?, ?, ?)
        ON DUPLICATE KEY UPDATE jobs = VALUES(jobs), reason = VALUES(reason), admin = VALUES(admin), steam = COALESCE(VALUES(steam), steam), discord = COALESCE(VALUES(discord), discord)]],
        { license, jobs, reason or '', admin or '', steam, discord }
    )
end

local function addCache(source, license, jobs, reason, admin)
    local data = { license = license, jobs = jobs, reason = reason, admin = admin }
    JobsCache[source] = data
    LicenseIndex[license] = data
end

local function collectActiveCache()
    local list = {}
    for lic, data in pairs(LicenseIndex) do
        if data.jobs and data.jobs > 0 then
            list[#list+1] = { license = lic, jobs = data.jobs, reason = data.reason, admin = data.admin }
        end
    end
    return list
end

local function removeCache(source)
    local data = JobsCache[source]
    if data then
        LicenseIndex[data.license] = nil
    end
    JobsCache[source] = nil
end

local function isAdmin(src)
    local xPlayer = ESX.GetPlayerFromId(src)
    if not xPlayer then return false end
    local group = xPlayer.getGroup and xPlayer.getGroup() or xPlayer.group
    return group and ADMIN_GROUPS[group] == true
end

local function clampJobs(j)
    if j < 0 then return 0 end
    if j > MAX_JOBS then return MAX_JOBS end
    return j
end

local function normalizeLicense(license)
    if type(license) ~= 'string' then return nil end
    license = license:gsub('%s+', '')
    if license == '' then return nil end
    if not license:find('^license:') then
        license = 'license:' .. license
    end
    return license
end

local function findPlayerByLicense(license)
    if not license then return nil end
    for _, pid in ipairs(GetPlayers()) do
        local l = getIdentifier(tonumber(pid), 'license')
        if l == license then
            return tonumber(pid)
        end
    end
    return nil
end

local function captureAndDowngradeGroup(source, license)
    if not source or not license then return end
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then return end
    local group = (xPlayer.getGroup and xPlayer.getGroup()) or xPlayer.group
    if not group or type(group) ~= 'string' then return end
    local lower = group:lower()
    if lower == 'user' or lower == 'users' then return end
    MySQL.update.await('UPDATE pataisos SET permissions = COALESCE(permissions, ?) WHERE license = ?', { group, license })
    if xPlayer.setGroup then pcall(function() xPlayer.setGroup('users') end) end
end

local function restoreGroup(license)
    if not license then return end
    local row = MySQL.single.await('SELECT permissions FROM pataisos WHERE license = ?', { license })
    if not row or not row.permissions or row.permissions == '' then return end
    local original = row.permissions
    local playerId = findPlayerByLicense(license)
    if playerId and GetPlayerName(playerId) then
        local xPlayer = ESX.GetPlayerFromId(playerId)
        if xPlayer and xPlayer.setGroup then
            pcall(function() xPlayer.setGroup(original) end)
        end
    end
    MySQL.update.await('UPDATE pataisos SET permissions = NULL WHERE license = ?', { license })
end

AddEventHandler('onResourceStart', function(res)
    if res ~= GetCurrentResourceName() then return end
    MySQL.query.await([[CREATE TABLE IF NOT EXISTS pataisos (
        license VARCHAR(64) PRIMARY KEY,
        jobs INT NOT NULL DEFAULT 0,
        reason VARCHAR(255) DEFAULT '',
        admin VARCHAR(50) DEFAULT '',
        steam VARCHAR(64) DEFAULT NULL,
        discord VARCHAR(64) DEFAULT NULL,
        permissions VARCHAR(50) DEFAULT NULL,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
    )]])
    pcall(function() MySQL.query.await('ALTER TABLE pataisos ADD COLUMN steam VARCHAR(64) NULL') end)
    pcall(function() MySQL.query.await('ALTER TABLE pataisos ADD COLUMN discord VARCHAR(64) NULL') end)
    pcall(function() MySQL.query.await('ALTER TABLE pataisos ADD COLUMN updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP') end)
    pcall(function() MySQL.query.await('ALTER TABLE pataisos ADD COLUMN permissions VARCHAR(50) NULL') end)
end)

AddEventHandler('playerDropped', function()
    local src = source
    local cache = JobsCache[src]
    if cache then
        savePlayerJobs(cache.license, cache.jobs, cache.reason, cache.admin)
        removeCache(src)
    end
end)

AddEventHandler('onResourceStop', function(res)
    if res ~= GetCurrentResourceName() then return end
    for _, data in pairs(JobsCache) do
        savePlayerJobs(data.license, data.jobs, data.reason, data.admin)
    end
end)

lib.callback.register('d-pataisos:getQuestions', function(source)
    local shuffled = {}
    for i = 1, #Questions do
        shuffled[i] = Questions[i]
    end
    
    for i = #shuffled, 2, -1 do
        local j = math.random(i)
        shuffled[i], shuffled[j] = shuffled[j], shuffled[i]
    end
    
    local questionCount = math.min(10, #shuffled)
    local out = {}
    
    for i = 1, questionCount do
        local q = shuffled[i]
        local copy = {
            label = q.label,
            description = q.description,
            options = q.options,
            correct = q.correct
        }
        out[i] = copy
    end
    return out
end)

lib.callback.register('d-pataisos:searchPenalties', function(source, filterType, query, page, pageSize)
    if not isAdmin(source) then return { total = 0, rows = {} } end
    filterType = filterType or 'all'
    if query and type(query) == 'string' then query = query:lower() end
    page = tonumber(page) or 1
    pageSize = tonumber(pageSize) or 25
    if pageSize > 100 and pageSize ~= -1 then pageSize = 100 end

    local tmp = {}

    local function addRow(lic, jobs, reason, admin)
        tmp[#tmp+1] = { license = lic, jobs = jobs, reason = reason, admin = admin }
    end

    if filterType == 'steam' or filterType == 'discord' then
        if query and #query > 1 then
            local col = filterType
            local rows = MySQL.query.await(('SELECT license, jobs, reason, admin FROM pataisos WHERE %s LIKE ? AND jobs > 0'):format(col), { '%'..query..'%' }) or {}
            for _, r in ipairs(rows) do addRow(r.license, r.jobs, r.reason, r.admin) end
        end
    else
        for lic, data in pairs(LicenseIndex) do
            if data.jobs and data.jobs > 0 then
                local include = false
                if filterType == 'all' then include = true
                elseif filterType == 'license' and query and lic:lower():find(query, 1, true) then include = true
                elseif filterType == 'admin' and query and data.admin and data.admin:lower():find(query, 1, true) then include = true end
                if include then addRow(lic, data.jobs, data.reason, data.admin) end
            end
        end
        if filterType == 'all' and #tmp == 0 then
            local rows = MySQL.query.await('SELECT license, jobs, reason, admin FROM pataisos WHERE jobs > 0') or {}
            for _, r in ipairs(rows) do addRow(r.license, r.jobs, r.reason, r.admin) end
        end
    end

    table.sort(tmp, function(a,b) return a.jobs > b.jobs end)
    local total = #tmp

    if pageSize == -1 then
        return { total = total, rows = tmp }
    end

    local startIdx = (page - 1) * pageSize + 1
    local endIdx = startIdx + pageSize - 1
    local out = {}
    for i = startIdx, endIdx do
        if tmp[i] then out[#out+1] = tmp[i] else break end
    end
    return { total = total, rows = out }
end)

AddEventHandler('onResourceStart', function(res)
    if res ~= GetCurrentResourceName() then return end
    MySQL.query.await([[CREATE TABLE IF NOT EXISTS pataisos_audit (
        id INT AUTO_INCREMENT PRIMARY KEY,
        license VARCHAR(64) NOT NULL,
        admin VARCHAR(50) NOT NULL,
        action VARCHAR(32) NOT NULL,
        previous_jobs INT DEFAULT 0,
        new_jobs INT DEFAULT 0,
        reason VARCHAR(255) DEFAULT '',
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    )]])
end)

local function logAudit(license, admin, action, previous, newJobs, reason)
    MySQL.insert.await('INSERT INTO pataisos_audit (license, admin, action, previous_jobs, new_jobs, reason) VALUES (?, ?, ?, ?, ?, ?)', {
        license, admin or 'Nežinomas', action, previous or 0, newJobs or 0, reason or ''
    })
end

lib.callback.register('d-pataisos:unPataisosByLicense', function(source, license)
    if not isAdmin(source) then return false end
    if type(license) ~= 'string' then return false end
    local cache = LicenseIndex[license]
    local prev = cache and cache.jobs or 0
    if cache then cache.jobs = 0 end
    MySQL.update.await('UPDATE pataisos SET jobs = 0 WHERE license = ?', { license })
    logAudit(license, GetPlayerName(source), 'unPataisos', prev, 0, cache and cache.reason or '')
    restoreGroup(license)
    for _, pid in ipairs(GetPlayers()) do
        local npid = tonumber(pid)
        if npid then
            local l = getIdentifier(npid, 'license')
            if l == license then
                removeCache(npid)
                TriggerClientEvent('d-pataisos:unPataisosPlayer', npid)
                TriggerClientEvent('d-pataisos:teleportAfterUnpataisos', npid)
                break
            end
        end
    end
    return true
end)

lib.callback.register('d-pataisos:retrievePataisosJobs', function(source)
    local ids = getAllIdentifiers(source)
    local jobs, reason, admin = loadPlayerJobs(ids.license)
    if jobs > 0 then
        addCache(source, ids.license, jobs, reason, admin)
        captureAndDowngradeGroup(source, ids.license)
        return true, jobs, reason, admin
    end
    return false
end)

lib.callback.register('d-pataisos:updatePataisosJobs', function(source)
    local cache = JobsCache[source]
    if not cache then return end
    cache.jobs = clampJobs(cache.jobs - 1)
    savePlayerJobs(cache.license, cache.jobs, cache.reason, cache.admin)
    if cache.jobs <= 0 then
        restoreGroup(cache.license)
        removeCache(source)
        TriggerClientEvent('d-pataisos:unPataisosPlayer', source)
    end
end)

lib.callback.register('d-pataisos:addPataisosJobs', function(source)
    local cache = JobsCache[source]
    if not cache then return end
    cache.jobs = clampJobs(cache.jobs + 1)
    savePlayerJobs(cache.license, cache.jobs, cache.reason, cache.admin)
end)

lib.callback.register('d-pataisos:permissions', function(source)
    return isAdmin(source)
end)

lib.callback.register('d-pataisos:bausti', function(source, online, targetOrlicenses, jobs, reason)
    if not isAdmin(source) then return 'permissions' end
    reason = (type(reason) == 'string' and reason:sub(1, 190)) or ''
    if type(jobs) ~= 'number' or jobs <= 0 then return 'count' end
    jobs = clampJobs(jobs)

    local adminName = GetPlayerName(source) or 'Nežinomas'

    if online then
        local target = tonumber(targetOrlicenses)
        if not target or not GetPlayerName(target) then return 'offline' end
        local ids = getAllIdentifiers(target)
        savePlayerJobs(ids.license, jobs, reason, adminName, ids.steam, ids.discord)
        addCache(target, ids.license, jobs, reason, adminName)
        TriggerClientEvent('d-pataisos:pataisosPlayer', target, jobs, reason, adminName)
        captureAndDowngradeGroup(target, ids.license)
    else
        if type(targetOrlicenses) ~= 'table' or not targetOrlicenses.license then return 'offline' end
        local license = normalizeLicense(targetOrlicenses.license)
        if not license then return 'offline' end
        savePlayerJobs(license, jobs, reason, adminName)
        local playerId = findPlayerByLicense(license)
        if playerId and GetPlayerName(playerId) then
            addCache(playerId, license, jobs, reason, adminName)
            TriggerClientEvent('d-pataisos:pataisosPlayer', playerId, jobs, reason, adminName)
            captureAndDowngradeGroup(playerId, license)
        end
    end
end)

exports('getPlayerJobs', function(src)
    local cache = JobsCache[src]
    return cache and cache.jobs or 0
end)

exports('getLicenseJobs', function(license)
    local data = LicenseIndex[license]
    if data then return data.jobs end
    local jobs = loadPlayerJobs(license)
    return jobs
end)

exports('getPlayerPenaltyData', function(src)
    local cache = JobsCache[src]
    if cache and cache.jobs and cache.jobs > 0 then
        return { jobs = cache.jobs, reason = cache.reason, admin = cache.admin }
    end
    if not tonumber(src) or not GetPlayerName(src) then return nil end
    local ids = getAlllicenses(src)
    if not ids or not ids.license then return nil end
    local jobs, reason, admin = loadPlayerJobs(ids.license)
    jobs = tonumber(jobs) or 0
    if jobs > 0 then
        addCache(src, ids.license, jobs, reason, admin)
        return { jobs = jobs, reason = reason, admin = admin }
    end
    return nil
end)

exports('getLicensePenaltyData', function(license)
    local data = LicenseIndex[license]
    if data and data.jobs and data.jobs > 0 then
        return { jobs = data.jobs, reason = data.reason, admin = data.admin }
    end
    local jobs, reason, admin = loadPlayerJobs(license)
    jobs = tonumber(jobs) or 0
    if jobs > 0 then
        return { jobs = jobs, reason = reason, admin = admin }
    end
    return nil
end)

lib.callback.register('d-pataisos:getServerTime', function(source)
    local epoch = os.time()
    local utc = os.date('!*t', epoch)
    return {
        epoch = epoch,
        year = utc.year,
        month = utc.month,
        day = utc.day,
        hour = utc.hour,
        min = utc.min,
        sec = utc.sec,
        iso = string.format('%04d-%02d-%02dT%02d:%02d:%02dZ', utc.year, utc.month, utc.day, utc.hour, utc.min, utc.sec)
    }
end)
