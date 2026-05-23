-- ls-recoil | framework-safe client

-- Try to bootstrap ESX if available. Won't error if you run ox_core/standalone.
local ESX = nil

CreateThread(function()
    if GetResourceState('es_extended') == 'started' then
        if pcall(function() return exports['es_extended'].getSharedObject end) and exports['es_extended'].getSharedObject then
            ESX = exports['es_extended']:getSharedObject()
        else
            while ESX == nil do
                TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
                Wait(100)
            end
        end

        if ESX and ESX.IsPlayerLoaded then
            while not ESX.IsPlayerLoaded() do
                Wait(100)
            end
        end
    end
end)

local function getPed()
    if cache and cache.ped then return cache.ped end
    return PlayerPedId()
end

local recoils = {
    [416676503]  = 1.34,
    [-957766203] = 1.22,
    [970310034]  = 1.17,
}

local DisableRecoil = false
local recoilThread = 250

CreateThread(function()
    while true do
        local ply = getPed()
        SetPedSuffersCriticalHits(ply, false)

        if IsPedArmed(ply, 6) then
            recoilThread = 0
            DisableControlAction(1, 140, true)
            DisableControlAction(1, 141, true)
            DisableControlAction(1, 142, true)
        elseif IsPedArmed(ply, 1) then
            recoilThread = 0
        else
            recoilThread = 500
        end

        if IsPedShooting(ply) and not DisableRecoil then
            local _, wep = GetCurrentPedWeapon(ply)
            local GamePlayCam = GetFollowPedCamViewMode()
            local inVehicle = IsPedInAnyVehicle(ply, false)
            local speed = math.ceil(GetEntitySpeed(ply))
            if speed > 69 then speed = 69 end

            Wait(50)

            local _, wep2 = GetCurrentPedWeapon(ply)
            if wep2 ~= `WEAPON_STUNGUN` then
                local group = GetWeapontypeGroup(wep2)
                local pitch = GetGameplayCamRelativePitch()
                local camDist = #(GetGameplayCamCoord() - GetEntityCoords(ply))

                local recoil = math.random(100, 140 + speed) / 100.0
                local isRifle = (group == 970310034)

                if camDist < 5.3 then
                    camDist = 1.0
                elseif camDist < 8.0 then
                    camDist = 4.0
                else
                    camDist = 7.0
                end

                if inVehicle then
                    recoil = recoil + (recoil * camDist)
                else
                    recoil = recoil * 0.6
                end

                if GamePlayCam == 4 then
                    recoil = recoil * 0.4
                    if isRifle then recoil = recoil * 0.1 end
                end

                if isRifle then
                    recoil = recoil * 0.4
                end

                local rl = math.random(4)
                local heading = GetGameplayCamRelativeHeading()
                local hf = math.random(10, 40 + speed) / 100.0
                if inVehicle then hf = hf * 2.0 end

                if rl == 1 then
                    SetGameplayCamRelativeHeading(heading + hf)
                elseif rl == 2 then
                    SetGameplayCamRelativeHeading(heading - hf)
                end

                local setPitch = pitch + recoil
                SetGameplayCamRelativePitch(setPitch, 0.8)
            end
        end

        Wait(recoilThread)
    end
end)

local function isOwner()
    if ESX and ESX.GetPlayerData then
        local x = ESX.GetPlayerData()
        return x and x.identifier == 'Char1:03a7ccef458056d7abcaebf02d4cb29ba476d376'
    end
    return false
end

RegisterCommand('disableRecoil', function()
    if isOwner() then
        DisableRecoil = not DisableRecoil
    end
end, false)

local disableRagdoll = false
RegisterCommand('disableRagdoll', function()
    if isOwner() then
        disableRagdoll = not disableRagdoll
        while disableRagdoll do
            SetPedCanRagdoll(getPed(), false)
            Wait(100)
        end
    end
end, false)
