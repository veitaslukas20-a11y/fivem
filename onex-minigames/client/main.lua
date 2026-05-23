local Promise = nil

RegisterNUICallback('onComplete', function(data, cb)
    SetNuiFocus(false, false)
    if Promise then
        Promise:resolve(data and data.success or false)
    end

    cb('ok')
end)

exports('startMinigame', function(minigame, data)
    SendNUIMessage({
        minigame = minigame,
        data = data
    })
    SetNuiFocus(true, true)

    Promise = promise.new()

    local result = Citizen.Await(Promise)
    return result
end)