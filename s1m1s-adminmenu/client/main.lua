---@diagnostic disable-next-line: lowercase-global
lib = lib

RegisterCommand('amenu', function()
    local allowed = lib.callback.await('adminmenu:permissions', false)

    if not allowed then return end

    local Admins = lib.callback.await('adminmenu:returnAdmins', false)
    local Super = lib.callback.await('adminmenu:superPermissions', false)

    SendNUIMessage({
        type = 'admins',
        admins = Admins,
    })

    SendNUIMessage({
        type = 'issuper',
        super = Super,
    })

    SendNUIMessage({
        type = 'menu',
        show = true,
    })

    SetNuiFocus(true, true)
end, false)

RegisterNUICallback('close', function(data, cb)
    SendNUIMessage({
        type = 'menu',
        show = false,
    })

    SetNuiFocus(false, false)
    if cb then cb({ ok = true }) end
end)

RegisterNUICallback('sendMessage', function(data, cb)
    if data and data.id and data.message then
        lib.callback.await('adminmenu:sendMessage', false, data.id, data.message)
    end
    if cb then cb({ ok = true }) end
end)

RegisterNetEvent('1x-hud:client:notify', function(subject, msg)
    exports['1x-hud']:sendNotification({
        type = 'INFO',
        title = subject or 'Pranešimas',
        message = msg or '',
        duration = 6000,
        icon = 'info'
    })
end)