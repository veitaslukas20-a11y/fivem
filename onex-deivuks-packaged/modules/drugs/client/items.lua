local Inventory = exports.ox_inventory
local UsingMeth = false
local MethTimeout = false
exports('meth', function(data, slot)
    if UsingMeth then return end
    if MethTimeout then return end
    Inventory:useItem(data, function(data)
        if data then
            SetTimeout(120000, function() MethTimeout = false end)
            MethTimeout = true
            UsingMeth = true
            local success = PlayProgress('Vartojate amfetaminą...', 3000, {
                dict = "mp_suicide",
                clip = "pill",
                flag = 49,
            })
            if not success then UsingMeth = false return end

            Citizen.CreateThread(function()
                StartScreenEffect('DeathFailMichaelIn', 0, false)
                Wait(40000)
                StopScreenEffect('DeathFailMichaelIn')
            end)

            Citizen.CreateThread(function()
                if not HasAnimSetLoaded("move_m@hobo@a") then
                    RequestAnimSet("move_m@hobo@a")
                    while not HasAnimSetLoaded("move_m@hobo@a") do
                        Citizen.Wait(0)
                    end
                end
                
                local time = 40000
                while time > 0 do
                    Wait(50)
                    ShakeGameplayCam("DRUNK_SHAKE", 1.5)
                    SetPedMotionBlur(cache.ped, true)

                    SetPedMovementClipset(cache.ped, "move_m@hobo@a", true)
                    SetPedIsDrunk(cache.ped, true)
                    SetPedAccuracy(cache.ped, 0)

                    time -= 50
                end

                ClearTimecycleModifier()
                ResetScenarioTypesEnabled()
                ResetPedMovementClipset(cache.ped, 0)
                SetPedIsDrunk(cache.ped, false)
                SetPedMotionBlur(cache.ped, false)
                StopGameplayCamShaking(false)

                SetPedToRagdoll(cache.ped, 1500, 1500, 0, 0, 0, 0)
                UsingMeth = false
            end)

            Citizen.CreateThread(function()
                local time2 = 15000
                local maxHealth = GetEntityMaxHealth(cache.ped)-1
                while time2 > 0 do
                    time2 -= 1000

                    local health = GetEntityHealth(cache.ped)

                    health += math.floor((20/15 * 1.0))

                    if health >= maxHealth then
                        SetEntityHealth(cache.ped, maxHealth)
                        break
                    end

                    exports['deivuks-utils']:health()
                    SetEntityHealth(cache.ped, health)

                    Wait(1000)
                end
            end)
        end
    end)
end)

local UsingCoke = false
exports('coke_proc', function(data, slot)
    if UsingCoke then return end
    Inventory:useItem(data, function(data)
        if data then
            UsingCoke = true
            local success = PlayProgress('Šniojate kokainą...', 8000, {
                dict = "missfbi3_party",
                clip = "snort_coke_b_male3",
            }, 1)
            if not success then UsingCoke = false return end

            Citizen.CreateThread(function()
                StartScreenEffect('DeadlineNeon', 0, false)
                Wait(40000)
                StopScreenEffect('DeadlineNeon')
            end)

            Citizen.CreateThread(function()
                if not HasAnimSetLoaded("MOVE_M@DRUNK@VERYDRUNK") then
                    RequestAnimSet("MOVE_M@DRUNK@VERYDRUNK")
                    while not HasAnimSetLoaded("MOVE_M@DRUNK@VERYDRUNK") do
                        Citizen.Wait(0)
                    end
                end
                
                local time = 40000
                while time > 0 do
                    Wait(50)
                    ShakeGameplayCam("DRUNK_SHAKE", 1.5)
                    SetPedMotionBlur(cache.ped, true)

                    SetPedMovementClipset(cache.ped, "MOVE_M@DRUNK@VERYDRUNK", true)
                    SetPedIsDrunk(cache.ped, true)
                    SetPedAccuracy(cache.ped, 0)

                    time -= 50
                end

                ClearTimecycleModifier()
                ResetScenarioTypesEnabled()
                ResetPedMovementClipset(cache.ped, 0)
                SetPedIsDrunk(cache.ped, false)
                SetPedMotionBlur(cache.ped, false)
                StopGameplayCamShaking(false)

                SetPedToRagdoll(cache.ped, 1500, 1500, 0, 0, 0, 0)

                local time = 30000
                while time > 0 do
                    RestorePlayerStamina(cache.playerId, 1.0)
                    SetPedMoveRateOverride(cache.ped, 5.0)
                    Wait(200)
                    time -= 200
                end

                RestorePlayerStamina(cache.playerId, 0.0)
                SetPedMoveRateOverride(cache.ped, 0.0)

                UsingCoke = false
            end)
        end
    end)
end)

