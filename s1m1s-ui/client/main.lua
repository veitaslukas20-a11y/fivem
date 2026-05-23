local keybingMenu = function(show, keybings, time) 
    SendNUIMessage({
        action = 'bottom',
        bottom = show,
        keybings = keybings
    })
    if time then
        Wait(time)
        SendNUIMessage({
            action = 'bottom',
            bottom = false,
        })
    end
end

exports('keybingMenu', keybingMenu)

Citizen.CreateThread(function()
    while true do
        keybingMenu(false)
        Wait(2000) 
    end
end)

local topText = function(show, text) 
    SendNUIMessage({
        action = 'top',
        top = show,
        text = text,
    })
end

exports('topText', topText)

local loading = function(show, persent) 
    SendNUIMessage({
        action = 'loading',
        loading = show,
        persent = persent,
    })
end

exports('loading', loading)

local kopija = ''

RegisterCommand('mirtis', function()
    lib.setClipboard(kopija)
    exports['1x-hud']:sendNotification({
        type = 'INFO',
        title = 'Mirties informacija',
        message = 'Jūsų mieties informacija buvo nukopijuota į jūsų iškarpinę (angl. clipboard). Šią informacija galite pateikti administratoriams tam prireikus.',
        duration = 6000,
        icon = 'skull'
    })
end)

local copySave = function(text) 
    kopija = text
end

RegisterNetEvent('d-ui:copy', copySave)