local Target = exports.ox_target
local Onex = exports['onex-utils']
local Inventory = exports.ox_inventory
local pState = LocalPlayer

local function RemoveObjects(objects)
    for i=1, #objects do
        local object = objects[i]

        DeleteEntity(object)
        Target:removeLocalEntity(object)

        while DoesEntityExist(object) do
            DeleteEntity(object)
            Wait(100)
        end
    end
end

local Processing = false
local currObj
local function Process(Object, Progresses, Items, Required, UID)
    if cache.vehicle or pState.dead then return false end
    if not Object then return end
    if Processing then return end
    if not cache.coords then return end

    if #(GetEntityCoords(Object) - cache.coords) > 4.5 then return end

    local Count = 0

    for _, item in pairs(Items) do
        Count = math.max(item.max, Count)
    end

    for _, item in pairs(Required) do
        if Inventory:GetItemCount(item.name) < (item.count or Count) then
            exports['1x-hud']:sendNotification({
                type = 'ERROR',
                title = 'Narkotikai',
                message = 'Deja neturite pakankamai resursų, kad apdirbtumėte narkotines medžiagas.',
                duration = 6000,
                icon = 'tablets'
            })
            Processing = false
            return
        end
    end

    for _, item in pairs(Items) do
        if not Onex:CanCarryItem(item.name, item.max) then
            exports['1x-hud']:sendNotification({
                type = 'ERROR',
                title = 'Narkotikai',
                message = 'Deja, nebeturite pakankamai vietos inventoriuje.',
                duration = 6000,
                icon = 'tablets'
            })
            Processing = false
            return
        end
    end

    Processing = true

    for _, progress in pairs(Progresses) do
        local success = PlayProgress(progress.Label, progress.Duration, progress.Anim)
        if not success then
            Processing = false
            return
        end
        if progress.Anim?.scenario then ClearPedTasksImmediately(cache.ped) end
    end

    currObj = Object
    local await = lib.callback.await('drugs:process:addItem', false, Object, UID)
    if not await then
        exports['1x-hud']:sendNotification({
            type = 'ERROR',
            title = 'Narkotikai',
            message = 'Deja, nebeturite pakankamai vietos inventoriuje.',
            duration = 6000,
            icon = 'tablets'
        })
        currObj = nil
        Processing = false
    else
        currObj = nil
        Processing = false
    end
end

lib.callback.register('drugs:procressDoesExist', function(obj)
    return Processing and DoesEntityExist(obj) and obj == currObj, true
end)

local function SetupProgresses()
    for i=1, #ConfigDrugs.Tables do

        local Progress = ConfigDrugs.Tables[i]

        for j=1, #Progress.Locations do
            local Location = Progress.Locations[j]
            Location.Objects = {}

            lib.points.new({
                coords = Location.Coords,
                distance = 200,
                onEnter = function(self)
                    SpawnTables(Location.Objects, Progress.Model, Location.Tables, Progress.Target, Progress.Icon, function(object)
                        Process(object, Progress.Progreses, Progress.Items, Progress.Required, i)
                    end)
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

    SetupProgresses()
end)

AddEventHandler('onResourceStop', function(resourceName)
    if (GetCurrentResourceName() ~= resourceName) then return end

    for i=1, #ConfigDrugs.Tables do
        local Table = ConfigDrugs.Tables[i]
        for j=1, #Table.Locations do
            local Location = Table.Locations[j]
            for h=1, #Location.Objects do
                local object = Location.Objects[h]
                DeleteEntity(object)
            end
        end
    end
end)