local UsingPara = false
exports('paracetamolis', function(data, slot)
    local playerPed = PlayerPedId()
    local maxHealth = GetEntityMaxHealth(playerPed)-1
    local health = GetEntityHealth(playerPed)

    if UsingPara then return end
    if health < maxHealth then
        Inventory:useItem(data, function(data)
            if data then
                UsingPara = true

                local success = PlayProgress('Rijate tabletę...', 3000, {
                    dict = "mp_suicide",
                    clip = "pill",
                }, 49)
                if not success then UsingPara = false return end

                Citizen.CreateThread(function()
                    StartScreenEffect('PPOrange', 0, false)
                    Wait(15000)
                    StopScreenEffect('PPOrange')
                    UsingPara = false
                end)

                Citizen.CreateThread(function()
                    for i=1, 20 do
                        health = GetEntityHealth(playerPed) + 1

                        if health >= maxHealth then
                            SetEntityHealth(playerPed, maxHealth)
                            break
                        end

                        exports['deivuks-utils']:health()
                        SetEntityHealth(playerPed, health)
                        Wait(500)
                    end
                end)
            end
        end)
    end
end)

local UsingAsp = false
exports('aspirinas', function(data, slot)
    if UsingAsp then return end
    Inventory:useItem(data, function(data)
        if data then
            UsingAsp = true
            Citizen.CreateThread(function()
                StartScreenEffect('ChopVision', 0, false)
                Wait(20000)
                StopScreenEffect('ChopVision')
                UsingAsp = false
            end)

            Citizen.CreateThread(function()
                local deleffect = 10000
                while deleffect > 0 do
                    deleffect -= 50
                    SetPedToRagdoll(PlayerPedId(), 1000, 1000, 0, 0, 0, 0)
                    Wait(50)
                end
            end)
        end
    end)
end)

local UsingKet = false
exports('ketaminas', function(data, slot)
    if UsingKet then return end
    Inventory:useItem(data, function(data)
        if data then
            UsingKet = true
            Citizen.CreateThread(function()
                StartScreenEffect('PPGreen', 0, false)
                Wait(20000)
                StopScreenEffect('PPGreen')
                UsingKet = false
            end)

            Citizen.CreateThread(function()
                local deleffect = 10000
                while deleffect > 0 do
                    deleffect -= 50
                    SetPedToRagdoll(PlayerPedId(), 1000, 1000, 0, 0, 0, 0)
                    Wait(50)
                end
            end)
        end
    end)
end)

local UsingEct = false
exports('ecstasy', function(data, slot)
    if UsingEct then return end
    Inventory:useItem(data, function(data)
        if data then
            UsingEct = true
            local success = PlayProgress('Rijate tabletę...', 3000, {
                dict = "mp_suicide",
                clip = "pill",
            }, 49)
            if not success then UsingEct = false return end

            Citizen.CreateThread(function()
                StartScreenEffect('PPOrange', 0, false)
                Wait(23000)
                StopScreenEffect('PPOrange')

                StartScreenEffect('ChopVision', 0, false)
                Wait(23000)
                StopScreenEffect('ChopVision')

                StartScreenEffect('PPGreen', 0, false)
                Wait(23000)
                StopScreenEffect('PPGreen')
            end)

            Citizen.CreateThread(function()
                local time = 65000
                if not HasAnimSetLoaded("MOVE_M@DRUNK@VERYDRUNK") then
                    RequestAnimSet("MOVE_M@DRUNK@VERYDRUNK")
                    while not HasAnimSetLoaded("MOVE_M@DRUNK@VERYDRUNK") do
                        Citizen.Wait(0)
                    end
                end

                while time > 0 do
                    Wait(50)
                    ShakeGameplayCam("DRUNK_SHAKE", 2.0)
                    SetPedMotionBlur(cache.ped, true)

                    SetPedMovementClipset(cache.ped, "MOVE_M@DRUNK@VERYDRUNK", true)
                    SetPedIsDrunk(cache.ped, true)
                    SetPedAccuracy(cache.ped, 0)

                    time -= 50
                end

                ClearTimecycleModifier()
                ResetScenarioTypesEnabled()
                ResetPedMovementClipset(cache.ped, 0)
                SetPedIsDrunk(cache.ped, false)
                SetPedMotionBlur(cache.ped, false)
                StopGameplayCamShaking(false)
                UsingEct = false
            end)

            Citizen.CreateThread(function()
                local time = 60000
                while time > 0 do
                    SetPedToRagdoll(cache.ped, 1500, 1500, 0, 0, 0, 0)

                    if not cache.vehicle then
                        Wait(100)
                        DoScreenFadeOut(100)
                        Wait(1000)
                        DoScreenFadeIn(100)
                    end

                    time -= 10000
                
                    Wait(10000)
                end
            end)
        end
    end)
end)

