-- ESX = nil
-- PlayerData = nil
-- PlayerJob = nil
-- PlayerGrade = nil
-- local VehicleData = nil

-- RegisterNetEvent('gk-carflip:Notify', function(message, type)
--     if Config.UseCustomNotify then
--         TriggerEvent('gk-carflip:CustomNotify', message, type)
--     elseif Config.UseESX then
--         ESX.ShowNotification(message)
--     end
-- end)

-- CreateThread(function()
--     if Config.UseESX then
--         while ESX == nil do
--             TriggerEvent("esx:getSharedObject", function(obj) ESX = obj end)
--             Wait(0)
--         end

--         while not ESX.IsPlayerLoaded() do
--             Wait(100)
--         end

--         PlayerData = ESX.GetPlayerData()
--         PlayerJob = PlayerData.job.name
--         PlayerGrade = PlayerData.job.grade

--         RegisterNetEvent("esx:setJob", function(job)
--             PlayerJob = job.name
--             PlayerGrade = job.grade
--         end)
--     end

--     if Config.UseChatCommand then
--         RegisterCommand(Config.ChatCommand, function()
--             TriggerEvent('gk-carflip:flipcar')
--         end)
--     end
-- end)

-- function hasRequiredJob()
--     local jobs = Config.Jobs == nil or next(Config.Jobs)
--     if jobs then
--         for jobName, gradeLevel in pairs(Config.Jobs) do
--             if PlayerJob == jobName and PlayerGrade >= gradeLevel then
--                 return true
--             end
--         end
--         return false
--     else
--         return true
--     end
-- end

-- RegisterNetEvent('gk-carflip:flipcar')
-- AddEventHandler('gk-carflip:flipcar', function()
--     local ped = PlayerPedId()
--     local inside = IsPedInAnyVehicle(ped, true)
--     if inside then
--         TriggerEvent('gk-carflip:Notify', Config.Lang['in_vehicle'], Config.LangType['error'])
--     elseif hasRequiredJob() then
--         local pedcoords = GetEntityCoords(ped)
--         VehicleData = ESX.Game.GetClosestVehicle()
--         local dist = #(pedcoords - GetEntityCoords(VehicleData))
--         if dist <= 3 then
--             local animDict = 'mini@repair'
--             local animName = 'fixing_a_player'

--             RequestAnimDict(animDict)
--             while not HasAnimDictLoaded(animDict) do
--                 Wait(10)
--             end

--             FreezeEntityPosition(ped, true)
--             TaskPlayAnim(ped, animDict, animName, 2.0, -2.0, -1, 49, 0, 0, 0, 0)

--             lib.progressBar({
--                 duration = Config.TimetoFlip * 1000,
--                 label = 'Apverčiama mašina...',
--                 useWhileDead = false,
--                 canCancel = true,
--                 controlDisables = {
--                     disableMovement = true,
--                     disableCarMovement = true,
--                     disableMouse = false,
--                     disableCombat = true,
--                 },
--                 animation = {
--                     animDict = animDict,
--                     anim = animName,
--                     flags = 49,
--                 },
--             })

--             local carCoords = GetEntityRotation(VehicleData, 2)
--             SetEntityRotation(VehicleData, carCoords[1], 0, carCoords[3], 2, true)
--             SetVehicleOnGroundProperly(VehicleData)
--             TriggerEvent('gk-carflip:Notify', Config.Lang['flipped'], Config.LangType['success'])
--             ClearPedTasks(ped)
--             FreezeEntityPosition(ped, false)
--         end
--     end
-- end)

-- CreateThread(function()
--     if Config.UseThirdEye then
--         exports[Config.ThirdEyeName]:Vehicle({
--             options = {
--                 {
--                     event = "gk-carflip:flipcar",
--                     icon = "fas fa-arrow-up",
--                     label = "Apversti tr. priemonę",
--                     distance = 2
--                 },
--             },
--         })
--     end
-- end)


local alreadyRevived = false

CreateThread(function()
    while true do
        Wait(500)
        local playerPed = PlayerPedId()

        if IsPedFatallyInjured(playerPed) and not alreadyRevived then
            local killer = GetPedSourceOfDeath(playerPed)

            if killer ~= 0 and IsEntityAVehicle(killer) then
                alreadyRevived = true

                Wait(1000)
                TriggerEvent('esx_ambulancejob:revive')
                
                exports['1x-hud']:sendNotification({
                    type = 'success',
                    title = 'Anti-VDM',
                    message = 'Kadangi jus nutrenkė transporto priemonė, buvote prikelti',
                    duration = 5000,
                    icon = 'heartbeat'
                })

                CreateThread(function()
                    local startTime = GetGameTimer()
                    while IsPedFatallyInjured(PlayerPedId()) and (GetGameTimer() - startTime) < 5000 do
                        Wait(100)
                    end
                    
                    if IsPedFatallyInjured(PlayerPedId()) then
                        TriggerEvent('esx_ambulancejob:revive')
                        Wait(1000)
                    end

                    if not IsPedFatallyInjured(PlayerPedId()) then
                        local ped = PlayerPedId()

                        DoScreenFadeOut(550)
                        Wait(500)
                        DoScreenFadeIn(550)

                        local coords = GetEntityCoords(ped)
                        local forward = GetEntityForwardVector(ped)
                        local safeCoords = coords + forward * 1.5

                        SetEntityCoords(ped, safeCoords.x, safeCoords.y, safeCoords.z, false, false, false, true)
                        ClearPedTasksImmediately(ped)
                        SetEntityInvincible(ped, true)
                        Wait(5000)
                        SetEntityInvincible(ped, false)
                    end

                    Wait(5000)
                    alreadyRevived = false
                end)
            end
        end
    end
end)