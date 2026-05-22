local HasAlreadyEnteredMarker, OnJob, IsNearCustomer, CustomerIsEnteringVehicle, CustomerEnteredVehicle,
    CurrentActionData = false, false, false, false, false, {}
local CurrentCustomer, CurrentCustomerBlip, DestinationBlip, targetCoords, LastZone, CurrentAction, CurrentActionMsg

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(xPlayer)
    ESX.PlayerData = xPlayer
    ESX.PlayerLoaded = true
end)

RegisterNetEvent('esx:onPlayerLogout')
AddEventHandler('esx:onPlayerLogout', function()
    ESX.PlayerLoaded = false
    ESX.PlayerData = {}
end)

RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job)
    ESX.PlayerData.job = job
end)

function OpenCloakroom()
    lib.registerContext({
        id = 'taxi_cloakroom',
        title = TranslateCap('cloakroom_menu'),
        options = {
          {
            title = TranslateCap('wear_citizen'),
            icon = 'shirt',
            onSelect = function()
                ESX.TriggerServerCallback('esx_skin:getPlayerSkin', function(skin)
                    TriggerEvent('skinchanger:loadSkin', skin)
                end)

                exports['ren-duty']:SetDuty('taxi', false)
            end,
          },
          {
            title = TranslateCap('wear_work'),
            icon = 'shirt',
            onSelect = function()
                TriggerEvent('skinchanger:getSkin', function(skin)
                    local uniformObject

                    local grade = ESX.GetPlayerData().job.grade

                    if skin.sex == 0 then
                        uniformObject = Config.Uniforms[grade]?.male
                    else
                        uniformObject = Config.Uniforms[grade]?.female
                    end

                    if uniformObject then
                        TriggerEvent('skinchanger:loadClothes', skin, uniformObject)
                    end
                end)

                exports['ren-duty']:SetDuty('taxi', true)
            end,
          },
        },
        onExit = function()
            CurrentAction = 'cloakroom'
            CurrentActionMsg = TranslateCap('cloakroom_prompt')
            CurrentActionData = {}
        end
    })

    lib.showContext("taxi_cloakroom")
end

function OpenTaxiActionsMenu()
    local options = {}

    local jobGrade = ESX.PlayerData.job?.grade_name

    if Config.EnablePlayerManagement and jobGrade == 'boss' or jobGrade == 'deputy' then
        options[#options + 1] = {
            icon = "wallet",
            title = TranslateCap('boss_actions'),
            onSelect = function()
                exports['s1m1s-bossmenu']:openMenu(jobGrade == 'boss')
            end
        }
    end

    lib.registerContext({
        id = 'taxi_actions',
        title = TranslateCap('taxi'),
        options = options,
        onExit = function()
            CurrentAction = 'taxi_actions_menu'
            CurrentActionMsg = TranslateCap('press_to_open')
            CurrentActionData = {}
        end
    })

    lib.showContext("taxi_actions")
end

function OpenMobileTaxiActionsMenu()
    local elements = {
        {unselectable = true, icon = "fas fa-taxi", title = TranslateCap('taxi')},
        {icon = "fas fa-scroll", title = TranslateCap('billing'), value = "billing"},
    }

    local options = {
        {
            title = TranslateCap('billing'),
            icon = "scroll",
            onSelect = function()
                local input = lib.inputDialog('Basic dialog', {
                    {type = 'number', label = TranslateCap('amount'), description = TranslateCap('bill_amount'), icon = 'check-double'},
                })
 
                if not input then 
                    ESX.ShowNotification(TranslateCap('amount_invalid'))
                    return 
                end
                local amount = tonumber(input[1])
                if amount == nil then
                    ESX.ShowNotification(TranslateCap('amount_invalid'))
                else
                    local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer()
                    if closestPlayer == -1 or closestDistance > 3.0 then
                        ESX.ShowNotification(TranslateCap('no_players_near'))
                    else
                        TriggerServerEvent('esx_billing:isiustiisrasa', GetPlayerServerId(closestPlayer), 'society_taxi', 'BOLT', amount)
                        ESX.ShowNotification(TranslateCap('billing_sent'))
                    end
                end
            end
        },
    }

    lib.registerContext({
        id = 'taxi_actions_mobile',
        title = TranslateCap('taxi'),
        options = options,
    })

    lib.showContext("taxi_actions_mobile")
end

function IsInAuthorizedVehicle()
    local playerPed = PlayerPedId()
    local vehModel = GetEntityModel(GetVehiclePedIsIn(playerPed, false))

    for i = 1, #Config.AuthorizedVehicles, 1 do
        if Config.AuthorizedVehicles[i].model and vehModel == joaat(Config.AuthorizedVehicles[i].model) then
            return true
        end
    end

    return false
