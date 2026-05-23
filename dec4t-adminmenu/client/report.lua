Reports = {}

RegisterNetEvent('adminmenu:updateReport', function(action, array)
    local reportKey = 'report_'..array.id
    if action == 'add' then
        Reports[reportKey] = array

        SendNUIMessage({
            type = 'reports',
            reports = Reports,
        })
        return
    elseif action == 'chat' then
        if not Reports[reportKey] then return end

        if not Reports[reportKey].chat then
            Reports[reportKey].chat = {}
        end

        local reportChat = Reports[reportKey].chat

        table.insert(reportChat, {
            user = array.user,
            message = array.message,
            role = array.role,
        })

        SendNUIMessage({
            type = 'reports',
            reports = Reports,
        })

        SendNUIMessage({
            type = 'update-chat',
            id = array.id,
            chat = reportChat,
        })
        return
    elseif action == 'close' then
        if not Reports[reportKey] then return end

        SendNUIMessage({
            type = 'remove-report',
            id = array.id,
        })

        Reports[reportKey] = nil

        SendNUIMessage({
            type = 'reports',
            reports = Reports,
        })
        return
    elseif action == 'claim' then
        if not Reports[reportKey] then return end

        Reports[reportKey].status = true
        Reports[reportKey].admin = array.admin

        SendNUIMessage({
            type = 'reports',
            reports = Reports,
        })
    end
end)