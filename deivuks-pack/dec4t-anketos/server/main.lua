local RESOURCE = GetCurrentResourceName()

local Webhooks = {
    default = "https://discord.com/api/webhooks/PAKEISKITE_DEFAULT",
    ambulance = "https://discord.com/api/webhooks/1506425322055139453/sl4Fb8ll1I71zCvz1V4PfZ47-cNsZJ6NkI4NpmAm4i2yObUhENjbcKHChOWHQYBhT8Un",
    bahama = "https://discord.com/api/webhooks/PAKEISKITE_bahama",
    dealership = "https://discord.com/api/webhooks/PAKEISKITE_dealership",
    dealershipment = "https://discord.com/api/webhooks/PAKEISKITE_dealershipment",
    mechanic = "https://discord.com/api/webhooks/PAKEISKITE_mechanic",
    mechanic2 = "https://discord.com/api/webhooks/PAKEISKITE_mechanic2",
    mechanic3 = "https://discord.com/api/webhooks/PAKEISKITE_mechanic3",
    mechanic4 = "https://discord.com/api/webhooks/PAKEISKITE_mechanic4",
    police = "https://discord.com/api/webhooks/1434813705282912278/mq4rRC9Yz9KU-0oT1FU4JzyczSi5yn_DdpEZEuLgD0y1VkQcMOCFNDVOaPl99LAXGico",
    taxi = "https://discord.com/api/webhooks/PAKEISKITE_taxi",
}

local function getWebhook(jobKey)
    if jobKey and Webhooks[jobKey] and Webhooks[jobKey] ~= "" then
        return Webhooks[jobKey]
    end
    return Webhooks.default
end

