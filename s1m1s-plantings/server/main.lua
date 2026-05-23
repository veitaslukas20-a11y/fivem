local weedCache = {}

RegisterNetEvent("s1m1s-plantings:spawnPlanting", function(coords) 
    local ent = CreateObjectNoOffset('bkr_prop_weed_01_small_01a', coords.x, coords.y, coords.z-1.5, true, true, true)
    FreezeEntityPosition(ent, true)
    weedCache[NetworkGetNetworkIdFromEntity(ent)] = {
        netid = NetworkGetNetworkIdFromEntity(ent),
        water = 0,
        food = 0,
        growth = 0,
        rate = 1,
        death = 0,
        prop = 'bkr_prop_weed_01_small_01a',
        coords = coords,
    }
    exports.ox_inventory:RemoveItem(source, 'weed_seed', 1)
    Entity(ent).state:set("weedProp", true, true)
end)

lib.callback.register("s1m1s-plantings:getObject", function(source, netid) 
    return weedCache[netid]
end)

lib.callback.register("s1m1s-plantings:GetConfig", function() 
    return Weed
end)

RegisterNetEvent("s1m1s-plantings:addValue", function(netid, tipas) 
    if tipas == 'food' then
        if weedCache[netid].food then
        exports.ox_inventory:RemoveItem(source, 'fertilizer', 1)
        weedCache[netid].food = weedCache[netid].food + math.random(35,50)
        if weedCache[netid].food > 100 then
            weedCache[netid].food = 100
        end
    end
    elseif tipas == 'water' then
        if weedCache[netid].water then
            exports.ox_inventory:RemoveItem(source, 'water', 1)
            weedCache[netid].water = weedCache[netid].water + math.random(35,50)
            if weedCache[netid].water > 100 then
                weedCache[netid].water = 100
            end
        end
    end
end)

Citizen.CreateThread(function() 
    while true do
            for k,v in pairs(weedCache) do
                local add = 0
                if v.food >= 25 then
                    v.food = v.food -25
                    add = add + math.random(3,10)
                end

                if v.water >= 25 then
                    v.water = v.water -25
                    add = add + math.random(3,10)
                end

                if add == 0 then
                    v.death = v.death + 25
                else
                    v.death = v.death - 25
                    if v.death < 0 then
                        v.death = 0
                    end
                end


                if v.death >= 100 then
                    v.rate = 0
                end

                v.growth = v.growth + add
                add = 0

                if v.growth > 100 then
                    v.growth = 100
                end

                if v.prop == 'bkr_prop_weed_01_small_01a' and v.growth >= 50 then
                    DeleteEntity(NetworkGetEntityFromNetworkId(k))
                    local ent = CreateObjectNoOffset('sf_prop_sf_weed_med_01a', v.coords.x, v.coords.y, v.coords.z-1.5, true, true, true)
                    FreezeEntityPosition(ent, true)
                    weedCache[NetworkGetNetworkIdFromEntity(ent)] = weedCache[k]
                    weedCache[NetworkGetNetworkIdFromEntity(ent)].netid = NetworkGetNetworkIdFromEntity(ent)
                    weedCache[NetworkGetNetworkIdFromEntity(ent)].prop = 'sf_prop_sf_weed_med_01a'
                    weedCache[k] = nil
                    Entity(ent).state:set("weedProp", true, true)
                elseif v.prop == 'sf_prop_sf_weed_med_01a' and v.growth >= 80 then
                    DeleteEntity(NetworkGetEntityFromNetworkId(k))
                    local ent = CreateObjectNoOffset('sf_prop_sf_weed_lrg_01a', v.coords.x, v.coords.y, v.coords.z-1.5, true, true, true)
                    FreezeEntityPosition(ent, true)
                    weedCache[NetworkGetNetworkIdFromEntity(ent)] = weedCache[k]
                    weedCache[NetworkGetNetworkIdFromEntity(ent)].netid = NetworkGetNetworkIdFromEntity(ent)
                    weedCache[NetworkGetNetworkIdFromEntity(ent)].prop = 'sf_prop_sf_weed_lrg_01a'
                    weedCache[k] = nil
                    Entity(ent).state:set("weedProp", true, true)
                end        
            end
        Wait(60 * 1000)
    end
end)

RegisterNetEvent("s1m1s-plantings:removeObj", function(netid) 
    DeleteEntity(NetworkGetEntityFromNetworkId(netid))
    weedCache[netid] = nil
end)

RegisterNetEvent("s1m1s-plantings:harvestObj", function(netid) 
    exports.ox_inventory:AddItem(source, 'marijuana', (math.floor(weedCache[netid].growth / 10)))
    DeleteEntity(NetworkGetEntityFromNetworkId(netid))
    weedCache[netid] = nil
end)

AddEventHandler('onResourceStop', function(resourceName)
    if GetCurrentResourceName() == resourceName then
      for k,v in pairs(weedCache) do
        DeleteEntity(NetworkGetEntityFromNetworkId(k))
      end

      weedCache = nil
    end
  end)