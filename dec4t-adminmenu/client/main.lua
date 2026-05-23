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

RegisterNUICallback('close', function(data)
    SendNUIMessage({
        type = 'menu',
        show = false,
    })

    SetNuiFocus(false, false)
end)

RegisterNUICallback('sendMessage', function(data)
    lib.callback.await('adminmenu:sendMessage', false, data.id, data.message)
end)