local Inventory = exports.ox_inventory

function OpenZoneMenu()
    local Options = {}

    if Job.name == 'police' and Job.grade >= 10 then
        if not Config.Zone.enabled then
            table.insert(Options,  {
                title = 'Pradėti resursų krovimą',
                description = 'Pradėjus resursų krovimą turėsite sudėti daiktus į sukurtą saugyklą, tuomet patvirtinsite utilizacijos proceso pradžią ir turėsite saugoti, kad pašaliniai asmenys nepatektų į šią zoną, kol procesas yra vykdomas. Ši procesą galėsite atšaukti, tačiau privalėsite susirinkti daiktus iš saugyklos.',
                icon = 'fa-solid fa-dumpster-fire',
                onSelect = function()
                    TriggerServerEvent('policezone:enableZone')
                end,
            })
        elseif not Config.Zone.started then
            table.insert(Options,  {
                title = 'Nutraukti krovimo procesą',
                description = 'Nutraukti krovimo procesą prieštai išimant visus į saugyklą sudėtus daiktus.',
                icon = 'fa-solid fa-power-off',
                onSelect = function()
                    TriggerServerEvent('policezone:disableZone')
                end,
            })

            table.insert(Options,  {
                title = 'Atidaryti saugyklą',
                description = 'Atidarykite saugyklą ir sudėkite daiktus kurios utilizuosite.',
                icon = 'fa-solid fa-dumpster',
                onSelect = function()
                    if Config.Zone.locked then return end
                    Inventory:openInventory('stash', 'policeutilization')
                end,
            })

            table.insert(Options,  {
                title = 'Pradėti utilizaciją',
                description = 'Pradėti utilizacijos procesą. DĖMESIO: Šis procesas yra neatšaukiamas, pradėjus procesą jį turėsite pabaigti, taip pat pradėjus procesą gaujos iškart galės matyti, kad buvo pradėta utilizacija ir judės link šios vietos.',
                icon = 'fa-solid fa-dumpster',
                onSelect = function()
                    TriggerServerEvent('policezone:startUtilization')
                end,
            })
        end
    end

    if Job.name ~= 'police' and Config.Zone.started and not Config.Zone.locked then
        table.insert(Options,  {
            title = 'Atidaryti saugyklą',
            description = 'Atidaryti utilizacijos saugyklą.',
            icon = 'fa-solid fa-dumpster',
            onSelect = function()
                if Config.Zone.locked then return end
                Inventory:openInventory('stash', 'policeutilization')
            end,
        })
    end

    if #Options == 0 then return end

    lib.registerContext({
        id = 'policezone:menu',
        title = 'Utilizacija',
        options = Options
    })

    lib.showContext('policezone:menu')
end
