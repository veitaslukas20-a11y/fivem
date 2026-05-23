local pState = LocalPlayer.state
local First = vector3(0.0, 0.0, 0.0)
local Second = vector3(5.0, 5.0, 5.0)

local Shift, W, E, A, D
local Pushing = false

RegisterCommand('+stumtishift' ,function()
    Shift = true
    if Shift and W and E then 
        PushVehicle()
    end
end, false)

RegisterCommand('-stumtishift' ,function()
    Shift = false
end, false)

RegisterKeyMapping('+stumtishift', '', 'keyboard', 'LSHIFT')

RegisterCommand('+stumtiw' ,function()
    W = true
    if Shift and W and E then 
        PushVehicle()
    end
end, false)

RegisterCommand('-stumtiw' ,function()
    W = false
end, false)

RegisterKeyMapping('+stumtiw', '', 'keyboard', 'W')

RegisterCommand('+stumtie' ,function()
    E = true
    if Shift and W and E then 
        PushVehicle()
    end
end, false)

RegisterCommand('-stumtie' ,function()
    E = false
end, false)

RegisterKeyMapping('+stumtie', '', 'keyboard', 'E')

RegisterCommand('stumtia' ,function()
    if not Pushing then return end 
    A = true
    Wait(500)
    A = false
end, false)

RegisterKeyMapping('stumtia', '', 'keyboard', 'A')

RegisterCommand('stumtid' ,function()
    if not Pushing then return end 
    D = true
    Wait(500)
    D = false
end, false)

RegisterKeyMapping('stumtid', '', 'keyboard', 'D')

function PushVehicle()
    Veh, Coords = lib.getClosestVehicle(GetEntityCoords(cache.ped), 4.0, false)
    IsInFront = false
    Dimensions = GetModelDimensions(GetEntityModel(Veh), First, Second)
    if not IsEntityAVehicle(Veh) then return end
    if not IsEntityVisible(Veh) then return end
    if IsEntityInWater(Veh) then return end
    if not IsVehicleSeatFree(Veh, -1) then return end
    if IsEntityDead(cache.ped) then return end
    if pState.dead then return end

    local roll = GetEntityRoll(Veh)
    if roll > 75.0 or roll < -75.0 then return FlipVehicle(Veh) end

    if #((GetEntityCoords(Veh) + GetEntityForwardVector(Veh)) - GetEntityCoords(cache.ped)) > #((GetEntityCoords(Veh) + GetEntityForwardVector(Veh) * -1) - GetEntityCoords(cache.ped)) then
        IsInFront = false
    else
        IsInFront = true
    end

    if IsInFront then    
        AttachEntityToEntity(PlayerPedId(), Veh, GetPedBoneIndex(6286), 0.0, Dimensions.y * -1 + 0.1 , Dimensions.z + 1.0, 0.0, 0.0, 180.0, 0.0, false, false, true, false, true)
    else
        AttachEntityToEntity(PlayerPedId(), Veh, GetPedBoneIndex(6286), 0.0, Dimensions.y - 0.3, Dimensions.z  + 1.0, 0.0, 0.0, 0.0, 0.0, false, false, true, false, true)
    end

    ESX.Streaming.RequestAnimDict('missfinale_c2ig_11')
    TaskPlayAnim(cache.ped, 'missfinale_c2ig_11', 'pushcar_offcliff_m', 2.0, -8.0, -1, 35, 0, 0, 0, 0)

    Pushing = true

    while Shift and W and E do 
        if not DoesEntityExist(Veh) then break end
        if IsEntityInWater(Veh) then break end 
        if IsEntityInAir(Veh) then break end
        if IsEntityInAir(cache.ped) then break end
        if not IsVehicleSeatFree(Veh, -1) then break end

        NetworkRequestControlOfEntity(Veh)

        if A then
            TaskVehicleTempAction(cache.ped, Veh, 11, 1000)
        end

        if D then
            TaskVehicleTempAction(cache.ped, Veh, 10, 1000)
        end

        if IsInFront then
            SetVehicleForwardSpeed(Veh, -1.0)
        else
            SetVehicleForwardSpeed(Veh, 1.0)
        end
        
        Wait(200)
    end

    Pushing = false
    DetachEntity(cache.ped, false, false)
    StopAnimTask(cache.ped, 'missfinale_c2ig_11', 'pushcar_offcliff_m', 2.0)
end

function FlipVehicle(Vehicle)
    SetEntityHeading(cache.ped, GetEntityHeading(Vehicle) + 90.0)
    lib.progressCircle({
        duration = 10000,
        position = 'bottom',
        label = 'Atverčiate automobilį...',
        useWhileDead = false,
        canCancel = false,
        disable = {
            car = true,
            move = true, 
            combat = true, 
            sprint = true,
        },
        anim = {
            scenario = 'WORLD_HUMAN_VEHICLE_MECHANIC',
            playEnter = false,
        }
        --[[anim = {
            dict = 'missfinale_c2ig_11',
            clip = 'pushcar_offcliff_m'
        },]]
    })

    local Coords = GetEntityRotation(Vehicle, 2)
    SetEntityRotation(Vehicle, Coords[1], 0, Coords[3], 2, true)
    SetVehicleOnGroundProperly(Vehicle)

    ClearPedTasks(ped)
