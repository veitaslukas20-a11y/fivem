ESX = exports["es_extended"]:getSharedObject()

local playerName = ''
local currentCount = 0
local maxPlayers = 0

local function UpdatePresence()
    -- Svarbu: ClientID turi būti skaičius (be kabučių config'e)
    SetDiscordAppId(Config.ClientID)
    SetDiscordRichPresenceAsset('def')

    local total = currentCount or 0
    local maxp = (maxPlayers and maxPlayers > 0) and maxPlayers or Config.PlayerCount

    -- Naudojam %d skaičiams
    local rp = string.format(Config.RichPresence, playerName, Config.PlayerText, total, maxp)
    SetRichPresence(rp)

    SetDiscordRichPresenceAssetText('ZyneX.lt')
end

-- Jei norėsi gauti vardą iš ESX Identity
local function resolvePlayerName()
    playerName = GetPlayerName(PlayerId())
    if Config.UseESXIdentity then
        local xPlayer = ESX.GetPlayerData()
        if xPlayer and xPlayer.firstName and xPlayer.lastName then
            playerName = (xPlayer.firstName .. ' ' .. xPlayer.lastName)
        end
    end
end

CreateThread(function()
    while not ESX.IsPlayerLoaded() do Wait(100) end

    resolvePlayerName()

    for _, v in pairs(Config.Buttons) do
        SetDiscordRichPresenceAction(v.index, v.name, v.url)
    end

    -- Pirmas atnaujinimas iškart
    ESX.TriggerServerCallback('ZyneX:getCounts', function(data)
        if data then
            currentCount = data.count or 0
            maxPlayers   = data.max   or 0
        end
        UpdatePresence()
    end)

    -- Toliau periodiškai traukiam iš serverio
    while true do
        ESX.TriggerServerCallback('ZyneX:getCounts', function(data)
            if data then
                currentCount = data.count or currentCount
                maxPlayers   = data.max   or maxPlayers
            end
            UpdatePresence()
        end)
        Wait(Config.ResourceTimer * 1000)
    end
end)
