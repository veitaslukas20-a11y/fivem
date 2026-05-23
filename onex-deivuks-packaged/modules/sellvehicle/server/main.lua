lib.callback.register('sellvehicle:trySell', function(source)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then return end

    local ped = GetPlayerPed(source)
    local veh = GetVehiclePedIsIn(ped, false)

    if veh == 0 then
        TriggerClientEvent('ox_lib:notify', source, {
            type = 'error',
            description = 'Turite būti transporto priemonėje!'
        })
        return
    end

    local plate = ESX.Math.Trim(GetVehicleNumberPlateText(veh))

    local result = MySQL.single.await('SELECT * FROM owned_vehicles WHERE plate = ?', {plate})
    if not result then
        TriggerClientEvent('ox_lib:notify', source, {
            type = 'error',
            description = 'Ši transporto priemonė jums nepriklauso!'
        })
        return
    end

    local payout = math.random(200, 1000)
    xPlayer.addAccountMoney('money', payout)

    MySQL.query('DELETE FROM owned_vehicles WHERE plate = ?', {plate})

    DeleteEntity(veh)

    TriggerClientEvent('ox_lib:notify', source, {
        type = 'success',
        description = ('Sėkmingai pridavėte automobilį už %s€'):format(payout)
    })
end)
