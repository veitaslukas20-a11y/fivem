local playerPed = PlayerPedId()

CreateThread(function()
    while true do
        ESX.SetPlayerData('coords',GetEntityCoords(playerPed))
        Wait(1000)
    end
end)