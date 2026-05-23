local perdirbejai_dirba, perdirbejai_apranga = false, false
local Target = exports.ox_target
local Onex = exports['onex-utils']
local Inventory = exports.ox_inventory

Citizen.CreateThread(function()
    while not ESX.IsPlayerLoaded() do Wait(500) end

    Target:addModel({
        `prop_dumpster_01a`,
        `prop_cs_dumpster_01a`,
        `p_dumpster_t`,
        `prop_dumpster_3a`,
        `prop_dumpster_4b`,
        `prop_dumpster_4a`,
        `prop_dumpster_02b`,
        `prop_dumpster_02a`,
        `prop_cs_bin_03`,
        `prop_cs_bin_02`,
        `prop_cs_bin_01`,
        `prop_cs_bin_01_skinned`,
        `prop_cs_bin_02`,
        `prop_bin_07b`,
        `prop_bin_01a`,
        `zprop_bin_01a_old`,
        `prop_recyclebin_03_a`,
        `prop_bin_07c`,
        `prop_bin_06a`,
        `prop_bin_07d`,
        `prop_bin_11b`,
        `prop_bin_04a`,
        `prop_bin_08a`,
        `prop_bin_02a`,
        `prop_bin_03a`,
        `prop_bin_08open`,
        `prop_bin_05a`,
        `prop_bin_07a`,
    }, {
        {
            icon = "fa-solid fa-dumpster",
            label = "Rinkti šiukšles",
            distance = 1.0,
            name = "d-perdirbimas:rinkti",
            onSelect = function(data)
                Rinkti(data.entity)
            end,
        },
    })

    local Conveyor, Ped = {}, {}
    for i = 1, 2 do
        local blip = AddBlipForCoord(deivuks_perdirbimas.Ped[i].x, deivuks_perdirbimas.Ped[i].y, deivuks_perdirbimas.Ped[i].z)
        SetBlipSprite(blip, 318)
        SetBlipDisplay(blip, 4)
        SetBlipScale(blip, 0.7)
        SetBlipColour(blip, 52)
        SetBlipAsShortRange(blip, true)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString('<font face="Roboto">Šiukšlių perdirbimo įmonė</font>')
        EndTextCommandSetBlipName(blip)

        local function spawnConveyor()
            if Conveyor[i] then return end
            local model = `prop_ind_conveyor_01`
            lib.requestModel(model)
            Conveyor[i] = CreateObject(model, deivuks_perdirbimas.Konvejeris[i].x, deivuks_perdirbimas.Konvejeris[i].y, deivuks_perdirbimas.Konvejeris[i].z, false, true, false)
            SetEntityHeading(Conveyor[i], deivuks_perdirbimas.Konvejeris[i].w)
            PlaceObjectOnGroundProperly(Conveyor[i])
            FreezeEntityPosition(Conveyor[i], true)

            Target:addLocalEntity(Conveyor[i], {
                {
                    name = "d-perdirbimas:perdirbti",
                    icon = "fa-solid fa-recycle",
                    label = "Perdirbti šiukšles",
                    onSelect = function(data)
                        Perdirbti(i)
                    end,
                    distance = 3.0
                },
            })
        end

        local function spawnPed()
            if Ped[i] then return end
            local model = `s_m_y_garbage`
            lib.requestModel(model)
            Ped[i] = CreatePed(4, model, deivuks_perdirbimas.Ped[i].x, deivuks_perdirbimas.Ped[i].y, deivuks_perdirbimas.Ped[i].z -1.0, deivuks_perdirbimas.Ped[i].w, false, true)
            Target:addLocalEntity(Ped[i], {
                {
                    name = "d-perdirbimas:meniu",
                    icon = "fa-solid fa-chalkboard-user",
                    label = "Kalbėtis su darbdaviu",
                    distance = 1.5,
                    onSelect = function()
                        SiuksMenu(i)
                    end,
                },
            })
            FreezeEntityPosition(Ped[i], true)
            SetEntityInvincible(Ped[i], true)
            SetBlockingOfNonTemporaryEvents(Ped[i], true)
        end

        local point = lib.points.new({
            coords = vec3(deivuks_perdirbimas.Ped[i]),
            distance = 50,
        })

        function point:onEnter()
            spawnConveyor()
            spawnPed()
        end

        function point:onExit()
            if Conveyor[i] and DoesEntityExist(Conveyor[i]) then
                Target:removeLocalEntity(Conveyor[i])
                DeleteEntity(Conveyor[i])
            end
            if Ped[i] and DoesEntityExist(Ped[i]) then
                Target:removeLocalEntity(Ped[i])
                DeleteEntity(Ped[i])
            end
            Conveyor[i] = nil
            Ped[i] = nil
        end
    end
end)

