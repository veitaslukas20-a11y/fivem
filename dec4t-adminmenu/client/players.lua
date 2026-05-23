RegisterNUICallback('action', function(data)
    lib.callback.await('adminmenu:action', false, data)
end)