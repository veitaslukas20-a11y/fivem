if Config.EnableBlips then
    Citizen.CreateThread(function()
        for k,v in pairs(Config.RentPoints) do
            local blip = AddBlipForCoord(v)
            SetBlipSprite(blip, Config.BlipSprite)
            SetBlipDisplay(blip, Config.BlipDisplay)
            SetBlipScale  (blip, Config.BlipScale)
            SetBlipColour (blip, Config.BlipColour)
            SetBlipAsShortRange(blip, true)
            BeginTextCommandSetBlipName("STRING")
            AddTextComponentString('<font face="Roboto">'..Config.BlipName..'</font>')
            EndTextCommandSetBlipName(blip)
        end
    end)
end