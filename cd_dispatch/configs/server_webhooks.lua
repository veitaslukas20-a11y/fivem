if not Config.AntiCheat.ENABLE then return end

local DiscordWebhook = 'CHANGEME' -- Add your Discord webhook URL here.

function SendAntiCheatWebhook(source, detection_method, messageData)
    if DiscordWebhook ~= nil and #DiscordWebhook > 10 then

        local identifier = GetIdentifier(source)
        local job = GetJob(source)
        local playerName = GetPlayerName(source)
        local characterName = 'N/A'

        local message = L('discordlogs_playerinfo', source, identifier, job, playerName, characterName)

        if detection_method == 'banned_word' then
            message = message..L('discordlogs_message_bannedword', messageData.bannedWord, messageData.flaggedMessage)

        elseif detection_method == 'event_spam' then
            message = message..L('discordlogs_message_eventspam', messageData.spamCount, messageData.spamLimit, messageData.speed)

        elseif detection_method == 'unauthorized_jobs' then
            message = message..L('discordlogs_message_unauthorizedjobs', messageData.jobs)

        elseif detection_method == 'duplicate_message' then
            message = message..L('discordlogs_message_duplicatealert', messageData.duplicateCount, messageData.duplicateThreshold)

        elseif detection_method == 'invalid_payload' then
            message = message..L('discordlogs_message_invalidpayload')
        end

        local data = {{
            ['color'] = '2061822',
            ['title'] = L('discordlogs_title'),
            ['description'] = message,
            ['footer'] = {
                ['text'] = os.date('%c'),
                ['icon_url'] = 'https://i.imgur.com/VMPGPTQ.png',
            },
        }}
        if Config.AntiCheat.discord_tag_everyone then
            PerformHttpRequest(DiscordWebhook, function(err, text, headers) end, 'POST', json.encode({username = L('dispatch'), content = '@everyone'}), { ['Content-Type'] = 'application/json' })
        end
        PerformHttpRequest(DiscordWebhook, function(err, text, headers) end, 'POST', json.encode({username = L('dispatch'), embeds = data}), { ['Content-Type'] = 'application/json' })
    end
end