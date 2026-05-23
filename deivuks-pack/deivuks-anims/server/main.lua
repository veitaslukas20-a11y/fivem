RegisterNetEvent('deivuks-anims:play:server', function(target, data)
    local src = source
    if not target then return end

    -- Siunčiame TARGET'ui animaciją (tas kuris bus nešamas / animuojamas)
    TriggerClientEvent('deivuks-anims:play', target, src, data)

    -- Siunčiame animaciją ir tam, kuris kviečia (jei reikia, client kodas pats susitvarko)
    TriggerClientEvent('deivuks-anims:play.me', src, data)
end)

RegisterNetEvent('deivuks-anims:stop', function(target)
    local src = source
    if target then
        -- Sustabdom animaciją target'ui
        TriggerClientEvent('deivuks-anims:stop', target)
    end
    -- Sustabdom animaciją sau
    TriggerClientEvent('deivuks-anims:stop', src)
end)

RegisterNetEvent('deivuks-anims:confirm.server', function(target, data)
    local src = source
    if not target then return end

    -- Paleidžiame animacijas abiem pusėm
    TriggerClientEvent('deivuks-anims:play', target, src, data)
    TriggerClientEvent('deivuks-anims:play.me', src, data)
end)

RegisterNetEvent('deivuks-anims:cancel', function(target)
    local src = source
    if target then
        TriggerClientEvent('deivuks-anims:stop', target)
    end
    TriggerClientEvent('deivuks-anims:stop', src)
end)

-- Kvietimas patvirtinimui (naudojamas client'e su exports['deivuks-request'])
RegisterNetEvent('deivuks-anims:wait.confirm', function(target, name, data)
    local src = source
    if not target then return end

    TriggerClientEvent('deivuks-anims:wait.confirm', target, src, name, data)
end)
