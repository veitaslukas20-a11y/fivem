local ped, open = nil, false

local function registerMenu()
    local options = {
        {
            title = 'Pasidaryti asmens tapatybės kortelę',
            description =
            'Paprašyk darbuotojos, kad ji tave nufotografuotų ir užsakytu padaryti ar atnaujinti asmens tapatybės kortelę. Kaina: 10 000€.',
            event = 'onex-dokumentai:create',
            args = { type = 'tapatybe' },
        },
        {
            title = 'Pasidaryti vairuotojo pažymėjimą',
            description =
            'Paprašyk darbuotojos, kad ji tave nufotografuotų ir užsakytu padaryti ar atnaujinti vairuotojo pažymėjimą. Kaina: 10 000€.',
            event = 'onex-dokumentai:create',
            args = { type = 'teises' },
        },
        {
            title = 'Pakeisti savo pavardę',
            description = 'Pasirašyti dokumentus, kuriuose nurodysite savo naują pavardę. Kaina: 5 000 000€.',
            event = 'onex-dokumentai:create',
            args = { type = 'pavarde' },
        },
        {
            title = 'Pakeisti savo vardą',
            description = 'Pasirašyti dokumentus, kuriuose nurodysite savo naują vardą. Kaina: 5 000 000€.',
            event = 'onex-dokumentai:create',
            args = { type = 'vardas' },
        },
        {
            title = 'Pasidaryti policijos pareigūno pažymėjimą',
            description = 'Paprašyk darbuotojos, kad ji tave nufotografuotų ir užsakytu padaryti ar atnaujinti policijos pareigūno pažymėjimą. Kaina: 10 000€.',
            event = 'onex-dokumentai:create',
            args = { type = 'policija' },
        }
    }
    lib.registerContext({
        id = 'create_document',
        title = 'Dokumentai',
        options = options,
    })
end

local function openMenu()
    CreateThread(function()
        while open do
            if IsControlPressed(1, 177) then
                SendNUIMessage({
                    show = false
                })
                open = false
                break
            end
            Wait(6)
        end
    end)
end

local function isWearingAMask()
    local turi = true
    local index = GetPedDrawableVariation(cache.ped, 1)
    if index <= 0 or Config.NotHideMasks[index] then turi = false end
    if not turi then
        local index2 = GetPedPropIndex(cache.ped, 0)
        if Config.HideHelmets[index2] then
            turi = true
        end
    end
    return turi
end

CreateThread(function()
    lib.requestModel('a_f_y_business_02')
    ped = CreatePed(4, `a_f_y_business_02`, -139.0927, -633.9534, 167.8205, 3.9761, false, true)

    exports.ox_target:addLocalEntity(ped, {
        {
            label = 'Kalbėtis su darbuotoja',
            event = "onex-dokumentai:menu",
            icon = "fa-solid fa-user-clock",
            distance = 1.5
        }
    })

    FreezeEntityPosition(ped, true)
    SetEntityInvincible(ped, true)
    SetBlockingOfNonTemporaryEvents(ped, true)

    for k, v in pairs(Config.Locations) do
        Config.Locations[k].point = lib.points.new({
            coords = v.coords,
            distance = 4.0,
            teleport = v.teleport,
            text = v.text,
            options = v.options,
        })

        local point = Config.Locations[k].point

        function point:onexit()
            lib.hideTextUI()
        end

        function point:nearby()
            DrawMarker(0, self.coords.x, self.coords.y, self.coords.z, 0, 0, 0, 0, 0, 0, 0.5, 0.5, 0.5, 8, 153, 226, 150, true, false, false, true, nil, nil, false)
            lib.showTextUI(self.text, self.options)

            if self.currentDistance < 2.0 and IsControlJustReleased(0, 38) then
                SetEntityCoords(cache.ped, self.teleport.x, self.teleport.y, self.teleport.z, true, false, false, false)
                FreezeEntityPosition(cache.ped, true)
                Wait(200)
                FreezeEntityPosition(cache.ped, false)
            end
        end
    end

    for _, info in pairs(Config.Blips) do
        info.blip = AddBlipForCoord(info.coords.x, info.coords.y, info.coords.z)
        SetBlipSprite(info.blip, info.id)
        SetBlipDisplay(info.blip, 4)
        SetBlipScale(info.blip, 0.7)
        SetBlipColour(info.blip, info.colour)
        SetBlipAsShortRange(info.blip, true)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString('<font face="Roboto">' .. info.title .. '</font>')
        EndTextCommandSetBlipName(info.blip)
    end

    registerMenu()
end)

