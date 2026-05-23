RegisterCommand('admins', function()
    local allowed = lib.callback.await('adminmenu:superPermissions', false)

    if not allowed then return end

    local Admins = lib.callback.await('adminmenu:returnAdmins', false)

    lib.registerContext({
        id = 'adminmenu:main',
        title = 'Administratorių valdymas',
        options = {
            {
                title = 'Administratorių sąrašas',
                description = 'Peržiūrėti ir koreguoti administratorius',
                icon = 'fa-solid fa-list',
                onSelect = function()
                    OpenAdminList(Admins)
                end,
            },
            {
                title = 'Pridėti administratorių',
                description = 'Pridėti naują administratorių',
                icon = 'fa-solid fa-plus',
                onSelect = function()
                    local input = lib.inputDialog('Pridėti administratorių', {
                        {type = 'input', label = 'Vardas', description = 'Įrašykite administratoriaus vardą', required = true},
                        {type = 'input', label = 'License', description = 'Įrašykite administratoriaus license (be license:)', required = true},
                        {type = 'select', label = 'Pasirinkite administratoriaus rolę', required = true, default = 'support', options = {
                            {value = 'owner', label = 'Savininkas'},
                            {value = 'dev', label = 'Developeris'},
                            {value = 'pagradmin', label = 'Pagr. Administratorius(-ė)'},
                            {value = 'vyradmin', label = 'Vyr. Administratorius(-ė)'},
                            {value = 'admin', label = 'Administratorius(-ė)'},
                            {value = 'vyrsupport', label = 'Vyr. Support'},
                            {value = 'support', label = 'Support'},
                        }},
                        {type = 'checkbox', label = 'Super permissions', checked = false},
                    })

                    if not input then return lib.showContext('adminmenu:main') end
                
                    lib.callback.await('adminmenu:insertAdmin', false, {
                        name = input[1],
                        license = input[2],
                        role = input[3],
                        super = input[4]
                    })
                end,
            }
        },
    })

    lib.showContext('adminmenu:main')
end, false)

function OpenAdminList(Admins)
    local Options = {}

    for k,v in pairs(Admins) do
        table.insert(Options, {
            title = v.name,
            description = 'Koreguoti adminsitratoriaus informaciją '..v.name,
            icon = 'fa-solid fa-user',
            onSelect = function()
                OpenEditor(v)
            end
        })
    end

    lib.registerContext({
        id = 'adminmenu:admins',
        menu = 'adminmenu:main',
        title = 'Administratorių sąrašas',
        options = Options,
    })

    lib.showContext('adminmenu:admins')
end

function OpenEditor(admin)
    lib.registerContext({
        id = 'adminmenu:admin',
        menu = 'adminmenu:admins',
        title = 'Koreguoti '..admin.name,
        options = {
            {
                title = 'Koreguoti administratoriaus parametrus',
                description = 'Koreguoti administratoriaus parametrus, pakeisti rolę, vardą, licese ar permissions',
                icon = 'fa-solid fa-pen-to-square',
                onSelect = function()
                    local input = lib.inputDialog('Koreguoti '..admin.name, {
                        {type = 'input', label = 'Vardas', description = 'Pakeiskite administratoriaus vardą', required = true, default = admin.name},
                        {type = 'input', label = 'License', description = 'Pakeiskite administratoriaus license', required = true, default = admin.license},
                        {type = 'select', label = 'Pakeiskite administratoriaus rolę', required = true, default = admin.role, options = {
                            {value = 'owner', label = 'Savininkas'},
                            {value = 'dev', label = 'Developeris'},
                            {value = 'pagradmin', label = 'Pagr. Administratorius(-ė)'},
                            {value = 'vyradmin', label = 'Vyr. Administratorius(-ė)'},
                            {value = 'admin', label = 'Administratorius(-ė)'},
                            {value = 'vyrsupport', label = 'Vyr. Support'},
                            {value = 'support', label = 'Support'},
                        }},
                        {type = 'checkbox', label = 'Super permissions', checked = admin.perms == 'super'},
                    })

                    if not input then return OpenEditor(admin) end

                    lib.callback.await('adminmenu:updateAdmin', false, {
                        name = input[1],
                        license2 = admin.license,
                        license = input[2],
                        role = input[3],
                        super = input[4]
                    })

                    admin.name = input[1]
                    admin.license = input[2]
                    admin.role = input[3]
                    admin.super = input[4] and 'super' or 'admin'

                    OpenEditor(admin)
                end
            },
            {
                title = 'Išmesti administratorių',
                description = 'Išmesti administratorių iš komandos',
                icon = 'fa-solid fa-trash',
                onSelect = function()
                    lib.callback.await('adminmenu:deleteAdmin', false, {
                        license = admin.license,
                    })
                end
            }
        },
    })

    lib.showContext('adminmenu:admin')
end