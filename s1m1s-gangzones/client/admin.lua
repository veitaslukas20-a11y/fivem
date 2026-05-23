itemNames = {}
local TempZone = {}

local function sanitizeColor(hex)
    if not hex or hex == '' then return 'FFFFFF' end
    hex = tostring(hex):gsub('#','')
    return string.upper(hex)
end

lib.callback.register('d-gangzones:adminmenu', function()
    lib.registerContext({
        id = 'gangzones:admin',
        title = 'Zonų meniu',
        options = {
            {
                title = 'Sukurti zoną',
                description = 'Sukurti naują gaujos zoną',
                icon = 'fa-solid fa-plus',
                onSelect = function()
                    CreateZone()
                end,
            },
            {
                title = 'Koreguoti sąrašą',
                description = 'Koreguoti gaujų sąrašą',
                icon = 'fa-solid fa-list',
                onSelect = function()
                    EditGangsList()
                end,
            },
            {
                title = 'Koreguoti zonas',
                description = 'Koreguoti gaujos zonas',
                icon = 'fa-solid fa-pen-to-square',
                onSelect = function()
                    EditZones()
                end,
            },
        }
    })

    lib.showContext('gangzones:admin')
end)

function CreateZone()
    local input = lib.inputDialog('Sukurti gaujos zoną', {
        {type = 'input', label = 'Pavadinimas', description = 'Zonos pavadinimas', required = true},
        {type = 'number', label = 'Užėmimo laikas', description = 'Zonos užėmimo laikas minutėmis', icon = 'fa-solid fa-clock', required = true, default = 15},
        {type = 'number', label = 'Cooldown', description = 'Laikas tarp zonos užėmimų valandomis', icon = 'fa-solid fa-clock', required = true, default = 12},
        {type = 'number', label = 'Zonos plotis', description = 'Zonos plotis (zone width)', icon = 'fa-solid fa-arrows-left-right', required = true},
        {type = 'number', label = 'Zonos ilgis', description = 'Zonos ilgis (zone length)', icon = 'fa-solid fa-arrows-up-down', required = true},
        {type = 'number', label = 'Zonos aukštis', description = 'Zonos aukštis (zone height)', icon = 'fa-solid fa-arrow-up', required = true},
        {type = 'select', label = 'Tipas', description = 'Zonos tipas', required = true, options = {
            {value = 'plovimas', label = 'Plovimas'},
            {value = 'blackmarket', label = 'Black market'},
            {value = 'armour', label = 'Šarvų craftinimas'},
            {value = 'ammunition', label = 'Kulkų craftinimas'},
            {value = 'guns', label = 'Ginklų craftinimas'},
            {value = 'guns2', label = 'Ginklų craftinimas 2'},
            {value = 'guns3', label = 'Pistoletų craftinimas'},
            {value = 'taisymas', label = 'Ginklų taisymas'},
            {value = 'drugdealer', label = 'Narkotikų pardavimas'},
            {value = 'addarmour', label = 'Šarvų užsidėjimas'},
            {value = 'bets', label = 'Iš pinigų (statymai)'},
            {value = 'unknown', label = 'Be tikslo'},
        }},
        {type = 'checkbox', label = 'Oficialios gaujos zona', checked = true},
    })

    if not input then return end

    lib.callback.await('d-gangzones:createZone', false, input[1], input[2], input[3], input[4], input[5], input[6], input[7], input[8], GetEntityCoords(cache.ped), GetEntityHeading(cache.ped))
end

