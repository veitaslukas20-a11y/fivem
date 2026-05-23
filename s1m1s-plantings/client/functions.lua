Utils = {}

Utils.IsOnGrass = function(coords)
    local ped = PlayerPedId()
	local num = StartShapeTestCapsule(coords.x,coords.y,coords.z+4,coords.x,coords.y,coords.z-2.0, 1,1,ped,7)
	local arg1, arg2, arg3, arg4, arg5 = GetShapeTestResultEx(num)
    for _, v in pairs(Config.Grass) do 
        if arg5 == v then
            return true
        end
    end
	return false
end

Utils.SpaceFree = function(coords, prop)
    return GetClosestObjectOfType(coords, 1.5, prop) == 0
end

Utils.ForwardVector = function(radius)
    local radius = radius or 1.0
    local coords = GetEntityCoords(cache.ped)
    local forward = GetEntityForwardVector(cache.ped) 
    return (coords + forward * radius)
end

Utils.PlayAnim = function(label, duration, anim)
    if lib.progressCircle({
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
    }) then return true else return false end
end