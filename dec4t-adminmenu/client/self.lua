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

RegisterNUICallback('closeself', function(data)
    SendNUIMessage({
        type = 'show-self-report',
        show = false,
    })

    SetNuiFocus(false, false)
end)

RegisterNUICallback('submitReport', function(data)
    local report = lib.callback.await('adminmenu:createReport', false, data)

    MyReport = report
    SendNUIMessage({
        type = 'created-report',
        report = MyReport,
    })
end)

RegisterNUICallback('closereport', function(data)
    lib.callback.await('adminmenu:selfClose', false, data.id)

    SendNUIMessage({
        type = 'close-self',
    })
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