function EditGangsList()
    local Options = {}

    table.insert(Options, {
        title = 'Pridėti gaują į sąrašą',
        description = 'Pridėti gaują į gaujų sąrašą',
        icon = 'fa-solid fa-plus',
        onSelect = function()
            local input = lib.inputDialog('Pridėti gaują', {
                {type = 'input', label = 'Gaujos darbas', description = 'Gaujos jobas (pvz:. cartel)', required = true},
                {type = 'checkbox', label = 'Oficialios gaujos zona', checked = true},
                {type = 'color', label = 'Spalva', description = 'Pasirinkite gaujos spalvą', required = true, format = 'hex'},
                {type = 'input', label = 'Gaujos pavadinimas', description = 'Nustatyti gaujos pavadinimą', required = true},
            })


if not input then return EditGangsList() end

local job = string.lower(input[1])
local official = input[2] or false
local color = sanitizeColor(input[3])
local name = input[4] ~= '' and input[4] or job

-- Vietinė runtime būklė (kad meniu iškart atsinaujintų be restarto)
Config.GangsList[job] = Config.GangsList[job] or {}
Config.GangsList[job].official = official
Config.GangsList[job].name = name
Config.GangColors[job] = color

EditGangsList()

-- Persistuoti į DB ir push'inti į visus klientus
lib.callback.await('d-gangzones:addGang', false, job, official, color, name)
        end,
    })

    for k,v in pairs(Config.GangsList) do
        Options[k] = {
            title = k,
            description = 'Koreguoti '..k..' gaują',
            icon = 'fa-solid fa-skull',
            iconColor = Config.GangColors[k] and '#'..Config.GangColors[k] or nil,
            onSelect = function()
                local input = lib.inputDialog('Koreguoti oficialumą', {
                    {type = 'checkbox', label = 'Oficialios gaujos zona', checked = v.official or false},
                    {type = 'color', label = 'Spalva', description = 'Pasirinkite gaujos spalvą', required = true, format = 'hex', default = Config.GangColors[k] and '#'..Config.GangColors[k] or nil},
                    {type = 'input', label = 'Gaujos pavadinimas', description = 'Nustatyti gaujos pavadinimą', required = true, default = Config.GangsList[k]?.name},
                })

if not input then return EditGangsList() end

local official = input[1] or false
local color = sanitizeColor(input[2])
local name = input[3] ~= '' and input[3] or k

Config.GangsList[k].official = official
Config.GangsList[k].name = name
Config.GangColors[k] = color

EditGangsList()

lib.callback.await('d-gangzones:editGang', false, k, official, color, name)
            end,
        }
    end

    lib.registerContext({
        id = 'gangzones:editGangs',
        menu = 'gangzones:admin',
        title = 'Koreguoti gaujas',
        options = Options
    })

    lib.showContext('gangzones:editGangs')
end

function EditZones()
    local Options = {}
    for k,v in pairs(Config.Zones) do
        Options[k] = {
            title = v.title,
            description = 'Koreguoti '..v.title,
            icon = 'fa-solid fa-person-rifle',
            onSelect = function()
                EditZone(string.lower(v.title) ,v)
            end,
        }
    end

    lib.registerContext({
        id = 'gangzones:edit',
        menu = 'gangzones:admin',
        title = 'Koreguoti zonas',
        options = Options
    })

    lib.showContext('gangzones:edit')
end