local UsingHera = false
exports('heroin_syringe', function(data, slot)
    if UsingHera then return end
    Inventory:useItem(data, function(data)
        if data then
            UsingHera = true
            
            local syringeProp = `prop_syringe_01`
            local syringeDict = "rcmpaparazzo1ig_4"
            local syringeAnim = "miranda_shooting_up"
            local syringeBone = 28422
            local syringeOffset = vector3(0.0, 0.0, 0)
            local syringeRot = vector3(0, 0, 0)


            RequestAnimDict(syringeDict)

            while not HasAnimDictLoaded(syringeDict) do
                Citizen.Wait(150)
            end

            RequestModel(syringeProp)

            while not HasModelLoaded(syringeProp) do
                Citizen.Wait(150)
            end

            local syringeObj = CreateObject(syringeProp, 0.0, 0.0, 0.0, true, true, false)
            local syringeBoneIndex = GetPedBoneIndex(cache.ped, syringeBone)

            SetCurrentPedWeapon(cache.ped, `weapon_unarmed`, true)
            AttachEntityToEntity(syringeObj, cache.ped, syringeBoneIndex, syringeOffset.x, syringeOffset.y, syringeOffset.z, syringeRot.x, syringeRot.y, syringeRot.z, false, false, false, false, 2, true)
            SetModelAsNoLongerNeeded(syringeProp)

            TaskPlayAnim(cache.ped, syringeDict, syringeAnim, 8.0, -8.0, -1, 49, 0, 0, 0, 0)

            RemoveAnimDict(syringeDict)

            local success = PlayProgress('Leidžiatės heroiną...', 30000)
            if not success then UsingHera = false return end

            ClearPedTasksImmediately(cache.ped)
            DeleteEntity(syringeObj)
            DeleteObject(syringeObj)

            Citizen.CreateThread(function()
                StartScreenEffect('PPPink', 0, false)
                Wait(30000)
                StopScreenEffect('PPPink')

                local deleffect = 5000
                while deleffect > 0 do
                    deleffect -= 50
                    SetPedToRagdoll(cache.ped, 1000, 1000, 0, 0, 0, 0)

                    if not cache.vehicle then
                        if deleffect == 4000 then DoScreenFadeOut(100) end
                        if deleffect == 3000 then DoScreenFadeIn(100) end

                        if deleffect == 2000 then DoScreenFadeOut(100) end
                        if deleffect == 1000 then DoScreenFadeIn(100) end
                    end

                    Wait(50)
                end

                StartScreenEffect('Dont_tazeme_bro', 0, false)

                local deleffect = 30000
                if not HasAnimSetLoaded("MOVE_M@DRUNK@VERYDRUNK") then
                    RequestAnimSet("MOVE_M@DRUNK@VERYDRUNK")
                    while not HasAnimSetLoaded("MOVE_M@DRUNK@VERYDRUNK") do
                        Citizen.Wait(0)
                    end
                end

                while deleffect > 0 do
                    Wait(50)
                    ShakeGameplayCam("DRUNK_SHAKE", 3.0)
                    SetPedMotionBlur(cache.ped, true)

                    SetPedMovementClipset(cache.ped, "MOVE_M@DRUNK@VERYDRUNK", true)
                    SetPedIsDrunk(cache.ped, true)
                    SetPedAccuracy(cache.ped, 0)

                    deleffect -= 50
                end
                
                StopScreenEffect('Dont_tazeme_bro')

                ClearTimecycleModifier()
                ResetScenarioTypesEnabled()
                ResetPedMovementClipset(cache.ped, 0)
                SetPedIsDrunk(cache.ped, false)
                SetPedMotionBlur(cache.ped, false)
                StopGameplayCamShaking(false)


                SetPedToRagdoll(cache.ped, 1000, 1000, 0, 0, 0, 0)
                UsingHera = false
            end)
        end
    end)
end)

