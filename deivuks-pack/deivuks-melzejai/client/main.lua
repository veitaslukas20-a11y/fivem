local Cows, Ped, Table, Puodas, melzejai_dirba, apranga_melzejai = {}, nil, nil, nil, false, false
local Target = exports.ox_target
local Onex = exports['onex-utils']
local Inventory = exports.ox_inventory

local function PlayLoading(label, time, anim)
    return lib.progressBar({
        duration = time,
        label = label,
        useWhileDead = false,
        canCancel = true,
        disable = {
            car = true,
            move = true,
            sprint = true,
            combat = true,
        },
        anim = anim,
    })
end

Citizen.CreateThread(function()
    while not ESX.IsPlayerLoaded() do Wait(500) end

    lib.points.new({
        coords = vec3(deivuks_melzejai.Ped),
        distance = 100,
        onEnter = function()
            local cowModel = `a_c_cow`
            lib.requestModel(cowModel)

            for k,v in pairs(deivuks_melzejai.Cows) do
                Cows[k] = {
                    entity = CreatePed(4, cowModel, v.x, v.y, v.z -1.2, v.w, false, true),
                    melze = 0
                }

                local cow = Cows[k]
                Target:addLocalEntity(cow.entity,{
                    {
                        icon = "fa-solid fa-cow",
                        label = "Melžti karvę",
                        name = 'melzejai:melzti',
                        coords = vec3(v.x, v.y, v.z),
                        id = k,
                        distance = 1.5,
                        onSelect = function(data)
                            Melzti(data.entity, k)
                        end,
                    }
                })
                FreezeEntityPosition(cow.entity, true)
                SetEntityInvincible(cow.entity, true)
                SetBlockingOfNonTemporaryEvents(cow.entity, true)
            end

            SetModelAsNoLongerNeeded(cowModel)

            local pedModel = `a_f_o_genstreet_01`
            lib.requestModel(pedModel)

            Ped = CreatePed(4, pedModel, deivuks_melzejai.Ped.x, deivuks_melzejai.Ped.y, deivuks_melzejai.Ped.z -1.0, deivuks_melzejai.Ped.w, false, true)

            Target:addLocalEntity(Ped,{
                {
                    icon = "fa-solid fa-chalkboard-user",
                    label = "Kalbėtis su darbdave",
                    name = 'melzejai:meniu',
                    distance = 1.5,
                    onSelect = function(data)
                        MelzejaiMeniu(data.entity)
                    end,
                }
            })
            FreezeEntityPosition(Ped, true)
            SetEntityInvincible(Ped, true)
            SetBlockingOfNonTemporaryEvents(Ped, true)
            SetModelAsNoLongerNeeded(pedModel)
        end,
        onExit = function()
            for _, cow in pairs(Cows) do
                Target:removeLocalEntity(cow.entity)
                DeleteEntity(cow.entity)
            end

            if Ped then
                Target:removeLocalEntity(Ped)
                DeletePed(Ped)
            end
        end
    })

    Target:addBoxZone({
        coords = deivuks_melzejai.In,
        size = vec3(1.0, 1.0, 1.0),
        rotation = 0.0,
        drawSprite = true,
        options = {
            {
                icon = "fa-solid fa-person-walking",
                label = "Įeiti",
                name = 'melzejai:go',
                distance = 3.5,
                onSelect = function(data)
                    Ieti()
                end,
            }
        },
    })
end)

local blips_melzejai = {
	{title = "Melžėjų darbovietė", colour = 4, id = 141, coords = vec3(967.3152, -2251.2212, 30.5547)},
	{title = "Pieno fabrikas", colour = 4, id = 473, coords = vec3(978.3676, -2227.0081, 31.6517)}
}

Citizen.CreateThread(function()
   for _, info in pairs(blips_melzejai) do
        info.blip = AddBlipForCoord(info.coords.x, info.coords.y, info.coords.z)
        SetBlipSprite(info.blip, info.id)
        SetBlipDisplay(info.blip, 4)
        SetBlipScale(info.blip, 0.7)
        SetBlipColour(info.blip, info.colour)
        SetBlipAsShortRange(info.blip, true)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString('<font face="Roboto">'..info.title..'</font>')
        EndTextCommandSetBlipName(info.blip)
   end
end)

Citizen.CreateThread(function()
    while true do
        for _, cow in pairs(Cows) do
            cow.melze = 0
        end
        Wait(300000)
    end
end)