local currObj
function Perdirbti(index)
    if perdirbejai_apranga then
        if perdirbejai_dirba then return end

        if Inventory:GetItemCount('siuksles') == 0 then
            exports['1x-hud']:sendNotification({
                type = 'ERROR',
                title = 'Perdirbimas',
                message = 'Deja, neturite pakankamai resursų atlikti šį veiksmą.',
                duration = 6000,
                icon = 'helmet-safety'
            })
            return
        end

        if not Onex:CanCarryItem('plastikas', 1) then
            exports['1x-hud']:sendNotification({
                type = 'ERROR',
                title = 'Perdirbimas',
                message = 'Deja, neturite pakankamai vietos inventoriuje.',
                duration = 6000,
                icon = 'helmet-safety'
            })
            return
        end

        perdirbejai_dirba = true

        local result = PlayPerdirbimas('Praplešiate šiukšlių maišą...', 2000, {
            dict = 'mini@repair',
            clip = 'fixing_a_ped',
        })
        if not result then
            perdirbejai_dirba = false
            return
        end

        local coords = GetEntityCoords(cache.ped) + GetEntityForwardVector(cache.ped) * 1.0
        local flotsam = `prop_rub_flotsam_01`
        lib.requestModel(flotsam)
        local siuksles = CreateObject(flotsam, coords.x, coords.y, coords.z, false, true, false)
        while not SlideObject(siuksles, deivuks_perdirbimas.Siuksles[index].x, deivuks_perdirbimas.Siuksles[index].y, deivuks_perdirbimas.Siuksles[index].z, 0.05, 0.05, 0.05, false) do
            Citizen.Wait(0)
        end
        SetModelAsNoLongerNeeded(flotsam)

        currObj = siuksles
        local success = lib.callback.await('d-perdirbimas:additem', false, siuksles, false, index, false)
        if success or not success then
            perdirbejai_dirba = false
        end
        currObj = nil

        DeleteEntity(siuksles)

        SetEntityAsNoLongerNeeded(siuksles)
    else
        exports['1x-hud']:sendNotification({
            type = 'ERROR',
            title = 'Perdirbimas',
            message = 'Deja, šiuo metu nesate apsirengęs darbinės uniformos.',
            duration = 6000,
            icon = 'helmet-safety'
        })
    end
end

function Rinkti(entity)
    if perdirbejai_apranga then
        if perdirbejai_dirba then return end

        if not Onex:CanCarryItem('siuksles', 1) then
            exports['1x-hud']:sendNotification({
                type = 'ERROR',
                title = 'Perdirbimas',
                message = 'Deja, neturite pakankamai vietos inventoriuje.',
                duration = 6000,
                icon = 'helmet-safety'
            })
            return
        end

        perdirbejai_dirba = true

        local result = PlayPerdirbimas('Renkate šiukšles...', 10000, {
            scenario = 'PROP_HUMAN_BUM_BIN',
        })

        if not result then
            perdirbejai_dirba = false
            return
        end

        currObj = entity
        local success = lib.callback.await('d-perdirbimas:additem', false, entity, true)
        if success or not success then
            perdirbejai_dirba = false
        end
        currObj = nil
    else
        exports['1x-hud']:sendNotification({
            type = 'ERROR',
            title = 'Perdirbimas',
            message = 'Deja, šiuo metu nesate apsirengęs darbinės uniformos.',
            duration = 6000,
            icon = 'helmet-safety'
        })
    end
end

lib.callback.register('perdirbimas:getObject', function(obj)
    return perdirbejai_apranga and perdirbejai_dirba and DoesEntityExist(obj) and obj == currObj, true
end)

