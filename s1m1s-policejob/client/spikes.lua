local glm = require 'glm'

exports('deploySpikestrip', function()
    if cache.vehicle then
        return
    end

    local size = lib.inputDialog('Deploy Spikestrip', {
        {type = 'number', label = 'Segmentų skaičius', description = 'Įveskite kiek spyglių segmentų norite išmesti', icon = 'road-spikes', min = 1, max = 4}
    })

    if not size then return end

    size = tonumber(size[1])
    if size > 4 then size = 4 end

    local success = lib.progressBar({
        duration = 1000 * size,
        label = 'Padedate spyglius...',
        useWhileDead = false,
        canCancel = true,
        disable = {
            car = true,
            combat = true,
        },
        anim = {
            dict = 'amb@prop_human_bum_bin@idle_b',
            clip = 'idle_d'
        },
    })
    
    if not success then return end

    local segment = {
        GetOffsetFromEntityInWorldCoords(cache.ped, 0.0, 1.0, 0.0),
        GetOffsetFromEntityInWorldCoords(cache.ped, 0.0, 4.15 * size - 1, 0.0)
    }
    local length = glm.snap(#(segment[1] - segment[2]), 0.01)

    for i = 1, 2 do
        while true do
            ---@diagnostic disable-next-line: redundant-parameter
            local retrieval, groundZ = GetGroundZFor_3dCoord_2(segment[i].x, segment[i].y, segment[i].z, false, true)
            segment[i] = vec3(segment[i].x, segment[i].y, retrieval and groundZ or segment[i].z + 1)

            if retrieval then
                break
            end
        end
    end

    segment[2] = segment[1] - glm.clampLength(segment[1] - segment[2], length)

    TriggerServerEvent('s1m1s-police:deploySpikestrip', {
        segment = segment,
        size = size,
        heading = GetEntityHeading(cache.ped),
    })
end)

local wheelBones = {
    standard = {
        [0] = 'wheel_lf',
        'wheel_rf',
        'wheel_lm1',
        'wheel_rm1',
        'wheel_lr',
        'wheel_rr',
        [547] = 'wheel_lm2',
        [549] = 'wheel_rm2',
    },
}

local flags = tonumber('11111000100001111111', 2)

AddStateBagChangeHandler('inScope', '', function(bagName, key, value, reserved, replicated)
    if value then
        local entity = GetEntityFromStateBagName(bagName)

        if GetEntityModel(entity) ~= `p_ld_stinger_s` then
            return
        end

        PlaceObjectOnGroundProperly(entity)
        FreezeEntityPosition(entity, true)

        local coords = GetEntityCoords(entity)
        local segment

        while DoesEntityExist(entity) do
            local sleep = cache.vehicle and math.abs(math.floor(500 - (GetEntitySpeed(cache.vehicle) * 3.6))) or 500
            local vehicle = GetClosestVehicle(coords.x, coords.y, coords.z, 15.0, 0, flags)

            if vehicle ~= 0 then
                sleep = 0

                local newCoords = GetEntityCoords(entity)

                if coords ~= newCoords or not segment then
                    coords = newCoords
                    segment = {
                        GetOffsetFromEntityInWorldCoords(entity, 0.0, -1.84, 0.0),
                        GetOffsetFromEntityInWorldCoords(entity, 0.0, 1.84, 0.0)
                    }
                end

                if IsEntityTouchingEntity(entity, vehicle) then
                    local bones = wheelBones.standard

                    for k, v in pairs(bones) do
                        if not IsVehicleTyreBurst(vehicle, k, false) and glm.segment.distance(segment[1], segment[2], GetEntityBonePosition_2(vehicle, GetEntityBoneIndexByName(vehicle, v))) < 1 then
                            SetVehicleTyreBurst(vehicle, k, false, 500.0)
                            break
                        end
                    end
                end
            end

            Wait(sleep)
        end
    end
end)