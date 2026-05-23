RegisterNetEvent('onex-clothes:change', function()
    if IsPedMale(cache.ped) then
        TriggerEvent('vms_charcreator:openCreator', 0, true, false)
    else
        TriggerEvent('vms_charcreator:openCreator', 1, true, false)
    end
end)