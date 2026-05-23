ESX = exports['es_extended']:getSharedObject()

-- Eventas pilnai išgydyti žaidėją
RegisterNetEvent('esx_basicneeds:healPlayer')
AddEventHandler('esx_basicneeds:healPlayer', function()
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then return end
    
    -- Atnaujinti hunger ir thirst statusus
    TriggerClientEvent('esx_status:set', source, 'hunger', 1000000)
    TriggerClientEvent('esx_status:set', source, 'thirst', 1000000)
    
    -- Išgydyti žaidėją
    TriggerClientEvent('esx_basicneeds:healPlayer', source)
end)

-- Eventas valgymui
RegisterNetEvent('esx_basicneeds:onEat')
AddEventHandler('esx_basicneeds:onEat', function(prop_name)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then return end
    
    -- Atnaujinti alkio statusą
    TriggerClientEvent('esx_status:add', source, 'hunger', 300000)
    
    -- Paleisti animaciją
    TriggerClientEvent('esx_basicneeds:onEat', source, prop_name)
end)

-- Eventas gėrimui
RegisterNetEvent('esx_basicneeds:onDrink')
AddEventHandler('esx_basicneeds:onDrink', function(prop_name)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then return end
    
    -- Atnaujinti troškulio statusą
    TriggerClientEvent('esx_status:add', source, 'thirst', 300000)
    
    -- Paleisti animaciją
    TriggerClientEvent('esx_basicneeds:onDrink', source, prop_name)
end)

-- Eventas kavos gėrimui
RegisterNetEvent('esx_basicneeds:onDrinkCoffee')
AddEventHandler('esx_basicneeds:onDrinkCoffee', function(prop_name)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then return end
    
    -- Atnaujinti troškulio statusą (kava mažiau atgaivina)
    TriggerClientEvent('esx_status:add', source, 'thirst', 150000)
    
    -- Paleisti animaciją
    TriggerClientEvent('esx_basicneeds:onDrinkCoffee', source, prop_name)
end)

-- Eventas alkoholio gėrimui
RegisterNetEvent('esx_basicneeds:onDrinkAlcohol')
AddEventHandler('esx_basicneeds:onDrinkAlcohol', function(prop_name)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then return end
    
    -- Atnaujinti troškulio statusą (alkoholis išdžiovina)
    TriggerClientEvent('esx_status:remove', source, 'thirst', 100000)
    
    -- Paleisti animaciją
    TriggerClientEvent('esx_basicneeds:onDrinkAlcohol', source, prop_name)
end)

-- Eventas rūkymui
RegisterNetEvent('esx_basicneeds:onSmoke')
AddEventHandler('esx_basicneeds:onSmoke', function(prop_name)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then return end
    
    -- Paleisti animaciją (rūkymas neturi įtakos statusams)
    TriggerClientEvent('esx_basicneeds:onSmoke', source, prop_name)
end)

-- === /heal (pilnas heal) tik nurodytoms grupėms ===
local AllowedHealGroups = {
    support    = true,
    vyrsupport = true,
    admin      = true,
    vyradmin   = true,
    dev        = true,
    owner      = true
}

local function isAllowed(xPlayer)
    if not xPlayer then return false end
    local group = (xPlayer.getGroup and xPlayer.getGroup()) or xPlayer.group or 'user'
    return AllowedHealGroups[group] or false
end

ESX.RegisterCommand('heal', 'user', function(xPlayer, args, showError)
    if not isAllowed(xPlayer) then
        TriggerClientEvent('ox_lib:notify', xPlayer.source, {
            title = 'Heal',
            description = 'Neturi teisės naudoti šios komandos.',
            type = 'error'
        })
        return
    end

    local targetArg = args.playerId
    if not targetArg then
        TriggerClientEvent('ox_lib:notify', xPlayer.source, {
            title = 'Heal',
            description = 'Naudojimas: /heal [ID]',
            type = 'error'
        })
        return
    end

    local targetId = (type(targetArg) == 'table' and targetArg.source) or tonumber(targetArg)
    if not targetId then
        TriggerClientEvent('ox_lib:notify', xPlayer.source, {
            title = 'Heal',
            description = 'Neteisingas ID.',
            type = 'error'
        })
        return
    end

    TriggerClientEvent('esx_ambulancejob:heal', targetId, 'big', false)

    TriggerClientEvent('ox_lib:notify', xPlayer.source, {
        title = 'Heal',
        description = ('Pagydytas žaidėjas ID %d'):format(targetId),
        type = 'success'
    })
end, false, {
    help = 'Pilnai pagydyti žaidėją pagal ID (tik admin grupės)',
    validate = true,
    arguments = {
        { name = 'playerId', help = 'Žaidėjo ID', type = 'player' }
    }
})

