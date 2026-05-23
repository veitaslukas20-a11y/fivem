local bones = {
    [0] = 'door_dside_f',
    [1] = 'door_pside_f',
    [2] = 'door_dside_r',
    [3] = 'door_pside_r'
}

function SetIntoVehicle(vehicle, seatIndex)
    if not escorting or not DoesEntityExist(vehicle) then return end

    local freeSeat = nil

    -- jei durų numeris pateiktas – naudok jį
    if seatIndex and IsVehicleSeatFree(vehicle, seatIndex) then
        freeSeat = seatIndex
    else
        -- kitaip rask bet kurią laisvą vietą (nuo galinės iki priekinės)
        for i = 2, -1, -1 do
            if IsVehicleSeatFree(vehicle, i) then
                freeSeat = i
                break
            end
        end
    end

    if not freeSeat then
        lib.notify({ title = 'Gangs', description = 'Nėra laisvų vietų automobilyje!', type = 'error' })
        return
    end

    -- Atskirti escortą prieš sodinant
    local id = NetworkGetPlayerIndexFromPed(escorting)
    if not id then return end

    local targetId = GetPlayerServerId(id)
    escortPlayer(escorting)

    -- Siunčiam serveriui info
    TriggerServerEvent('s1m1s-gangs:setinveh', targetId, NetworkGetNetworkIdFromEntity(vehicle), freeSeat)
end

function SetOutVehicle(vehicle)
    if not DoesEntityExist(vehicle) then return end
    local ped = nil

    for seat = -1, 6 do
        local p = GetPedInVehicleSeat(vehicle, seat)
        if p ~= 0 and IsPedAPlayer(p) and IsPedCuffed(p) then
            ped = p
            break
        end
    end

    if ped then
        local id = NetworkGetPlayerIndexFromPed(ped)
        local targetId = GetPlayerServerId(id)
        TriggerServerEvent('s1m1s-gangs:outveh', targetId, NetworkGetNetworkIdFromEntity(vehicle))
    end
end

RegisterNetEvent('s1m1s-gangs:setinveh', function(vehicle, seat)
    local veh = NetworkGetEntityFromNetworkId(vehicle)
    if DoesEntityExist(veh) then
        TaskWarpPedIntoVehicle(cache.ped, veh, seat)
    end
end)

RegisterNetEvent('s1m1s-gangs:outveh', function(vehicle)
    local veh = NetworkGetEntityFromNetworkId(vehicle)
    if DoesEntityExist(veh) then
        TaskLeaveVehicle(cache.ped, veh, 256)
    end
end)