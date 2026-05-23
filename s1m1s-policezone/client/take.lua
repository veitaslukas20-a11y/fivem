local Time, Deadline, Locked = 0, 0, false
local StartedCounter = false
local ForceStopLoop = false

function TakingZone()
    if StartedCounter then
        ForceStopLoop = true
        ShowTaking(false)
    end

    Time, Deadline, Locked = lib.callback.await('policezone:getInfo', false)
    if not Time or not Deadline or Locked == nil then return end

    StatCounter()
end

function StatCounter()
    while StartedCounter do
        Wait(100)
    end

    Citizen.CreateThreadNow(function()
        StartedCounter = true

        while InZone do
            if not InZone or ForceStopLoop or not Config.Zone.started then break end

            if Locked and Time > 0 then
                Time = math.max(Time - 1000, 0)
            end

            if not Locked and Deadline > 0 then
                Deadline = math.max(Deadline - 1000, 0)
            end

            ShowTaking(true, CalculateTime(Time), CalculateTime(Deadline), Locked)

            Wait(1000)
        end

        ForceStopLoop = false
        StartedCounter = false
    end)
end

RegisterNetEvent('policezone:enableAccess', function()
    Locked = false
    Config.Zone.locked = nil
end)