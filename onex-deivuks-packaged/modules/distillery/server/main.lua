local distileryCache = {}

lib.callback.register("DDistillery:getConfig", function() 
    return DDistillery
end)

lib.callback.register("DDistillery:GetItemLabel", function(source, itemas) 
    local item = exports.ox_inventory:Items(itemas)
    return item.label
end)

RegisterNetEvent("d-DDistillery:sellitems", function() 
    local payout = 0
    for k,v in pairs(DDistillery.Prices) do
        local count = exports.ox_inventory:GetItem(source, k, nil, true)
        if count > 0 then
            exports.ox_inventory:RemoveItem(source, k, count)
            payout = payout + (count * v)
        end
    end

    if payout == 0 then
        return
    end
    
    exports.ox_inventory:AddItem(source, 'black_money', payout)
end)

lib.callback.register('DDistillery:getObject', function(source, netid) 
    return distileryCache[netid]
end)

RegisterNetEvent("DDistillery:spawnMachine", function(coords, heading)
    local ent = CreateObjectNoOffset('prop_still', coords.x, coords.y, coords.z-0.9, true, true, true)
    FreezeEntityPosition(ent, true)
    SetEntityHeading(ent, heading)
    distileryCache[NetworkGetNetworkIdFromEntity(ent)] = {
        progress = nil,
        ingridients = nil,
        type = nil,
        ingridients = nil,
        filtered = false,
        netid = NetworkGetNetworkIdFromEntity(ent),
        entity = ent,
    }
    exports.ox_inventory:RemoveItem(source, 'samaparatas', 1)
    Entity(ent).state:set("samaparatas", true, true)
end)

RegisterNetEvent("distilery:update", function(netid, tipas, data)
    local source = source
    if tipas == 'type' then
        distileryCache[netid].type = data
    elseif tipas == 'ingridients' then

        if data then
            if checkPlayerInventory(source, DDistillery.RequireItems[distileryCache[netid].type]) then 
                for k,v in pairs(DDistillery.RequireItems[distileryCache[netid].type]) do
                    exports.ox_inventory:RemoveItem(source, k, v.count)
                end

                distileryCache[netid].ingridients = data
            else
                TriggerClientEvent('ox_lib:notify', source, {
                    title = 'VIRIMAS',
                    description = "Jūs neturite reikiamų daiktų",
                    type = 'info',
                    icon = 'wine-bottle'
                })
                return
            end
        else
            distileryCache[netid].ingridients = data
        end
    elseif tipas == 'heated' then
        distileryCache[netid].heated = data
        if data then
            if not distileryCache[netid].progress then
                distileryCache[netid].progress = 0
            end
        end
    elseif tipas == 'filtered' then
        distileryCache[netid].filtered = data
    end
end)

Citizen.CreateThread(function() 
    while true do
        for k, v in pairs(distileryCache) do
            if v.heated then
                if not v.progress then v.progress = 0 end
                v.progress = v.progress + math.random(1, 5)
                if v.progress >= 100 then
                    v.progress = 100
                    v.heated = false
                end
            end
        end
        Wait(15 * 1000)
    end
end)

RegisterNetEvent("distilery:end", function(netid) 

    local amount = math.random(3,7)
    if distileryCache[netid].type == 'grudai' then
        if exports.ox_inventory:CanCarryItem(source, 'samagonas', amount) then
            exports.ox_inventory:AddItem(source, 'samagonas', amount)
        else
            TriggerClientEvent('ox_lib:notify', source, {
                title = 'VIRIMAS',
                description = "Jūs negalite tiek panešti",
                type = 'info',
                icon = 'wine-bottle'
            })
        end
    end

    DeleteEntity(distileryCache[netid].entity)
    exports.ox_inventory:AddItem(source, 'samaparatas', 1)
    distileryCache[netid] = nil
end)

RegisterNetEvent("DDistillery:removeObject", function(kaskas, netid) 
    DeleteEntity(distileryCache[netid].entity)
    exports.ox_inventory:AddItem(source, 'samaparatas', 1)
    distileryCache[netid] = nil
end)

function checkPlayerInventory(source, categoryItems)
    for itemName, itemData in pairs(categoryItems) do
        local itemCount = exports.ox_inventory:GetItem(source, itemName, nil, true)
        
        if not itemCount or itemCount < itemData.count then
            return false
        end
    end

    return true
end

AddEventHandler('onResourceStop', function(resourceName)
    if GetCurrentResourceName() == resourceName then
      for k,v in pairs(distileryCache) do
        DeleteEntity(NetworkGetEntityFromNetworkId(k))
      end

      distileryCache = nil
    end
  end)