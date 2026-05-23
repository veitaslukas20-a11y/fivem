Citizen.CreateThread(function()
    local insidePoint = false

    local blip = AddBlipForCoord(-424.9871, -1686.0278, 19.0291)
    SetBlipSprite(blip, 227)
    SetBlipColour(blip, 1)
	SetBlipScale(blip, 0.6)
    SetBlipAsShortRange(blip, true)
    BeginTextCommandSetBlipName("STRING")
	AddTextComponentString('<font face="Roboto">Automobilių pridavimas</font>')
    EndTextCommandSetBlipName(blip)

    lib.points.new({
        coords = vec3(-424.9871, -1686.0278, 19.0291),
        distance = 10,
        onEnter = function()
            lib.showTextUI('[E] - Priduoti automobilį', {
                position = "bottom-center",
                icon = 'car',
            })
            insidePoint = true
        end,
        onExit = function()
            insidePoint = false
            lib.hideTextUI()
        end
    })

    lib.addKeybind({
        name = 'vehicleSellMenu',
        description = 'Atidaryti pardavimo meniu',
        defaultKey = 'E',
        onPressed = function()
            if not insidePoint then return end
            local success = lib.alertDialog({
                header = 'Ar esate tikras',
                content = 'kad norite priduoti automobilį? Už automobilį gausite minimalią sumą nuo 200 iki 1000 eurų.',
                centered = true,
                cancel = true
            })

            if success == 'confirm' then
                lib.callback.await('sellvehicle:trySell', false)
            end
        end,
    })
end)