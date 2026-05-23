local function sendNotification(data)
    if GetResourceState('litrp-hud') == 'started' then
        exports['litrp-hud']:sendNotification(data)
    else
        TriggerEvent('chat:addMessage', {
            color = {255, 255, 255},
            multiline = true,
            args = {data.title or 'Info', data.message or 'No message'}
        })
    end
end

RegisterNetEvent('givecar:menu', function()
    local _source = GetPlayerServerId(PlayerId())
    local input = lib.inputDialog('Automobilio išdavimas', {
        {type = 'number', label = 'Žaidėjo ID', description = 'Įveskite žaidėjo ID', icon = 'fa-solid fa-user'},
        {type = 'input', label = 'Automobilio spawn', description = 'Automobilio spawn kodas', required = true, icon = 'fa-solid fa-car'},
        {type = 'input', label = 'Automobilio numeriai', description = 'Automobilio numeriai (palikite tuščia - sugeneruos automatiškai)', icon = 'fa-solid fa-hashtag', required = false, min = 0, max = 8},
        {type = 'select', label = 'Automobilio tipas', description = 'Automobilio tipas', icon = 'fa-solid fa-truck-plane', options = {
            {value = 'owned_vehicles', label = 'Land'},
            {value = 'owned_laivai',   label = 'Water'},
            {value = 'owned_planes',   label = 'Sky'},
        }},
        {type = 'checkbox', label = 'Full Tune', required = false, checked = false, icon = 'fa-solid fa-wrench'},
        {type = 'checkbox', label = 'Dovana',    required = false, checked = false, icon = 'fa-solid fa-gift'},
    })

    if not input then return end
    if not input[1] or not input[2] then return end

    local player      = tonumber(input[1])
    local model       = tostring(input[2])
    local hash        = GetHashKey(model)
    local plate       = tostring(input[3] or '')
    local vehicleType = input[4]
    local fulltune    = input[5]
    local present     = input[6]

    if not IsModelValid(hash) then
        sendNotification({ type = 'ERROR', title = 'Klaida', message = 'Automobilis nerastas: ' .. model, duration = 5000, icon = 'car' })
        return
    end

    if not lib.requestModel(model, 10000) then
        sendNotification({ type = 'ERROR', title = 'Klaida', message = 'Automobilis negali būti pakrautas: ' .. model, duration = 5000, icon = 'exclamation-triangle' })
        return
    end

    if #plate < 1 then
        plate = exports['s1m1s-vehicleshop']:generatePlate('Land')
    else
        if string.find(plate, '[žūųšįėęčąŽŪŲŠĮĖĘČĄ]') or string.find(plate, '[%p%c]') then
            sendNotification({ type = 'ERROR', title = 'Klaida', message = 'Neteisingi numerio simboliai', duration = 5000, icon = 'hashtag' })
            return
        end
    end

    local coords  = GetEntityCoords(cache.ped)
    local vehicle = CreateVehicle(hash, coords.x, coords.y, coords.z, 0.0, false, true)
    while not DoesEntityExist(vehicle) do Wait(100) end

    SetEntityVisible(vehicle, false, false)
    SetEntityCollision(vehicle, false, true)

    local props = exports['s1m1s-garagev3']:GetVehicleProperties(vehicle)
    props.plate = string.upper(plate)

    if fulltune then
        SetVehicleModKit(vehicle, 0)
        props.modEngine      = GetNumVehicleMods(vehicle, 11) - 1
        props.modBrakes      = GetNumVehicleMods(vehicle, 12) - 1
        props.modTransmission = GetNumVehicleMods(vehicle, 13) - 1
        props.modSuspension  = GetNumVehicleMods(vehicle, 15) - 1
        props.modTurbo       = 1
        props.modArmor       = GetNumVehicleMods(vehicle, 16) - 1
    end

    DeleteEntity(vehicle)

    local success, result = lib.callback.await('givecar:player', false, player, props, vehicleType, model, present)

    if success then
        sendNotification({
            type     = 'SUCCESS',
            title    = 'Sėkmė',
            message  = 'Automobilis išduotas žaidėjui ID: ' .. player .. '\nNumeriai: ' .. result,
            duration = 6000,
            icon     = 'check'
        })
    else
        sendNotification({
            type     = 'ERROR',
            title    = 'Klaida',
            message  = 'Nepavyko išduoti: ' .. (result or 'Nežinoma klaida'),
            duration = 5000,
            icon     = 'times'
        })
    end
end)