AddEventHandler('esx:playerLoaded', function(playerId, xPlayer)
    -- Palaukti kol visi resursai bus užkrauti
    Citizen.SetTimeout(5000, function()
        TriggerClientEvent('esx_status:set', playerId, 'hunger', 1000000)
        TriggerClientEvent('esx_status:set', playerId, 'thirst', 1000000)
    end)
end)

-- Eventas resurso paleidimui
RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(playerId, xPlayer)
    MySQL.Async.fetchScalar('SELECT status FROM users WHERE identifier = @identifier', {
        ['@identifier'] = xPlayer.identifier
    }, function(statusData)
        if not statusData then
            -- Jei nėra statusų (t. y. naujas žaidėjas) – duok pilnus
            TriggerClientEvent('esx_status:set', playerId, 'hunger', 1000000)
            TriggerClientEvent('esx_status:set', playerId, 'thirst', 1000000)
        end
    end)
end)

-- Eventas resurso sustabdymui
AddEventHandler('onResourceStop', function(resourceName)
    if GetCurrentResourceName() ~= resourceName then return end
    
    print("^3[esx_basicneeds] Resource stopped^7")
end)

-- Callback'ai client side naudojimui
lib.callback.register('esx_basicneeds:getPlayerStatus', function(source)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then return {} end
    
    -- Čia galima pridėti logiką gauti dabartinius žaidėjo statusus
    -- Kol kas grąžinam tuščią objektą
    return {}
end)

-- Eventas maisto naudojimui su itemais
RegisterNetEvent('esx_basicneeds:useItem')
AddEventHandler('esx_basicneeds:useItem', function(itemName)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then return end
    
    -- Tikrinam koks itemas naudojamas ir atliekam atitinkamą veiksmą
    if itemName == 'bread' or itemName == 'sandwich' then
        TriggerEvent('esx_basicneeds:onEat', source, itemName)
    elseif itemName == 'water' or itemName == 'soda' then
        TriggerEvent('esx_basicneeds:onDrink', source, itemName)
    elseif itemName == 'coffee' then
        TriggerEvent('esx_basicneeds:onDrinkCoffee', source, itemName)
    elseif itemName == 'beer' or itemName == 'wine' then
        TriggerEvent('esx_basicneeds:onDrinkAlcohol', source, itemName)
    elseif itemName == 'cigarette' then
        TriggerEvent('esx_basicneeds:onSmoke', source, itemName)
    end
    
    -- Pašalinam itemą iš inventory (jei reikia)
    -- xPlayer.removeInventoryItem(itemName, 1)
end)

-- Eventas atstatyti gyvybes po mirties
RegisterNetEvent('esx_basicneeds:respawn')
AddEventHandler('esx_basicneeds:respawn', function()
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then return end
    
    -- Atstatyti dalinius statusus po prisikėlimo
    TriggerClientEvent('esx_status:set', source, 'hunger', 500000)
    TriggerClientEvent('esx_status:set', source, 'thirst', 500000)
    
    print(string.format("^3[esx_basicneeds] Player %s respawned, statuses reset^7", xPlayer.getName()))
end)

-- Eventas mirties nuo bado/troškulio
RegisterNetEvent('esx_basicneeds:diedFromNeeds')
AddEventHandler('esx_basicneeds:diedFromNeeds', function()
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then return end
    
    print(string.format("^1[esx_basicneeds] Player %s died from hunger/thirst^7", xPlayer.getName()))
    
    -- Čia galima pridėti papildomą logiką mirties atveju
    -- Pvz., pranešimai adminams, statistikos įrašymas, etc.
end)