-- ===================== ESX / OXMYSQL ==========================
local ESX = nil
CreateThread(function()
    if GetResourceState('es_extended') == 'started' then
        ESX = exports['es_extended']:getSharedObject()
        print(('[%s] ESX OK'):format(RESOURCE))
    else
        print(('[%s] Įspėjimas: es_extended nerastas — tęsime be ESX.'):format(RESOURCE))
    end

    if GetResourceState('oxmysql') == 'started' then
        print(('[%s] oxmysql OK — naudosime duomenų bazę.'):format(RESOURCE))
        local createSql = [[
            CREATE TABLE IF NOT EXISTS twox_anketos (
                id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
                type VARCHAR(32),
                job_key VARCHAR(64),
                player_identifier VARCHAR(64),
                player_name VARCHAR(64),
                payload LONGTEXT,
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
            ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
        ]]
        exports.oxmysql:execute(createSql, {})
    else
        print(('[%s] oxmysql nerastas — įrašysime į /data/*.json (sukurkite /data aplanką).'):format(RESOURCE))
        -- Bandome sukurti .keep, kad egzistuotų /data aplankas (jei leidžiama)
        SaveResourceFile(RESOURCE, 'data/.keep', '1', -1)
    end
end)

-- ====================== Pagalbinės funkcijos ===================
local function getPlayerIdentity(src)
    local name = GetPlayerName(src) or ('player_%d'):format(src)
    local identifier = ('src:%d'):format(src)

    if ESX then
        local xPlayer = ESX.GetPlayerFromId(src)
        if xPlayer then
            identifier = xPlayer.identifier or identifier
        end
    else
        for i = 0, GetNumPlayerIdentifiers(src) - 1 do
            local id = GetPlayerIdentifier(src, i)
            if id and id ~= '' then identifier = id break end
        end
    end
    return name, identifier
end

local RATE_WINDOW = 60   -- sekundžių
local RATE_LIMIT  = 5    -- max pateikimų per langą
local rate_state = {}
local function allowedToSubmit(identifier)
    local now = os.time()
    local s = rate_state[identifier]
    if not s or now >= (s.resetAt or 0) then
        rate_state[identifier] = { count = 1, resetAt = now + RATE_WINDOW }
        return true
    end
    if s.count < RATE_LIMIT then
        s.count = s.count + 1
        return true
    end
    return false
end

local function sanitizeKey(key)
    if type(key) ~= 'string' then return nil end
    key = key:sub(1, 64)
    key = key:gsub('[^%w_%-%/]', '')
    if key == '' then return nil end
    return key
end

local function toEmbedFields(tbl, cap)
    local fields = {}
    local n = 0
    for k, v in pairs(tbl or {}) do
        n = n + 1
        if cap and n > cap then break end
        local t = type(v)
        local val = t == 'table' and json.encode(v) or tostring(v)
        table.insert(fields, { name = tostring(k), value = string.sub(val, 1, 1024), inline = false })
    end
    return fields
end

local function sendToDiscord(jobKey, title, payload, authorName, authorId, color)
    local url = getWebhook(jobKey)
    if not url or url == "" then return end

    local description = ("**Žaidėjas:** %s\n**Identifier:** `%s`"):format(authorName or '-', authorId or '-')
    local embeds = {{
        title = title,
        description = description,
        color = color or 5793266,
        fields = toEmbedFields(payload, 25),
        timestamp = os.date('!%Y-%m-%dT%H:%M:%SZ')
    }}

    PerformHttpRequest(url, function() end, 'POST', json.encode({
        username = 'TwoX - Anketos',
        embeds = embeds
    }), { ['Content-Type'] = 'application/json' })
end

local function jobLabel(jobKey)
    if type(twox_anketos) == 'table' and type(twox_anketos.Labels) == 'table' then
        return twox_anketos.Labels[jobKey] or jobKey or 'Nežinomas darbas'
    end
    return jobKey or 'Nežinomas darbas'
end

local function saveSubmission(kind, key, payload, src)
    local playerName, playerIdentifier = getPlayerIdentity(src)
    local record = {
        type = kind,
        job_key = key,
        player_identifier = playerIdentifier,
        player_name = playerName,
        payload = payload,
        created_at = os.date('!%Y-%m-%dT%H:%M:%SZ')
    }

    if GetResourceState('oxmysql') == 'started' then
        exports.oxmysql:insert(
            'INSERT INTO twox_anketos (type, job_key, player_identifier, player_name, payload) VALUES (?, ?, ?, ?, ?)',
            { record.type, record.job_key, record.player_identifier, record.player_name, json.encode(record.payload) }
        )
    else
        local fileName = ('data/%s_%s_%s.json'):format(kind, os.date('!%Y%m%d_%H%M%S'), tostring(src))
        SaveResourceFile(RESOURCE, fileName, json.encode(record, { indent = true }), -1)
    end

    local lbl = jobLabel(key or '')
    local title = ('%s | %s'):format(lbl, (kind == 'form' and 'Darbo anketa') or (kind == 'weapon_license' and 'Ginklo licencija') or (kind == 'statement' and 'Pareiškimas') or kind)
    local color = (kind == 'form' and 3066993) or (kind == 'weapon_license' and 15105570) or (kind == 'statement' and 3447003) or 5793266
    sendToDiscord(key, title, payload, playerName, playerIdentifier, color)

    print(('[%s] %s | %s | %s pateikė anketą.'):format(RESOURCE, kind, key or '-', playerName))
end

local function validatePayload(tbl, maxKeys)
    if type(tbl) ~= 'table' then return false end
    local n = 0
    for k, v in pairs(tbl) do
        n = n + 1
        if n > (maxKeys or 100) then return false end
        local vt = type(v)
        if vt ~= 'string' and vt ~= 'number' and vt ~= 'boolean' and vt ~= 'table' then
            return false
        end
        if vt == 'string' and #v > 2000 then
            return false
        end
    end
    return true
end

-- ====================== Serverio eventai =======================
RegisterNetEvent('twox_anketos:submitForm', function(jobKey, answers)
    local src = source
    local name, identifier = getPlayerIdentity(src)

    jobKey = sanitizeKey(jobKey)
    if not jobKey then
        print(('[%s] submitForm: blogas job key iš %s'):format(RESOURCE, name))
        return
    end
    if not allowedToSubmit(identifier) then
        TriggerClientEvent('chat:addMessage', src, { args = { '^1Anketa', 'Per dažni pateikimai. Pabandykite vėliau.' } })
        return
    end
    if not validatePayload(answers, 200) then return end

    saveSubmission('form', jobKey, answers, src)
    TriggerClientEvent('chat:addMessage', src, { args = { '^2Anketa', 'Sėkmingai pateikta. Ačiū!' } })
end)

RegisterNetEvent('twox_anketos:submitWeaponLicense', function(answers)
    local src = source
    local _, identifier = getPlayerIdentity(src)
    if not allowedToSubmit(identifier) then
        TriggerClientEvent('chat:addMessage', src, { args = { '^1Licencija', 'Per dažni pateikimai. Pabandykite vėliau.' } })
        return
    end
    if not validatePayload(answers, 50) then return end
    saveSubmission('weapon_license', 'police', answers, src)
    TriggerClientEvent('chat:addMessage', src, { args = { '^2Licencija', 'Prašymas pateiktas.' } })
end)

RegisterNetEvent('twox_anketos:submitStatement', function(data)
    local src = source
    local _, identifier = getPlayerIdentity(src)
    if not allowedToSubmit(identifier) then
        TriggerClientEvent('chat:addMessage', src, { args = { '^1Pareiškimas', 'Per dažni pateikimai. Pabandykite vėliau.' } })
        return
    end
    if not validatePayload(data, 200) then return end
    saveSubmission('statement', 'police', data, src)
    TriggerClientEvent('chat:addMessage', src, { args = { '^2Pareiškimas', 'Sėkmingai pateiktas.' } })
end)

-- ======================= Eksportas kitiems script'ams =========
exports('Submit', function(kind, key, payload, src)
    if type(src) ~= 'number' then src = source end
    if kind ~= 'form' and kind ~= 'weapon_license' and kind ~= 'statement' then return false end
    if kind == 'form' then key = sanitizeKey(key) end
    if not validatePayload(payload, 200) then return false end
    saveSubmission(kind, key, payload, src or 0)
    return true
end)