RegisterNetEvent('onex-dokumentai:menu', function()
    lib.showContext('create_document')
end)

RegisterNetEvent('onex-dokumentai:showMenu', function(data, type)
    lib.registerContext({
        id = 'onex_dokumentai',
        title = Config.Documents[type].header.title,
        options = {
            {
                title = Config.Documents[type].options[1].title,
                description = Config.Documents[type].options[1].description,
                event = 'onex-dokumentai:show-near',
                args = { type = type, duomenys = data },
            },
            {
                title = Config.Documents[type].options[2].title,
                description = Config.Documents[type].options[2].description,
                event = 'onex-dokumentai:show-player',
                args = { type = type, duomenys = data },
            },
        },
    })
    lib.showContext('onex_dokumentai')
end)

RegisterNetEvent('onex-dokumentai:show-player', function(data)
    SendNUIMessage({
        type = data.type,
        data = data.duomenys,
        show = true
    })
    open = true
    openMenu()
end)

RegisterCommand('showteises', function()
    local testData = {
        type = 'teises',
        duomenys = {
            firstname = 'Jonas',
            lastname = 'Jonaitis',
            birth = '2000-01-01',
            given = '2023-01-01',
            valid = '2026-01-01',
            code = 'LT123456',
            cardnumber = '87654321',
            categories = "B, A1"
        }
    }

    print("[DEBUG] Manually triggering show-player event with test data:", json.encode(testData))

    -- Simulating the document display event
    TriggerEvent('onex-dokumentai:show-player', testData)
end, false)


RegisterNetEvent('onex-dokumentai:show-near', function(data)
    local closestPlayer, closestPlayerDistance = ESX.Game.GetClosestPlayer()
    if closestPlayer ~= -1 and closestPlayerDistance <= 2.0 then
        TriggerServerEvent('onex-dokumentai:show-player', GetPlayerServerId(closestPlayer), data)
    else
        lib.defaultNotify({
            title = 'Nėra žaidėjų šalia',
            description = 'Aplink jus nėra jokių žaidėjų, kuriems galėtumėte duoti tapatybės kortelę.',
            status = 'error'
        })
    end
end)

