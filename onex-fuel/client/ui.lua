local ESX = exports['es_extended']:getSharedObject()

RegisterNUICallback("processFuelPayment", function(data, cb)
    local stationId = (data and data.stationId) or 0
    local liters = tonumber(data.liters) or 0
    local paymentMethod = data.paymentMethod or "cash"
    local fuelType = data.fuelType or "regular"

    lib.callback('onex-fuel:processFuelPayment', false, function(success, msg)
        if success then
            SetNuiFocus(false, false)
            SendNUIMessage({ action = 'setVisible', data = { visible = false } })

            local ped = PlayerPedId()
            RequestAnimDict("weapon@w_sp_jerrycan")
            while not HasAnimDictLoaded("weapon@w_sp_jerrycan") do
                Wait(10)
            end
            TaskPlayAnim(ped, "weapon@w_sp_jerrycan", "fire", 8.0, -8.0, -1, 49, 0, false, false, false)

            if lib.progressCircle({
                duration = 6000,
                label = 'Pildomas kuras...',
                position = 'bottom',
                useWhileDead = false,
                canCancel = false,
                disable = { move = true, car = true, combat = true },
            }) then
                ClearPedTasks(ped)
                TriggerEvent('FuelManager:UpdateFuel', liters, (fuelType == 'premium') and 'premium_degalai' or 'paprasti_degalai')
                ESX.ShowNotification('Kuras sekmingai papildytas.', 'success')
            else
                ClearPedTasks(ped)
            end
        else
            ESX.ShowNotification(msg or 'Nepakanka pinigu!', 'error')
        end
        cb({ ok = success, message = msg })
    end, stationId, paymentMethod, fuelType, liters)
end)

RegisterNUICallback("buyItem", function(data, cb)
    if not data or not data.item then return cb({ ok = false }) end
    TriggerServerEvent('onex-fuel:buyItem', data.item)
    cb({ ok = true })
end)

RegisterNUICallback("closeUI", function(_, cb)
    SetNuiFocus(false, false)
    SendNUIMessage({ action = 'setVisible', data = { visible = false } })
    cb({ ok = true })
end)
