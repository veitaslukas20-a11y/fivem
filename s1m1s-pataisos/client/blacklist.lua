local blacklistTime = 0

local seconds_in_minute = 60
local seconds_in_hour = 60 * 60
local seconds_in_day = 24 * 60 * 60

local function showBlacklist()
    local diff_seconds = blacklistTime
    local days = math.floor(diff_seconds / seconds_in_day)
    diff_seconds = diff_seconds % seconds_in_day

    local hours = math.floor(diff_seconds / seconds_in_hour)
    diff_seconds = diff_seconds % seconds_in_hour

    local minutes = math.floor(diff_seconds / seconds_in_minute)
    local seconds = diff_seconds % seconds_in_minute

    SendNUIMessage({
        type = 'blacklist',
        show = true,
        time = ('%dd. %dh %dmin %ds'):format(days, hours, minutes, seconds)
    })
end

local function initBlacklist()
    Citizen.CreateThread(function()
        while blacklistTime > 0 do
            blacklistTime -= 1
            showBlacklist()
            Wait(1000)
        end

        SendNUIMessage({
            type = 'blacklist',
            show = false,
        })
    end)
end

RegisterNetEvent('pataisos:addBlacklist', function(time)
    if blacklistTime <= 0 then
        blacklistTime = time
        initBlacklist()
    else
        blacklistTime = time
    end
end)