CreateThread(function()
    while true do
        Wait(1000)
        NetworkSetFriendlyFireOption(true)
        SetCanAttackFriendly(PlayerPedId(), true, true)
        local ped = PlayerPedId()
        SetEntityProofs(ped, false, false, false, false, false, false, false, false)
        SetPedCanRagdoll(ped, true)
    end
end)
