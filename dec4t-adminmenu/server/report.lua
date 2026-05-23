local Reports = {}

-- 📝 Žaidėjas sukuria reportą
lib.callback.register('adminmenu:createReport', function(source, data)
    local reportId = math.random(1000, 9999)
    data.id = reportId
    data.status = false
    data.chat = {}
    data.admin = nil
    data.player = {
        id = source,
        name = GetPlayerName(source)
    }

    Reports['report_'..reportId] = data

    -- Atnaujinam visiems adminams
    TriggerClientEvent('adminmenu:updateReports', -1, Reports)

    print(('✅ Reportas sukurtas #%s nuo %s'):format(reportId, data.player.name))
    return data
end)

-- 🗑 Žaidėjas pats uždaro savo reportą
lib.callback.register('adminmenu:selfClose', function(source, reportId)
    local reportKey = 'report_'..reportId
    local report = Reports[reportKey]
    if not report then return false end

    -- Patikrinam ar žaidėjas pats sukūrė reportą
    if report.player.id ~= source then return false end

    Reports[reportKey] = nil

    TriggerClientEvent('adminmenu:removeReport', -1, reportId)
    TriggerClientEvent('adminmenu:updateSelfHistory', source)

    print(('❌ Reportas #%s uždarytas žaidėjo %s'):format(reportId, GetPlayerName(source)))
    return true
end)

lib.callback.register('adminmenu:sendMessage', function(source, reportId, message)
    local report = Reports[reportId]
    if not report then return false end

    -- Ensure chat exists
    report.chat = report.chat or {}

    local isAdmin = report.admin and report.admin.id == source
    local senderName = GetSafePlayerName(source)

    local chatEntry = {
        senderId = source,
        senderName = senderName,
        message = message or "",
        time = os.time(),
        role = isAdmin and 'admin' or 'user',
        color = isAdmin and (report.admin.color or "#FF0000") or "#FFFFFF"
    }

    table.insert(report.chat, chatEntry)

    -- Notify participants with safe data
    TriggerClientEvent('adminmenu:updateSelfChat', report.ownerId, {
        senderName = senderName,
        message = message or "",
        color = chatEntry.color,
        role = chatEntry.role
    })

    return true
end)

-- ✅ Adminas claim'ina reportą
RegisterNetEvent('adminmenu:serverUpdateReport', function(action, array)
    local reportKey = 'report_'..array.id
    local report = Reports[reportKey]
    if not report then return end

    if action == 'claim' then
        report.status = true
        report.admin = array.admin

        TriggerClientEvent('adminmenu:updateReports', -1, Reports)
        print(('⚠️ Reportas #%s claimintas admino: %s'):format(array.id, array.admin))

    elseif action == 'close' then
        Reports[reportKey] = nil

        TriggerClientEvent('adminmenu:removeReport', -1, array.id)
        TriggerClientEvent('adminmenu:updateSelfHistory', report.player.id)

        print(('🔒 Reportas #%s uždarytas admino'):format(array.id))
    end
end)


RegisterNetEvent('adminmenu:gotoPlayer', function(targetId)
    local src = source
    local targetPed = GetPlayerPed(targetId)
    local coords = GetEntityCoords(targetPed)

    TriggerClientEvent('adminmenu:teleportTo', src, coords)
end)

-- CLIENT teleport handler
RegisterNetEvent('adminmenu:teleportTo', function(coords)
    SetEntityCoords(PlayerPedId(), coords.x, coords.y, coords.z, false, false, false, false)
end)
