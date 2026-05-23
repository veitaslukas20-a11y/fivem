local sleep = 1000
local Config, zones, boxes, boxesCount = nil, {}, {}, 0

local ox_inventory = exports.ox_inventory
local Target = exports.ox_target
local Onex = exports['onex-utils']

Citizen.CreateThread(function()
    while not ESX.IsPlayerLoaded() do
        Wait(500)
    end

    Config = lib.callback.await('d-treasures:getConfig', false)

    Blip = AddBlipForCoord(Config.Ped.coords)
    SetBlipSprite(Blip, 605)
    SetBlipDisplay(Blip, 4)
    SetBlipScale(Blip, 0.7)
    SetBlipColour(Blip, 31)
    SetBlipAsShortRange(Blip, true)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString('<font face="Roboto">Sendaikčių parduotuvė</font>')
    EndTextCommandSetBlipName(Blip)

    local point = lib.points.new({
        coords = vec3(Config.Ped.coords.x, Config.Ped.coords.y, Config.Ped.coords.z),
        distance = 20,
    })

    function point:onEnter()
        CreateLocalPed()
    end

    function point:onExit()
        if Config.Ped.register then 
            Target:removeLocalEntity(Config.Ped.register)
            DeleteEntity(Config.Ped.register)
            Config.Ped.register = nil
        end
    end
end)

function CreateLocalPed()
    if not Config.Ped.register then
        RequestModel(`a_m_y_bevhills_01`)
        while not HasModelLoaded(`a_m_y_bevhills_01`) do
            Wait(100)
        end
        Config.Ped.register = CreatePed(4, `a_m_y_bevhills_01`, Config.Ped.coords.x, Config.Ped.coords.y, Config.Ped.coords.z -1.0, Config.Ped.coords.w, false, true)
        FreezeEntityPosition(Config.Ped.register, true)
        SetEntityInvincible(Config.Ped.register, true)
        SetBlockingOfNonTemporaryEvents(Config.Ped.register, true)
        NetworkFadeInEntity(Config.Ped.register, true, true)

        Target:addLocalEntity(Config.Ped.register, {
            {
                icon = "fa-solid fa-euro-sign",
                onSelect = function()
                    OpenMenu()
                end,
                label = "Parduoti sendaikčius",
                distance = 2.0
            },
        })
    end
end

local function sellSingleItem(itemName, itemDisplayLabel, itemQuantity)
    local sellResult = lib.callback.await('d-treasures:sellItem', false, itemName)

    if not sellResult then
        exports['1x-hud']:sendNotification({
            type = 'ERROR',
            title = 'Sendaikčių supirkimas',
            message = 'Deja, neturite daiktų, kurie mane domintų.',
            duration = 7000,
            icon = 'gem'
        })
    else
        exports['1x-hud']:sendNotification({
            type = 'SUCCESS',
            title = 'Sendaikčių supirkimas',
            message = ('Sėkmingai pardavėte %dx %s už %d€.'):format(itemQuantity, itemDisplayLabel, sellResult),
            duration = 7000,
            icon = 'gem'
        })
    end
end

