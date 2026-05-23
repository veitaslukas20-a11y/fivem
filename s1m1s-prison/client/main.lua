local Config = lib.load('config')
local Time = 0

local Target = exports.ox_target

local function PlayAnimation(label, anim, prop, duration)
    return lib.progressCircle({
        duration = duration,
        label = label,
        canCancel = true,
        useWhileDead = false,
        allowRagdoll = false,
        allowCuffed = false,
        allowFalling = false,
        disable = {
            move = true,
            car = true,
            combat = true,
        },
        anim = anim,
        prop = prop,
    }) 
end

local DoingTask = false
local TasksTargets = {}
local Blips = {}
local Point

local function TeleportBack()
    Citizen.CreateThread(function()
        while true do
            if IsEntityAttached(cache.ped) then
                DetachEntity(cache.ped, false, true)
            end

            if cache.vehicle then
                TaskLeaveVehicle(cache.ped, cache.vehicle, 16)
            end

            if #(GetEntityCoords(cache.ped) - Config.Zone.Coords) > Config.Zone.Radius then
                SetEntityCoords(cache.ped, vec3(Config.Enter))
            else
                break
            end
        end

        SetEntityHeading(cache.ped, Config.Enter.w)
    end)
end

AddEventHandler('reload_death:onPlayerRevive', function()
    if Time <= 0 then return end
    Wait(500)
    SetEntityCoords(cache.ped, vec3(Config.Enter))
end)

local function InitJobs()
    Point = lib.points.new({
        coords = Config.Zone.Coords,
        distance = Config.Zone.Radius,
    })

    function Point:onExit()
        if Time <= 0 then return end
        TeleportBack()
    end

    lib.disableControls:Add({37, 141, 140, 142, 25, 106, 91})
    function Point:nearby()
		lib.disableControls()
    end


    for index, data in pairs(Config.Works) do
        for id, coords in pairs(data.Locations) do
            local blip = AddBlipForCoord(vec3(coords))
            SetBlipSprite(blip, 1)
            SetBlipDisplay(blip, 2)
            SetBlipScale(blip, 0.5)
            SetBlipColour(blip, 29)
            SetBlipAsShortRange(blip, false)
            BeginTextCommandSetBlipName("STRING")
            AddTextComponentString('<font face="Roboto">'..data.Target..'</font>')
            EndTextCommandSetBlipName(blip)

            Blips[#Blips + 1] = blip

            TasksTargets[#TasksTargets + 1] = Target:addBoxZone({
                coords = vec3(coords.x, coords.y, coords.z - 1.0),
                size = vec3(1.0, 1.0, 1.0),
                rotation = 0,
                options = {
                    {
                        label = data.Target,
                        icon = data.Icon,
                        distance = 2.0,
                        onSelect = function()
                            if DoingTask then return end
                            DoingTask = true
                            if PlayAnimation(data.Label, data.Anim, data.Prop, data.Duration) then
local result = lib.callback.await('prison:doneJob', false, index, id)
DoingTask = false

if result then
    -- Refresh time from server after job completion
    Time = lib.callback.await('prison:getTime', false)
    
    -- Check if time is up after work
    if Time <= 0 then
        TriggerEvent('prison:unjailed')
    end
                                end
                                DoingTask = false
                            else
                                DoingTask = false
                            end
                        end
                    }
                }
            })
        end
    end
end

local function FormatTime(ms)
    local minutes = math.floor(ms / 60 / 1000)
    ms -= minutes * 60 * 1000
    local seconds = math.floor(ms / 1000)
    return minutes, seconds
end

local function SetJailTimer()
    Citizen.CreateThreadNow(function()
        while Time > 0 do
            Time -= 1000

            local minutes, seconds = FormatTime(Time)
            lib.showTextUI(('Jums liko %d:%02d'):format(minutes, seconds), {
                position = 'top-center',
                icon = 'fa-solid fa-handcuffs',
                iconAnimation = 'beatFade',
            })

            -- Check if time is up
            if Time <= 0 then
                TriggerEvent('prison:unjailed')
                break
            end

            Wait(1000)
        end
    end)
end

local function SetUniform(jail)
	if jail then
		TriggerEvent('skinchanger:getSkin', function(skin)
			local uniformObject = (skin.sex == 0) and Config.Uniform.Male or Config.Uniform.Female

			TriggerEvent('skinchanger:loadClothes', skin, uniformObject)
		end)
	else
		ESX.TriggerServerCallback('esx_skin:getPlayerSkin', function(skin)
			TriggerEvent('skinchanger:loadSkin', skin)
		end)
	end
end

lib.callback.register('prison:checkJob', function()
    return DoingTask
end)

lib.callback.register('prison:doneJob', function(workIndex, locationId)
    -- Get player identifier
    local player = ESX.GetPlayerData()
    if not player or not player.identifier then return false end
    
    -- Calculate time to remove (in milliseconds)
    local workData = Config.Works[workIndex]
    if not workData then return false end
    
    local removeMs = workData.Remove or (1 * 60 * 1000)
    
    -- Update time locally
    Time = math.max(0, Time - removeMs)
    
    -- Return success
    return true
end)

