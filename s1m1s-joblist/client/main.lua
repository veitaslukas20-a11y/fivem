local Companies = {
    police = 'Los Santos Policijos Departamentas',
    ambulance = 'Los Santos Ligoninė',
    mechanic = 'Los Santos Autoservisas',
    mechanic2 = '6SRT Autoservisas',
    mechanic3 = 'Paleto Bay Autoservisas',
    mechanic4 = 'Sandy Shores Autoservisas',
    taxi = 'BOLT',
}

RegisterCommand('algalapis', function()
    local list = lib.callback.await('joblist:getList', false)
    if not list then return end 

    local temployees = {}
    for k,v in pairs(list) do 
        v.identifier = k
        table.insert(temployees, v)
    end

    SendNUIMessage({
        type = 'employees',
        company = Companies[ESX.GetPlayerData().job.name],
        employees = temployees,
    })

    local salaries = lib.callback.await('joblist:getSalaries', false)

    SendNUIMessage({
        type = 'salaries',
        salaries = salaries,
    })

    SendNUIMessage({
        type = 'show',
        show = true,
    })

    SetNuiFocus(true, true)
end)

RegisterNUICallback('close', function()
    SendNUIMessage({
        type = 'show',
        show = false,
    })

    SetNuiFocus(false, false)
end)

RegisterNUICallback('payEmployee', function(data)
    lib.callback.await('joblist:salary', false, data)
end)

exports('menu', function()
    local salaries, autopay, hours = lib.callback.await('joblist:getSalaries', false)
    if not salaries then return end 

    local grades = lib.callback.await('d-bosmenu:returnGrades', false)

    local algos = {}

    for grade, data in pairs(grades) do 
        if salaries[tostring(grade)] then 
            algos[grade] = {}
            algos[grade].alga = salaries[tostring(grade)] 
            algos[grade].label = data.label
            algos[grade].grade = grade
        else 
            algos[grade] = {}
            algos[grade].alga = {valandinis = 0, premija = 0}
            algos[grade].label = data.label
            algos[grade].grade = grade
        end
    end

    table.sort(algos, function (a, b) return a.grade > b.grade end)
    OpenSalaries(algos, autopay, hours)
end)

function OpenSalaries(employees, autopay, hours)
    local Options = {
        {
            title = 'Automatinis mokėjimas',
            description = 'Ar norite, kad algos būtų išmokamos automatiškai? Automatinis algų išmokejimas įvyksta kiekvieną pirmadinį 00:15.',
            icon = 'fa-solid fa-robot',
            metadata = {
                {
                    label = 'Automatinis',
                    value = autopay and 'Taip' or 'Ne',
                }, 
            },
            onSelect = function()
                local input = lib.inputDialog('Automatinis išmokejimas', {
                    {type = 'checkbox', label = 'Ar norite, kad algos būtų išmokamos automatiškai?', checked = autopay},
                })

                if input then 
                    lib.callback.await('joblist:setAutoPay', false, input[1])
                    autopay = input[1]
                end

                OpenSalaries(employees, autopay, hours)
            end,
        },
        {
            title = 'Minimalus valandų skaičius',
            description = 'Nustatykite minimalų valandų skaičių kurį reiktų pradirbti darbuotojams.',
            icon = 'fa-regular fa-hourglass-half',
            metadata = {
                {
                    label = 'Valandų skaičius',
                    value = hours or 0,
                }, 
            },
            onSelect = function()
                local input = lib.inputDialog('Minilamus valandų skaičius', {
                    {type = 'number', label = 'Minimalus valandų skaičius', description = 'Įveskite minimalų valandų skaičių kurį reiktų pradirbti darbuojams.', required = true, default = hours or 0},
                })

                if input then 
                    lib.callback.await('joblist:setMinHours', false, input[1])
                    hours = input[1]
                end

                OpenSalaries(employees, autopay, hours)
            end,
        },
    }
    for k,v in pairs(employees) do 
        table.insert(Options, {
            title = v.label,
            description = 'Nustatykite algą '..v.label..' pareigas einantiems darbuotojams. * Premijos skiriamos už išrašytas sąskaitas.',
            icon = 'fa-solid fa-user-clock',
            metadata = {
                {
                    label = 'Valandinis',
                    value = v.alga.valandinis,
                }, 
                {
                    label = 'Premija',
                    value = v.alga.premija,
                }, 
            },
            onSelect = function()
                local input = lib.inputDialog('Nustatykite atlyginimą', {
                    {type = 'number', label = 'Nustatykite valandinį atlyginimą', description = 'Nustatykite valandinį atlyginimą '..v.label..' pareigas einantiems darbuotojams.', required = true, default = v.alga.valandinis},
                    {type = 'number', label = 'Nustatykite premiją', description = 'Nustatykite premiją '..v.label..' pareigas einantiems darbuotojams. * Skiriama už išrašytas sąskaitas', required = true, default = v.alga.premija},
                })

                if input then
                    lib.callback.await('joblist:setSalary', false, v.grade, input[1], input[2])
                    employees[k].alga.valandinis = input[1]
                    employees[k].alga.premija = input[2]
                end
                OpenSalaries(employees, autopay, hours)
            end,
        })
    end

    lib.registerContext({
        title = 'Nustatykite algas',
        id = 'joblist:algos',
        menu = 'dbossmenu',
        options = Options
    })

    lib.showContext('joblist:algos')
end