local Inventory = exports.ox_inventory
local Onex = exports['onex-utils']

local Config = {}

CreateThread(function()
    while not ESX.IsPlayerLoaded() do Wait(500) end
    local Data = lib.callback.await('DDistillery:getConfig', false)
    Config = Data

    local SpawnedPed = nil
    local ped = Config.Ped
    local point = lib.points.new({
        coords = vec3(ped.x, ped.y, ped.z),
        distance = 20.0,
    })
     
    function point:onEnter()
        if SpawnedPed then return end

        RequestModel(`a_m_m_hillbilly_01`)
        while not HasModelLoaded(`a_m_m_hillbilly_01`) do
            Wait(100)
        end
        SpawnedPed = CreatePed(4, `a_m_m_hillbilly_01`, ped.x, ped.y, ped.z -1.0, ped.w, false, true)
        FreezeEntityPosition(SpawnedPed, true)
        SetEntityInvincible(SpawnedPed, true)
        SetBlockingOfNonTemporaryEvents(SpawnedPed, true)
        NetworkFadeInEntity(SpawnedPed, true, true)

        exports.ox_target:addLocalEntity(SpawnedPed, {
            {
                label = 'Kalbėtis su ūkininku',
                name = 'distillery_sell',
                icon = 'fa-solid fa-wheat-awn',
                distance = 2.0,
                onSelect = function()
                    lib.registerContext({
                        id = 'distillery_main',
                        title = 'Ūkininkas',
                        options = {
                            {
                                title = 'Parduoti samagoną',
                                description = 'Parduoti visą turimą samagoną ūkininkui.',
                                icon = 'fa-solid fa-wheat-awn',
                                onSelect = function(args)
                                    TriggerServerEvent('d-distillery:sellitems')
                                end,
                            }
                        }
                    })
                
                    lib.showContext('distillery_main')
                end
            }
        })
    end
     
    function point:onExit()
        if not SpawnedPed then return end

        DeletePed(SpawnedPed)
        exports.ox_target:removeLocalEntity(SpawnedPed, 'distillery_sell')

        SpawnedPed = nil
    end
end)

local PropPoints = {}

