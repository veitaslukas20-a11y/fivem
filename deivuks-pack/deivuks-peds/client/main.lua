local pState = LocalPlayer.state
RegisterCommand('peds', function()
    if IsEntityDead(cache.ped) or pState.dead then return end
    local peds = lib.callback.await('peds:getPeds', false)

    if not peds then
        exports['1x-hud']:sendNotification({
            type = 'ERROR',
            title = 'Veikėjų meniu',
            message = 'Deja, neturite neivieno veikėjo kuris būtų priskirtas jums.',
            duration = 5000,
        })
        return
    end

    local health = GetEntityHealth(cache.ped)
    local maxHealth = GetPedMaxHealth(cache.ped)

    local options = {}
    for _, ped in pairs(peds) do
        table.insert(options, {
            title = ped.name,
            description = ('%s veikėjas'):format(ped.name),
            onSelect = function()
                lib.requestModel(ped.model)
                SetPlayerModel(cache.playerId, ped.model)
                SetPedMaxHealth(cache.ped, maxHealth)
                SetEntityHealth(cache.ped, health)
            end
        })
    end

    lib.registerContext({
        id = 'peds',
        title = 'Jūsų veikėjai',
        options = options,
    })
    lib.showContext('peds')
end)