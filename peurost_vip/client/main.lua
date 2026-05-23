function OpenMenu()
    local data = lib.callback.await("peurost_vip:GetVIPData")
    if not data then
        return
    end

    local options = {
        {
            title = 'Jūsų VIP lygis: '..data.level,
            readOnly = true,
            icon = "crown"
        },
    }

    if data.vehiclePlates.state then
        options[#options + 1] = {
            title = 'Tr. priemonės numerio pakeitimas',
            description = "Galimas",
            icon = "car-rear",
            onSelect = function()
                if not IsPedInAnyVehicle(PlayerPedId(), false) then
                    lib.notify({
                        title = 'VIP',
                        description = 'Turi sedėti tr. priemonėje kurios numerius nori pakeisti',
                        type = 'error'
                    })
                    return
                end

                local pVeh = GetVehiclePedIsIn(PlayerPedId(), false)

                local input = lib.inputDialog('Tr. priemonės numerių keitimas', {
                    {type = 'input', label = 'Nauji valstybiniai numeriai', description = 'Įveskite norimus naujus valstybinius numerius', required = true, min = 1, max = 8},
                })
 
                if not input or not input[1] or #input[1] < 1 or #input[1] > 8 then
                    lib.notify({
                        title = 'VIP',
                        description = 'Neteisinga įvestis, bandykite dar kartą!',
                        type = 'error'
                    })
                    return 
                end

                local alpha = string.find(input[1], '[žūųšįėęčąŽŪŲŠĮĖĘČĄ]')
                local specials = string.find(input[1], '[%p%c%s]')
                if alpha or specials then
                    lib.notify({
                        title = 'VIP',
                        description = 'Neteisinga įvestis, bandykite dar kartą!',
                        type = 'error'
                    })
                    return 
                end

                local result = lib.callback.await("peurost_vip:ChangeVehiclePlates", false, GetVehicleNumberPlateText(pVeh), input[1])

                if not result.state then
                    lib.notify({
                        title = 'VIP',
                        description = result.message,
                        type = 'error'
                    })
                    return
                end

                SetVehicleNumberPlateText(pVeh, input[1])
                TriggerServerEvent('carkeys:RequestVehicleLock', VehToNet(pVeh), GetVehicleDoorLockStatus(pVeh), GetVehicleClass(pVeh))

                lib.notify({
                    title = 'VIP',
                    description = result.message,
                    type = 'success'
                })
            end
        }
    else
        options[#options + 1] = {
            title = 'Tr. priemonės numerio pakeitimas',
            description = GenerateTimeLeft(data.vehiclePlates.timeLeft),
            readOnly = true,
            icon = "car-rear"
        }
    end

    if data.kit then
        if data.kit.state then
            options[#options + 1] = {
                title = 'Daiktų rinkinukas',
                description = "Galimas",
                icon = "gift",
                onSelect = function()
                    local result = lib.callback.await("peurost_vip:ClaimKit", false)
                    if not result.state then
                        lib.notify({
                            title = 'VIP',
                            description = result.message,
                            type = 'error'
                        })
                        return
                    end

                    lib.notify({
                        title = 'VIP',
                        description = result.message,
                        type = 'success'
                    })
                end
            }
        else
            options[#options + 1] = {
                title = 'Daiktų rinkinukas',
                description = GenerateTimeLeft(data.kit.timeLeft),
                disabled = true,
                readOnly = true,
                icon = "gift"
            }
        end
    end

    if data.inventory then 
        if data.inventory.state then
            options[#options + 1] = {
                title = 'Inventoriaus padidinimas',
                description = "Neatsiimtas",
                icon = "gift",
                onSelect = function()
                    local result = lib.callback.await("peurost_vip:ClaimInventory", false)
                    if not result.state then
                        lib.notify({
                            title = 'VIP',
                            description = result.message,
                            type = 'error'
                        })
                        return
                    end

                    lib.notify({
                        title = 'VIP',
                        description = result.message,
                        type = 'success'
                    })
                end
            }
        else
            options[#options + 1] = {
                title = 'Inventoriaus padidinimas',
                description = "Atsiimta",
                readOnly = true,
                disabled = true,
                icon = "gift"
            }
        end
    end

    if data.discounts then 
        if data.discounts.state then
            options[#options + 1] = {
                title = 'Frakcijų sąskaitų nuolaidos',
                description = "Neatsiimtas",
                icon = "gift",
                onSelect = function()
                    local result = lib.callback.await("peurost_vip:ClaimDiscounts", false)
                    if not result.state then
                        lib.notify({
                            title = 'VIP',
                            description = result.message,
                            type = 'error'
                        })
                        return
                    end

                    lib.notify({
                        title = 'VIP',
                        description = result.message,
                        type = 'success'
                    })
                end
            }
        else
            options[#options + 1] = {
                title = 'Frakcijų sąskaitų nuolaidos',
                description = "Atsiimta",
                disabled = true,
                readOnly = true,
                icon = "gift"
            }
        end
    end

    if data.vehicle then
        options[#options + 1] = {
            title = 'Importiniai automobiliai',
            description = data.vehicle.state and "Peržiūrėti automobilių sąrašą" or GenerateTimeLeft(data.vehicle.timeLeft),
            icon = "car",
            disabled = not data.vehicle.state,
            onSelect = function()
                OpenImports()
            end
        }
    end

    lib.registerContext({
        id = 'vip_menu',
        title = 'VIP Meniu',
        options = options,
    })
     
    lib.showContext('vip_menu')