local function MainMenu(netid)
    local data = lib.callback.await('distillery:getObject', false, netid)
    if not data then return end 

    local Options = {}

    if not data.progress then
        table.insert(Options, {
            title = 'Pasirinkti samagono tipą',
            description = 'Pasirinkite samagono tipą, nuo to priklausys kokie ingridientai bus reikalingi.',
            disabled = data.ingridients ~= nil,
            icon = 'fa-solid fa-flask',
            onSelect = function(args)
                local input = lib.inputDialog('Pasirinkti samagono tipą', {
                    {type = 'select', label = 'Pasirinkite samagono tipą', description = 'Pasirinkite samagono tipą, nuo to priklausys kokie ingridientai bus reikalingi.', required = true, options = {
                        {value = 'grudai', label = 'Paprastas samagonas'},
                        {value = 'moliugas', label = 'Moliūgų skonio samagonas'},
                        {value = 'apelsinas', label = 'Apelsinų skonio samagonas'},
                        {value = 'avietes', label = 'Aviečių skonio samagonas'},
                    }, default = 'grudai'},
                })

                if not input then return end
                TriggerServerEvent('distilery:update', data.netid, 'type', input[1])
            end,
        })

        local required = data.type and Config.RequireItems[data.type] or Config.RequireItems['grudai']
        local Metadata = {}

        for item, info in pairs(required) do 
            if not info.label then 
                info.label = Onex:getLabel(item)
            end

            Metadata[info.label] = info.count
        end

        table.insert(Options, {
            title = 'Sudėti ingridientus',
            description = 'Sudėti ingridientus į virimo aparatą.',
            icon = 'fa-solid fa-wheat-awn',
            disabled = not data.type or (data.ingridients ~= nil),
            metadata = Metadata,
            onSelect = function(args)
                local done =  DDistillery.Progress("Sudedate ingridientus...", 5000, {
                    dict = 'anim@amb@clubhouse@tutorial@bkr_tut_ig3@',
                    clip = 'machinic_loop_mechandplayer',
                    flag = 1,
                })
                if not done then return end 

                TriggerServerEvent('distilery:update', data.netid, 'ingridients', true)
            end,
        })

        table.insert(Options, {
            title = 'Įkaitinti aparatą',
            description = 'Įkaitinti samagono aparatą ir pradėti virimą.',
            disabled = (not data.type or not data.ingridients) or data.heated,
            icon = 'fa-solid fa-temperature-arrow-up',
            onSelect = function(args)
                local success = lib.skillCheck({'easy', 'easy', {areaSize = 60, speedMultiplier = 2}})
                if not success then DDistillery.Explode(ent) return end 

                local done =  DDistillery.Progress("Įkaitinamas virimo aparatas...", 5000, {
                    dict = 'anim@amb@clubhouse@tutorial@bkr_tut_ig3@',
                    clip = 'machinic_loop_mechandplayer',
                    flag = 1,
                })
                if not done then return end 

                TriggerServerEvent('distilery:update', data.netid, 'heated', true)
            end,
        })
    end

    if data.progress then 

        table.insert(Options, {
            title = not data.filtered and 'Gamybos procesas' or 'Filtravimo procesas',
            description = 'Apačioje galite matyti, kiek liko iki proceso pabaigos.',
            icon = not data.filtered and 'fa-solid fa-temperature-high' or 'fa-solid fa-filter',
            progress = data.progress,
            metadata = {
                ['Procesas'] = data.progress..'%',
            }
        })

        if data.progress >= 100 and not data.filtered then
            table.insert(Options, {
                title = 'Filtruoti samagoną',
                description = 'Išfiltruokite samagoną, kad jį būtų galima išpilstyti.',
                icon = 'fa-solid fa-filter',
                onSelect = function(args)
                    local done =  DDistillery.Progress("Pradedate filtravimą...", 5000, {
                        dict = 'anim@amb@clubhouse@tutorial@bkr_tut_ig3@',
                        clip = 'machinic_loop_mechandplayer',
                        flag = 1,
                    })
                    if not done then return end 

                    TriggerServerEvent('distilery:update', data.netid, 'filtered', true)
                end,
            })
        end

        if data.progress >= 100 and data.filtered then 
            table.insert(Options, {
                title = 'Išpilstyti samagoną',
                description = 'Išpilstyti samagoną į butelius.',
                icon = 'fa-solid fa-wine-bottle',
                onSelect = function(args)
                    local done =  DDistillery.Progress("Išpilstote samagoną...", 5000, {
                        dict = 'anim@amb@clubhouse@tutorial@bkr_tut_ig3@',
                        clip = 'machinic_loop_mechandplayer',
                        flag = 1,
                    })
                    if not done then return end 

                    TriggerServerEvent('distilery:end', data.netid)
                end,
            })
        end

    end

    table.insert(Options, {
        title = 'Panaikinti samagono aparatą',
        description = 'Panaikinti samagono aparatą ir nutraukti gamybą.',
        icon = 'fa-solid fa-trash',
        onSelect = function(args)
            local done =  DDistillery.Progress("Išardote aparatą...", 5000, {
                dict = 'anim@amb@clubhouse@tutorial@bkr_tut_ig3@',
                clip = 'machinic_loop_mechandplayer',
                flag = 1,
            })
            if not done then return end 

            TriggerServerEvent('distillery:removeObject', false, data.netid)
        end,
    })

    lib.registerContext({
        id = 'distillery_main',
        title = 'Samagono virimas',
        options = Options
    })

    lib.showContext('distillery_main')
end

exports('samaparatas', function(data)
    local coords = DDistillery.ForwardVector()

    if GetClosestObjectOfType(coords.x, coords.y, coords.z, 1.5, `prop_still`) ~= 0 then 
        DDistillery.Notify('Virimo aparato pastatyti vienas šalia kito negalite.') 
        return false 
    end

    if not DDistillery.IsOnGrass(Config.Grass) then 
        DDistillery.Notify('Šioje vietoje virimo aparato pastatyti negalite, jis gali stovėti tik ant žolės arba kitos dangos kaip smėlio ar panašiai.')
        return false
    end

    local result = DDistillery.Progress("Surenkamas gamybos aparatas...", 5000, {
        dict = 'anim@amb@clubhouse@tutorial@bkr_tut_ig3@',
        clip = 'machinic_loop_mechandplayer',
        flag = 1
    })

    if not result then return false end 

    TriggerServerEvent('distillery:spawnMachine', coords, GetEntityHeading(cache.ped))
end)

AddStateBagChangeHandler("samaparatas", nil, function(bagName, key, value) 
    local entity = GetEntityFromStateBagName(bagName)
    if entity == 0 then return end

    while not DoesEntityExist(entity) do 
        Wait(100)
    end

    local netid = NetworkGetNetworkIdFromEntity(entity)

    exports.ox_target:addEntity(netid, {
        {
            label = 'Atidaryti gamybos meniu',
            icon = 'fa-solid fa-bottle-droplet',
            name = 'samaparatas:'..netid,
            distance = 2.0, 
            onSelect = function()
                MainMenu(netid)
            end,
        }
    })
end)