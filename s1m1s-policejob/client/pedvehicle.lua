local bones = {
    [0] = 'dside_f',
    [1] = 'pside_f',
    [2] = 'dside_r',
    [3] = 'pside_r'
}


function SetIntoVehicle(vehicle, door)
    if not escorting then return end
    if not vehicle then return end 

    local freeSeat = nil
    local coords = GetEntityCoords(escorting)

    if IsVehicleSeatFree(vehicle, door - 1) then
        if GetVehicleDoorLockStatus(vehicle) ~= 2 and GetVehicleDoorAngleRatio(vehicle, door) > 0.0 then
            freeSeat = door - 1
        end
    end

    if freeSeat then
        local id = NetworkGetPlayerIndexFromPed(escorting)
        id = GetPlayerServerId(id)
        escortPlayer(escorting)
        TriggerServerEvent('s1m1s-police:setinveh', id, NetworkGetNetworkIdFromEntity(vehicle), freeSeat)
    end
end

function SetOutVehicle(vehicle)
    local ped = nil
    if GetVehicleDoorLockStatus(vehicle) ~= 2 then
        if GetPedInVehicleSeat(vehicle, 1) ~= 0 then ped = GetPedInVehicleSeat(vehicle, 1) end
        if GetPedInVehicleSeat(vehicle, 2) ~= 0 then ped = GetPedInVehicleSeat(vehicle, 2) end

        if ped then
            local id = NetworkGetPlayerIndexFromPed(ped)
            id = GetPlayerServerId(id)
            TriggerServerEvent('s1m1s-police:outveh', id, NetworkGetNetworkIdFromEntity(vehicle))
        end
    end
end

RegisterNetEvent('s1m1s-police:setinveh', function(vehicle, seat)
    TaskWarpPedIntoVehicle(cache.ped, NetworkGetEntityFromNetworkId(vehicle), seat)
end)

RegisterNetEvent('s1m1s-police:outveh', function(vehicle)
    TaskLeaveVehicle(cache.ped, NetworkGetEntityFromNetworkId(vehicle), 256)
end)

function canInteractWithDoor(entity, coords, door, useOffset)
    if not GetIsDoorValid(entity, door) or GetVehicleDoorLockStatus(entity) > 1 or IsVehicleDoorDamaged(entity, door) then return end

    if useOffset then return true end

    local boneName = bones[door]

    if not boneName then return false end

    boneId = GetEntityBoneIndexByName(entity, 'door_' .. boneName)

    if boneId ~= -1 then
        return #(coords - GetEntityBonePosition_2(entity, boneId)) < 0.5 or
            #(coords - GetEntityBonePosition_2(entity, GetEntityBoneIndexByName(entity, 'seat_' .. boneName))) < 0.72
    end
end