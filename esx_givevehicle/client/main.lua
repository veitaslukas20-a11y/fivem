local function sendNotification(data)
    -- Always use litrp-hud if available
    if GetResourceState('litrp-hud') == 'started' then
        exports['litrp-hud']:sendNotification(data)
    end
    
    -- Also send to chat
    TriggerEvent('chat:addMessage', {
        color = {255, 255, 255},
        multiline = true,
        args = {data.title or 'Info', data.message or 'No message'}
    })
end

RegisterNetEvent('givecar:menu', function()
	local _source = GetPlayerServerId(PlayerId())
	local input = lib.inputDialog('Dialog title', {
		{type = 'number', label = 'Žaidėjo ID', description = 'Įveskite žaidėjo ID', icon = 'fa-solid fa-user'},
		{type = 'input', label = 'Automobilio spawn', description = 'Automobilio spawn kodas', required = true, icon = 'fa-solid fa-car'},
		{type = 'input', label = 'Automobilio numeriai', description = 'Automobilio numeriai (jeigu nenorite uždėti vardinių numerių palikite laukelį tusčia)', icon = 'fa-solid fa-hashtag', required = false, min = 0, max = 8},
		{type = 'select', label = 'Automobilio tipas', description = 'Automobilio tipas (Land, Water, Sky)', icon = 'fa-solid fa-truck-plane', options = {
			{value = 'owned_vehicles', label = 'Land'},
			{value = 'owned_laivai', label = 'Water'},
			{value = 'owned_planes', label = 'Sky'},
		}},
		{type = 'checkbox', label = 'Full Tune', required = false, checked = false, icon = 'fa-solid fa-wrench'},
		{type = 'checkbox', label = 'Dovana', required = false, checked = false, icon = 'fa-solid fa-gift'},
	})

    if not input then return end

    if input[1] and input[2] then 
        local player = tonumber(input[1])
        local model = tostring(input[2])
        local hash = GetHashKey(tostring(input[2]))
        local plate = tostring(input[3])
        local type = input[4]
        local fulltune = input[5]
        local present = input[6]

        if not IsModelValid(hash) then 
            sendNotification({
                type = 'ERROR',
                title = 'Klaida',
                message = 'Automobilis nerastas: ' .. model,
                duration = 5000,
                icon = 'car'
            })
            return false
        end

        if not lib.requestModel(model, 10000) then
            sendNotification({
                type = 'ERROR',
                title = 'Klaida',
                message = 'Automobilis negali būti pakrautas: ' .. model,
                duration = 5000,
                icon = 'exclamation-triangle'
            })
            return false
        end

        if #plate < 1 then
            plate = exports['s1m1s-vehicleshop']:generatePlate('Land')
        else
            if string.find(plate, '[žūųšįėęčąŽŪŲŠĮĖĘČĄ]') or string.find(plate, '[%p%c]') then
                sendNotification({
                    type = 'ERROR',
                    title = 'Klaida',
                    message = 'Neteisingi numerio simboliai',
                    duration = 5000,
                    icon = 'hashtag'
                })
                return
            end
        end

        local coords = GetEntityCoords(cache.ped)
        local _vehicle = CreateVehicle(hash, coords.x, coords.y, coords.z, 0.0, false, true)
        while not DoesEntityExist(_vehicle) do
            Wait(100)
        end

        SetEntityVisible(_vehicle, false, false)
        SetEntityCollision(_vehicle, false, true)

        local props = exports['s1m1s-garagev3']:GetVehicleProperties(_vehicle)
        props.plate = string.upper(plate)

        -- Apply full tune if requested
        if fulltune then
            SetVehicleModKit(_vehicle, 0)
            props.modEngine = GetNumVehicleMods(_vehicle, 11) - 1
            props.modBrakes = GetNumVehicleMods(_vehicle, 12) - 1
            props.modTransmission = GetNumVehicleMods(_vehicle, 13) - 1
            props.modSuspension = GetNumVehicleMods(_vehicle, 15) - 1
            props.modTurbo = 1
            props.modArmor = GetNumVehicleMods(_vehicle, 16) - 1
        end

        -- Log the action
        local logas = {
            ['Player'] = _source,
            ['Target'] = player,
            ['Log'] = 'give_car',
            ['Title'] = 'Gave Vehicle',
            ['Message'] = 'Spawn: `' ..model.. '` \nPlate: `' ..plate..'`\nFull Tune: `'..(fulltune and 'yes' or 'no')..'`\nGift: `'..(present and 'yes' or 'no')..'`',
            ['Color'] = 'blue',
        }

        TriggerServerEvent('Boost-Logs:SendLog', logas)

        -- Give the vehicle to the player (no automatic spawn)
        local success, uid = lib.callback.await('givecar:player', false, player, props, type, model, present)
        
        if success then
            -- Don't spawn immediately, let the player use /importcar to spawn
            sendNotification({
                type = 'SUCCESS',
                title = 'Sėkmė',
                message = 'Automobilis sėkmingai išduotas žaidėjui ID: ' .. player .. '\nImporto kodas: ' .. uid,
                duration = 8000,
                icon = 'check'
            })
        else
            sendNotification({
                type = 'ERROR',
                title = 'Klaida',
                message = 'Nepavyko išduoti automobilio: ' .. (uid or 'Nežinoma klaida'),
                duration = 5000,
                icon = 'times'
            })
        end

        DeleteEntity(_vehicle)
    end
end)

