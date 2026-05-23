
local Fuel = {
    isFueling = false,
    lastVehicle = cache.vehicle or GetVehiclePedIsIn(PlayerPedId(), false),
    currentStationId = nil
}

CreateThread(function()
    if Config.Debug.showBlips and Config.FuelBlips then
        for _, b in ipairs(Config.FuelBlips) do
            local blip = AddBlipForCoord(b.coords.x, b.coords.y, b.coords.z)
            SetBlipSprite(blip, b.sprite or 361)
            SetBlipColour(blip, b.color or 46)
            SetBlipScale(blip, 0.8)
            SetBlipAsShortRange(blip, true)
            BeginTextCommandSetBlipName('STRING')
            AddTextComponentString(b.label or 'Degalinė')
            EndTextCommandSetBlipName(blip)
        end
    end
end)

RegisterNetEvent('FuelManager:UpdateFuel', function(liters, itemName)
    local veh = cache.vehicle or GetVehiclePedIsIn(PlayerPedId(), false)
    if not veh or not DoesEntityExist(veh) then return end
    local state = Entity(veh).state
    local cur = state.fuel or 0
    local new = math.min(100.0, cur + (tonumber(liters) or 0))
    state:set('fuel', new, true)
end)

local function addTargets()
    for _, model in ipairs(Config.FuelPumpProps) do
        exports.ox_target:addModel(model, {
            {
                name = 'onex_fuel_open',
                label = 'Degalinė',
                icon = 'fa-solid fa-gas-pump',
                distance = 2.0,
                onSelect = function(entity)
                    local ped = PlayerPedId()
                    local veh = cache.vehicle or GetVehiclePedIsIn(ped, false)
                    if (not veh or veh == 0) then
                        local coords = GetEntityCoords(ped)
                        veh = GetClosestVehicle(coords.x, coords.y, coords.z, 6.0, 0, 70)
                    end
                    if not veh or veh == 0 then
                        lib.notify({ title='Degalinė', description='Nėra transporto priemonės netoliese (iki 6m).', type='error' })
                        return
                    end
                    Fuel.lastVehicle = veh

                    local pedCoords = GetEntityCoords(ped)
                    local nearest, dist = nil, 9999.0
                    for i, s in ipairs(Config.FuelBlips) do
                        local d = #(vector3(s.coords.x, s.coords.y, s.coords.z) - pedCoords)
                        if d < dist then nearest=i dist=d end
                    end
                    Fuel.currentStationId = nearest

                    SetNuiFocus(true, true)
                    SendNUIMessage({ action = 'setVisible', data = { visible = true }})

                    -- Kainos/likučiai į UI
                    lib.callback('FuelManager:GetFuelStock', false, function(stock)
                        SendNUIMessage({ action = 'setFuelData', data = {
                            regularPrice = stock.regularCost or Config.FuelSystem.RegularFuelPrice,
                            premiumPrice = stock.premiumCost or Config.FuelSystem.PremiumFuelPrice,
                            stockRegular = stock.regular or 0,
                            stockPremium = stock.premium or 0
                        }})
                    end, Fuel.currentStationId)
                end
            }
        })
    end
end

CreateThread(function()
    Wait(500)
    addTargets()
end)

RegisterNetEvent('FuelManager:UpdateFuel', function(liters, itemName)
    local veh = Fuel.lastVehicle
    if not veh or not DoesEntityExist(veh) then return end
    local state = Entity(veh).state
    local cur = state.fuel or 0
    local new = math.min(100.0, cur + (tonumber(liters) or 0))
    state:set('fuel', new, true)
end)

RegisterNUICallback('closeUI', function(_, cb)
    SetNuiFocus(false, false)
    -- paslėpti UI per NUI (užtikrinimui)
    SendNUIMessage({ action = 'setVisible', data = { visible = false }})
    cb({ ok = true })
end)

_G.FuelManager = Fuel
