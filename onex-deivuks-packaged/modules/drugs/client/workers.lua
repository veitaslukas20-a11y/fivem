SelfData = {}

local LocationTypes = {}

Citizen.CreateThread(function()
    while not ESX.IsPlayerLoaded() do
        Wait(100)
    end

    SelfData = lib.callback.await('drugs:returnSelfData', false) or {}

    while not ConfigDrugs do Wait(100) end

    for _, data in pairs(ConfigDrugs.Plants) do
        if data.Type then
            LocationTypes[#LocationTypes + 1] = {
                value = data.Type.value,
                label = data.Type.label
            }
        end
    end
end)

local function addWorker()
    local Players = lib.getNearbyPlayers(GetEntityCoords(cache.ped), 10.0, false)

    if #Players == 0 then return end

    local options = {}

    for _, player in pairs(Players) do
        local id = GetPlayerServerId(player.id)
        options[#options + 1] = {
            value = id,
            label = ('#%s Žaidėjas'):format(id),
        }
    end

    local input = lib.inputDialog('Pasirinkite naują darbuotoją', {
        {type = 'select', label = 'Pasirinkite žaidėją', description = 'Pasirinkite kurį iš šių šalia esančių žaidėjų norite pridėti į sąrašą.', required = true, options = options},
        {type = 'select', label = 'Pasirinkite lokaciją', description = 'Pasirinkite kuriai iš šių lokacijų priskirsite žaidėją.', required = true, options = LocationTypes},
    })

    if input then
        lib.callback.await('drugs:addWorker', false, input[1], input[2])
    end

    lib.showContext('drugs:workers')
end

local function editWorker(name, identifier, location)
    lib.registerContext({
        id = 'drugs:editworker',
        menu = 'drugs:viewworkers',
        title = name,
        options = {
            {
                title = 'Išmesti darbuotoją',
                description = 'Išmesti darbuotoją iš sąrašo.',
                icon = 'user-minus',
                onSelect = function()
                    local alert = lib.alertDialog({
                        header = 'Ar esi įsitikinęs,',
                        content = 'kad nori išmesti '..name..' darbuotoją?',
                        centered = true,
                        cancel = true
                    })

                    if alert == 'confirm' then
                        lib.callback.await('drugs:removeWorker', false, identifier)
                    else
                        editWorker(name, identifier, location)
                    end
                end,
            },
            {
                title = 'Pakeisti paskirtą lokaciją',
                description = 'Pakeisti darbuotojui paskirtą lokaciją',
                icon = 'user-pen',
                onSelect = function()
                    local input = lib.inputDialog('Pasirinkite lokaciją', {
                        {type = 'select', label = 'Pasirinkite lokaciją', description = 'Pasirinkite kokią lokaciją norite priskirti šiam darbuotojui.', required = true, options = LocationTypes, default = location},
                    })

                    if input then
                        lib.callback.await('drugs:editWorker', false, identifier, input[1])
                        location = input[1]
                    end

                    editWorker(name, identifier, location)
                end,
            }
        }
    })

    lib.showContext('drugs:editworker')
end

local function viewWorkers()
    local workersData = lib.callback.await('drugs:returnWorkers', false)

    if not workersData then return end

    local options = {}

    for _, data in pairs(workersData) do
        table.insert(options, {
            title = data.workerName,
            description = 'Redaguoti darbuotojo '..data.workerName..' informaciją.',
            icon = 'user-pen',
            onSelect = function()
                editWorker(data.workerName, data.workerIdentifier, data.locationName)
            end,
        })
    end

    lib.registerContext({
        id = 'drugs:viewworkers',
        menu = 'drugs:workers',
        title = 'Lokacijų darbuotojai',
        options = options
    })

    lib.showContext('drugs:viewworkers')
end

RegisterCommand('darbininkai', function()
    local gang = ESX.GetPlayerData().job.name
    if not ConfigDrugs.Gangs.Official[gang] and not ConfigDrugs.Gangs.Unofficial[gang] then return end

    if ESX.GetPlayerData().job.grade_name ~= 'boss' then return end

    lib.registerContext({
        id = 'drugs:workers',
        title = 'Lokacijų darbuotojai',
        options = {
            {
                title = 'Pridėti darbuotoją',
                description = 'Pridėti naują darbuotoją prie darbuotojų sąrašo',
                icon = 'user-plus',
                onSelect = function()
                    addWorker()
                end,
            },
            {
                title = 'Peržiūrėti darbuotojus',
                description = 'Peržiūrėkite visus esamus darbuotojus',
                icon = 'map-location-dot',
                onSelect = function()
                    viewWorkers()
                end,
            },
        }
    })

    lib.showContext('drugs:workers')
end, false)

RegisterNetEvent('drugs:removeSelf', function()
    SelfData = {}

    exports['1x-hud']:sendNotification({
        type = 'ERROR',
        title = 'Lokacijų sistema',
        message = 'Jūs buvote išmestas iš lokacijų darbuotojų sąrašo. Nuo dabar jūs vėl rinksite narkotikus normaliu greičiu.',
        duration = 5000,
    })
end)

RegisterNetEvent('drugs:addSelf', function()
    SelfData = lib.callback.await('drugs:returnSelfData', false) or {}

    if SelfData.location then
        for _, data in pairs(LocationTypes) do
            if data.value == SelfData.location then
                exports['1x-hud']:sendNotification({
                    type = 'SUCCESS',
                    title = 'Lokacijų sistema',
                    message = 'Jūs buvote priskirtas prie '..data.label..' lokacijos. Šioje lokacijoje galėsite greičiau rinkti narkotikus.',
                    duration = 5000,
                })
                break
            end
        end
    end
end)