end

RegisterCommand("vipmeniu", function()
    OpenMenu()
end)

function GenerateTimeLeft(time)
    local days = math.floor(time / 86400)
    local hours = math.floor((time % 86400) / 3600)
    local minutes = math.floor((time % 3600) / 60)

    local formattedTime = ""
    if days > 0 then
        formattedTime = formattedTime .. string.format("%d d. ", days)
    end

    if hours > 0 then
        formattedTime = formattedTime .. string.format("%d h. ", hours)
    end

    formattedTime = formattedTime .. string.format("%d min.", minutes)
    return formattedTime
end

function OpenImports()
    local Options = {}
    for k,v in pairs(Config.Vehicles) do 
        Options[k] = {
            title = v.name,
            description = 'Automobilio kaina '..v.price..'€.',
            icon = "car",
            onSelect = function()
                local alert = lib.alertDialog({
                    header = 'Esu įsitikinęs,',
                    content = 'kad noriu pirkti '..v.name..' automobilį už '..v.price..'€.',
                    centered = true,
                    cancel = true,
                    labels = {
                        confirm = 'Taip',
                        cancel = 'Ne',
                    }
                })

                if alert == 'confirm' then
                    lib.callback.await('vipmenu:buyVehicle', false, k) 
                else 
                    lib.showContext('vip_vehicles')
                end
            end
        }
    end

    lib.registerContext({
        id = 'vip_vehicles',
        menu = 'vip_menu',
        title = 'VIP Automobilių sąrašas',
        options = Options
    })
     
    lib.showContext('vip_vehicles')
end

lib.callback.register('vipmenu:getProperties', function(props)
    lib.requestModel(props.model, 5000)

    local vehicle = CreateVehicle(props.model, GetEntityCoords(cache.ped), GetEntityHeading(cache.ped), false, true)

    SetEntityVisible(vehicle, false, 0)
    SetEntityCollision(vehicle, false, false)
    FreezeEntityPosition(vehicle, true)

    props = exports['s1m1s-garagev3']:GetVehicleProperties(vehicle)

    props.plate = exports['s1m1s-vehicleshop']:generatePlate('Land')

    while DoesEntityExist(vehicle) do
        DeleteEntity(vehicle)
        DeleteVehicle(vehicle)
        Wait(100)
    end

    return props
end)

local vipLevel = 0
RegisterNetEvent('vipmenu:setLevel', function(level)
    if GetInvokingResource() ~= nil then return end
    vipLevel = level
end)

exports('getLevel', function()
    return vipLevel
end)