end

AddEventHandler('esx_taxijob:hasEnteredMarker', function(zone)
    if zone == 'VehicleSpawner' then
        CurrentAction = 'vehicle_spawner'
        CurrentActionMsg = TranslateCap('spawner_prompt')
        CurrentActionData = {}
    elseif zone == 'VehicleDeleter' then
        local playerPed = PlayerPedId()
        local vehicle = GetVehiclePedIsIn(playerPed, false)

        if IsPedInAnyVehicle(playerPed, false) and GetPedInVehicleSeat(vehicle, -1) == playerPed then
            CurrentAction = 'delete_vehicle'
            CurrentActionMsg = TranslateCap('store_veh')
            CurrentActionData = {
                vehicle = vehicle
            }
        end
    elseif zone == 'TaxiActions' then
        CurrentAction = 'taxi_actions_menu'
        CurrentActionMsg = TranslateCap('press_to_open')
        CurrentActionData = {}

    elseif zone == 'Cloakroom' then
        CurrentAction = 'cloakroom'
        CurrentActionMsg = TranslateCap('cloakroom_prompt')
        CurrentActionData = {}
    end
end)

AddEventHandler('esx_taxijob:hasExitedMarker', function(zone)
    lib.hideContext(true)
    CurrentAction = nil
end)

-- Create Blips
CreateThread(function()
    local blip = AddBlipForCoord(Config.Zones.TaxiActions.Pos.x, Config.Zones.TaxiActions.Pos.y,
        Config.Zones.TaxiActions.Pos.z)

    SetBlipSprite(blip, 198)
    SetBlipDisplay(blip, 4)
    SetBlipScale(blip, 1.0)
    SetBlipColour(blip, 5)
    SetBlipAsShortRange(blip, true)

    BeginTextCommandSetBlipName('STRING')
    AddTextComponentSubstringPlayerName(TranslateCap('blip_taxi'))
    EndTextCommandSetBlipName(blip)
end)

-- Enter / Exit marker events, and draw markers
CreateThread(function()
    while true do
        local sleep = 1500
        if ESX.PlayerData.job and ESX.PlayerData.job.name == 'taxi' then

            local coords = GetEntityCoords(PlayerPedId())
            local isInMarker, currentZone = false

            for k, v in pairs(Config.Zones) do
                local zonePos = vector3(v.Pos.x, v.Pos.y, v.Pos.z)
                local distance = #(coords - zonePos)

                if v.Type ~= -1 and distance < Config.DrawDistance then
                    sleep = 0
                    DrawMarker(v.Type, v.Pos.x, v.Pos.y, v.Pos.z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, v.Size.x, v.Size.y,
                        v.Size.z, v.Color.r, v.Color.g, v.Color.b, 100, false, false, 2, v.Rotate, nil, nil, false)
                end

                if distance < v.Size.x then
                    isInMarker, currentZone = true, k
                end
            end

            if (isInMarker and not HasAlreadyEnteredMarker) or (isInMarker and LastZone ~= currentZone) then
                HasAlreadyEnteredMarker, LastZone = true, currentZone
                TriggerEvent('esx_taxijob:hasEnteredMarker', currentZone)
            end

            if not isInMarker and HasAlreadyEnteredMarker then
                HasAlreadyEnteredMarker = false
                TriggerEvent('esx_taxijob:hasExitedMarker', LastZone)
            end
        end
        Wait(sleep)
    end
end)


-- Key Controls
CreateThread(function()
    while true do
        local sleep = 1500
        if CurrentAction and not ESX.PlayerData.dead then
            sleep = 0
            ESX.ShowHelpNotification(CurrentActionMsg)

            if IsControlJustReleased(0, 38) and ESX.PlayerData.job and ESX.PlayerData.job.name == 'taxi' then
                if CurrentAction == 'taxi_actions_menu' then
                    OpenTaxiActionsMenu()
                elseif CurrentAction == 'cloakroom' then
                    OpenCloakroom()
                elseif CurrentAction == 'vehicle_spawner' then
                    OpenVehicleSpawnerMenu()
                elseif CurrentAction == 'delete_vehicle' then
                    DeleteJobVehicle()
                end

                CurrentAction = nil
            end
        end
        Wait(sleep)
    end
end)

RegisterCommand('taximenu', function()
    if not ESX.PlayerData.dead and Config.EnablePlayerManagement and ESX.PlayerData.job and ESX.PlayerData.job.name == 'taxi' then
        OpenMobileTaxiActionsMenu()
    end
end, false)

RegisterKeyMapping('taximenu', 'Open Taxi Menu', 'keyboard', 'f6')