RegisterNetEvent('prison:jailed', function()
    Time = lib.callback.await('prison:getTime', false)
    
    if Time > 0 then
        SetJailTimer()

        SetEntityCoords(cache.ped, vec3(Config.Enter))
        SetEntityHeading(cache.ped, Config.Enter.w)

        SetUniform(true)

        InitJobs()
    else
        -- Time is already up, trigger unjail immediately
        TriggerEvent('prison:unjailed')
    end
end)

-- client snippet (įdėti į tavo client failą)
RegisterNetEvent('prison:openJailMenu', function()
    -- LT texts per tavo pageidavimą
    local dialog = lib.inputDialog('Įkalinimas', {
        { type = 'input', label = 'Žaidėjo server ID', required = true },
        { type = 'input', label = 'Minutės', required = true },
        { type = 'input', label = 'Išpirkos kaina (EUR)', required = false },
    })
    if not dialog then return end

    local targetId = tonumber(dialog[1])
    local minutes = tonumber(dialog[2])
    local price = tonumber(dialog[3]) or 0

    -- show confirmation
    local choice = lib.alertDialog({
        header = 'Patvirtinimas',
        content = ('Ar tikrai norite įkalinti %s už %d min? Išpirkos kaina: %d€'):format(tostring(targetId), minutes, price),
        centered = true
    })
    if choice ~= 'confirm' then return end

    -- call server callback to do jail
    local ok, err = lib.callback.await('prison:doJail', false, targetId, minutes, price)
    if ok then
        lib.notify({title = 'Kalėjimas', description = 'Sėkmingai įkalinta.', type = 'success'})
    else
        lib.notify({title = 'Kalėjimas', description = 'Įvyko klaida: ' .. tostring(err or ''), type = 'error'})
    end
end)

RegisterNetEvent('prison:unjailed', function()
    Time = 0

    if Point then
        Point:remove()
    end
    lib.hideTextUI()

    SetEntityCoords(cache.ped, vec3(Config.Exit))
    SetEntityHeading(cache.ped, Config.Exit.w)
    SetUniform(false)

    for _, id in pairs(TasksTargets) do
        Target:removeZone(id)
    end

    for _, blip in pairs(Blips) do
        RemoveBlip(blip)
    end

    TasksTargets = {}
    Blips = {}

    lib.disableControls:Remove({37, 141, 140, 142, 25, 106, 91})
end)

Citizen.CreateThread(function()
    local blip = AddBlipForCoord(vec3(Config.Enter))
    SetBlipSprite(blip, 188)
    SetBlipDisplay(blip, 4)
    SetBlipScale(blip, 1.2)
    SetBlipColour(blip, 29)
    SetBlipAsShortRange(blip, false)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString('<font face="Roboto">Kalėjimas</font>')
    EndTextCommandSetBlipName(blip)

    local NPC = nil
    local npcModel = `s_m_m_armoured_01`
    lib.points.new({
        coords = Config.NPC,
        distance = 20,
        onEnter = function()
            if NPC then return end
            lib.requestModel(npcModel)
            NPC = CreatePed(4, npcModel, Config.NPC.x, Config.NPC.y, Config.NPC.z -1.0, Config.NPC.w, false, true)
            SetModelAsNoLongerNeeded(npcModel)
            FreezeEntityPosition(NPC, true)
            SetEntityInvincible(NPC, true)
            SetBlockingOfNonTemporaryEvents(NPC, true)
            NetworkFadeInEntity(NPC, true)
    
            Target:addLocalEntity(NPC, {
                {
                    label = "Peržiūrėti įkalintuosius",
                    icon = "fa-solid fa-handcuffs",
                    distance = 2.0,
                    onSelect = function()
                        local Options = {}

                        local jailed = lib.callback.await('prison:getJailed', false)

                        for _, player in pairs(jailed) do
                            table.insert(Options, {
                                title = ('%s įkalintas %d minutėms'):format(player.name, player.time),
                                description = ('Išpirkite šį asmenį iš kalėjimo už %d€'):format(player.price),
                                onSelect = function()
                                    local alert = lib.alertDialog({
                                        header = 'Ar esate tikras',
                                        content = ('kad norite išpirkti %s iš kalėjimo už %d€'):format(player.name, player.price),
                                        centered = true,
                                        cancel = true
                                    })

                                    if alert == 'confirm' then
                                        local unjailed, amount = lib.callback.await('prison:tryUnjail', false, player.id)
                                        if not unjailed then
                                            exports['1x-hud']:sendNotification({
                                                type = 'ERROR',
                                                title = 'Kalėjimas',
                                                message = 'Įvyko klaida bandant išpirkti asmenį iš kalėjimo. Tai galėjo įvykti dėl to, jog neturite pakankamai pinigų sąskaitoje arba asmuo nebėra aktyvus.',
                                                duration = 5000,
                                            })
                                        else
                                            exports['1x-hud']:sendNotification({
                                                type = 'INFO',
                                                title = 'Kalėjimas',
                                                message = ('Sėkmingai išleidote %s asmenį iš kalėjimo už %d€.'):format(player.name, amount),
                                                duration = 5000,
                                            })
                                        end
                                    end
                                end
                            })
                        end

                        lib.registerContext({
                            id = 'jail:prisoners',
                            title = 'Kalėjimas',
                            options = Options
                        })
                        lib.showContext('jail:prisoners')
                    end,
                },
            })
        end,
        onExit = function()
            if NPC then
                DeleteEntity(NPC)
                NPC = nil
            end
        end
    })
end)