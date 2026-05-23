RegisterCommand('dalys', function(source, args)
    local args1 = args[1]
    local args2 = args[2]

    if not cache.vehicle then return end
    if ((args2=="visos")and(args1=="uzdeti")) then
        for i=0,30 do
            if (DoesExtraExist(cache.vehicle, i)==1) then
                SetVehicleAutoRepairDisabled(cache.vehicle, true)
                SetVehicleExtra(cache.vehicle, i, false)		
                SetVehicleAutoRepairDisabled(cache.vehicle, true)
            end
        end
    elseif ((args2=="visos")and(args1=="nuimti")) then
        for i=0,30 do
            if (DoesExtraExist(cache.vehicle, i)==1) then
                SetVehicleAutoRepairDisabled(cache.vehicle, true)
                SetVehicleExtra(cache.vehicle, i, true)
                SetVehicleAutoRepairDisabled(cache.vehicle, true)
            end
        end
    else
        local extra = tonumber(args2)
        if (DoesExtraExist(cache.vehicle, extra)==1) then
            if (args1=='uzdeti') then
                SetVehicleAutoRepairDisabled(cache.vehicle, true)
                SetVehicleExtra(cache.vehicle, extra, false)
                SetVehicleAutoRepairDisabled(cache.vehicle, true)
            elseif (args1=='nuimti') then
                SetVehicleAutoRepairDisabled(cache.vehicle, true)
                SetVehicleExtra(cache.vehicle, extra, true)
                SetVehicleAutoRepairDisabled(cache.vehicle, true)
            end	
        end
    end
end, false)
