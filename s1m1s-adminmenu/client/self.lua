local History = {}
local MyReport = {}

RegisterCommand('report', function()
    SendNUIMessage({
        type = 'update-self-player',
        name = GetPlayerName(PlayerId()),
        id = GetPlayerServerId(PlayerId()),
    })

    SendNUIMessage({
        type = 'show-self-report',
        show = true,
    })

    SetNuiFocus(true, true)
end, false)

RegisterNetEvent('adminmenu:selfClosedReport', function(chat)
    SendNUIMessage({
        type = 'close-self',
    })
end)

RegisterNUICallback('closeself', function(data, cb)
    SendNUIMessage({
        type = 'show-self-report',
        show = false,
    })

    SetNuiFocus(false, false)
    if cb then cb({ ok = true }) end
end)

RegisterNUICallback('submitReport', function(data, cb)
    if not data then if cb then cb({ ok = false }) end return end
    local report = lib.callback.await('adminmenu:createReport', false, data)
    if report then
        MyReport = report
        SendNUIMessage({
            type = 'created-report',
            report = MyReport,
        })
        if cb then cb({ ok = true, id = report.id }) end
    else
        if cb then cb({ ok = false }) end
    end
end)

---@diagnostic disable-next-line: lowercase-global
lib = lib

RegisterNUICallback('closereport', function(data, cb)
    if data and data.id then
        lib.callback.await('adminmenu:selfClose', false, data.id)
    end
    SendNUIMessage({ type = 'close-self' })
    if cb then cb({ ok = true }) end
end)

RegisterNetEvent('adminmenu:updateSelfChat', function(chat)
    table.insert(MyReport.chat, chat)
    SendNUIMessage({
        type = 'update-self-chat',
        chat = MyReport.chat,
    })
end)

RegisterNetEvent('adminmenu:updateSelfHistory', function()
    table.insert(History, MyReport)
    MyReport = {}

    SendNUIMessage({
        type = 'udpate-history',
        history = History,
    })
end)