end


--[[local Vehicle = {Coords = nil, Vehicle = nil, Dimension = nil, IsInFront = false, Distance = nil}
Citizen.CreateThread(function()
    Citizen.Wait(200)
    while true do
        local ped = PlayerPedId()
        local closestVehicle, Distance = ESX.Game.GetClosestVehicle()
        local vehicleCoords = GetEntityCoords(closestVehicle)
        local dimension = GetModelDimensions(GetEntityModel(closestVehicle), First, Second)
        if Distance < 3.0  and not IsPedInAnyVehicle(ped, false) and IsEntityVisible(closestVehicle) then
            Vehicle.Coords = vehicleCoords
            Vehicle.Dimensions = dimension
            Vehicle.Vehicle = closestVehicle
            Vehicle.Distance = Distance
            if GetDistanceBetweenCoords(GetEntityCoords(closestVehicle) + GetEntityForwardVector(closestVehicle), GetEntityCoords(ped), true) > GetDistanceBetweenCoords(GetEntityCoords(closestVehicle) + GetEntityForwardVector(closestVehicle) * -1, GetEntityCoords(ped), true) then
                Vehicle.IsInFront = false
            else
                Vehicle.IsInFront = true
            end
        else
            Vehicle = {Coords = nil, Vehicle = nil, Dimensions = nil, IsInFront = false, Distance = nil}
        end
        Citizen.Wait(500)
    end
end)

local vehThread = 500
Citizen.CreateThread(function()
    while true do 
        local ped = PlayerPedId()
        if Vehicle.Vehicle ~= nil then
            vehThread = 5
                if IsVehicleSeatFree(Vehicle.Vehicle, -1) and GetVehicleEngineHealth(Vehicle.Vehicle) <= Config.DamageNeeded then
                    --ESX.Game.Utils.DrawText3D({x = Vehicle.Coords.x, y = Vehicle.Coords.y, z = Vehicle.Coords.z}, 'Spauskite [~g~SHIFT~w~] ir [~g~E~w~] kad, stumti masina', 0.4)
                end
            if not IsEntityInWater(ped) and not IsEntityInWater(Vehicle.Vehicle) and IsControlPressed(0, Keys["LEFTSHIFT"]) and IsVehicleSeatFree(Vehicle.Vehicle, -1) and not IsEntityAttachedToEntity(ped, Vehicle.Vehicle) and IsControlJustPressed(0, Keys["E"])  and GetVehicleEngineHealth(Vehicle.Vehicle) <= Config.DamageNeeded then
                NetworkRequestControlOfEntity(Vehicle.Vehicle)
                local coords = GetEntityCoords(ped)
                if Vehicle.IsInFront then    
                    AttachEntityToEntity(PlayerPedId(), Vehicle.Vehicle, GetPedBoneIndex(6286), 0.0, Vehicle.Dimensions.y * -1 + 0.1 , Vehicle.Dimensions.z + 1.0, 0.0, 0.0, 180.0, 0.0, false, false, true, false, true)
                else
                    AttachEntityToEntity(PlayerPedId(), Vehicle.Vehicle, GetPedBoneIndex(6286), 0.0, Vehicle.Dimensions.y - 0.3, Vehicle.Dimensions.z  + 1.0, 0.0, 0.0, 0.0, 0.0, false, false, true, false, true)
                end

                ESX.Streaming.RequestAnimDict('missfinale_c2ig_11')
                TaskPlayAnim(ped, 'missfinale_c2ig_11', 'pushcar_offcliff_m', 2.0, -8.0, -1, 35, 0, 0, 0, 0)
                Citizen.Wait(200)

                local currentVehicle = Vehicle.Vehicle
                 while true do
                    Citizen.Wait(5)
                    if IsDisabledControlPressed(0, Keys["A"]) then
                        TaskVehicleTempAction(PlayerPedId(), currentVehicle, 11, 1000)
                    end

                    if IsDisabledControlPressed(0, Keys["D"]) then
                        TaskVehicleTempAction(PlayerPedId(), currentVehicle, 10, 1000)
                    end

                    if Vehicle.IsInFront then
                        SetVehicleForwardSpeed(currentVehicle, -1.0)
                    else
                        SetVehicleForwardSpeed(currentVehicle, 1.0)
                    end

                    if HasEntityCollidedWithAnything(currentVehicle) then
                        SetVehicleOnGroundProperly(currentVehicle)
                    end

                    if IsEntityInWater(currentVehicle) or IsEntityInWater(ped) then 
                        DetachEntity(ped, false, false)
                        StopAnimTask(ped, 'missfinale_c2ig_11', 'pushcar_offcliff_m', 2.0)
                        FreezeEntityPosition(ped, false)
                        break
                    end

                    if not IsDisabledControlPressed(0, Keys["E"]) then
                        DetachEntity(ped, false, false)
                        StopAnimTask(ped, 'missfinale_c2ig_11', 'pushcar_offcliff_m', 2.0)
                        FreezeEntityPosition(ped, false)
                        break
                    end
                end
            end
        else
            vehThread = 500
        end
        Wait(vehThread)
    end
end)]]