local curObj
function Melzti(entity, id)
    if apranga_melzejai then
        if melzejai_dirba then return end
        if #(GetEntityCoords(cache.ped) - GetEntityCoords(entity)) > 4.0 then return end

        local cow = Cows[id]

        if cow.melze <= 10 then
            if not Onex:CanCarryItem('nemilk', 1) then
                exports['1x-hud']:sendNotification({
                    type = 'ERROR',
                    title = 'Melžėjai',
                    message = 'Deja, nebeturite pakankamai vietos inventoriuje.',
                    duration = 6000,
                    icon = 'cow'
                })
                return
            end

            melzejai_dirba = true

            local success = PlayLoading('Melžiate karvę...', 10000, {
                dict = 'anim@amb@clubhouse@tutorial@bkr_tut_ig3@',
                clip = 'machinic_loop_mechandplayer',
            })
            if success then
                curObj = entity
                lib.callback.await('d-melzejai:additem', false, entity, 'nemilk', id)
                curObj = nil
                cow.melze += 1
                melzejai_dirba = false
            else
                melzejai_dirba = false
            end
        else
            exports['1x-hud']:sendNotification({
                type = 'ERROR',
                title = 'Melžėjai',
                message = 'Deja, ši karvė jau nebeturi pieno, bandyk melžti kitą.',
                duration = 6000,
                icon = 'cow'
            })
            melzejai_dirba = false
        end
    else
        exports['1x-hud']:sendNotification({
            type = 'ERROR',
            title = 'Melžėjai',
            message = 'Deja, šiuo metu nesate apsirengęs darbinės uniformos.',
            duration = 6000,
            icon = 'cow'
        })
    end
end

function Virinti(entity)
    if apranga_melzejai then
        if melzejai_dirba then return end
        if #(GetEntityCoords(cache.ped) - GetEntityCoords(entity)) > 4.0 then return end

        if not Onex:CanCarryItem('milk', 1) then
            exports['1x-hud']:sendNotification({
                type = 'ERROR',
                title = 'Melžėjai',
                message = 'Deja, nebeturite pakankamai vietos inventoriuje.',
                duration = 6000,
                icon = 'cow'
            })
            return
        end

        if not Inventory:GetItemCount('nemilk', 1) then
            exports['1x-hud']:sendNotification({
                type = 'ERROR',
                title = 'Melžėjai',
                message = 'Deja neturite pakankamai nepasterizuoto pieno vykdyti šiam procesui.',
                duration = 6000,
                icon = 'cow'
            })
            return
        end

        melzejai_dirba = true

        local success = PlayLoading('Pilate pieną...', 2000, {
            dict = 'mini@repair',
            clip = 'fixing_a_ped'
        })
        if success then
            UseParticleFxAssetNextCall("core")
            local smoke = StartParticleFxLoopedAtCoord("exp_grd_bzgas_smoke", deivuks_melzejai.Puodas.x, deivuks_melzejai.Puodas.y, deivuks_melzejai.Puodas.z, 0.0, 0.0, 0.0, 0.5, false, false, false, false)

            local success = PlayLoading('Pienas verda...', 10000, {
                dict = 'timetable@amanda@ig_2',
                clip = 'ig_2_base_amanda',
            })
            if success then
                curObj = entity
                lib.callback.await('d-melzejai:additem', false, entity, 'milk')
                StopParticleFxLooped(smoke, true)
                melzejai_dirba = false
                curObj = nil
            else
                melzejai_dirba = false
            end
        else
            melzejai_dirba = false
        end
    else
        exports['1x-hud']:sendNotification({
            type = 'ERROR',
            title = 'Melžėjai',
            message = 'Deja, šiuo metu nesate apsirengęs darbinės uniformos.',
            duration = 6000,
            icon = 'cow'
        })
    end
end

lib.callback.register('melzejai:getObject', function(obj)
    return apranga_melzejai and melzejai_dirba and DoesEntityExist(obj) and curObj == obj, true
end)

function Ieti()
    SetEntityCoords(cache.ped, deivuks_melzejai.Out.x, deivuks_melzejai.Out.y, deivuks_melzejai.Out.z, true, false, false, false)

    local tableModel = `prop_table_04`
    lib.requestModel(tableModel)

    Table = CreateObject(tableModel, deivuks_melzejai.Table.x, deivuks_melzejai.Table.y, deivuks_melzejai.Table.z, false, true, false)
    SetEntityHeading(Table, deivuks_melzejai.Table.w)
    FreezeEntityPosition(Table, true)

    local potModel = `prop_kitch_pot_huge`
    lib.requestModel(potModel)

    Puodas = CreateObject(potModel, deivuks_melzejai.Puodas.x, deivuks_melzejai.Puodas.y, deivuks_melzejai.Puodas.z, false, true, false)
    SetEntityHeading(Puodas, deivuks_melzejai.Puodas.w)
    FreezeEntityPosition(Puodas, true)

    Target:addLocalEntity(Puodas,{
        {
            icon = "fa-solid fa-fire-burner",
            label = "Virinti pieną",
            name = 'melzejai:virinti',
            distance = 1.5,
            onSelect = function(data)
                Virinti(data.entity)
            end,
        }
    })

    Target:addBoxZone({
        coords = vector3(1087.0445, -3099.4333, -38.9999),
        size = vec3(1.0, 1.0, 1.0),
        rotation = 0.0,
        drawSprite = true,
        options = {
            {
                icon = "fa-solid fa-person-walking",
                label = "Išeiti",
                name = 'melzejai:out',
                distance = 3.5,
                onSelect = function(data)
                    Iseiti(data.entity)
                end,
            }
        },
    })

