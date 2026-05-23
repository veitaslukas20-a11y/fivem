local Target = exports.ox_target
local Onex = exports['onex-utils']
local Inventory = exports.ox_inventory
local pState = LocalPlayer

local function RemoveObjects(objects)
    for _, object in pairs(objects) do
        Target:removeLocalEntity(object)
        DeleteEntity(object)

        if DoesEntityExist(object) then
            lib.waitFor(function ()
                if not DoesEntityExist(object) then
                    return true
                else
                    SetEntityAsMissionEntity(object, true, true)
                    SetEntityAsNoLongerNeeded(object)
                    DeleteEntity(object)
                end
            end, 'Unable to delete entity', 10000)
        end
    end
end

local function RemoveObject(objects, delObject)
    for id, object in pairs(objects) do
        if object == delObject then
            Target:removeLocalEntity(object)
            DeleteEntity(object)
            table.remove(objects, id)

            if DoesEntityExist(object) then
                lib.waitFor(function ()
                    if not DoesEntityExist(object) then
                        return true
                    else
                        SetEntityAsMissionEntity(object, true, true)
                        SetEntityAsNoLongerNeeded(object)
                        DeleteEntity(object)
                    end
                end, 'Unable to delete entity', 10000)
            end
            break
        end
    end
end

local PickingUp = false
local currObj
local function PickUp(Object, Label, Duration, Anim, Items, Duoble, Location, UID)
    if cache.vehicle or pState.dead then return false end
    if not Object then return false end
    if PickingUp then return false end
    if not cache.coords then return false end

    if #(GetEntityCoords(Object) - cache.coords) > 4.5 then return false end

    local Efficiency = 1.0

    if SelfData.jobName and SelfData.locationName == Location then
        local isOfficial = ConfigDrugs.Gangs.Official[SelfData.jobName]
        Efficiency = isOfficial and ConfigDrugs.Workers.Official.Efficiency or ConfigDrugs.Workers.Unofficial.Efficiency
    end

    local double = Inventory:GetItemCount(Duoble)

    for _, item in pairs(Items) do
        if not Onex:CanCarryItem(item.name, item.max * (double and 1 or 2)) then
            exports['1x-hud']:sendNotification({
                type = 'ERROR',
                title = 'Narkotikai',
                message = 'Deja, nebeturite pakankamai vietos inventoriuje.',
                duration = 6000,
                icon = 'tablets'
            })
            return false
        end
    end

    PickingUp = true

    local success = PlayProgress(Label, Duration / Efficiency, Anim)
    if not success then
        PickingUp = false
        return false
    end
    if Anim.scenario then ClearPedTasksImmediately(cache.ped) end

    currObj = Object
    local await = lib.callback.await('drugs:addItem', false, Object, UID)
    if not await then
        exports['1x-hud']:sendNotification({
            type = 'ERROR',
            title = 'Narkotikai',
            message = (Location == 'boxes') and 'Deja, nebeturite pakankamai vietos inventoriuje arba nieko neradote.' or 'Deja, nebeturite pakankamai vietos inventoriuje.',
            duration = 6000,
            icon = 'tablets'
        })
        PickingUp = false
        currObj = nil
    else
        currObj = nil
        PickingUp = false
    end

    return true
end

lib.callback.register('drugs:objectDoesExist', function(obj)
    return PickingUp and DoesEntityExist(obj) and currObj == obj, true
end)

local function SetupPlantings()
    for i=1, #ConfigDrugs.Plants do

        local Plant = ConfigDrugs.Plants[i]

        for j=1, #Plant.Locations do
            local Location = Plant.Locations[j]
            Location.Objects = {}

            lib.points.new({
                coords = Location.Coords,
                distance = 200,
                nearby = function(self)
                    SpawnObjects(Location.Objects, Plant.Model, 10, Location.Coords, Location.Radius, Plant.Target, Plant.Icon, function(object)
                        if PickUp(object, Plant.Loading, Plant.Duration, Plant.Anim, Plant.Items, Plant.Double, Plant.Type?.value, i) then
                            RemoveObject(Location.Objects, object)
                        end
                    end)
                    Wait(1000)
                end,
                onExit = function(self)
                    RemoveObjects(Location.Objects)
                    Location.Objects = {}
                end
            })
        end

    end
end

Citizen.CreateThread(function()
    while not ConfigDrugs do Wait(100) end

    SetupPlantings()
end)

AddEventHandler('onResourceStop', function(resourceName)
    if (GetCurrentResourceName() ~= resourceName) then return end

    for i=1, #ConfigDrugs.Plants do
        local Plant = ConfigDrugs.Plants[i]
        for j=1, #Plant.Locations do
            local Location = Plant.Locations[j]
            for h=1, #Location.Objects do
                local object = Location.Objects[h]
                DeleteEntity(object)
            end
        end
    end
end)

local blips = {}
RegisterNetEvent("esx:setJob")
AddEventHandler('esx:setJob', function(job, lastJob)
    if job.name == 'admin' and #blips == 0 then
        for _, plantData in pairs(ConfigDrugs.Plants) do
            for _, location in pairs(plantData.Locations) do
                local blip = AddBlipForCoord(location.Coords)

                SetBlipSprite(blip, 469)
                SetBlipDisplay(blip, 4)
                SetBlipScale(blip, 1.0)
                SetBlipColour(blip, 0)
                SetBlipAsShortRange(blip, true)

                BeginTextCommandSetBlipName('STRING')
                AddTextComponentString('<font face="Roboto">'..plantData.Blip..'</font>')
                EndTextCommandSetBlipName(blip)

                table.insert(blips, blip)
            end
        end

        for _, plantData in pairs(ConfigDrugs.Tables) do
            for _, location in pairs(plantData.Locations) do
                local blip = AddBlipForCoord(location.Coords)

                SetBlipSprite(blip, 651)
                SetBlipDisplay(blip, 4)
                SetBlipScale(blip, 1.0)
                SetBlipColour(blip, 0)
                SetBlipAsShortRange(blip, true)

                BeginTextCommandSetBlipName('STRING')
                AddTextComponentString('<font face="Roboto">'..plantData.Blip..'</font>')
                EndTextCommandSetBlipName(blip)

                table.insert(blips, blip)
            end
        end
    elseif #blips > 0 then
        for _, blip in pairs(blips) do
            RemoveBlip(blip)
        end

        blips = {}
    end
end)