function OpenMenu()
    local totalSellValue = 0
    local playerHasItemsToSell = false
    local availableItemsToSell = {}

    local menuOptions = {
        {
            title = ('Parduokite visus daiktus už %d€'):format(totalSellValue),
            description = ('Parduokite visus turimus daiktus kuriuos supirkėjas nupirks už %d€'):format(totalSellValue),
            disabled = not playerHasItemsToSell,
            onSelect = function()
                local sellAllResult = lib.callback.await('d-treasures:sellAllItems', false, availableItemsToSell)

                if not sellAllResult then
                    exports['1x-hud']:sendNotification({
                        type = 'ERROR',
                        title = 'Sendaikčių supirkimas',
                        message = 'Deja, neturite daiktų, kurie mane domintų.',
                        duration = 7000,
                        icon = 'gem'
                    })
                else
                    exports['1x-hud']:sendNotification({
                        type = 'SUCCESS',
                        title = 'Sendaikčių supirkimas',
                        message = ('Sėkmingai pardavėte daiktus už %d€.'):format(sellAllResult),
                        duration = 7000,
                        icon = 'gem'
                    })
                end
            end
        },
        {
            title = 'Parduokite visus daiktus išskyrus...',
            description = 'Galite pasirinti daiktus, kurių neparduosite supirkėjui',
            disabled = not playerHasItemsToSell,
            onSelect = function()
                local itemChoices = {}
                for _, treasureItem in pairs(Config.Shop) do
                    if ox_inventory:GetItemCount(treasureItem.name) > 0 then
                        itemChoices[#itemChoices + 1] = {
                            value = treasureItem.name,
                            label = (Onex:getLabel(treasureItem.name)):gsub("^%l", string.upper),
                        }
                    end
                end

                local userSelection = lib.inputDialog('Pasirinkite daiktus', {
                    {
                        type = 'multi-select',
                        label = 'Pasirinkite ko nenorite parduoti',
                        description = 'Pasirinkite daiktus, kuriuos norite pasilikti.',
                        required = true,
                        options = itemChoices,
                        searchable = true,
                        clearable = true
                    },
                })

                if not userSelection or not userSelection[1] then
                    return
                end

                local itemsToKeep = {}
                for _, itemName in pairs(userSelection[1]) do
                    itemsToKeep[itemName] = true
                end

                local filteredSellResult = lib.callback.await('d-treasures:sellItemsByFilter', false, availableItemsToSell, itemsToKeep)

                if not filteredSellResult then
                    exports['1x-hud']:sendNotification({
                        type = 'ERROR',
                        title = 'Sendaikčių supirkimas',
                        message = 'Deja, neturite daiktų, kurie mane domintų.',
                        duration = 7000,
                        icon = 'gem'
                    })
                else
                    exports['1x-hud']:sendNotification({
                        type = 'SUCCESS',
                        title = 'Sendaikčių supirkimas',
                        message = ('Sėkmingai pardavėte daiktus už %d€.'):format(filteredSellResult),
                        duration = 7000,
                        icon = 'gem'
                    })
                end
            end
        },
    }

    for _, treasureItem in pairs(Config.Shop) do
        local playerItemCount = ox_inventory:GetItemCount(treasureItem.name)

        if playerItemCount > 0 then
            availableItemsToSell[#availableItemsToSell + 1] = treasureItem.name

            local itemTotalValue = treasureItem.price * playerItemCount
            totalSellValue = totalSellValue + itemTotalValue

            local itemDisplayName = (Onex:getLabel(treasureItem.name)):gsub("^%l", string.upper)

            menuOptions[#menuOptions + 1] = {
                title = ('Parduokite %dx %s už %d€.'):format(playerItemCount, itemDisplayName, itemTotalValue),
                description = ('Parduokite visas(-us) %s už %d€.\nVieneto kaina: %d€.'):format(itemDisplayName, itemTotalValue, treasureItem.price),
                onSelect = function()
                    sellSingleItem(treasureItem.name, itemDisplayName, playerItemCount)
                end
            }

            playerHasItemsToSell = true
        end
    end

    menuOptions[1].title = ('Parduokite visus daiktus už %d€'):format(totalSellValue)
    menuOptions[1].description = ('Parduokite visus turimus daiktus kuriuos supirkėjas nupirks už %d€'):format(totalSellValue)
    menuOptions[1].disabled = not playerHasItemsToSell
    menuOptions[2].disabled = not playerHasItemsToSell

    lib.registerContext({
        id = 'deivuks-treasures',
        title = 'Parduoti sendaikčius',
        menu = 'deivuks_treasures',
        options = menuOptions
    })

    lib.showContext('deivuks-treasures')
end

local isInZone = true
local lastBoxesReset = 0
local BOXES_RESET_TIMER = 10 * 60 * 1000

Citizen.CreateThread(function()
    -- Wait until Config and Config.Locations are available
    while not Config or not Config.Locations do
        Wait(100)
    end

    for locationId, zone in pairs(Config.Locations) do
        if zone and zone.coords and zone.size then
            local point = lib.points.new({
                coords = zone.coords,
                distance = zone.size + 20.0,
            })

            function point:onEnter()
                isInZone = true
                SpawnBoxes(zone, locationId)
                Citizen.CreateThread(function()
                    while isInZone do
                        if (GetGameTimer() - lastBoxesReset) > BOXES_RESET_TIMER and boxesCount < 2 then
                            lastBoxesReset = GetGameTimer()
                            SpawnBoxes(zone, locationId)
                        end
                        Wait(1000)
                    end
                end)
            end

            function point:onExit()
                isInZone = false
                DeleteBoxes()
            end
        else
            print(("[deivuks-treasures] Invalid zone configuration for locationId: %s"):format(tostring(locationId)))
        end
    end
end)


function ValidateBoxes(coords)
	if #boxes > 0 then
		local validate = true

		for _, boxEnt in pairs(boxes) do
			if #(coords - GetEntityCoords(boxEnt)) < 5 then
				validate = false
			end
		end

		return validate
	else
		return true
	end
end

function GenerateBoxCoords(coords)
    math.randomseed(GetGameTimer())
	while true do
		Wait(100)

		local coordX, coordY

		local modX = math.random(-15, 15)

		Wait(100)

		local modY = math.random(-15, 15)

		coordX = coords.x + modX
		coordY = coords.y + modY

		local coordZ = GetCoordZ(vec3(coordX, coordY, coords.z))
		local coord = vector3(coordX, coordY, coordZ)

		if ValidateBoxes(coord) then
			return coord
		end
	end
end

function GenerateZCoords(z)
    local array = {}
    for i=1, 20 do
        table.insert(array, tostring(z-i*1.0))
        table.insert(array, tostring(z+i*1.0))
    end
    return array
end

function GetCoordZ(coords)
	local groundCheckHeights = GenerateZCoords(coords.z)

	for i, height in ipairs(groundCheckHeights) do
		local foundGround, z = GetGroundZFor_3dCoord(coords.x, coords.y, tonumber(height), false)

		if foundGround then
			return z
		end
	end
	return coords.z
end

function SpawnBoxes(Zone, locationId)
    if boxesCount == 4 then return end
	while boxesCount < 4 do
        local boxCoords = GenerateBoxCoords(Zone.coords)

        ESX.Game.SpawnLocalObject(`prop_box_wood05a`, boxCoords, function(entity)
            PlaceObjectOnGroundProperly(entity)
			FreezeEntityPosition(entity, true)

            Target:addLocalEntity(entity, {
                {
                    icon = "fa-solid fa-box-open",
                    label = 'Atidaryti dėžę',
                    onSelect = function(data)
                        if cache.vehicle then return end

                        OpenBox(data.entity, locationId)
                    end,
                    distance = 4.0
                },
            })

            table.insert(boxes, entity)
            boxesCount += 1
        end)
    end
end

local PickingBox = false
function OpenBox(entity, locationId)
    if not entity then return end
    if PickingBox then return end

    if #(GetEntityCoords(entity) - cache.coords) > 4.5 then return end

    PickingBox = true

    if lib.progressCircle({
        label = 'Atidarote dėžę...',
        duration = 15000,
        position = 'bottom',
        canCancel = true,
        allowSwimming = true,
        allowFalling = false,
        allowCuffed = false,
        allowRagdoll = false,
        useWhileDead = false,
        disable = {
            move = true,
            car = true,
            combat = true,
            mouse = false,
        },
        anim = {
            dict = 'amb@prop_human_bum_bin@base',
            clip = 'base',
            flag = 1,
        }
    }) then
        local await = lib.callback.await('d-treasures:getReward', false, locationId)
        if not await then 
            exports['1x-hud']:sendNotification({
                type = 'SUCCESS',
                title = 'Nardymas',
                message = 'Deja, jūs nebeturite pakankamai vietos arba nieko neradote dėžėje.',
                duration = 5000,
            })
        end

        DeleteBox(entity)
        PickingBox = false
    else 
        PickingBox = false
    end
end

function DeleteBoxes()
    for boxId, boxEnt in pairs(boxes) do
        if boxEnt then
            DeleteEntity(boxEnt)
            Target:removeLocalEntity(boxEnt)
            table.remove(boxes, boxId)
        end
    end
    boxesCount = 0
end

function DeleteBox(entity)
    for boxId, boxEnt in pairs(boxes) do
        if boxEnt == entity then
            boxesCount -= 1
            DeleteEntity(entity)
            Target:removeLocalEntity(entity)
            table.remove(boxes, boxId)
            break
        end
    end
end