local usingOxLib    = (GetResourceState and GetResourceState('ox_lib') == 'started')
local usingOxTarget = (GetResourceState and GetResourceState('ox_target') == 'started')

if not usingOxTarget then
    print('[twox-anketos] ĮSPĖJIMAS: ox_target nerastas — taikiniai neveiks.')
end
if not usingOxLib then
    print('[twox-anketos] ĮSPĖJIMAS: ox_lib nerastas — dialogai neveiks.')
end

-- ====== Utils / Config ======
local function ensureConfig()
    if type(twox_anketos) ~= 'table' then twox_anketos = {} end
    if type(twox_anketos.Coords) ~= 'table' then twox_anketos.Coords = {} end
    if type(twox_anketos.Labels) ~= 'table' then twox_anketos.Labels = {} end
    if twox_anketos.TargetSize == nil then twox_anketos.TargetSize = vec3(1.8, 1.8, 2.2) end
end

local function labelFor(job)
    ensureConfig()
    return twox_anketos.Labels[job] or job
end

local function VEC3(x,y,z)
    if vec3 then return vec3(x,y,z) end
    return vector3(x,y,z)
end

local function v4ToXYZW(v4)
    if type(v4) == 'vector4' then
        return v4.x, v4.y, v4.z, v4.w
    elseif type(v4) == 'table' then
        return v4.x or v4[1], v4.y or v4[2], v4.z or v4[3], v4.w or v4.heading or v4[4]
    end
    return nil, nil, nil, nil
end

local function tableFromInputs(keys, values)
    local t = {}
    for i, k in ipairs(keys) do
        t[k] = values and values[i] or nil
    end
    return t
end

-- ====== Dialogai (ox_lib) ======
local function OpenForm(jobKey)
    if not usingOxLib then return end
    local title = ('Darbo anketa — %s'):format(labelFor(jobKey))
    local inputs = lib.inputDialog(title, {
        { type = 'input',   label = 'Vardas ir Pavardė',        placeholder = 'Jonas Jonaitis', required = true,  min = 3, max = 50 },
        { type = 'number',  label = 'Amžius (RP)',               required = true, min = 16, max = 80 },
        { type = 'input',   label = 'Telefono Numeris',               required = true },
        { type = 'textarea',label = 'Apie save',                 placeholder = 'Patirtis, stiprybės, silpnybės', required = true, min = 10, max = 300 },
        { type = 'textarea',label = 'Motyvacija',                placeholder = 'Kodėl nori prisijungti?',         required = true, min = 10, max = 300 },
        { type = 'input',   label = 'Turima patirtis',           placeholder = 'pvz. 200h, Mechanikas', required = false, max = 120 },
        { type = 'checkbox',label = 'Sutinku su serverio taisyklėmis', required = true },
    })
    if not inputs then return end
    local keys = { 'V.Pavarde', 'RP Metai', 'Tl.Numeris', 'Apie Save', 'Motyvacija', 'Kokia patirtis', 'Ar sutinka su taisyklem' }
    local data = tableFromInputs(keys, inputs)
    TriggerServerEvent('twox_anketos:submitForm', jobKey, data)
    lib.notify({ title = 'Anketa', description = 'Išsiųsta!', type = 'success' })
end

local function OpenWeaponLicense()
    if not usingOxLib then return end
    local inputs = lib.inputDialog('Ginklo licencijos prašymas', {
        { type = 'input',   label = 'Vardas ir Pavardė', required = true, min = 3, max = 50 },
        { type = 'number',  label = 'Amžius (RP)',       required = true, min = 16, max = 80 },
        { type = 'input',   label = 'Telefono Numeris',  required = false, max = 80 },
        { type = 'textarea',label = 'Kodėl reikia licencijos?', required = true, min = 10, max = 600 },
        { type = 'checkbox',label = 'Pažįstu ginklų saugojimo taisykles', required = true },
    })
    if not inputs then return end
    local keys = { 'vardas', 'amzius', 'Tl.Numeris', 'priezastis', 'taisykles' }
    local data = tableFromInputs(keys, inputs)
    TriggerServerEvent('twox_anketos:submitWeaponLicense', data)
    lib.notify({ title = 'Licencija', description = 'Prašymas pateiktas!', type = 'success' })
end

local function OpenStatement()
    if not usingOxLib then return end
    local inputs = lib.inputDialog('Pareiškimas policijai', {
        { type = 'input',   label = 'Antraštė', required = true, min = 3, max = 60 },
        { type = 'textarea',label = 'Aprašymas', required = true, min = 10, max = 1200 },
    })
    if not inputs then return end
    local keys = { 'antraste', 'aprasymas' }
    local data = tableFromInputs(keys, inputs)
    TriggerServerEvent('twox_anketos:submitStatement', data)
    lib.notify({ title = 'Pareiškimas', description = 'Pateikta!', type = 'success' })
end

-- ====== ox_target zonos ======
local createdZones = {}

local function addZoneFor(job, v4)
    if not usingOxTarget then return end
    local x, y, z, w = v4ToXYZW(v4)
    if not (x and y and z) then return end

    local label = labelFor(job)
    local options = {
        {
            icon = 'fa-solid fa-clipboard',
            label = ('Pildyti darbo anketą'):format(label),
            name = ('twox_anketos:%s_form'):format(job),
            onSelect = function(data) OpenForm(job) end
        },
    }

    if job == 'police' then
        options[#options+1] = {
            icon = 'fa-solid fa-gun',
            label = 'Ginklo licencija',
            name  = 'twox_anketos:weapon_license',
            onSelect = function(data) OpenWeaponLicense() end
        }
        options[#options+1] = {
            icon = 'fa-solid fa-file-lines',
            label = 'Pareiškimas policijai',
            name  = 'twox_anketos:statement',
            onSelect = function(data) OpenStatement() end
        }
    end

    local zoneId = exports.ox_target:addBoxZone({
        coords = VEC3(x,y,z),
        size = twox_anketos.TargetSize or vec3(1.8,1.8,2.2),
        rotation = w or 0.0,
        debug = twox_anketos.DrawZones == true,
        options = options
    })
    createdZones[#createdZones+1] = zoneId
    print(('[twox-anketos] ox_target zona sukurta: %s @ (%.2f, %.2f, %.2f)'):format(job, x, y, z))
end

CreateThread(function()
    ensureConfig()
    for job, v4 in pairs(twox_anketos.Coords) do
        addZoneFor(job, v4)
    end
end)

AddEventHandler('onResourceStop', function(res)
    if res ~= GetCurrentResourceName() then return end
    if usingOxTarget then
        for _, id in ipairs(createdZones) do
            exports.ox_target:removeZone(id)
        end
    end
end)