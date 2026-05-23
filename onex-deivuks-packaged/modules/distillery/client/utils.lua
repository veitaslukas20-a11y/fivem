DDistillery = {}

DDistillery.Props = {}

DDistillery.Explode = function(ent)
    math.randomseed()
    math.random() math.random() math.random() math.random()
    if (math.random(1, 100) <= math.random(1, 10)) then
        coords = GetEntityCoords(PlayerPedId())
        AddExplosion(coords.x, coords.y, coords.z + 1.0, 9, 0.9, 1, 0, 1065353216)
        exports.qtarget:RemoveTargetEntity(ent)
        DDistillery.DeleteProp(ent)
        Props[ent] = nil
        return false
    end
end

DDistillery.IsOnGrass = function(grass)
    local ped = PlayerPedId()
    local coords = GetEntityCoords(ped)
	local num = StartShapeTestCapsule(coords.x,coords.y,coords.z+4,coords.x,coords.y,coords.z-2.0, 1,1,ped,7)
	local arg1, arg2, arg3, arg4, arg5 = GetShapeTestResultEx(num)
    for _, v in pairs(grass) do 
        if arg5 == v then
            return true
        end
    end
	return false
end

DDistillery.ForwardVector = function(radius)
    if not radius then radius = 1.0 end
    coords = GetEntityCoords(PlayerPedId())
    forward = GetEntityForwardVector(PlayerPedId()) 
    return (coords + forward * radius)
end

DDistillery.Progress = function(label, duration, anim)
    return lib.progressCircle({
        label = label,
        duration = duration,
        position = 'bottom',
        useWhileDead = false,
        allowRagdoll = false, 
        allowCuffed = false, 
        allowFalling = false, 
        canCancel = false,
        anim = anim,
        disable = {
            car = true,
            move = true,
            combat = true,
            mouse = false,
        },
    })
end

DDistillery.MiniGame = function(difficulty)
    local success = lib.skillCheck(difficulty)
    return success
end

DDistillery.Notify = function(message)
    exports['1x-hud']:sendNotification({
        type = 'INFO',
        title = 'Virimas',
        message = message,
        duration = 6000,
        icon = 'wine-bottle'
    })
end


DDistillery.DrawText3D = function(coords, text, height)
    local font = 4
    if height then _z = height + 1 else _z = 1 end
	coords = vector3(coords.x, coords.y, coords.z + _z)

	local camCoords = GetGameplayCamCoords()
	local distance = #(coords - camCoords)

	if not font then font = 0 end

	local scale = (1 / distance) * 2
	local fov = (1 / GetGameplayCamFov()) * 100
	scale = scale * fov

	SetTextScale(0.0 * scale, 0.55 * scale)
	SetTextFont(font)
	SetTextColour(255, 255, 255, 255)
	SetTextDropshadow(0, 0, 0, 0, 255)
	SetTextDropShadow()
	SetTextOutline()
	SetTextCentre(true)

	SetDrawOrigin(coords, 0)
	BeginTextCommandDisplayText('STRING')
	AddTextComponentSubstringPlayerName(text)
	EndTextCommandDisplayText(0.0, 0.0)
	ClearDrawOrigin()
end