function EditZone(title, zone)
    TempZone = Config.Zones[title]
    TempZone = json.encode(TempZone)
    TempZone = json.decode(TempZone)

    local Options = {
        {
            title = 'Vieta',
            description = 'Pakeisti vietą',
            icon = 'fa-solid fa-location-arrow',
            onSelect = function()
                local alert = lib.alertDialog({
                    header = 'Ar esate tuom tikras?',
                    content = 'Jūs pakeitėte zonos koordinates, ar norite jas patvirtinti?',
                    centered = true,
                    cancel = true,
                })

                EditZone(title, zone)

                if alert ~= 'confirm' then return end

                ESX.ShowNotification('Jūs pakeitėte zonos koordinates.')

                TempZone.coords = GetEntityCoords(cache.ped)
                TempZone.rotation = GetEntityHeading(cache.ped)
            end,
        },
        {
            title = 'Pavadinimas',
            description = 'Pakeisti pavadinimą',
            icon = 'fa-solid fa-font',
            onSelect = function()
                local input = lib.inputDialog('Pakeisti pavadinimą', {
                    {type = 'input', label = 'Pavadinimas', description = 'Zonos pavadinimas', required = true, default = string.upper(zone.title)},
                })

                EditZone(title, zone)

                if not input then return end

                TempZone.title = input[1]
            end,
        },
        {
            title = 'Pakeisti užėmimo laiką',
            description = 'Pakeisti zonos užemimo laiką',
            icon = 'fa-solid fa-clock',
            onSelect = function()
                local input = lib.inputDialog('Pakeisti užėmimo laiką', {
                    {type = 'number', label = 'Užėmimo laikas', description = 'Zonos užėmimo laikas minutėmis', icon = 'fa-solid fa-clock', required = true, default = zone.time},
                })

                EditZone(title, zone)

                if not input then return end

                TempZone.time = input[1]
            end,
        },
        {
            title = 'Pakeisti cooldown',
            description = 'Pakeisti laiką tarp zonos užėmimų valandomis',
            icon = 'fa-solid fa-clock',
            onSelect = function()
                local input = lib.inputDialog('Pakeisti cooldown', {
                    {type = 'number', label = 'Cooldown', description = 'Laikas tarp zonos užėmimų valandomis', icon = 'fa-solid fa-clock', required = true, default = zone.cooldown},
                })

                EditZone(title, zone)

                if not input then return end

                TempZone.cooldown = input[1]
            end,
        },
        {
            title = 'Pakeisti zonos plotį',
            description = 'Pakeisti zonos plotį (zone width)',
            icon = 'fa-solid fa-left-right',
            onSelect = function()
                local input = lib.inputDialog('Pakeisti zonos plotį', {
                    {type = 'number', label = 'Zonos plotis', description = 'Zonos plotis (zone width)', icon = 'fa-solid fa-arrows-left-right', required = true, default = zone.size.x},
                })

                EditZone(title, zone)

                if not input then return end

                TempZone.size.x = input[1] * 1.0
            end,
        },
        {
            title = 'Pakeisti zonos ilgį',
            description = 'Pakeisti zonos ilgį (zone length)',
            icon = 'fa-solid fa-arrows-up-down',
            onSelect = function()
                local input = lib.inputDialog('Pakeisti zonos ilgį', {
                    {type = 'number', label = 'Zonos ilgis', description = 'Zonos ilgis (zone length)', icon = 'fa-solid fa-arrows-up-down', required = true, default = zone.size.y},
                })

                EditZone(title, zone)

                if not input then return end

                TempZone.size.y = input[1] * 1.0
            end,
        },
        {
            title = 'Pakeisti zonos aukštį',
            description = 'Pakeisti zonos aukštį (zone height)',
            icon = 'fa-solid fa-arrow-up',
            onSelect = function()
                local input = lib.inputDialog('Pakeisti zonos aukštį', {
                    {type = 'number', label = 'Zonos aukštis', description = 'Zonos aukštį (zone height)', icon = 'fa-solid fa-arrow-up', required = true, default = zone.size.z},
                })

                EditZone(title, zone)

                if not input then return end

                TempZone.size.z = input[1] * 1.0
            end,
        },
        {
            title = 'Pakeisti zonos tipą',
            description = 'Pakeisti zonos tipą',
            icon = 'fa-solid fa-square',
            onSelect = function()
                local input = lib.inputDialog('Pakeisti zonos tipą', {
                    {type = 'select', label = 'Tipas', description = 'Zonos tipas', required = true, options = {
                        {value = 'plovimas', label = 'Plovimas'},
                        {value = 'blackmarket', label = 'Black market'},
                        {value = 'armour', label = 'Šarvų craftinimas'},
                        {value = 'ammunition', label = 'Kulkų craftinimas'},
                        {value = 'guns', label = 'Ginklų craftinimas'},
                        {value = 'guns2', label = 'Ginklų craftinimas 2'},
                        {value = 'guns3', label = 'Pistoletų craftinimas'},
                        {value = 'taisymas', label = 'Ginklų taisymas'},
                        {value = 'drugdealer', label = 'Narkotikų pardavimas'},
                        {value = 'addarmour', label = 'Šarvų užsidėjimas'},
                        {value = 'bets', label = 'Iš pinigų (statymai)'},
                        {value = 'unknown', label = 'Be tikslo'},
                    }, default = zone.type or nil},
                })

                EditZone(title, zone)

                if not input then return end

                TempZone.type = input[1]
            end,
        },
        {
            title = 'Pakeisti zonos oficialumą',
            description = 'Pakeisti zonos oficialumą',
            icon = 'fa-solid fa-skull',
            onSelect = function()
                local input = lib.inputDialog('Pakeisti zonos oficialumą', {
                    {type = 'checkbox', label = 'Oficialios gaujos zona', checked = zone.official},
                })

                EditZone(title, zone)

                if not input then return end

                TempZone.official = input[1]
            end,
        },
        {
            title = 'Pakeisti zonos valdytojus',
            description = 'Pakeisti zonos valdytojus (užėmėjus)',
            icon = 'fa-solid fa-person-rifle',
            onSelect = function()
                local input = lib.inputDialog('Pakeisti zonos valdytojus', {
                    {type = 'input', label = 'Zonos valdytojai', description = 'Zonos valdytojai (užėmėjai)', required = true, default = zone.owners or ''},
                })

                EditZone(title, zone)

                if not input then return end

                if input[1] == 'nil' then input[1] = nil end
                TempZone.owners = input[1]
            end,
        },
        {
            title = 'Atstatyti cooldown',
            description = 'Atstatyti zonos cooldown',
            icon = 'fa-solid fa-stopwatch',
            onSelect = function()
                local alert = lib.alertDialog({
                    header = 'Patvirtinkite',
                    content = 'Kad norite atstatyti zonos laikmatį.',
                    centered = true,
                    cancel = true
                })

                EditZone(title, zone)

                if alert ~= 'confirm' then return end

                lib.callback.await('d-gangzones:resetCooldown', false, title)
            end,
        },
        {
            title = 'Pakeisti, kiek kartų zona buvo užimta',
            description = 'Pakeiskite, kiek kartų zona buvo užimta. 3 kartai padidina narkotikų pardavimo kainą.',
            icon = 'fa-solid fa-calendar',
            onSelect = function()
                local input = lib.inputDialog('Zonos užėmimo kartai', {
                    {type = 'number', label = 'Zonos užemimo kartai', description = 'Nustatykite kiek kartų zona buvo užimta.', required = true, default = zone.timesTaken or 1},
                })

                EditZone(title, zone)

                if not input then return end
                TempZone.timesTaken = input[1]
            end,
        },
        {
            title = 'Patvirtinti pakeitimus',
            description = 'Patvirtinti zonos pakeitimus',
            icon = 'fa-solid fa-square-check',
            onSelect = function()
                EditZones()
                lib.callback.await('d-gangzones:updateZone', false, title, TempZone)
            end,
        },
        {
            title = 'Ištrinti zoną',
            description = 'Ištrinti šią zoną',
            icon = 'fa-solid fa-trash',
            onSelect = function()
                lib.callback.await('d-gangzones:updateZone', false, title, nil)
            end,
        },
    }

    if zone.type == 'blackmarket' then
        local option = {
            title = 'Koreguoti Black Market',
            description = 'Koreguoti Black Market (kainas, daiktus)',
            icon = 'fa-solid fa-shop',
            onSelect = function()
                EditMarket(title)
            end,
        }
        table.insert(Options, option)
    elseif zone.type == 'plovimas' then
        local option = {
            title = 'Koreguoti plovimą',
            description = 'Koreguoti plovimo procentą',
            icon = 'fa-solid fa-money-bill-trend-up',
            onSelect = function()
                local input = lib.inputDialog('Koreguoti plovimą', {
                    {type = 'number', label = 'Plovimo procentas', description = 'Koreguoti plovimo procentą', required = true, default = zone.ppercent or 80},
                })

                EditZone(title, zone)

                if not input then return end

                TempZone.ppercent = input[1]
                TempZone.pcooldown = 0
            end,
        }
        table.insert(Options, option)
    elseif zone.type == 'drugdealer' then
        local option = {
            title = 'Koreguoti narkotikų pardavimą',
            description = 'Koreguoti narkotikų pardavimą (kainas, narkotikus)',
            icon = 'fa-solid fa-capsules',
            onSelect = function()
                EditDealer(title)
            end,
        }
        table.insert(Options, option)
    elseif zone.type == 'addarmour' then
        local option = {
            title = 'Koreguoti šarvų užsidėjimą',
            description = 'Koreguoti šarvų užsidėjimą (maksimalų skaičių, cooldown)',
            icon = 'fa-solid fa-shield',
            onSelect = function()
                EditAddArmour(title)
            end,
        }
        table.insert(Options, option)
    end

    lib.registerContext({
        id = 'gangzones:editzone',
        menu = 'gangzones:edit',
        title = 'Koreguoti '..string.upper(zone.title),
        options = Options
    })

    lib.showContext('gangzones:editzone')