local UsingMush = false
exports('mushroom_proc', function(data, slot)
    if UsingMush then return end
    Inventory:useItem(data, function(data)
        if data then
            UsingMush = true
            
            local success = PlayProgress('Valgote grybukus...', 5000, {
                dict = "mp_player_inteat@burger",
                clip = "mp_player_int_eat_burger",
            })
            if not success then UsingMush = false return end

            Citizen.CreateThread(function()
                StartScreenEffect('DrugsTrevorClownsFight', 0, false)
                Wait(60000)
                StopScreenEffect('DrugsTrevorClownsFight')
            end)

            Citizen.CreateThread(function()
                SetTimecycleModifier('heathaze')
                SetTimecycleModifierStrength(1.5)
                if not HasAnimSetLoaded("MOVE_M@QUICK") then
                    RequestAnimSet("MOVE_M@QUICK")
                    while not HasAnimSetLoaded("MOVE_M@QUICK") do
                        Citizen.Wait(0)
                    end
                end

                PlaySoundFrontend(-1, "Prologue_Sounds", "COPS_ARRIVE", 1)
                StopSound(1)

                local time = 60000
                SetRunSprintMultiplierForPlayer(cache.playerId, 1.3)

                SetPedToRagdoll(cache.ped, 1500, 1500, 0, 0, 0, 0)

                while time > 0 do
                    Wait(50)
                    SetPedMoveRateOverride(cache.playerId, 8.0)
                    ShakeGameplayCam("DRUNK_SHAKE", 2.5)
                    SetPedMotionBlur(cache.ped, true)

                    SetPedMovementClipset(cache.ped, "MOVE_M@QUICK", true)
                    SetPedIsDrunk(cache.ped, true)
                    SetPedAccuracy(cache.ped, 0)

                    time -= 50
                end

                SetRunSprintMultiplierForPlayer(cache.playerId, 1.0)

                ClearTimecycleModifier()
                ResetScenarioTypesEnabled()
                ResetPedMovementClipset(cache.ped, 0)
                SetPedIsDrunk(cache.ped, false)
                SetPedMotionBlur(cache.ped, false)
                StopGameplayCamShaking(false)

                SetPedToRagdoll(cache.ped, 1500, 1500, 0, 0, 0, 0)
                UsingMush = false
            end)

            Citizen.CreateThread(function()
                local time = 50000
                while time > 0 do
                    SetPedToRagdoll(PlayerPedId(), 1500, 1500, 0, 0, 0, 0)

                    if not cache.vehicle then
                        Wait(100)
                        DoScreenFadeOut(100)
                        Wait(1000)
                        DoScreenFadeIn(100)
                    end

                    time -= 10000
                
                    Wait(10000)
                end
            end)
        end
    end)
end)

local UsingGuminukai = false
exports('guminukai', function(data, slot)
    if UsingGuminukai then return end
    Inventory:useItem(data, function(data)
        if data then
            UsingGuminukai = true
            local success = PlayProgress('Valgote guminukus...', 3000, {
                dict = "amb@code_human_wander_eating_donut@male@idle_a",
                clip = "idle_c",
            }, 49)
            if not success then UsingGuminukai = false return end

            Citizen.CreateThread(function()
                StartScreenEffect('DrugsMichaelAliensFight', 0, false)
                Wait(30000)
                StopScreenEffect('DrugsMichaelAliensFight')

                StartScreenEffect('DrugsTrevorClownsFight', 0, false)
                Wait(30000)
                StopScreenEffect('DrugsTrevorClownsFight')
            end)

            Citizen.CreateThread(function()
                local time = 65000
                RequestAnimSet("move_m@drunk@verydrunk")
                while not HasAnimSetLoaded("move_m@drunk@verydrunk") do
                    Citizen.Wait(10)
                end
                SetPedMovementClipset(cache.ped, "move_m@drunk@verydrunk", 1.0)
                SetPedIsDrunk(cache.ped, true)
                ShakeGameplayCam("DRUNK_SHAKE", 1.5)
                SetPedMotionBlur(cache.ped, true)

                while time > 0 do
                    Wait(50)
                    ShakeGameplayCam("DRUNK_SHAKE", 1.5)
                    SetPedMotionBlur(cache.ped, true)

                    SetPedMovementClipset(cache.ped, "move_m@hurry_bustling", true)
                    SetPedIsDrunk(cache.ped, true)
                    SetPedAccuracy(cache.ped, 5)

                    time -= 50
                end

                ClearTimecycleModifier()
                ResetScenarioTypesEnabled()
                ResetPedMovementClipset(cache.ped, 0)
                SetPedIsDrunk(cache.ped, false)
                SetPedMotionBlur(cache.ped, false)
                StopGameplayCamShaking(false)
                UsingGuminukai = false
            end)

            Citizen.CreateThread(function()
                local time = 60000
                while time > 0 do
                    SetPedToRagdoll(cache.ped, 1000, 1000, 0, 0, 0, 0)

                    if not cache.vehicle then
                        Wait(100)
                        DoScreenFadeOut(200)
                        Wait(1200)
                        DoScreenFadeIn(200)
                    end

                    time -= 10000
                    Wait(10000)
                end
            end)
        end
    end)
end)