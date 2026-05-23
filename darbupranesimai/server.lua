print("DEBUG: Server script loading...")

local ESX = exports['es_extended']:getSharedObject()

-- Allowed jobs for boss auto messages
local allowedJobs = {
    police = true,
    ambulance = true,
    mechanic2 = true,
    mechanic3 = true,
    taxi = true,
    dealership = true
}

-- Job titles for notifications
local jobTitles = {
    police = "Policijos pranešimas",
    ambulance = "Medikų pranešimas",
    mechanic2 = "Mechanikų pranešimas",
    taxi = "Bolt pranešimas",
    dealership = "Salonų pranešimas"
}

-- Helper
local function isEmptyMessage(msg)
    if type(msg) ~= "string" then return true end
    return msg:gsub("%s+", "") == ""
end

-- Manual job messages
RegisterNetEvent("jobsnotify:send", function(job, message)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    if not xPlayer then return end

    if not allowedJobs[xPlayer.job.name] then
        TriggerClientEvent("jobsnotify:client:notify", src, "Klaida", "Jūsų darbas negali siųsti pranešimų.", 4000)
        return
    end

    if xPlayer.job.name ~= job or (xPlayer.job.grade_name or "") ~= "boss" then
        TriggerClientEvent("jobsnotify:client:notify", src, "Klaida", "Neturite teisės siųsti pranešimo.", 4000)
        return
    end

    if isEmptyMessage(message) then return end

    local title = jobTitles[job] or "Pranešimas"
    TriggerClientEvent("jobsnotify:client:notify", -1, title, message, 8000)
end)

-- Auto job messages
RegisterNetEvent("jobsnotify:autoSendAll", function(job, message)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    if not xPlayer then return end

    -- ✅ Restrict to allowed jobs only
    if not allowedJobs[xPlayer.job.name] then
        TriggerClientEvent("jobsnotify:client:notify", src, "Klaida", "Jūsų darbas negali paleisti autožinučių.", 4000)
        return
    end

    if xPlayer.job.name ~= job or (xPlayer.job.grade_name or "") ~= "boss" then
        TriggerClientEvent("jobsnotify:client:notify", src, "Klaida", "Tik savo darbo bosas gali paleisti autožinutes.", 4000)
        return
    end

    if isEmptyMessage(message) then return end

    local title = jobTitles[job] or "Pranešimas"
    TriggerClientEvent("jobsnotify:client:notify", -1, title, message, 8000)
end)

print("DEBUG: Server script loaded completely")