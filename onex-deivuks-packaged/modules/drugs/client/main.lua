local Target = exports.ox_target

ConfigDrugs = nil

Citizen.CreateThread(function()
    while not ESX.IsPlayerLoaded() do Wait(500) end

    ConfigDrugs = lib.callback.await('drugs:getConfig', false)
end)

function IsFarEnough(newCoords, objects)
    for _, object in pairs(objects) do
        if #(newCoords - GetEntityCoords(object)) < 10 then
            return false
        end
    end
    return true
end

function GetHeights(z)
    local array = {}
    for i=1, 70 do 
        table.insert(array, tostring(z-i*1.0))
        table.insert(array, tostring(z+i*1.0))
    end 
    return array
end

function GetGroundZ(x, y, z)
	local heights = GetHeights(z)

	for _, height in ipairs(heights) do
		local foundGround, z = GetGroundZFor_3dCoord(x, y, tonumber(height), Citizen.ReturnResultAnyway())

		if foundGround then
			return z
		end
	end

	return z
end

local SpawiningObjects = false
function SpawnObjects(objects, model, amount, center, range, label, icon, action)
    if SpawiningObjects then return end
    SpawiningObjects = true
    lib.requestModel(model, 5000)

    local curAmount = amount - #objects

    if curAmount == 0 then
        SpawiningObjects = false
        return
    end

    for i = 1, curAmount do
        local validCoords = nil

        repeat
            local randomX = center.x + math.random(-range, range)
            local randomY = center.y + math.random(-range, range)
            local randomZ = center.z

            local groundZ = GetGroundZ(randomX, randomY, randomZ)

            local newCoords = vector3(randomX, randomY, groundZ)

            if #(newCoords - center) < range then
                if IsFarEnough(newCoords, objects) then
                    validCoords = newCoords
                end
            end

        until validCoords

        local object = CreateObject(model, validCoords.x, validCoords.y, validCoords.z, false, true, false)

        while not DoesEntityExist(object) do
            Wait(100)
        end

        PlaceObjectOnGroundProperly(object)
        Wait(100)
        FreezeEntityPosition(object, true)

        Target:addLocalEntity(object, {
            {
                icon = icon,
                label = label,
                distance = 4.0,
                onSelect = function()
                    action(object)
                end,
            },
        })

        table.insert(objects, object)
    end

    SpawiningObjects = false
end

function SpawnTables(objects, model, tables, label, icon, action)
    if SpawiningObjects then return end
    SpawiningObjects = true

    for i = 1, #tables do
        local coords = tables[i]
        local object = CreateObject(model, coords.x, coords.y, coords.z, false, true, false)

        while not DoesEntityExist(object) do
            Wait(100)
        end

        SetEntityHeading(object, coords.w)

        PlaceObjectOnGroundProperly(object)
        FreezeEntityPosition(object, true)

        Target:addLocalEntity(object, {
            {
                icon = icon,
                label = label,
                distance = 4.0,
                canInteract = function()
                    return true
                end,
                onSelect = function()
                    action(object)
                end,
            },
        })

        table.insert(objects, object)
    end

    SpawiningObjects = false
end

function PlayProgress(label, duration, anim)
    if lib.progressCircle({
        label = label,
        duration = duration,
        position = 'bottom',
        useWhileDead = false,
        allowRagdoll = false,
        allowCuffed = false,
        allowFalling = false,
        canCancel = true,
        anim = anim,
        disable = {
            car = true,
            move = true,
            combat = true,
            mouse = false,
        },
    }) then return true else return false end
end

local Inventory = exports.ox_inventory
local playerState = LocalPlayer.state

local Unpacking = false
exports('unpack', function(item, item2)
    if Unpacking then return end
    Inventory:closeInventory()
    playerState.invBusy = true
    Wait(100)
    local success = lib.skillCheck({'easy', 'easy', 'easy'}, {'w', 'a', 's', 'd'}) -- Laikinas sprendimas dėl macro keys
    if not success then
        playerState.invBusy = false
        return
    end

    Unpacking = true

    local success = PlayProgress('Išpakuojate narkotikus iš maišelio...', 4000, {
        dict = "anim@amb@carmeet@take_photos@male_b@base",
        clip = "base",
    })
    if success then
        local await = lib.callback.await('drugs:unpack', false, item, item2)
        if await or not await then
            Unpacking = false
            playerState.invBusy = false
        end
    else
        Unpacking = false
        playerState.invBusy = false
    end
end)


local Packing = false
exports('pack', function(item, item2)
    if Packing then return end

    if Inventory:GetItemCount(item) < 3 then
        exports['1x-hud']:sendNotification({
            type = 'ERROR',
            title = 'Narkotikai',
            message = 'Deja, neturite pakankamai narkotikų, kad atliktumėte šį veiksmą.',
            duration = 6000,
            icon = 'pills'
        })
        return
    end

    if Inventory:GetItemCount('plastic_bag') == 0 then
        exports['1x-hud']:sendNotification({
            type = 'ERROR',
            title = 'Narkotikai',
            message = 'Deja, neturite pakankamai švirkštų.',
            duration = 6000,
            icon = 'pills'
        })
        return
    end

    Inventory:closeInventory()
    playerState.invBusy = true
    Wait(100)
    local success = exports['onex-minigames']:startMinigame('packingdrugs', {
        product = item
    })
    if not success then
        playerState.invBusy = false
        return
    end

    Packing = true

    local success = PlayProgress('Supakuojate narkotikus į maišelius...', 4000, {
        dict = "anim@amb@carmeet@take_photos@male_b@base",
        clip = "base",
    })
    if success then
        local await = lib.callback.await('drugs:pack', false, item, item2)
        if await or not await then
            Packing = false
            playerState.invBusy = false
        end
    else
        Packing = false
        playerState.invBusy = false
    end
end)

exports('heroin_syringe_pack', function()
    if Packing then return end

    if Inventory:GetItemCount('heroin') < 2 then
        exports['1x-hud']:sendNotification({
            type = 'ERROR',
            title = 'Narkotikai',
            message = 'Deja, neturite pakankamai narkotikų, kad atliktumėte šį veiksmą.',
            duration = 6000,
            icon = 'pills'
        })
        return
    end

    if Inventory:GetItemCount('svirkstas') == 0 then
        exports['1x-hud']:sendNotification({
            type = 'ERROR',
            title = 'Narkotikai',
            message = 'Deja, neturite pakankamai švirkštų.',
            duration = 6000,
            icon = 'pills'
        })
        return
    end

    Inventory:closeInventory()
    playerState.invBusy = true
    Wait(100)
    local success = lib.skillCheck({'easy', 'easy', 'easy'}, {'w', 'a', 's', 'd'}) -- Laikinas sprendimas dėl macro keys
    if not success then
        playerState.invBusy = false
        return
    end

    Packing = true

    local success = PlayProgress('Supakuojate narkotikus į švirkštą...', 4000, {
        dict = "anim@amb@carmeet@take_photos@male_b@base",
        clip = "base",
    })
    if success then
        local await = lib.callback.await('drugs:heroin:syringe', false)
        if await or not await then
            Packing = false
            playerState.invBusy = false
        end
    else
        Packing = false
        playerState.invBusy = false
    end
end)

lib.callback.register('drugs:isPacking', function()
    return Packing or Unpacking
end)