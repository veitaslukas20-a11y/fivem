local Gumyte = nil 

Citizen.CreateThread(function()
    while not ESX.IsPlayerLoaded() do Wait(100) end
    SetPedCanLosePropsOnDamage(cache.ped, false, 0)
end)

exports('gumyte', function()
    PlayAnim('clothingtie', 'check_out_a', 2000)
    if not Gumyte then
        Gumyte = {
            Drawable = GetPedDrawableVariation(cache.ped, 2),
            Texture = GetPedTextureVariation(cache.ped, 2)
        }

        if IsPedMale(cache.ped) then
            SetPedComponentVariation(cache.ped, 2, 25, 0, true)
        else 
            SetPedComponentVariation(cache.ped, 2, 0, 0, true)
        end
    else
        SetPedComponentVariation(cache.ped, 2, Gumyte.Drawable, Gumyte.Texture, 0)
        Gumyte = nil
    end
end)

function PlayAnim(dict, anim, duration, move)
    local flag = 51
    if not move then flag = 1 end
    local Ped = PlayerPedId()
	while not HasAnimDictLoaded(dict) do RequestAnimDict(dict) Wait(100) end
	TaskPlayAnim(Ped, dict, anim, 3.0, 3.0, duration, 51, 0, false, false, false)
end