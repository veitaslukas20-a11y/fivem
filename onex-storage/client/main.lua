lib.locale()

local ox_inventory = exports.ox_inventory
local NearPoint = false

local function ShowNotification(text, type)
    exports['1x-hud']:sendNotification({
        type = type,
        title = 'Sandėliai',
        message = locale(text),
        duration = 5000,
        icon = 'box-open'
    })
end

local function DrawText3D(coords, text, customEntry)
    local str = text

    if customEntry ~= nil then
        AddTextEntry(customEntry, str)
        BeginTextCommandDisplayHelp(customEntry)
    else
        AddTextEntry(GetCurrentResourceName(), str)
        BeginTextCommandDisplayHelp(GetCurrentResourceName())
    end
    EndTextCommandDisplayHelp(2, false, false, -1)

    SetFloatingHelpTextWorldPosition(1, coords)
    SetFloatingHelpTextStyle(2, 2, -1, 3, 0)
end

local function InitWarehouses()
    for i = 1, #Config.Warehouses do
        local Warehouse = Config.Warehouses[i]

        blip = AddBlipForCoord(Warehouse.pos.x, Warehouse.pos.y, Warehouse.pos.z)
        SetBlipSprite(blip, 478)
        SetBlipDisplay(blip, 4)
        SetBlipScale(blip, 0.6)
        SetBlipColour(blip, 47)
        SetBlipAsShortRange(blip, true)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString("<font face='Roboto'>Sandėlis</font>")
        EndTextCommandSetBlipName(blip)

        local Point = lib.points.new({
            coords = Warehouse.pos,
            distance = 2
        })

        function Point:nearby()
            DrawText3D(self.coords, "~INPUT_PICKUP~ Sandelis")
        end

        function Point:onEnter()
            NearPoint = Warehouse
        end
         
        function Point:onExit()
            NearPoint = false
        end
    end
end

CreateThread(function()
    while not ESX.IsPlayerLoaded() do Wait(500) end
    InitWarehouses()
end)

local function OpenStorageInformation(id, data)
    local Options = {
        {
            title = 'Atidaryti sandėlį',
            description = 'Spustelėkite norėdami atidaryti sandėlį',
            icon = 'fa-solid fa-box-open',
            onSelect = function()
                local notify = lib.callback.await('onex-storages:openStorage', false, data.id)
                if notify ~= true then 
                    ShowNotification(notify, 'ERROR')
                end
            end
        },
        {
            title = 'Parduokite sandėlį',
            description = 'Spustelėkite norėdami parduoti sandėlį',
            icon = 'fa-solid fa-trash',
            onSelect = function()
                local alert = lib.alertDialog({
                    header = 'Patvirtinkite',
                    content = string.format('Aš esu įsitikinęs, kad noriu parduoti %s sandėlį už %s€?', data.id, math.floor(data.price * 0.7)),
                    centered = true,
                    cancel = true
                })
                if alert == 'confirm' then
                    local notify = lib.callback.await('onex-storage:sell', false, data.id)
                    if notify ~= true then 
                        ShowNotification(notify, 'ERROR')
                    else 
                        ShowNotification('sold_warehouse', 'SUCCESS')
                    end
                else 
                    lib.showContext('storages_info')
                end
            end
        }
    }

    lib.registerContext({
        id = 'storages_info',
        menu = 'storages_self',
        title = string.format('#%s Sandėlys', data.id),
        options = Options,
    })

    lib.showContext('storages_info')
end

local function OpenMyStorages()
    local storages = lib.callback.await('onex-storages:getSelfStorages', false)
    local Options = {}

    if #storages == 0 then
        table.insert(Options, {
            title = 'Neturite jokių nuosavų sandėlių',
            description = 'Deja, tačiau neturite jokių sandėlių, kuriuos jūs būtumėte įsigijęs',
            icon = 'fa-solid fa-dolly',
            disabled = true,
        })
    else 
        for k, v in pairs(storages) do 
            table.insert(Options, {
                title = string.format('#%s Sandėlys', v.id),
                description = string.format('Spustelėkite norėdami atidaryti sandėlio #%s informaciją', v.id),
                icon = 'fa-solid fa-box',
                onSelect = function()
                    OpenStorageInformation(k, v)
                end,
                metadata = {
                    {
                        label = 'Tipas',
                        value = locale(v.type..'_storage'),
                    }
                }
            })
        end
    end

    lib.registerContext({
        id = 'storages_self',
        menu = 'storages_main',
        title = 'Jūsų sandėliai',
        options = Options,
    })

    lib.showContext('storages_self')
end

local function OpenStoragesShop()
    local prices = lib.callback.await('onex-storages:getPrices', false)
    local Options = {}

    for k,v in pairs(prices) do 
        table.insert(Options, {
            title = locale(v.type..'_storage'),
            description = string.format('Pirkite šį sandėlį už %s€. Sandėlio svoris: %skg', v.price, Config.Storages[v.type].weight),
            icon = 'fa-solid fa-boxes-stacked',
            onSelect = function()
                local alert = lib.alertDialog({
                    header = 'Patvirtinkite',
                    content = string.format('Aš esu įsitikinęs, kad noriu pirkti %s už %s€.', locale(v.type..'_storage'), v.price),
                    centered = true,
                    cancel = true
                })
                if alert == 'confirm' then
                    local notify, type = lib.callback.await('onex-storage:purchase', false, v.type)
                    ShowNotification(notify, type)
                end
            end
        })
    end

    lib.registerContext({
        id = 'storages_shop',
        menu = 'storages_main',
        title = 'Sandėlių parduotuvė',
        options = Options,
    })

    lib.showContext('storages_shop')
end

RegisterKeyMapping("openwarehouse", "Atidaryti sandeli", "keyboard", "E")
RegisterCommand("openwarehouse", function()
    if not NearPoint then return end
    local data = lib.callback.await('onex-storage:getData', false, NearPoint.requiredVIP)
    if data ~= true then
        return ShowNotification(data, 'ERROR')
    end

    lib.registerContext({
        id = 'storages_main',
        title = 'Sandėliai',
        options = {
            {
                title = 'Peržiūrėti turimus sandėlius',
                description = 'Peržiūrėkite savo turimus sandėlius',
                icon = 'fa-solid fa-box-open',
                onSelect = function()
                    OpenMyStorages()
                end,
            },
            {
                title = 'Nusipirkti daugiau sandėlių',
                description = 'Peržiūrėti šiuo metu parduodamus sandėlius',
                icon = 'fa-solid fa-parachute-box',
                onSelect = function()
                    OpenStoragesShop()
                end,
            },
        }
    })

    lib.showContext('storages_main')
end)