local function setUniform()
    TriggerEvent('skinchanger:getSkin', function(skin)
        if skin.sex == 0 then
            if perdirbejai_apranga then
                ESX.TriggerServerCallback('esx_skin:getPlayerSkin', function(skin)
                    TriggerEvent('skinchanger:loadSkin', skin)
                end)
                exports['1x-hud']:sendNotification({
                    type = 'INFO',
                    title = 'Perdirbimas',
                    message = 'Persirengėte į civilinę uniformą.',
                    duration = 6000,
                    icon = 'helmet-safety'
                })

                perdirbejai_apranga = false
                perdirbejai_dirba = false
            else
                local clothesSkin = {
                    ['tshirt_1'] = 15, ['tshirt_2'] = 0,                -- You need to adapt it according to your own server by changing the values below. If you don't know about this, you can contact me.
                    ['torso_1'] = 167, ['torso_2'] = 0,
                    ['decals_1'] = 0, ['decals_2'] = 0,
                    ['arms'] = 99,
                    ['pants_1'] = 149, ['pants_2'] = 0,
                    ['shoes_1'] = 139, ['shoes_2'] = 0,
                    ['helmet_1'] = -1, ['helmet_2'] = 1,
                    ['chain_1'] = 0, ['chain_2'] = 0,
                    ['ears_1'] = -1, ['ears_2'] = 0,
                    ['mask_1'] = 0, ['mask_2'] = 0,
                    ['bags_1'] = 0, ['bags_2'] = 0,
                    ['glasses_1'] = -1, ['glasses_2'] = 0,
                }
                TriggerEvent('skinchanger:loadClothes', skin, clothesSkin)

                perdirbejai_apranga = true
                perdirbejai_dirba = false
            end   
        else
            if perdirbejai_apranga then
                ESX.TriggerServerCallback('esx_skin:getPlayerSkin', function(skin)
                    TriggerEvent('skinchanger:loadSkin', skin)
                end)
                exports['1x-hud']:sendNotification({
                    type = 'INFO',
                    title = 'Perdirbimas',
                    message = 'Persirengėte į civilinę uniformą.',
                    duration = 6000,
                    icon = 'helmet-safety'
                })

                perdirbejai_apranga = false
                perdirbejai_dirba = false
            else
                local clothesSkin = {
                    ['tshirt_1'] = 7, ['tshirt_2'] = 0,                -- You need to adapt it according to your own server by changing the values below. If you don't know about this, you can contact me.
                    ['torso_1'] = 398, ['torso_2'] = 5,
                    ['decals_1'] = 0, ['decals_2'] = 0,
                    ['arms'] = 96,
                    ['pants_1'] = 157, ['pants_2'] = 0,
                    ['shoes_1'] = 94, ['shoes_2'] = 0,
                    ['helmet_1'] = -1, ['helmet_2'] = 0,
                    ['chain_1'] = 0, ['chain_2'] = 0,
                    ['ears_1'] = -1, ['ears_2'] = 0,
                    ['mask_1'] = 0, ['mask_2'] = 0,
                    ['bags_1'] = 0, ['bags_2'] = 0,
                    ['glasses_1'] = -1, ['glasses_2'] = 0,
                    ['bproof_1'] = 0,  ['bproof_2'] = 0,
                }
                TriggerEvent('skinchanger:loadClothes', skin, clothesSkin)

                perdirbejai_apranga = true
                perdirbejai_dirba = false
            end
        end
        exports['1x-hud']:sendNotification({
            type = 'INFO',
            title = 'Perdirbimas',
            message = 'Persirengėte į darbinę uniformą.',
            duration = 6000,
            icon = 'helmet-safety'
        })
    end)
end

local function pridavimas(index)
    if perdirbejai_dirba then return end
    if perdirbejai_apranga then
        if #(GetEntityCoords(cache.ped) - vec3(deivuks_perdirbimas.Ped[index])) < 3.0 then
            perdirbejai_dirba = true
            local notify, type = lib.callback.await('d-perdirbimas:pridavimas', false)
            perdirbejai_dirba = false
            exports['1x-hud']:sendNotification({
                type = string.upper(tostring(type)),
                title = 'Perdirbimas',
                message = notify,
                duration = 6000,
                icon = 'helmet-safety'
            })
        end
    else
        exports['1x-hud']:sendNotification({
            type = 'ERROR',
            title = 'Perdirbimas',
            message = 'Deja, šiuo metu nesate apsirengęs darbinės uniformos.',
            duration = 6000,
            icon = 'helmet-safety'
        })
    end
end

function SiuksMenu(index)
    lib.registerContext({
        id = 'perdirbimas',
        title = 'Šiukšlių perdirbimas',
        onExit = function()
        end,
        options = {
            {
                title = 'Persirengti',
                description = 'Persirenkite darbinę/civilinę uniformą.',
                onSelect = function()
                    setUniform()
                end
            },
            {
                title = 'Priduoti perdirbtas šiukšles',
                description = 'Priduok šiukšles ir gauk atlygį.',
                onSelect = function()
                    pridavimas(index)
                end
            },
        },
    })
    lib.showContext('perdirbimas')
end

function PlayPerdirbimas(label, time, anim)
    return lib.progressBar({
        duration = time,
        label = label,
        useWhileDead = false,
        allowFalling = false,
        allowCuffed = false,
        allowSwimming = false,
        allowRagdoll = false,
        canCancel = true,
        disable = {
            car = true,
            move = true,
            combat = false,
            mouse = false,
            sprint = true,
        },
        anim = anim
    })
end
