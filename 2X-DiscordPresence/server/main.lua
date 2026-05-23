ESX = exports["es_extended"]:getSharedObject()

ESX.RegisterServerCallback('ZyneX:getCounts', function(source, cb)
    local count = #GetPlayers()                                -- tikras prisijungusių skaičius
    local max   = GetConvarInt('sv_maxclients', Config.PlayerCount or 32)  -- max iš serverio convaro
    cb({ count = count, max = max })
end)
