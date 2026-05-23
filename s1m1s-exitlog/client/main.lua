local activeExits = {}

local function drawExit(coords, name, reason, time)
    local onScreen, _x, _y = World3dToScreen2d(coords.x, coords.y, coords.z + 0.5)

    local camCoords = GetGameplayCamCoords()
	local distance = #(coords - camCoords)

    local scale = (1 / distance) * 2
	local fov = (1 / GetGameplayCamFov()) * 100
	scale = scale * fov

    SetTextScale(0.0 * scale, 0.35 * scale)
    SetTextFont(13)
    SetTextColour(0, 255, 0, 215)
    SetTextEntry("STRING")
    SetTextCentre(true)
    AddTextComponentString(time)
    DrawText(_x, _y - 0.02 * scale)

    SetTextScale(0.0 * scale, 0.35 * scale)
    SetTextFont(13)
    SetTextColour(255, 255, 255, 215)
    SetTextEntry("STRING")
    SetTextCentre(true)
    AddTextComponentString(name)
    DrawText(_x, _y)

    SetTextScale(0.0 * scale, 0.35 * scale)
    SetTextFont(13)
    SetTextColour(255, 0, 0, 215)
    SetTextEntry("STRING")
    SetTextCentre(true)
    AddTextComponentString(reason)
    DrawText(_x, _y + 0.02 * scale)

    local factor = (#reason + #name + #time) / 370
    DrawRect(_x, _y + 0.014 * scale, (0.015 + factor) * scale, 0.07 * scale, 0, 0, 0, 150)
end

local closeExits = {}
RegisterNetEvent("showDisconnect", function(playerName, id, reason, time, coords)
    local formatted = {
        coords  = coords,
        time = ("Laikas: %s"):format(time),
        name = ("Slapyvardis: %s | ID: %d"):format(playerName, id),
        reason = ("Priežastis: %s"):format(reason),
    }

    table.insert(activeExits, formatted)

    SetTimeout(3 * 60 * 1000, function()
        table.remove(activeExits, 1)
        if #activeExits == 0 then
            closeExits = {}
        end
    end)
end)

Citizen.CreateThread(function()
    while true do
        if #activeExits > 0 then
            local coords = GetEntityCoords(cache.ped)

            closeExits = {}

            for _, exit in ipairs(activeExits) do
                local dist = #(exit.coords - coords)

                if dist < 15.0 then
                    closeExits[#closeExits + 1] = exit
                end
            end
        end

        Wait(1000)
    end
end)

local sleep = 500
Citizen.CreateThread(function()
    while true do
        if #closeExits > 0 then
            sleep = 0

            local coords = GetEntityCoords(cache.ped)

            for _, exit in ipairs(closeExits) do
                local dist = #(exit.coords - coords)

                DrawMarker(
                    32,
                    exit.coords.x,
                    exit.coords.y,
                    exit.coords.z,
                    0.0, 0.0, 0.0,
                    0.0, 0.0, 0.0,
                    0.5, 0.5, 0.5,
                    255, 255, 0, 68,
                    false, true, 2, false, nil, nil, false
                )

                if dist < 5.0 then
                    drawExit(exit.coords, exit.name, exit.reason, exit.time)
                end
            end
        else
            sleep = 500
        end

        Wait(sleep)
    end
end)