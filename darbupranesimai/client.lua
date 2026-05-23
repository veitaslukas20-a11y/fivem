print("DEBUG: Client script loading...")

local ESX = exports['es_extended']:getSharedObject()

-- Only these jobs can use the menu/features
local allowedJobs = {
    police = true,
    ambulance = true,
    mechanic3 = true,
    mechanic2 = true,
    taxi = true,
    dealership = true
}

local function isAllowedJob(jobName)
    return jobName and allowedJobs[jobName] == true
end

local wait = false
local delay = 60
local autoMessageActive = false
local autoMessageTimer = nil

local function sendJobNotification(data)
    if not ESX then return end
    local job = data.job
    local PlayerData = ESX.GetPlayerData()
    if not PlayerData or not PlayerData.job then return end

    -- Block if job not allowed
    if not isAllowedJob(PlayerData.job.name) then
        lib.notify({title="Klaida", description="Jūsų darbas negali naudoti šio meniu.", type="error"})
        return
    end

    if PlayerData.job.name ~= job or PlayerData.job.grade_name ~= "boss" then
        lib.notify({title="Klaida", description="Neturite teisės siųsti pranešimų.", type="error"})
        return
    end

    if wait then
        lib.notify({title="Palaukite", description="Turite palaukti prieš siųsdami kitą pranešimą.", type="error"})
        return
    end

    wait = true
    SetTimeout(delay*1000,function() wait=false end)

    local input = lib.inputDialog("Siųsti pranešimą", {
        {type="input", label="Pranešimo tekstas", placeholder="Įrašykite čia...", required=true}
    })
    if not input then wait=false return end

    local message = input[1] and tostring(input[1]):gsub("%s+","") or ""
    if message=="" then
        lib.notify({title="Klaida", description="Pranešimo tekstas negali būti tuščias.", type="error"})
        wait=false
        return
    end

    TriggerServerEvent("jobsnotify:send", job, input[1])
end

local function startAutoMessage()
    if autoMessageActive then
        lib.notify({title="Klaida", description="Autožinutė jau paleista.", type="error"})
        return
    end
    if not ESX then
        lib.notify({title="Klaida", description="Sistema nepakrauta.", type="error"})
        return
    end

    local PlayerData = ESX.GetPlayerData()
    if not PlayerData or not PlayerData.job then
        lib.notify({title="Klaida", description="Žaidėjo duomenys nepasiekiami.", type="error"})
        return
    end

    -- Block if job not allowed
    if not isAllowedJob(PlayerData.job.name) then
        lib.notify({title="Klaida", description="Jūsų darbas negali naudoti šio meniu.", type="error"})
        return
    end

    local job   = PlayerData.job.name
    local grade = PlayerData.job.grade_name

    if grade ~= "boss" then
        lib.notify({title="Klaida", description="Tik bosas gali paleisti autožinutes.", type="error"})
        return
    end

    local input = lib.inputDialog("Autožinutė visiems", {
        {type="input",  label="Žinutės tekstas", placeholder="Įrašykite čia...", required=true},
        {type="number", label="Kas kiek minučių kartoti?", placeholder="Pvz: 5", required=true}
    })
    if not input then return end

    local message = tostring(input[1] or "")
    local minutes = tonumber(input[2] or 0) or 0

    if message == "" or minutes <= 0 then
        lib.notify({title="Klaida", description="Neteisingi duomenys.", type="error"})
        return
    end

    -- hard floor: 1 minute
    local interval = math.max(1, minutes) * 60000

    autoMessageActive = true
    CreateThread(function()
        while autoMessageActive do
            -- server will re-check that we're boss of THIS job
            TriggerServerEvent("jobsnotify:autoSendAll", job, message)
            Wait(interval)
        end
    end)

    lib.notify({title="Sėkmingai", description="Autožinutė paleista.", type="success"})
end

local function stopAutoMessage()
    if autoMessageActive then
        autoMessageActive=false
        lib.notify({title="Sustabdyta", description="Autožinutė išjungta.", type="inform"})
    else
        lib.notify({title="Info", description="Autožinutė nėra aktyvi.", type="error"})
    end
end

RegisterCommand("stopauto", stopAutoMessage, false)

local function openJobMenu()
    if not ESX then
        lib.notify({title="Klaida", description="Sistema nepakrauta.", type="error"})
        return
    end

    local PlayerData = ESX.GetPlayerData()
    if not PlayerData or not PlayerData.job then
        lib.notify({title="Klaida", description="Žaidėjo duomenys nepasiekiami.", type="error"})
        return
    end

    local job   = PlayerData.job.name
    local grade = PlayerData.job.grade_name

    -- 🚫 If not one of the restricted jobs, don't open the menu at all
    if not isAllowedJob(job) then
        lib.notify({title="Klaida", description="Jūsų darbas negali naudoti šio meniu.", type="error"})
        return
    end

    if grade ~= "boss" then
        lib.notify({title="Klaida", description="Tik boso rangas gali siųsti pranešimus.", type="error"})
        return
    end

    local options = {}
    local jobOptions = {
        police      = {title="Policijos pranešimas", icon="shield"},
        ambulance   = {title="Medikų pranešimas", icon="briefcase-medical"},
        mechanic    = {title="Mechanikų pranešimas", icon="wrench"},
        taxi        = {title="Bolt pranešimas", icon="car"},
        dealership  = {title="Salonų pranešimas", icon="store"}
    }

    if jobOptions[job] then
        options[#options+1] = {
            title = jobOptions[job].title,
            description = "Siųsti pranešimą visiems",
            icon = jobOptions[job].icon,
            onSelect = function() sendJobNotification({job=job}) end
        }
    end

    options[#options+1] = {
        title="Autožinutė",
        description="Nustatyti automatinį pranešimą",
        icon="bullhorn",
        onSelect=startAutoMessage
    }

    if autoMessageActive then
        options[#options+1] = {
            title="Sustabdyti autožinutę",
            description="Išjungti vykdomą autožinutę",
            icon="ban",
            onSelect=stopAutoMessage
        }
    end

    lib.registerContext({id="jobnotify_menu", title="Darbo pranešimai", options=options})
    lib.showContext("jobnotify_menu")
end

RegisterCommand("darbupranesimas", openJobMenu, false)
RegisterKeyMapping('darbupranesimas','Atidaryti darbų pranešimų meniu','keyboard','F6')

RegisterNetEvent("jobsnotify:client:notify", function(title,message,duration)
    if exports and exports["1x-hud"] then
        exports["1x-hud"]:sendNotification({
            type="INFO", title=title, message=message, duration=duration or 6000, icon="info"
        })
    else
        lib.notify({title=title, description=message, type="inform", duration=duration or 6000})
    end
end)

print("DEBUG: Client script loaded completely")