-- Optionally, you can comment out or remove the event handler for 'givecar:spawnvehicle' if you don't want it to be used at all.
-- RegisterNetEvent('givecar:spawnvehicle', function(modelInput, plate, fulltune, uid, present)
--     if not uid then return end
--     local _source = GetPlayerServerId(PlayerId())
    
--     -- Handle model input - could be string or hash
--     local model = modelInput
--     local hash
    
--     if type(modelInput) == 'number' then
--         hash = modelInput
--         -- Try to get display name from hash
--         if IsModelValid(hash) then
--             model = GetDisplayNameFromVehicleModel(hash)
--             if not model or model == 'CARNOTFOUND' then
--                 model = tostring(hash)
--             end
--         else
--             sendNotification({
--                 type = 'ERROR',
--                 title = 'Klaida',
--                 message = 'Automobilis nerastas (neteisingas hash)',
--                 duration = 5000,
--                 icon = 'search'
--             })
--             return false
--         end
--     else
--         -- It's a string
--         model = tostring(modelInput)
--         hash = GetHashKey(model)
        
--         if not IsModelValid(hash) then
--             sendNotification({
--                 type = 'ERROR',
--                 title = 'Klaida',
--                 message = 'Automobilis nerastas (neteisingas modelio pavadinimas)',
--                 duration = 5000,
--                 icon = 'search'
--             })
--             return false
--         end
--     end

--     if not lib.requestModel(hash, 10000) then
--         sendNotification({
--             type = 'ERROR',
--             title = 'Klaida',
--             message = 'Automobilis negali būti pakrautas',
--             duration = 5000,
--             icon = 'exclamation-triangle'
--         })
--         return false
--     end

--     if not plate then
--         plate = exports['s1m1s-vehicleshop']:generatePlate('Land')
--     end

--     -- Spawn the vehicle immediately
--     local coords = GetEntityCoords(cache.ped)
--     local heading = GetEntityHeading(cache.ped)
--     local _vehicle = CreateVehicle(hash, coords.x + 3.0, coords.y, coords.z, heading, true, false)
    
--     while not DoesEntityExist(_vehicle) do
--         Wait(100)
--     end

--     -- Set vehicle properties
--     local props = exports['s1m1s-garagev3']:GetVehicleProperties(_vehicle)
--     props.plate = string.upper(plate)

--     if fulltune == 1 then
--         SetVehicleModKit(_vehicle, 0)
--         SetVehicleMod(_vehicle, 11, GetNumVehicleMods(_vehicle, 11) - 1, false)
--         SetVehicleMod(_vehicle, 12, GetNumVehicleMods(_vehicle, 12) - 1, false)
--         SetVehicleMod(_vehicle, 13, GetNumVehicleMods(_vehicle, 13) - 1, false)
--         SetVehicleMod(_vehicle, 15, GetNumVehicleMods(_vehicle, 15) - 1, false)
--         ToggleVehicleMod(_vehicle, 18, true)
--         SetVehicleMod(_vehicle, 16, GetNumVehicleMods(_vehicle, 16) - 1, false)
--     end

--     -- Set full gas
--     SetVehicleFuelLevel(_vehicle, 100.0)
    
--     SetVehicleNumberPlateText(_vehicle, plate)
--     SetEntityAsMissionEntity(_vehicle, true, true)
    
--     sendNotification({
--         type = 'SUCCESS',
--         title = 'Automobilis gauta!',
--         message = 'Importo kodas: ' .. uid .. '\nNaudokite /importcar ' .. uid .. ' norėdami išsaugoti garaže',
--         duration = 10000,
--         icon = 'car'
--     })

--     local logas = {
--         ['Player'] = _source,
--         ['Log'] = 'receive_vehicle',
--         ['Title'] = 'Received Vehicle',
--         ['Message'] = 'Import Code: `'..uid..'`\nSpawn: `' ..model.. '` \nPlate: `' ..plate..'`\nFull Tune: `'..((fulltune == 1) and 'yes' or 'no')..'`\nGift: `'..((present == 1) and 'yes' or 'no')..'`',
--         ['Color'] = 'green',
--     }

--     TriggerServerEvent('Boost-Logs:SendLog', logas)
-- end)

-- Remove the old callback since we're using direct event now
lib.callback.register('givecar:spawnvehicle', function(modelInput, plate, fulltune, uid, present)
    -- This callback is no longer used but kept for compatibility
    return true, modelInput
end)