end

function EditAddArmour(zone)
    local Options = {
        {
            title = 'Koreguoti užsidėjimų skaičių',
            description = 'Koreguoti maksimalų šarvų užsidėjimų skaičių',
            icon = 'fa-solid fa-shield',
            onSelect = function()
                local input = lib.inputDialog('Koreguoti užsidėjimų skaičių', {
                    {type = 'number', label = 'Maksimalus skaičius', description = 'Įveskite maksimalų šarvų užsidėjimų skaičių', required = true, default = TempZone.armour?.max},
                })
            
                if input then 
                    TempZone.armour = TempZone.armour or {}
                    TempZone.armour.max = input[1]
                end

                EditAddArmour(zone)
            end,
        },
        {
            title = 'Koreguoti užsidėjimų cooldown',
            description = 'Koreguoti šarvų užsidėjimų cooldown',
            icon = 'fa-solid fa-clock',
            onSelect = function()
                local input = lib.inputDialog('Koreguoti užsidėjimų cooldown', {
                    {type = 'number', label = 'Cooldown', description = 'Įveskite šarvų užsidėjimų cooldown minutėmis', required = true, default = TempZone.armour?.cooldown},
                })
            
                if input then 
                    TempZone.armour = TempZone.armour or {}
                    TempZone.armour.cooldown = input[1]
                end

                EditAddArmour(zone)
            end,
        },
    }

    lib.registerContext({
        id = 'gangzones:editaddarmour',
        menu = 'gangzones:editzone',
        title = 'Šarvų užsidėjimas',
        options = Options
    })

    lib.showContext('gangzones:editaddarmour')
