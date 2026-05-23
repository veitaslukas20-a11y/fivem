local zoneKey, Time, DeadLine, Stopped = nil, 0, 0, false
local StartedCounter = false
local ForceStopLoop = false

function TakingZone(title)
    zoneKey = string.lower(title)

    if StartedCounter then
        ForceStopLoop = true
        ShowTaking(false)
    end

    Time, DeadLine, Stopped = lib.callback.await('d-gangzones:takingZone', false, zoneKey)
    if not Time or not DeadLine or Stopped == nil then return end

    StatCounter()
end

function StatCounter()
    while StartedCounter do
        Wait(100)
    end

    Citizen.CreateThreadNow(function()
        StartedCounter = true

        while Current do
            if not Current or ForceStopLoop or not Current?.takers then break end

            if not Stopped then
                if Time > 0 then
                    Time -= 1000
                end

                if DeadLine < 5400000 then
                    DeadLine -= 1000
                end
            else
                if DeadLine > 0 then
                    DeadLine -= 1000
                end
            end

            ShowTaking(true, zoneKey, CalculateTime(Time), CalculateTime(DeadLine), Stopped)

            Wait(1000)
        end

        ForceStopLoop = false
        StartedCounter = false
    end)
end

RegisterNetEvent('d-gangzones:setStoped', function(value)
    Stopped = value
end)