local canChange = true

-- NUI: nustatyti darbą
RegisterNUICallback('setJob', function(data)
    if not data then return end
    if not canChange then return end
    canChange = false

    local success = lib.callback.await('d-multijob:setJob', false, data)
    if success then
        -- galim atnaujinti UI iš karto
        local jobs = lib.callback.await('d-multijob:getJobs', false)
        SendNUIMessage({
            show = true,
            jobs = jobs
        })
    end

    Wait(1000)
    canChange = true
end)

-- NUI: ištrinti darbą
RegisterNUICallback('deleteJob', function(data)
    if not data then return end
    lib.callback.await('d-multijob:deleteJob', false, data)

    -- atnaujinam UI po job pašalinimo
    local jobs = lib.callback.await('d-multijob:getJobs', false)
    if #jobs == 0 then
        SendNUIMessage({show=false})
        SetNuiFocus(false, false)
    else
        SendNUIMessage({show=true, jobs=jobs})
    end
end)

-- NUI: uždaryti meniu
RegisterNUICallback('close', function(data)
    SendNUIMessage({show=false})
    SetNuiFocus(false, false)
end)

-- Komanda: atidaryti /darbai meniu
RegisterCommand('darbai', function()
    local result = lib.callback.await('d-multijob:getJobs', false)

    if #result == 0 then
        exports['1x-hud']:sendNotification({
            type = 'ERROR',
            title = 'Darbai',
            message = 'Deja, neturite jokių darbų. Esate bedarbis.',
            duration = 5000,
            icon = 'briefcase'
        })
        return
    end

    -- ikonėlės ir gang pavadinimai
    for _, data in pairs(result) do
        data.icon = Config.icons[data.job] or Config.icons['gangs']
        local gangName = exports['s1m1s-gangzones']:getGangName(data.job)
        if gangName then
            data.job_label = gangName
        end
    end

    SendNUIMessage({
        show = true,
        jobs = result
    })
    SetNuiFocus(true, true)
end)
