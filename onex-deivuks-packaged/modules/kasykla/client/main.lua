local Ped
local Config, Stones, StoneCount = {}, {}, 0

local Target = exports.ox_target

local Buying = false
local function OpenMenu()
    if #(cache.coords - vec3(Config.NPC.coords.x, Config.NPC.coords.y, Config.NPC.coords.z)) > 3.0 then return end 

    lib.registerContext({
        id = 's1m1s_kasykla',
        title = 'Skaldakasys Jonas',
        menu = 's1m1s_kasykla',
        options = {
            {
                title = 'Nusipirkti kirtiklį',
                description = 'Nusipirkti kirtiklį už 1500€, su kuriuo galėsite kirsti akmenis',
                icon = 'fa-solid fa-gem',
                iconColor = '#fff',
                onSelect = function()
                    if Buying then return end
                    Buying = true 
                    local result = lib.callback.await('d-kasykla:buyPickaxe', false)
                    if not result then 
                        Buying = false
                        exports['1x-hud']:sendNotification({
                            type = 'ERROR',
                            title = 'Kasykla',
                            message = 'Neturite pakankamai pinigų banke arba neturite vietos inventoriuje.',
                            duration = 6000,
                            icon = 'gem'
                        })
                    else 
                        Buying = false
                    end
                end,
            },
            {
                title = 'Parduoti iškasenas',
                description = 'Pereiti prie iškasenų pardavimo',
                icon = 'fa-solid fa-gem',
                iconColor = '#fff',
                onSelect = function()
                    OpenSelling()
                end,
            },
        }
    })
    lib.showContext('s1m1s_kasykla')
end

local function CreateLocalPed()
    if not Ped then
        RequestModel(`ig_joeminuteman`)
        while not HasModelLoaded(`ig_joeminuteman`) do
            Wait(100)
        end
        local coords = Config.NPC.coords
        Ped = CreatePed(4, `ig_joeminuteman`, coords.x, coords.y, coords.z -1.0, coords.w, false, true)
        FreezeEntityPosition(Ped, true)
        SetEntityInvincible(Ped, true)
        SetBlockingOfNonTemporaryEvents(Ped, true)
        NetworkFadeInEntity(Ped, true, true)
        
        Target:addLocalEntity(Ped, {
            {
                label = 'Kalbėtis su skaldakasiu',
                icon = "fa-solid fa-gem",
                onSelect = function()
                    OpenMenu()
                end,
                distance = 2.0,
            },
        })
    end
end

Citizen.CreateThread(function()
    while not ESX.IsPlayerLoaded() do 
        Wait(500)
    end
    
    Config = lib.callback.await('d-kasykla:getConfig', false)  

    local blip = AddBlipForCoord(Config.NPC.coords)
    SetBlipSprite(blip, 527)
    SetBlipColour(blip, 0)
	SetBlipScale(blip, 0.6)
    SetBlipAsShortRange(blip, true)
    BeginTextCommandSetBlipName("STRING")
	AddTextComponentString('<font face="Roboto">Kasykla</font>')
    EndTextCommandSetBlipName(blip)

    local point = lib.points.new({
        coords = Config.Zone,
        distance = 100,
    })
     
    function point:onEnter()
        SpawnStones()
        CreateLocalPed()
    end
     
    function point:onExit()
        DeleteStones()
        if Ped then 
            Target:removeLocalEntity(Ped)
            DeletePed(Ped)
            Ped = nil
        end
    end
end)

function SpawnStones()
    if StoneCount ~= #Config.Stones then 
        for k,v in pairs(Config.Stones) do 
            ESX.Game.SpawnLocalObject('prop_rock_2_a', vec3(v.x, v.y, v.z -1.0), function(obj)
                FreezeEntityPosition(obj, true)

                Target:addLocalEntity(obj, {
                    {
                        name = 'kasykla:stone',
                        icon = "fa-solid fa-gem",
                        label = 'Kirsti akmenį',
                        canInteract = function()
                            return not IsEntityDead(cache.ped) or GetEntityHealth(cache.ped) ~= 0
                        end,
                        onSelect = function()
                            local count = exports.ox_inventory:Search('count', 'pickaxe')

                            if count and count > 0 then 
                                Stone(obj, k)
                            else
                                exports['1x-hud']:sendNotification({
                                    type = 'ERROR',
                                    title = 'Skaldykla',
                                    message = 'Neturite kirtiklio, įsigyk jį pas skaldakasį.',
                                    duration = 6000,
                                    icon = 'gem'
                                })
                            end
                        end,
                        distance = 2.0,
                    }
                })

                StoneCount += 1
                table.insert(Stones, obj)
            end)
        end
    end
end

function DeleteStones()
    for i=1, StoneCount do 
        ESX.Game.DeleteObject(Stones[i])
        Target:removeLocalEntity(Stones[i])
    end
    StoneCount = 0
end

