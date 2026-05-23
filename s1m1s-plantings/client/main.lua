local Inventory = exports.ox_inventory

exports('weed_lemonhaze_seed', function(data, slot)
    local coords = Utils.ForwardVector()

    if not Utils.IsOnGrass(coords) or not Utils.SpaceFree(coords, `bkr_prop_weed_01_small_01a`) then
        exports['1x-hud']:sendNotification({
            type = 'ERROR',
            title = 'Žolės auginimas',
            message = 'Deja, tačiau šioje vietoje negalite sodinti marijuanos.',
            duration = 5000,
        })
        return
    end

    local success = Utils.PlayAnim('Sodinate augalą...', 7000, {
        scenario = 'world_human_gardener_plant'
    })
    if success then
        TriggerServerEvent('s1m1s-plantings:spawnPlanting', coords)
    end
end)

local function ShowWeedInfo(netid)
    local Options = {}
    local netData = lib.callback.await('s1m1s-plantings:getObject', false, netid)
    if not netData then return end

    if netData.rate > 0 then
        Options = {
            {
                title = 'Drėgmė',
                description = 'Kanapės augalo žemės drėgnumas, spausk šį pasirinkimą, kad palaistytum augalą',
                icon = 'fa-solid fa-bottle-water',
                progress = netData.water,
                metadata = {
                    {label = 'Procentai', value = math.floor(netData.water)..'%'}
                },
                onSelect = function()
                    local count = Inventory:GetItemCount('water')
                    if count == 0 then 
                        exports['1x-hud']:sendNotification({
                            type = 'ERROR',
                            title = 'Žolės auginimas',
                            message = 'Deja, bet neturite pakankamai vandens palaistyti šiam augalui.',
                            duration = 5000,
                            icon = 'cannabis'
                        })
                        return
                    end

                    local success = Utils.PlayAnim('Laistote augalą...', 4000, {
                        dict = "weapon@w_sp_jerrycan",
                        clip = "fire",
                    })
                    if success then
                        TriggerServerEvent('s1m1s-plantings:addValue', netid, 'water')
                    end
                end,
            },
            {
                title = 'Trąšos',
                description = 'Kanapės augalo žemės patręšimas, spausk šį pasirinkimą, kad patręštum augalą',
                icon = 'fa-solid fa-seedling',
                progress = netData.food,
                metadata = {
                    {label = 'Procentai', value = math.floor(netData.food)..'%'}
                },
                onSelect = function()
                    local count = Inventory:GetItemCount('fertilizer')
                    if count == 0 then 
                        exports['1x-hud']:sendNotification({
                            type = 'ERROR',
                            title = 'Žolės auginimas',
                            message = 'Deja, bet neturite pakankamai vandens palaistyti šiam augalui.',
                            duration = 5000,
                            icon = 'cannabis'
                        })
                        return
                    end

                    local success = Utils.PlayAnim('Tręšiate augalą...', 4000, {
                        dict = "weapon@w_sp_jerrycan",
                        clip = "fire",
                    })
                    if success then
                        TriggerServerEvent('s1m1s-plantings:addValue', netid, 'food')
                    end
                end,
            },
            {
                title = 'Augimas',
                description = 'Kanapės augalo augimas',
                icon = 'fa-solid fa-hand-holding-droplet',
                progress = netData.growth,
                metadata = {
                    {label = 'Procentai', value = math.floor(netData.growth)..'%'}
                },
            },
            {
                title = 'Nurinkti',
                description = 'Nurinkti užaugintas kanapes',
                icon = 'fa-solid fa-cannabis',
                disabled = (netData.growth < 50),
                onSelect = function()
                    local alert = lib.alertDialog({
                        header = 'Ar esate įsitinkinęs,',
                        content = 'kad norite nurinkti kanapės augalą',
                        centered = true,
                        cancel = true
                    })
                    if alert == 'confirm' then 
                        local success = Utils.PlayAnim('Nurenkate užaugintas kanapes...', 5000, {
                            scenario = 'world_human_gardener_plant',
                        })
                        if success then
                            TriggerServerEvent('s1m1s-plantings:harvestObj', netid)
                        end
                    end
                end,
            },
            {
                title = 'Panaikinti',
                description = 'Panaikinti kanapės augalą',
                icon = 'fa-solid fa-circle-xmark',
                onSelect = function()
                    local alert = lib.alertDialog({
                        header = 'Ar esate įsitinkinęs,',
                        content = 'kad norite sunaikinti kanapės augalą',
                        centered = true,
                        cancel = true
                    })
                    if alert == 'confirm' then 
                        local success = Utils.PlayAnim('Naikinate augalą...', 5000, {
                            scenario = 'world_human_gardener_plant',
                        })
                        if success then
                            TriggerServerEvent('s1m1s-plantings:removeObj', netid)
                        end
                    end
                end,
            },
        }
    else
        Options = {
            {
                title = 'Panaikinti',
                description = 'Panaikinti nuvytusį kanapės augalą',
                icon = 'fa-solid fa-plant-wilt',
                onSelect = function()
                    local success = Utils.PlayAnim('Naikinate augalą...', 3000, {
                        scenario = 'world_human_gardener_plant'
                    })
                    if success then
                        TriggerServerEvent('s1m1s-plantings:removeObj', netid)
                    end
                end,
            },
        }
    end

    lib.registerContext({
        id = 'plantings',
        title = 'Kanapės augalas',
        options = Options
    })
    lib.showContext('plantings')
end

AddStateBagChangeHandler("weedProp", nil, function(bagName, key, value)
    local entity = GetEntityFromStateBagName(bagName)
    if entity == 0 then return end

    while not DoesEntityExist(entity) do 
        Wait(100)
    end

    local netid = NetworkGetNetworkIdFromEntity(entity)

    exports.ox_target:addEntity(netid, {
        {
            label = 'Apžiūrėti augalą',
            icon = 'fa-solid fa-cannabis',
            name = 'weed:'..netid,
            distance = 2.0, 
            onSelect = function()
                ShowWeedInfo(netid)
            end,
        }
    })
end)