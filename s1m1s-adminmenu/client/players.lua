RegisterNUICallback('action', function(data, cb)
    if data then
        lib.callback.await('adminmenu:action', false, data)
    end
    if cb then cb({ ok = true }) end
end)

---@diagnostic disable-next-line: lowercase-global
lib = lib