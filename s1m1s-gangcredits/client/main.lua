local LevelstTranslator = {
    'Pirmas',
    'Antras',
    'Trečias',
    'Ketvirtas',
    'Penktas',
    'Šeštas'
}

exports('openManage', function()
    local levels = lib.callback.await('gangcredits:getlevels', false)
    OpenManage(levels)
end)

function OpenManage(levels)
    lib.registerContext({
        id = 'gangcredits',
        title = 'Gaujų patobulinimai',
        options = {
            {
                title = 'Bendras sandėlis',
                description = 'Bendro sandėlio dabartinis lygis: '..LevelstTranslator[levels.rstash],
                icon = 'fa-solid fa-box-open',
                disabled = Config.rstash[levels.rstash + 1] == nil,
                onSelect = function()
                    local Options = {}
                    for level, data in pairs(Config.rstash) do
                        Options[#Options + 1] = {
                            title = LevelstTranslator[level]..' lygis',
                            description = ('%s€ kaina, %skg, %s slotų'):format(data.price, data.weight, data.slots),
                            icon = 'fa-solid fa-box-open',
                            disabled = level <= levels.rstash,
                            onSelect = function()
                                local success = lib.callback.await('gangcredits:buyLevel', false, 'rstash', level)
                                if success then
                                    levels.rstash = level
                                end
                            end
                        }
                    end

                    lib.registerContext({
                        id = 'gangcredits:rstash',
                        title = 'Bendro sandėlio patobulinimai',
                        menu = 'gangcredits',
                        onBack = function()
                            OpenManage(levels)
                        end,
                        options = Options
                    })

                    lib.showContext('gangcredits:rstash')
                end,
            },
            {
                title = 'Boso sandėlis',
                description = 'Boso sandėlio dabartinis lygis: '..LevelstTranslator[levels.bstash],
                icon = 'fa-solid fa-box-open',
                disabled = Config.bstash[levels.bstash + 1] == nil,
                onSelect = function()
                    local Options = {}
                    for level, data in pairs(Config.bstash) do
                        Options[#Options + 1] = {
                            title = LevelstTranslator[level]..' lygis',
                            description = ('%s€ kaina, %skg, %s slotų'):format(data.price, data.weight, data.slots),
                            icon = 'fa-solid fa-box-open',
                            disabled = level <= levels.bstash,
                            onSelect = function()
                                local success = lib.callback.await('gangcredits:buyLevel', false, 'bstash', level)
                                if success then
                                    levels.bstash = level
                                end
                            end
                        }
                    end

                    lib.registerContext({
                        id = 'gangcredits:bstash',
                        title = 'Boso sandėlio patobulinimai',
                        menu = 'gangcredits',
                        onBack = function()
                            OpenManage(levels)
                        end,
                        options = Options
                    })

                    lib.showContext('gangcredits:bstash')
                end,
            },
            {
                title = 'Šarvai',
                description = 'Šarvų dabartinis lygis: '..LevelstTranslator[levels.armour],
                icon = 'fa-solid fa-shield',
                disabled = Config.armour[levels.armour + 1] == nil,
                onSelect = function()
                    local Options = {}
                    for level, data in pairs(Config.armour) do
                        Options[#Options + 1] = {
                            title = LevelstTranslator[level]..' lygis',
                            description = ('%s€ kaina, %s šarvų procentas, %s užsidėjimo kaina'):format(data.price, data.amount, data.bprice),
                            icon = 'fa-solid fa-shield',
                            disabled = level <= levels.armour,
                            onSelect = function()
                                local success = lib.callback.await('gangcredits:buyLevel', false, 'armour', level)
                                if success then
                                    levels.armour = level
                                end
                            end
                        }
                    end

                    lib.registerContext({
                        id = 'gangcredits:armour',
                        title = 'Šarvų patobulinimai',
                        menu = 'gangcredits',
                        onBack = function()
                            OpenManage(levels)
                        end,
                        options = Options
                    })

                    lib.showContext('gangcredits:armour')
                end,
            },
        }
    })

    lib.showContext('gangcredits')
end

exports('openArmour', function()
    local levels = lib.callback.await('gangcredits:getlevels', false)
    OpenArmour(levels)
end)

function OpenArmour(levels)
    local Options = {}
    for level=1, levels.armour do
        local data = Config.armour[level]
        Options[#Options + 1] = {
            title = LevelstTranslator[level]..' lygis',
            description = ('%s šarvų procentas, %s užsidėjimo kaina'):format(data.amount, data.bprice),
            disabled = data.amount == 0,
            icon = 'fa-solid fa-shield',
            onSelect = function()
                local armour = lib.callback.await('gangcredits:addArmour', false, level)
                if armour ~= false then
                    exports['deivuks-utils']:armour()
                    SetPedArmour(cache.ped, armour)
                end
            end
        }
    end

    lib.registerContext({
        id = 'gangcredits:addarmour',
        title = 'Šarvų užsidėjimas',
        options = Options
    })

    lib.showContext('gangcredits:addarmour')
end

local TypesTranslator = {
    armour = 'Šarvų patobulinimai',
    rstash = 'Bendros saugyklos patobulinimai',
    bstash = 'Boso saugyklos patobulinimai',
    garage = 'Garažo patobulinimai',
}

function ViewGang(data)
    local Options = {}

    if type(data.levels) == 'string' then data.levels = json.decode(data.levels) end

    for type, level in pairs(data.levels) do
        table.insert(Options, {
            title = TypesTranslator[type],
            description = 'Pakeisti '..TypesTranslator[type]..' lygį. Dabartinis lygis: '..(LevelstTranslator[level] or 'Neįgytas')..'.',
            icon = 'pen-ruler',
            onSelect = function()
                local Levels = {}
                for i, __ in pairs(Config[type]) do
                    table.insert(Levels, {
                        value = i,
                        label = LevelstTranslator[i],
                    })
                end

                local input = lib.inputDialog(TypesTranslator[type]..' lygis', {
                    {type = 'select', label = 'Pasirinkite lygį', description = 'Pasirinkite vieną iš lygių', required = true, options = Levels},
                })

                if not input or not input[1] then return ViewGang(data) end

                data.levels[type] = input[1]

                lib.callback.await('gangcredits:editLevel', false, data.job, type, input[1])
                ViewGang(data)
            end
        })
    end

    lib.registerContext({
        id = 'gangcredits:viewgang',
        menu = 'gangcredits:admin',
        title = 'Gaujų administravimas',
        options = Options
    })

    lib.showContext('gangcredits:viewgang')
end

function AdminMenu()
    local data = lib.callback.await('gangcredits:returnAll', false)

    if not data then return end

    local Options = {}

    for _, v in pairs(data) do
        table.insert(Options, {
            title = v.job,
            description = 'Peržiūrėti '..v.job..' informaciją',
            icon = 'skull',
            onSelect = function()
                ViewGang(v)
            end
        })
    end

    lib.registerContext({
        id = 'gangcredits:admin',
        title = 'Gaujų administravimas',
        options = Options
    })

    lib.showContext('gangcredits:admin')
end

RegisterCommand('gangcredits', function()
    AdminMenu()
end)