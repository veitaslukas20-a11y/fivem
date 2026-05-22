-- local nui = false
-- local currentCam = nil
-- local isTimerActive = false

-- local TIMER_INTERVAL = 1000
-- local ANIMATION_DICT = "anim@mp_bedmid@left_var_04"
-- local ANIMATION_NAME = "f_sleep_l_loop_bighouse"

-- local BED_CONFIG = {
--     coords = vector3(-485.5482, -340.5350, 68.8),
--     heading = 346.6909,
--     wakeupCoords = vector3(-435.7338, -357.4071, 34.9107),
--     wakeupHeading = 353.8511
-- }

-- local CAM_CONFIG = {
--     offset = vector3(1.5, 1.5, 1.0),
--     circleRadius = 1.5,
--     circleHeight = 2.0,
--     animationDuration = 4000,
--     progressMultiplier = 3
-- }

-- local function sendAngularMessage(action, data)
--     SendNUIMessage({
--         action = action,
--         data = data
--     })
-- end

-- local function toggleNui(type, shouldShow)
--     SetNuiFocus(shouldShow, shouldShow)
--     nui = shouldShow
--     sendAngularMessage("toggleNui", {
--         type = type,
--         shouldShow = shouldShow
--     })
-- end

-- local function cleanupCamera()
--     if currentCam and DoesCamExist(currentCam) then
--         RenderScriptCams(false, false, 0, true, true)
--         DestroyCam(currentCam, false)
--         currentCam = nil
--     end
-- end

-- local function resetPlayerState()
--     local playerPed = PlayerPedId()
--     FreezeEntityPosition(playerPed, false)
--     ClearPedTasksImmediately(playerPed)
    
--     SetEntityCoords(playerPed, BED_CONFIG.wakeupCoords)
--     SetEntityHeading(playerPed, BED_CONFIG.wakeupHeading)
-- end

-- local function showWakeupNotification()
--     exports['1x-hud']:sendNotification({
--         type = 'SUCCESS',
--         title = 'Vyr. Daktaras',
--         message = 'Jūs atsikėlėte iš lovos. Jūsų sveikata yra atstatyta.',
--         duration = 6000,
--         icon = 'staff-snake'
--     })
-- end

-- local function startTimer(seconds)
--     if isTimerActive then return end
    
--     isTimerActive = true
--     local timer = seconds
    
--     Citizen.CreateThread(function()
--         while timer > 0 and isTimerActive do
--             Citizen.Wait(TIMER_INTERVAL)
--             timer = timer - 1
            
--             sendAngularMessage("updateTimer", {
--                 time = timer,
--                 type = "bed"
--             })
--         end
        
--         if isTimerActive then
--             isTimerActive = false
--             toggleNui("", false)
--             cleanupCamera()
--             resetPlayerState()
--             TriggerServerEvent('imports:setDimension')
--             showWakeupNotification()
--             TriggerServerEvent('esx_ambulancejob:setBedStatus', false)
--         end
--     end)
-- end

-- local function setupPlayerAnimation()
--     local playerPed = PlayerPedId()
    
--     FreezeEntityPosition(playerPed, true)
--     SetEntityCoords(playerPed, BED_CONFIG.coords)
--     SetEntityHeading(playerPed, BED_CONFIG.heading)
    
--     RequestAnimDict(ANIMATION_DICT)
--     while not HasAnimDictLoaded(ANIMATION_DICT) do
--         Citizen.Wait(10)
--     end
    
--     TaskPlayAnim(playerPed, ANIMATION_DICT, ANIMATION_NAME, 8.0, -8.0, -1, 1, 0, false, false, false)
    
--     return playerPed
-- end

-- local function createCameraWithAnimation(playerPed)
--     currentCam = CreateCam("DEFAULT_SCRIPTED_CAMERA", true)
    
--     local startPos = BED_CONFIG.coords + CAM_CONFIG.offset
--     SetCamCoord(currentCam, startPos.x, startPos.y, startPos.z)
--     PointCamAtEntity(currentCam, playerPed, 0.0, 0.0, 0.0, true)
--     SetCamActive(currentCam, true)
--     RenderScriptCams(true, false, 0, true, true)
    
--     local startTime = GetGameTimer()
--     local endTime = startTime + CAM_CONFIG.animationDuration
    
--     Citizen.CreateThread(function()
--         while GetGameTimer() < endTime do
--             local progress = (endTime - GetGameTimer()) / CAM_CONFIG.animationDuration
--             local angle = progress * CAM_CONFIG.progressMultiplier
            
--             local newX = BED_CONFIG.coords.x + math.cos(angle) * CAM_CONFIG.circleRadius
--             local newY = BED_CONFIG.coords.y + math.sin(angle) * CAM_CONFIG.circleRadius
--             local newZ = BED_CONFIG.coords.z + CAM_CONFIG.circleHeight
            
--             SetCamCoord(currentCam, newX, newY, newZ)
--             PointCamAtEntity(currentCam, playerPed, 0.0, 0.0, 0.0, true)
            
--             Citizen.Wait(10)
--         end
--     end)
-- end

-- local function toggleBed()
--     TriggerServerEvent('esx_ambulancejob:setBedStatus', true)
--     TriggerServerEvent('imports:setDimension')
--     toggleNui("bed", true)
    
--     local bedTimer = ESX.Math.Round(Config.BedTimer / 1000)
--     startTimer(bedTimer)
    
--     local playerPed = setupPlayerAnimation()
--     createCameraWithAnimation(playerPed)
-- end

-- local function forceExitBed()
--     if not nui then return end
    
--     isTimerActive = false
--     toggleNui("", false)
--     cleanupCamera()
--     resetPlayerState()
    
--     TriggerServerEvent('imports:setDimension')
    
--     TriggerServerEvent('esx_ambulancejob:setBedStatus', false)
    
--     exports['1x-hud']:sendNotification({
--         type = 'INFO',
--         title = 'Vyr. Daktaras',
--         message = 'Jūs buvote pašalinti iš lovos administracijos sprendimu.',
--         duration = 6000,
--         icon = 'staff-snake'
--     })
-- end

-- RegisterNUICallback("hideFrame", function(_, cb)
--     isTimerActive = false
--     toggleNui("", false)
--     cleanupCamera()
--     cb({})
-- end)

-- RegisterNetEvent('esx_ambulancejob:toggleBed')
-- AddEventHandler('esx_ambulancejob:toggleBed', toggleBed)

-- RegisterNetEvent('esx_ambulancejob:forceExitBed')
-- AddEventHandler('esx_ambulancejob:forceExitBed', forceExitBed)