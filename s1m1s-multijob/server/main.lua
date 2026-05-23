local ESX = exports["es_extended"]:getSharedObject()
local oxmysql = exports.oxmysql

local playerJobs = {}
local JobLabels = {}
local GradeLabels = {}

-- ===== SQL lentelė (unikalus indeksas REPLACE'ui) =====
AddEventHandler('onResourceStart', function(res)
    if res ~= GetCurrentResourceName() then return end
    oxmysql:executeSync([[
        CREATE TABLE IF NOT EXISTS `multijob_jobs` (
            `identifier` VARCHAR(64) NOT NULL,
            `job`        VARCHAR(50) NOT NULL,
            `grade`      INT NOT NULL DEFAULT 0,
            PRIMARY KEY (`identifier`,`job`)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
    ]], {})
end)

-- Užkrauname visus darbų pavadinimus ir rangus iš DB
CreateThread(function()
    local jobs = oxmysql:executeSync('SELECT name, label FROM jobs', {})
    for _, v in pairs(jobs or {}) do JobLabels[v.name] = v.label end

    local grades = oxmysql:executeSync('SELECT job_name, grade, label FROM job_grades', {})
    for _, v in pairs(grades or {}) do
        if not GradeLabels[v.job_name] then GradeLabels[v.job_name] = {} end
        GradeLabels[v.job_name][tonumber(v.grade)] = v.label
    end
end)

-- Pilnas job label
local function GetFullJobLabel(job, grade)
    if job == 'unemployed' then return 'Bedarbis' end
    local jobLabel = JobLabels[job] or (ESX.Jobs[job] and ESX.Jobs[job].label) or string.upper(job)
    local gradeLabel = (GradeLabels[job] and GradeLabels[job][grade]) or ('Rangas ' .. tostring(grade))
    return ("%s - %s"):format(jobLabel, gradeLabel)
end

local function hasJobInCache(identifier, job)
    local list = playerJobs[identifier] or {}
    for _, v in ipairs(list) do
        if v.job == job then return true end
    end
    return false
end

local function addJobToCache(identifier, job, grade)
    playerJobs[identifier] = playerJobs[identifier] or {}
    -- update if exists
    for _, v in ipairs(playerJobs[identifier]) do
        if v.job == job then
            v.grade = grade
            v.job_label = GetFullJobLabel(job, grade)
            return
        end
    end
    table.insert(playerJobs[identifier], {job=job, grade=grade, job_label=GetFullJobLabel(job, grade)})
end

local function removeJobFromCache(identifier, job)
    local list = playerJobs[identifier]
    if not list then return end
    for i = #list, 1, -1 do
        if list[i].job == job then
            table.remove(list, i)
        end
    end
end

-- Užkrauti žaidėjo job’us prisijungus
AddEventHandler('esx:playerLoaded', function(playerId, xPlayer)
    local identifier = xPlayer.getIdentifier()
    playerJobs[identifier] = {}

    local rows = oxmysql:executeSync('SELECT job, grade FROM multijob_jobs WHERE identifier = ?', {identifier}) or {}
    if #rows == 0 then
        local jobName, grade = xPlayer.job.name, xPlayer.job.grade
        addJobToCache(identifier, jobName, grade)
        oxmysql:executeSync('REPLACE INTO multijob_jobs (identifier, job, grade) VALUES (?, ?, ?)', {identifier, jobName, grade})
    else
        for _, v in pairs(rows) do
            addJobToCache(identifier, v.job, v.grade)
        end
    end
end)

-- Callback: gauti žaidėjo job’us
lib.callback.register('d-multijob:getJobs', function(source)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then return {} end
    local identifier = xPlayer.getIdentifier()
    playerJobs[identifier] = playerJobs[identifier] or {}
    -- atnaujinam labelius (jei DB labeliai pasikeitė)
    for _, v in ipairs(playerJobs[identifier]) do
        v.job_label = GetFullJobLabel(v.job, v.grade)
    end
    return playerJobs[identifier]
end)

-- Callback: setJob (leidžiame tik į savo sąraše esantį job'ą arba 'unemployed')
lib.callback.register('d-multijob:setJob', function(source, data)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer or not data or not data.job then return false end
    local job  = tostring(data.job)
    local grade = tonumber(data.grade) or 0

    if job ~= 'unemployed' and not hasJobInCache(xPlayer.getIdentifier(), job) then
        TriggerClientEvent('ox_lib:notify', source, {title='Darbas', description='Neturi teisės šiam darbui.', type='error'})
        return false
    end

    if not ESX.DoesJobExist(job, grade) then
        TriggerClientEvent('ox_lib:notify', source, {title='Darbas', description='Darbas neegzistuoja.', type='error'})
        return false
    end

    xPlayer.setJob(job, grade)
    addJobToCache(xPlayer.getIdentifier(), job, grade)
    oxmysql:executeSync('REPLACE INTO multijob_jobs (identifier, job, grade) VALUES (?, ?, ?)', {xPlayer.getIdentifier(), job, grade})

    TriggerClientEvent('ox_lib:notify', source, {
        title='Darbas',
        description='Sėkmingai pakeitei darbą į '..GetFullJobLabel(job, grade),
        type='success'
    })
    return true
end)

-- Callback: deleteJob
lib.callback.register('d-multijob:deleteJob', function(source, data)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer or not data or not data.job then return end
    local identifier = xPlayer.getIdentifier()
    playerJobs[identifier] = playerJobs[identifier] or {}

    -- šalinam iš cache
    removeJobFromCache(identifier, data.job)
    -- šalinam iš DB (NAUDOJAM execute/executeSync, ne insert!)
    oxmysql:executeSync('DELETE FROM multijob_jobs WHERE identifier=? AND job=?', {identifier, data.job})

    -- jei dabartinis aktyvus darbas buvo pašalintas – perjungiam
    if xPlayer.job and xPlayer.job.name == data.job then
        local newJob = playerJobs[identifier][1]
        if newJob then
            xPlayer.setJob(newJob.job, newJob.grade)
            TriggerClientEvent('ox_lib:notify', source, {
                title='Darbas',
                description='Darbas pašalintas. Perjungta į: '..GetFullJobLabel(newJob.job, newJob.grade),
                type='info'
            })
        else
            xPlayer.setJob('unemployed', 0)
            addJobToCache(identifier, 'unemployed', 0)
            oxmysql:executeSync('REPLACE INTO multijob_jobs (identifier, job, grade) VALUES (?, ?, ?)', {identifier, 'unemployed', 0})
            TriggerClientEvent('ox_lib:notify', source, {
                title='Darbas',
                description='Dabar esate bedarbis.',
                type='info'
            })
        end
    end
end)

-- Papildomas event'as: nukirpti konkretų job iš kito resurso (pvz., bossmenu)
RegisterNetEvent('d-multijob:removeJob', function(targetSourceOrIdentifier, jobName)
    local identifier, src
    if type(targetSourceOrIdentifier) == 'number' then
        src = targetSourceOrIdentifier
        local x = ESX.GetPlayerFromId(src)
        if not x then return end
        identifier = x.getIdentifier()
    else
        identifier = targetSourceOrIdentifier
    end
    if not identifier or not jobName then return end

    removeJobFromCache(identifier, jobName)
    oxmysql:executeSync('DELETE FROM multijob_jobs WHERE identifier=? AND job=?', {identifier, jobName})

    if src then
        local x = ESX.GetPlayerFromId(src)
        if x and x.job and x.job.name == jobName then
            x.setJob('unemployed', 0)
        end
    end
end)

-- Ta pati funkcija kaip export'as
exports('RemoveJobForIdentifier', function(identifier, jobName)
    if not identifier or not jobName then return end
    removeJobFromCache(identifier, jobName)
    oxmysql:executeSync('DELETE FROM multijob_jobs WHERE identifier=? AND job=?', {identifier, jobName})
end)

-- Automatinis atnaujinimas, jei job keičiasi kitur
AddEventHandler('esx:setJob', function(playerId, job, lastJob)
    local xPlayer = ESX.GetPlayerFromId(playerId)
    if not xPlayer then return end

    local identifier = xPlayer.getIdentifier()
    playerJobs[identifier] = playerJobs[identifier] or {}

    -- Jei atleistas -> naujas job 'unemployed' => pašalinam būtent paskutinį darbą iš multijobo
    if job and job.name == 'unemployed' and lastJob and lastJob.name and lastJob.name ~= 'unemployed' then
        removeJobFromCache(identifier, lastJob.name)
        oxmysql:executeSync('DELETE FROM multijob_jobs WHERE identifier=? AND job=?', {identifier, lastJob.name})
        -- užtikrinam, kad unemployed būtų įrašytas
        addJobToCache(identifier, 'unemployed', 0)
        oxmysql:executeSync('REPLACE INTO multijob_jobs (identifier, job, grade) VALUES (?, ?, ?)', {identifier, 'unemployed', 0})
        return
    end

    -- kitu atveju – įtraukiam/atnaujinam naują job į multijob (paliekant senus)
    if job and job.name then
        addJobToCache(identifier, job.name, job.grade or 0)
        oxmysql:executeSync('REPLACE INTO multijob_jobs (identifier, job, grade) VALUES (?, ?, ?)', {identifier, job.name, job.grade or 0})
    end
end)