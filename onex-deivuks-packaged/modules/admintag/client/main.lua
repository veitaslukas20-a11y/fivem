local Admins = {}
local playerStates = {}

local dedSleep = 1000
Citizen.CreateThread(function()
    Admins = lib.callback.await('tag:getAdmins', false)

    while true do
        local statesCount = (#playerStates > 0)
        dedSleep = statesCount and 6 or 1000

        if statesCount then
            for _, pState in pairs(playerStates) do
                DrawText3D(GetEntityCoords(pState.ped), ('%s%s ~w~%s'):format(pState.color, pState.name, pState.nick), 1.0, 1.0)
            end
        end

        Wait(dedSleep)
    end
end)

local function getAdminData(id, ped)
    local serverId = GetPlayerServerId(id)
    if not serverId then return end
    local admin = Admins[serverId]
    if not admin then return end
    if admin.show and (IsEntityVisible(ped) and GetEntityAlpha(ped) > 0) then
        playerStates[#playerStates + 1] = {name = admin.name, color = admin.color, nick = admin.nick, ped = ped}
    end
end

Citizen.CreateThread(function()
    while true do
        local playerPos = GetEntityCoords(cache.ped, true)
        local closestPlayers = lib.getNearbyPlayers(playerPos, 15, true) or {}
        playerStates = {}

        for _, player in pairs(closestPlayers) do
            getAdminData(player.id, player.ped)
        end

        closestPlayers = {}

        Wait(2000)
    end
end)

RegisterNetEvent('tag:updateTags', function(index, data)
    Admins[index] = data
end)

function DrawText3D(coords, text, size, zx)
    local font = 13
	coords = vector3(coords.x, coords.y, coords.z + zx)

	local camCoords = GetGameplayCamCoords()
	local distance = #(coords - camCoords)

	local scale = (size / distance) * 2
	local fov = (1 / GetGameplayCamFov()) * 100
	scale = scale * fov

	SetTextScale(0.0 * scale, 0.55 * scale)
	SetTextFont(font)
	SetTextColour(255, 255, 255, 255)
	SetTextDropshadow(0, 0, 0, 0, 255)
	SetTextDropShadow()
	SetTextOutline()
	SetTextCentre(true)

	SetDrawOrigin(coords.x, coords.y, coords.z, false)
	BeginTextCommandDisplayText('STRING')
	AddTextComponentSubstringPlayerName(text)
	EndTextCommandDisplayText(0.0, 0.0)
	ClearDrawOrigin()
end