RegisterNetEvent('onex-dokumentai:create', function(data)
    if data.type == 'policija' and ESX.GetPlayerData().job.name ~= 'police' then
        lib.defaultNotify({
            title = 'Klaida',
            description = 'Nesate policijos pareigūnas',
            status = 'error'
        })
        return
    end
    if isWearingAMask() then
        lib.defaultNotify({
            title = 'Klaida',
            description =
            'Atsisakau jus aptarnauti, kadangi jūs dėvite kaukę arba šalmą. Prašome nusiimti apdarus dengiančius veidą ir slepiančius jūsų tapatybę.',
            status = 'error'
        })
        return
    end
    if data.type == 'vardas' then
        local input = lib.inputDialog('Pasikeiskite vardą', {
            { type = 'input', label = 'Įveskite vardą', description = 'Įveskite norimą savo vardą', required = true, min = 2, max = 20 },
        })
        if not input then return end

        data.input = input[1]
    elseif data.type == 'pavarde' then
        local input = lib.inputDialog('Pasikeiskite pavardę', {
            { type = 'input', label = 'Įveskite pavardę', description = 'Įveskite norimą savo pavardę', required = true, min = 2, max = 20 },
        })

        if not input then return end

        data.input = input[1]
    end

    local state, text, makeNew = lib.callback.await('onex-dokumentai:check', false, data, data.input)
    if not state and not makeNew then
        lib.defaultNotify({
            title = 'Klaida',
            description = text,
            status = 'info'
        })
        return
    end

    if state or makeNew then
        DoScreenFadeOut(100)
        SetEntityCoords(cache.ped, -137.9715, -627.6572, 168.8205, true, false, false, false)
        FreezeEntityPosition(ped, false)
        SetEntityCoords(ped, -141.3856, -627.9413, 168.8205, true, false, false, false)
        Wait(1000)
        DoScreenFadeIn(100)
        FreezeEntityPosition(ped, true)
        FreezeEntityPosition(cache.ped, true)
        SetEntityHeading(cache.ped, 99.6314)
        SetEntityHeading(ped, 271.2104)
        local dict, anim = "amb@world_human_paparazzi@male@base", "base"
        while not HasAnimDictLoaded(dict) do
            RequestAnimDict(dict)
            Wait(50)
        end
        TaskPlayAnim(ped, dict, anim, 1.5, 1.5, -1, 1, 0, false, false, false)
        RemoveAnimDict(dict)
        local model, bone, propPlacement = 'prop_pap_camera_01', 28422, { 0.0, 0.0, 0.0, 0.0, 0.0, 0.0 }
        local hash = GetHashKey(model)
        while not HasModelLoaded(hash) do
            RequestModel(hash)
            Wait(50)
        end
        local coords = GetEntityCoords(ped)
        local newProp = CreateObject(hash, coords.x, coords.y, coords.z + 0.2, false, true, false)
        AttachEntityToEntity(newProp, ped, GetPedBoneIndex(ped, bone), propPlacement[1] + 0.0,
            propPlacement[2] + 0.0, propPlacement[3] + 0.0, propPlacement[4] + 0.0, propPlacement[5] + 0.0,
            propPlacement[6] + 0.0, true, true, false, false, 1, true)
        SetFlash(0, 0, 100, 200, 100)
        Wait(300)
        SetFlash(0, 0, 100, 200, 100)
        Wait(300)
        SetFlash(0, 0, 100, 200, 100)
        Wait(300)
        SetFlash(0, 0, 100, 200, 100)
        Wait(2500)
        DoScreenFadeOut(100)
        SetEntityAsMissionEntity(newProp)
        DeleteEntity(newProp)
        FreezeEntityPosition(ped, false)
        ClearPedTasksImmediately(ped)
        SetEntityCoords(ped, -139.0927, -633.9534, 167.8205, true, false, false, false)
        FreezeEntityPosition(ped, true)
        SetEntityHeading(ped, 12.9165)
        Wait(1000)
        DoScreenFadeIn(100)
        FreezeEntityPosition(cache.ped, false)
        SendNUIMessage({
            upload = true,
            data = data,
            image = exports["MugShotBase64"]:GetMugShotBase64(cache.ped, true),
        })
    end
end)

RegisterNUICallback('uploadResult', function(data, cb)
    local res = lib.callback.await('onex-dokumentai:create', false, data)
    cb(true)
end)

AddEventHandler('onResourceStop', function(resourceName)
    if (GetCurrentResourceName() == resourceName) then
        if ped then
            DeletePed(ped)
        end
    end
end)

RegisterCommand('testdocumentas', function()
    -- Mock test data
    local testData = {
        type = "tapatybe", -- Change this to 'tapatybe', 'policija', etc. to test different types
        firstname = "Jonas",
        lastname = "Petrauskas",
        birth = "1995-06-20",
        sex = "Vyras",
        cardnumber = math.random(100000, 999999), -- Generate random card number
        valid = "2030-12-31", -- Example expiry date
        given = "233-23-22", -- Issued date
        categories = "B, C", -- Example driving categories
        image = exports["MugShotBase64"]:GetMugShotBase64(cache.ped, true) -- Player image
    }

    -- Send test data to UI
    SendNUIMessage({
        upload = true,
        data = testData,
        image = testData.image,
    })

    print("✅ Test document triggered successfully!")
end, false)

local function requestDocument(docType)
    local playerId = GetPlayerServerId(PlayerId())

    print(("[DEBUG] Client Export `%s` triggered by player: %s"):format(docType, playerId))

    -- Request data from the server based on document type
    TriggerServerEvent('onex-dokumentai:getDocument', docType)
end

-- Export functions for `teises` and `tapatybe`
exports('teises', function()
    requestDocument('teises')
end)

exports('tapatybe', function()
    requestDocument('tapatybe')
end)

-- Receive the data from the server and open the document
RegisterNetEvent('onex-dokumentai:receiveDocument', function(data, docType)
    print(("[DEBUG] Received `%s` data from server: %s"):format(docType, json.encode(data)))

    -- Display the menu with the retrieved document data
    TriggerEvent('onex-dokumentai:showMenu', data, docType)
end)
