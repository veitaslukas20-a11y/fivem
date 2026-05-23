exports('sukujointa', function (data, slot)
    local hasWeed = exports.ox_inventory:Search('count', 'weed_proc')
    local hasPaper = exports.ox_inventory:Search('count', 'weed_papers')
    
    if hasWeed < 1 or hasPaper < 1 then
        ESX.ShowNotification('Truksta reikiamu resursu.')
        return false
    end

    if lib.progressCircle({
        duration = 4000,
        position = 'bottom',
        label = 'Sukate suktinę',
        useWhileDead = false,
        allowRagdoll = false,
        allowCuffed = false,
        allowFalling = false,
        canCancel = true,
        anim = { dict = 'nmt_3_rcm-10', clip = 'cs_nigel_dual-10' },
        disable = { combat = true }
    }) then
        local make = lib.callback.await('onex:joint:make', false)
    else
        return false
    end
end)