end

function EditMarket(zone)
    local Options = {
        {
            title = 'Pridėti daiktą',
            description = 'Pridėti daiktą prie black market',
            icon = 'fa-solid fa-plus',
            onSelect = function()
                local input = lib.inputDialog('Pridėti daiktą', {
                    {type = 'input', label = 'Daiktas', description = 'Daiktas, kurį norite pridėti', required = true},
                    {type = 'number', label = 'Kaina', description = 'Daikto kaina', required = true},
                    {type = 'number', label = 'Savaitė', description = 'Kurią savaitę po užėmimo šis daiktas bus prieinamas', required = true, default = 1},
                })
            
                if input then 
                    TempZone.blackmarket[input[1]] = {
                        item = input[1],
                        label = (itemNames[input[1]] or input[1]):gsub("^%l", string.upper),
                        week = input[3],
                        price = input[2],
                        cooldown = 0,
                    }
                end

                EditMarket(zone)
            end,
        },
    }

    if not TempZone.blackmarket then TempZone.blackmarket = {} end
    for k,v in pairs(TempZone.blackmarket) do 
        local option = {
            title = v.label,
            description = 'Koreguoti '..v.label,
            icon = 'fa-solid fa-shop',
            onSelect = function()
                local input = lib.inputDialog('Koreguoti daiktą', {
                    {type = 'number', label = 'Kaina', description = 'Daikto kaina', required = true, default = v.price},
                    {type = 'number', label = 'Savaitė', description = 'Kurią savaitę po užėmimo šis daiktas bus prieinamas', required = true, default = v.week},
                    {type = 'checkbox', label = 'Panaikinti daiktą'},
                })

                if input then 
                    TempZone.blackmarket[v.item].price = input[1]
                    TempZone.blackmarket[v.item].week = input[2]
                    if input[3] then
                        TempZone.blackmarket[v.item] = nil
                    end
                end

                EditMarket(zone)
            end,
        }
        table.insert(Options, option)
    end


    lib.registerContext({
        id = 'gangzones:editmarket',
        menu = 'gangzones:editzone',
        title = 'Black Market',
        options = Options
    })

    lib.showContext('gangzones:editmarket')
end

function EditDealer(zone)
    local Options = {
        {
            title = 'Pridėti narkotiką',
            description = 'Pridėti narkotiką prie narkotikų pardavimo',
            icon = 'fa-solid fa-plus',
            onSelect = function()
                local input = lib.inputDialog('Pridėti narkotiką', {
                    {type = 'input', label = 'Narkotikas', description = 'Narkotikas, kurį norite pridėti', required = true},
                    {type = 'number', label = 'Kaina', description = 'Narkotiko kaina', required = true},
                })
            
                if input then 
                    TempZone.drugdealer[input[1]] = {
                        item = input[1],
                        label = itemNames[input[1]],
                        price = input[2],
                        cooldown = 0,
                    }
                end

                EditDealer(zone)
            end,
        },
    }

    if not TempZone.drugdealer then TempZone.drugdealer = {} end
    for k,v in pairs(TempZone.drugdealer) do 
        local option = {
            title = v.label,
            description = 'Koreguoti '..v.label,
            icon = 'fa-solid fa-shop',
            onSelect = function()
                local input = lib.inputDialog('Koreguoti narkotiką', {
                    {type = 'number', label = 'Kaina', description = 'Daikto kaina', required = true},
                    {type = 'checkbox', label = 'Panaikinti daiktą'},
                })

                if input then 
                    TempZone.drugdealer[v.item].price = input[1]
                    if input[2] then
                        TempZone.drugdealer[v.item] = nil
                    end
                end

                EditDealer(zone)
            end,
        }
        table.insert(Options, option)
    end


    lib.registerContext({
        id = 'gangzones:editdealer',
        menu = 'gangzones:editzone',
        title = 'Narkotikų pardavimas',
        options = Options
    })

    lib.showContext('gangzones:editdealer')
end

Citizen.CreateThread(function()
    local Inventory = exports.ox_inventory
    for item, data in pairs(Inventory:Items()) do
        itemNames[item] = data.label
    end

    Inventory:displayMetadata({
        coinDate  = 'Dropo data',
    })
end)