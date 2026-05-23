function OpenGangMenu(zone)
    local title = string.lower(zone.title)

    if zone.type == 'blackmarket' then
        if not zone.blackmarket then return ESX.ShowNotification('Įvyko klaida bandant atidaryti meniu, prašome keiptis į administratorius (gaujų prižiūrėtojus), kad būtų sukurtas black market šiai gaujos zonai.') end
        BlackMarket(title, zone.blackmarket, zone.daysOwned)
    elseif zone.type == 'plovimas' then
        if not zone.ppercent then return ESX.ShowNotification('Įvyko klaida bandant atidaryti meniu, prašome keiptis į administratorius (gaujų prižiūrėtojus), kad būtų pakoreguotas plovimo procentas šiai gaujos zonai.') end
        Plovimas(title)
    elseif zone.type == 'armour' then
        if not zone.crafting then return ESX.ShowNotification('Įvyko klaida bandant atidaryti meniu, prašome keiptis į administratorius (gaujų prižiūrėtojus), kad būtų pakoreguotas crafting šiai gaujos zonai.') end
        Creafing(zone)
    elseif zone.type == 'addarmour' then
        if not zone.armour then return ESX.ShowNotification('Įvyko klaida bandant atidaryti meniu, prašome keiptis į administratorius (gaujų prižiūrėtojus), kad būtų pakoreguotas crafting šiai gaujos zonai.') end
        AddArmour(zone)
    elseif zone.type == 'unknown' then
        ESX.ShowNotification('Šiuo metu per daug pavojinga, neturiu ką pasiūlyti.')
    elseif zone.type == 'ammunition' then
        if not zone.crafting then return ESX.ShowNotification('Įvyko klaida bandant atidaryti meniu, prašome keiptis į administratorius (gaujų prižiūrėtojus), kad būtų pakoreguotas crafting šiai gaujos zonai.') end
        Creafing(zone)
    elseif zone.type == 'guns' then
        if not zone.crafting then return ESX.ShowNotification('Įvyko klaida bandant atidaryti meniu, prašome keiptis į administratorius (gaujų prižiūrėtojus), kad būtų pakoreguotas crafting šiai gaujos zonai.') end
        Creafing(zone)
    elseif zone.type == 'guns2' then
        if not zone.crafting then return ESX.ShowNotification('Įvyko klaida bandant atidaryti meniu, prašome keiptis į administratorius (gaujų prižiūrėtojus), kad būtų pakoreguotas crafting šiai gaujos zonai.') end
        Creafing(zone)
    elseif zone.type == 'guns3' then
        if not zone.crafting then return ESX.ShowNotification('Įvyko klaida bandant atidaryti meniu, prašome keiptis į administratorius (gaujų prižiūrėtojus), kad būtų pakoreguotas crafting šiai gaujos zonai.') end
        Creafing(zone)
    elseif zone.type == 'taisymas' then
        if not zone.crafting then return ESX.ShowNotification('Įvyko klaida bandant atidaryti meniu, prašome keiptis į administratorius (gaujų prižiūrėtojus), kad būtų pakoreguotas crafting šiai gaujos zonai.') end
        Creafing(zone)
    elseif zone.type == 'drugdealer' then
        if not zone.drugdealer then return ESX.ShowNotification('Įvyko klaida bandant atidaryti meniu, prašome keiptis į administratorius (gaujų prižiūrėtojus), kad būtų sukurtas narkotikų sąrašas šiai gaujos zonai.') end
        DrugDealer(title, zone.drugdealer)
    end
end

local MarketLevels = {
    'Pirmajam',
    'Antrajam',
    'Trečiajam',
    'Ketvirtajam',
    'Penktajam',
    'Šeštajam'
}

function AddArmour(zone)
    local Options = {
        {
            title = 'Užsidėti šarvus',
            description = 'Užsidėkite šarvus, tačiau prisiminkite, kad ši funkcija turi limitus. Šarvų limitas: '..(zone.armour and zone.armour.max or 0)..', Cooldown: '..(zone.armour and zone.armour.cooldown or 0)..' min.',
            icon = 'fa-solid fa-shield',
            onSelect = function()
                local canEquip = lib.callback.await('d-gangzones:addArmour', false, string.lower(zone.title))
                if canEquip then
                    exports['deivuks-utils']:armour()
                    SetPedArmour(cache.ped, 50)
                end
            end,
        }
    }

    lib.registerContext({
        id = 'gangzones:addarmour',
        title = 'Užsidėti šarvus',
        options = Options
    })

    lib.showContext('gangzones:addarmour')
end

function BlackMarket(zone, market, daysOwned)
    if zone.official and ESX.GetPlayerData().job.grade < 1 then return end

    local Options = {}
    local level = math.floor(daysOwned / 7)
    for k,v in pairs(market) do
        if level >= v.week then
            Options[k] = {
                title = v.label,
                description = 'Pirkti '..v.label..' už '..currency(v.price)..'. Šis daiktas priklauso '..MarketLevels[v.week+1]..' lygiui.',
                icon = 'fa-solid fa-basket-shopping',
                onSelect = function()
                    local input = lib.inputDialog('Pirkti '..v.label..' už '..currency(v.price), {
                        {type = 'number', label = 'Kiekis', description = 'Įveskite daikto kiekį', required = true, default = 1},
                    })
                
                    BlackMarket(zone, market, daysOwned)

                    if not input then return end

                    lib.callback.await('d-gangzones:buyItem', false, zone, v.item, input[1])
                end,
            }
        end
    end

    lib.registerContext({
        id = 'gangzones:blackshop',
        title = 'Juodoji rinka',
        options = Options
    })

    lib.showContext('gangzones:blackshop')
end

function Plovimas(zone)
    local input = lib.inputDialog('Plauti pinigus ', {
        {type = 'number', label = 'Pinigų suma', description = 'Įveskite pinigų sumą', required = true},
    })

    if not input then return end

    lib.callback.await('d-gangzones:plovimas', false, zone, input[1])
end

function Creafing(zone)
    if zone.official and ESX.GetPlayerData().job.grade < 2 then return end
    exports['fuksus-crafting']:openCrafting(zone.crafting)
end

function DrugDealer(zone, dealer)
    if ESX.GetPlayerData().job.grade < 3 then return end

    local Options = {}
    for k,v in pairs(dealer) do
        Options[k] = {
            title = v.label,
            description = 'Parduoti '..v.label..' už '..currency(v.timesTaken and v.price * 1.3 or v.price),
            icon = 'fa-solid fa-capsules',
            onSelect = function()
                local input = lib.inputDialog('Parduoti '..v.label..' už '..currency(v.timesTaken and v.price * 1.3 or v.price), {
                    {type = 'number', label = 'Kiekis', description = 'Įveskite narkotiko kiekį', required = true, default = 1},
                })
            
                DrugDealer(zone, dealer)

                if not input then return end

                lib.callback.await('d-gangzones:sellDrug', false, zone, v.item, input[1])
            end,
        }
    end

    lib.registerContext({
        id = 'gangzones:dealer',
        title = 'Narkotikų pardavimas',
        options = Options
    })

    lib.showContext('gangzones:dealer')
end

function currency(n)
    return tostring(math.floor(n)):reverse():gsub("(%d%d%d)","%1,"):gsub(",(%-?)$","%1"):reverse()..' €'
end