end

function Iseiti(data)
    Target:removeZone('melzejai:out')

    if Table then
        DeleteEntity(Table)
    end

    if Puodas then
        Target:removeLocalEntity(Puodas)
        DeleteEntity(Puodas)
    end

    melzejai_dirba = false
    SetEntityCoords(cache.ped, deivuks_melzejai.In.x, deivuks_melzejai.In.y, deivuks_melzejai.In.z, true, false, false, false)
end

local function SetUniform()
    TriggerEvent('skinchanger:getSkin', function(skin)
        if skin.sex == 0 then
            if apranga_melzejai then
                ESX.TriggerServerCallback('esx_skin:getPlayerSkin', function(skin)
                    TriggerEvent('skinchanger:loadSkin', skin)
                end)
                exports['1x-hud']:sendNotification({
                    type = 'SUCCESS',
                    title = 'Melžėjai',
                    message = 'Persirengėte į civilinę uniformą.',
                    duration = 6000,
                    icon = 'cow'
                })
                apranga_melzejai = false
            else
                apranga_melzejai = true
                TriggerEvent('skinchanger:loadClothes', skin, deivuks_melzejai.Uniforms.Male)
                exports['1x-hud']:sendNotification({
                    type = 'SUCCESS',
                    title = 'Melžėjai',
                    message = 'Persirengėte į darbinę uniformą.',
                    duration = 6000,
                    icon = 'cow'
                })
            end
        else
            if apranga_melzejai then
                ESX.TriggerServerCallback('esx_skin:getPlayerSkin', function(skin)
                    TriggerEvent('skinchanger:loadSkin', skin)
                end)
                exports['1x-hud']:sendNotification({
                    type = 'SUCCESS',
                    title = 'Melžėjai',
                    message = 'Persirengėte į civilinę uniformą.',
                    duration = 6000,
                    icon = 'cow'
                })
                apranga_melzejai = false
            else
                apranga_melzejai = true
                TriggerEvent('skinchanger:loadClothes', skin, deivuks_melzejai.Uniforms.Female)
                exports['1x-hud']:sendNotification({
                    type = 'SUCCESS',
                    title = 'Melžėjai',
                    message = 'Persirengėte į darbinę uniformą.',
                    duration = 6000,
                    icon = 'cow'
                })
            end
        end
    end)
end

function MelzejaiMeniu(entity)
    if #(GetEntityCoords(entity) - GetEntityCoords(cache.ped)) > 3.0 then return end

    lib.registerContext({
        id = 'melzejai',
        title = 'Melžėjai',
        options = {
            {
                title = 'Persirengti',
                description = 'Persirenkite darbinę/civilinę uniformą.',
                onSelect = function()
                    SetUniform()
                end
            },
            {
                title = 'Parduoti pieną',
                description = 'Parduoti visą turimą pasterizuotą pieną.',
                onSelect = function()
                    local count, price = lib.callback.await('d-melzejai:parduoti', false)
                    if count then
                        exports['1x-hud']:sendNotification({
                            type = 'SUCCESS',
                            title = 'Melžėjai',
                            message = ('Šaunuolis, gerai padirbėjai, ačiū už %s pieno pakuotes, štai tavo atlygis: %s'):format(count, price),
                            duration = 6000,
                            icon = 'cow'
                        })
                    else
                        exports['1x-hud']:sendNotification({
                            type = 'ERROR',
                            title = 'Melžėjai',
                            message = 'Neturi pieno pakuočių, kurias galėtum man parduoti.',
                            duration = 6000,
                            icon = 'cow'
                        })
                    end
                end
            },
        },
    })
    lib.showContext('melzejai')
end

AddEventHandler('onResourceStop', function(resourceName)
    if (GetCurrentResourceName() ~= resourceName) then return end

    for _, cow in pairs(Cows) do
        DeletePed(cow.entity)
        Target:removeLocalEntity(cow.entity)
    end

    if Table then
        DeleteEntity(Table)
    end

    if Puodas then
        Target:removeLocalEntity(Puodas)
        DeleteEntity(Puodas)
    end

    Target:removeZone('melzejai')
    Target:removeZone('melzejai2')

    if Ped then
        Target:removeLocalEntity(Ped)
        DeletePed(Ped)
    end
end)