local Kerta = false
local Pickaxe
local function PlayMinimage(success)
    if success then
        local dict, clip = 'melee@large_wpn@streamed_core', 'ground_attack_on_spot'
        lib.requestAnimDict(dict, 10000)
        TaskPlayAnim(cache.ped, dict, clip, 8.0, 8.0, -1, 80, 0, false, false, false)
        RemoveAnimDict(dict)
        Wait(1000)
        return true
    else
        DetachEntity(Pickaxe, true, true)
        DeleteEntity(Pickaxe)
        FreezeEntityPosition(cache.ped, false)
        Pickaxe = nil
        Kerta = false
        return false
    end
end

function Stone(obj, UID)
    if Kerta then return end
    if #(cache.coords - GetEntityCoords(obj)) > 3.0 then return end

    Kerta = true

    Wait(300)
    local types = {{areaSize = 60, speedMultiplier = 1.65}, {areaSize = 50, speedMultiplier = 1}, {areaSize = 60, speedMultiplier = 1.25}, {areaSize = 70, speedMultiplier = 1.5}}
    math.randomseed(GetGameTimer())

    FreezeEntityPosition(cache.ped, true)

    lib.requestModel('prop_tool_pickaxe', 10000)
    Pickaxe = CreateObject(`prop_tool_pickaxe`, 0, 0, 0, true, true, true) 
    SetModelAsNoLongerNeeded(`prop_tool_pickaxe`)

    while not DoesEntityExist(Pickaxe) do 
        Wait(100)
    end

    AttachEntityToEntity(Pickaxe, cache.ped, GetPedBoneIndex(cache.ped, 57005), 0.18, -0.02, -0.02, 350.0, 100.00, 140.0, true, true, false, true, 1, true)

    local success = lib.skillCheck({types[math.random(#types)]})
    if not PlayMinimage(success) then return false end

    local success = lib.skillCheck({types[math.random(#types)]})
    if not PlayMinimage(success) then return false end

    local success = lib.skillCheck({types[math.random(#types)]})
    if not PlayMinimage(success) then return false end

    local await = lib.callback.await('d-kasykla:addItem', false, UID)
    if await or not await then
        Wait(1000)
        DetachEntity(Pickaxe, true, true)
        DeleteEntity(Pickaxe)
        FreezeEntityPosition(cache.ped, false)
        Pickaxe = nil
        Kerta = false
    end

    if not await then 
        exports['1x-hud']:sendNotification({
            type = 'ERROR',
            title = 'Kasykla',
            message = 'Deja, neturite pakankamai vietos inventoriuje, kad galėtumėte tęsti kasybą.',
            duration = 6000,
            icon = 'gem'
        })
    end
end

local Selling = false
function OpenSelling()
    if Selling then return end 
    lib.registerContext({
        id = 's1m1s_kasykla',
        title = 'Skaldakasys Jonas',
        menu = 's1m1s_kasykla',
        options = {
            {
                title = 'Parduoti auksą',
                description = 'Parduoti iškastą auksą už '..Config.Prices.gold..'€',
                icon = 'fa-solid fa-coins',
                iconColor = '#fff',
                onSelect = function()
                    SellGoods('gold')
                end,
            },
            {
                title = 'Parduoti deimantus',
                description = 'Parduoti iškastus deimantus už '..Config.Prices.diamond..'€',
                icon = 'fa-solid fa-coins',
                iconColor = '#fff',
                onSelect = function()
                    SellGoods('diamond')
                end,
            },
            {
                title = 'Parduoti geležį',
                description = 'Parduoti iškastą geležį už '..Config.Prices.iron..'€',
                icon = 'fa-solid fa-cubes',
                iconColor = '#fff',
                onSelect = function()
                    SellGoods('iron')
                end,
            },
            {
                title = 'Parduoti varį',
                description = 'Parduoti iškastą varį už '..Config.Prices.copper..'€',
                icon = 'fa-solid fa-cubes',
                iconColor = '#fff',
                onSelect = function()
                    SellGoods('copper')
                end,
            },
        }
    })
    lib.showContext('s1m1s_kasykla')
end

function SellGoods(item)
    local result = lib.callback.await('d-kasykla:sell', false, item)
    if result ~= false then 
        Selling = false

        exports['1x-hud']:sendNotification({
            type = 'SUCCESS',
            title = 'Kasykla',
            message = 'Pardavėte iškasenas už '..result..'€. Pinigus gavote bankiniu pavedimu.',
            duration = 6000,
            icon = 'gem'
        })

        return
    end 

    Selling = false
    exports['1x-hud']:sendNotification({
        type = 'ERROR',
        title = 'Kasykla',
        message = 'Neturite pakankamai iškasenų, kad galėtumėte jas parduoti.',
        duration = 6000,
        icon = 'gem'
    })
end

AddEventHandler('onResourceStop', function(resourceName)
    if (GetCurrentResourceName() == resourceName) then
        DeleteStones()
    end
end)