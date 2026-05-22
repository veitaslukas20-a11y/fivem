local lastSkin = nil
local isMenuOpened = false
local handsup = false
local gender = nil

local storeIsIn = nil

if Config.Core == "ESX" then
    ESX = Config.CoreExport()
elseif Config.Core == "QB-Core" then
    QBCore = Config.CoreExport()

    AddEventHandler('qb-menu:client:menuClosed', function()
        isMenuOpened = false
        if Config.UseQSInventory then
            exports[Config.QSInventoryName]:setInClothing(false)
        end
    end)
end

Citizen.CreateThread(function()
    Citizen.Wait(250)
    if Config.Menu == "ox_lib" then
        local import = LoadResourceFile('ox_lib', 'init.lua')
        local chunk = assert(load(import, '@@ox_lib/init.lua'))
        chunk()
    end
end)

RegisterNUICallback('buyClothes', function(data)
    if Config.Core == "ESX" then
        ESX.TriggerServerCallback('vms_clothestore:payForClothes', function(callback) 
            if callback then
                DeleteSkinCam()
                TriggerEvent('skinchanger:getSkin', function(skin)
                    if Config.SkinManager == "esx_skin" then
                        TriggerServerEvent('esx_skin:save', skin)
                    elseif Config.SkinManager == "fivem-appearance" then
                        TriggerEvent('fivem-appearance:setOutfit', Character_AP)
			            TriggerServerEvent('fivem-appearance:save', Character_AP)
                    elseif Config.SkinManager == "illenium-appearance" then
                        TriggerServerEvent('illenium-appearance:server:saveAppearance', Character_AP)
                    end
                    openSaveMenu()
                end)
                if Config.SoundsEffects then
                    PlaySoundFrontend(-1, 'PURCHASE', 'HUD_LIQUOR_STORE_SOUNDSET', 1)
                end
            else
                if Config.SoundsEffects then
                    PlaySoundFrontend(-1, 'ERROR', 'HUD_LIQUOR_STORE_SOUNDSET', 1)
                end
            end
        end, data.price, data.type)
    elseif Config.Core == "QB-Core" then
        QBCore.Functions.TriggerCallback('vms_clothestore:payForClothes', function(callback)
            if callback then
                DeleteSkinCam()
                if Config.SkinManager == 'qb-clothing' then
                    local model = GetEntityModel(PlayerPedId())
                    local character_encode = json.encode(Character_QB)
                    TriggerServerEvent("qb-clothing:saveSkin", model, character_encode)
                    openSaveMenu()
                elseif Config.SkinManager == "fivem-appearance" or Config.SkinManager == "illenium-appearance" then
                    local playerPed = PlayerPedId()
                    local appearance = exports[Config.SkinManager]:getPedAppearance(playerPed)
                    TriggerServerEvent(Config.SkinManager..':server:saveAppearance', appearance)
                    openSaveMenu()
                end
                if Config.SoundsEffects then
                    PlaySoundFrontend(-1, 'PURCHASE', 'HUD_LIQUOR_STORE_SOUNDSET', 1)
                end
            else
                if Config.SoundsEffects then
                    PlaySoundFrontend(-1, 'ERROR', 'HUD_LIQUOR_STORE_SOUNDSET', 1)
                end
            end
        end, data.price, data.type)
    end
end)

RegisterNUICallback('cancelClothes', function(data)
    if Config.Core == "ESX" then
        TriggerEvent('skinchanger:loadSkin', lastSkin)
    elseif Config.Core == "QB-Core" then
        if Config.SkinManager == "fivem-appearance" or Config.SkinManager == "illenium-appearance" then
            TriggerEvent(Config.SkinManager..':client:reloadSkin')
        elseif Config.SkinManager == "qb-clothing" then
            TriggerServerEvent("qb-clothes:loadPlayerSkin")
            TriggerServerEvent("qb-clothing:loadPlayerSkin")
        end
    end
    DeleteSkinCam()
end)

RegisterNUICallback("openBill", function(data)
    local shouldOpen = false
    local currentValue = data.currentValue
    local receipt = {}
    local receiptTotal = 0

    local playerGender = GetEntityModel(PlayerPedId()) == GetHashKey('mp_m_freemode_01') and 'male' or 'female'
    for k, v in pairs(currentValue) do
        if v.newValue ~= v.value then
            if (Config.PricesForIdsSpecificStores[storeIsIn] and Config.PricesForIdsSpecificStores[storeIsIn][playerGender][k] and Config.PricesForIdsSpecificStores[storeIsIn][playerGender][k] and Config.PricesForIdsSpecificStores[storeIsIn][playerGender][k][tostring(v.newValue)] ~= nil) then
                receipt[k] = Config.PricesForIdsSpecificStores[storeIsIn][playerGender][k][tostring(v.newValue)]
                
            elseif (Config.PricesForComponentSpecificStores[storeIsIn] and Config.PricesForComponentSpecificStores[storeIsIn][playerGender] and Config.PricesForComponentSpecificStores[storeIsIn][playerGender][k] ~= nil) then
                receipt[k] = Config.PricesForComponentSpecificStores[storeIsIn][playerGender][k]
                
            elseif (Config.PricesForIds and Config.PricesForIds[playerGender] and Config.PricesForIds[playerGender][k] and Config.PricesForIds[playerGender][k][tostring(v.newValue)] ~= nil) then
                receipt[k] = Config.PricesForIds[playerGender][k][tostring(v.newValue)]
                
            elseif (Config.PricesForComponent[k] ~= nil) then
                receipt[k] = Config.PricesForComponent[k]
                
            else
                receipt[k] = Config.DefaultPrice

            end
            receiptTotal = receiptTotal + receipt[k]
            shouldOpen = true
        end
    end
    if shouldOpen then
        SendNUIMessage({
            action = 'openReceipt',
            receipt = receipt,
            receiptTotal = receiptTotal
        })
    else
        if Config.Core == "ESX" then
            TriggerEvent('skinchanger:loadSkin', lastSkin)
        elseif Config.Core == "QB-Core" then
            if Config.SkinManager == "fivem-appearance" or Config.SkinManager == "illenium-appearance" then
                TriggerEvent(Config.SkinManager..':client:reloadSkin')
            elseif Config.SkinManager == "qb-clothing" then
                TriggerServerEvent("qb-clothes:loadPlayerSkin")
                TriggerServerEvent("qb-clothing:loadPlayerSkin")
            end
        end
        DeleteSkinCam()
    end
end)

RegisterNUICallback("change", function(data)
    Character_ESX[data.type] = data.new
    if Config.Core == "ESX" then
        if Config.SkinManager == "esx_skin" then
            TriggerEvent('skinchanger:change', data.type, data.new)
        elseif Config.SkinManager == "fivem-appearance" or Config.SkinManager == "illenium-appearance" then
            appearance_switcher(data.type, data.new)
        end
    elseif Config.Core == "QB-Core" then
        if Config.SkinManager == "qb-clothing" then
            qbcore_switcher(data.type, data.new)
        elseif Config.SkinManager == "fivem-appearance" or Config.SkinManager == "illenium-appearance" then
            appearance_switcher(data.type, data.new)
        end
    end
    local secondItem, secondValue = GetMaxVal(data.type)
    if secondItem and secondValue then
        SendNUIMessage({
            action = 'updateSecondValue',
            mainItem = data.type,
            mainValue = data.new,
            secondItem = secondItem,
            secondValue = secondValue
        })
        if Config.Core == "ESX" then
            if Config.SkinManager == "esx_skin" then
                TriggerEvent('skinchanger:change', secondItem, 0)
            elseif Config.SkinManager == "fivem-appearance" or Config.SkinManager == "illenium-appearance" then
                appearance_switcher(secondItem, 0)
            end
        elseif Config.Core == "QB-Core" then
            if Config.SkinManager == "qb-clothing" then
                qbcore_switcher(secondItem, 0)
            elseif Config.SkinManager == "fivem-appearance" or Config.SkinManager == "illenium-appearance" then
                appearance_switcher(secondItem, 0)
            end
        end
    end
    if Config.SoundsEffects then
        PlaySoundFrontend(-1, "NAV_LEFT_RIGHT", "HUD_FRONTEND_DEFAULT_SOUNDSET", true)
    end
end)

RegisterNUICallback("hands_up", function(data)
    local myPed = PlayerPedId()
    if handsup then
        ClearPedTasksImmediately(myPed)
        RequestAnimDict(Config.ClothingPedAnimation[1])
        while not HasAnimDictLoaded(Config.ClothingPedAnimation[1]) do
            Wait(1)
        end
        TaskPlayAnim(myPed, Config.ClothingPedAnimation[1], Config.ClothingPedAnimation[2], 8.0, 0.0, -1, 1, 0, 0, 0, 0)
        handsup = false
    elseif not handsup then
        RequestAnimDict(Config.HandsUpAnimation[1])
        while not HasAnimDictLoaded(Config.HandsUpAnimation[1]) do
            Wait(1)
        end
        TaskPlayAnim(myPed, Config.HandsUpAnimation[1], Config.HandsUpAnimation[2], 8.0, 0.0, -1, Config.HandsUpAnimation[3], 0, 0, 0, 0)
        handsup = true
    end
end)

RegisterNetEvent('vms_clothestore:receiveRequestOutfit')
AddEventHandler('vms_clothestore:receiveRequestOutfit', function(playerRequester, outfitTable)
    if Config.UseCustomQuestionMenu then
        Config.CustomQuestionMenu(playerRequester, outfitTable.label, outfitTable)
    else
        if Config.Menu == "esx_context" then
            local elements = {
                {unselectable = true, title = Config.PriceForAcceptOutfit and Config.PriceForAcceptOutfit >= 1 and (Config.Translate['title_share'].name):format(outfitTable.label, Config.PriceForAcceptOutfit) or (Config.Translate['title_share_free'].name):format(outfitTable.label), icon = Config.Translate['title_share'].icon},
                {title = Config.Translate['share_accept'].name, icon = Config.Translate['share_accept'].icon, value = "yes"},
                {title = Config.Translate['share_reject'].name, icon = Config.Translate['share_reject'].icon, value = "no"}
            }
            ESX.OpenContext(Config.ESXContext_Align, elements, function(menu2, element2)
                if element2.value == "yes" then
                    TriggerServerEvent("vms_clothestore:acceptOutfit", playerRequester, outfitTable.label, outfitTable)
                end
                ESX.CloseContext()
                isMenuOpened = false
            end, function(menu)
                isMenuOpened = false
            end)
        elseif Config.Menu == "esx_menu_default" then
            local elements = {
                {icon = Config.Translate['share_accept'].icon, label = Config.Translate['share_accept'].name, value = "yes"},
                {icon = Config.Translate['share_reject'].icon, label = Config.Translate['share_reject'].name, value = "no"}
            }
            ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'select_option2', {
                title = Config.PriceForAcceptOutfit and Config.PriceForAcceptOutfit >= 1 and (Config.Translate['title_share'].name):format(outfitTable.label, Config.PriceForAcceptOutfit) or (Config.Translate['title_share_free'].name):format(outfitTable.label), 
                elements = elements, 
                align = Config.ESXMenuDefault_Align
            }, function(data2, menu2)
                if data2.current.value == "yes" then
                    TriggerServerEvent("vms_clothestore:acceptOutfit", playerRequester, outfitTable.label, outfitTable)
                    menu2.close()
                    isMenuOpened = false
                else
                    menu2.close()
                    isMenuOpened = false
                end
            end, function(data2, menu2)
                menu2.close()
                isMenuOpened = false
            end)
        elseif Config.Menu == "qb-menu" then
            local elements = {
                {
                    header = Config.PriceForAcceptOutfit and Config.PriceForAcceptOutfit >= 1 and (Config.Translate['title_share'].name):format(outfitTable.label, Config.PriceForAcceptOutfit) or (Config.Translate['title_share_free'].name):format(outfitTable.label),
                    icon = Config.Translate['title_share'].icon,
                    isMenuHeader = true,
                },
                {
                    header = Config.Translate['share_accept'].name,
                    icon = Config.Translate['share_accept'].icon,
                    params = {
                        isAction = true,
                        event = function()
                            TriggerServerEvent("vms_clothestore:acceptOutfit", playerRequester, outfitTable.label, outfitTable)
                            isMenuOpened = false
                        end
                    }
                },
                {
                    header = Config.Translate['share_reject'].name,
                    icon = Config.Translate['share_reject'].icon,
                    params = {
                        isAction = true,
                        event = function()
                            isMenuOpened = false
                        end
                    }
                },
            }
            exports['qb-menu']:openMenu(elements)
        elseif Config.Menu == "ox_lib" then
            local elements = {
                {
                    icon = Config.Translate['remove_yes'].icon,
                    title = Config.Translate['remove_yes'].name, 
                    onSelect = function()
                        TriggerServerEvent("vms_clothestore:acceptOutfit", playerRequester, outfitTable.label, outfitTable)
                        isMenuOpened = false
                    end,
                    onExit = function()
                        isMenuOpened = false
                    end
                },
                {
                    icon = Config.Translate['remove_no'].icon,
                    title = Config.Translate['remove_no'].name, 
                    onSelect = function()
                        isMenuOpened = false
                    end,
                    onExit = function()
                        isMenuOpened = false
                    end
                },
            }
            lib.registerContext({
                id = "clothestore-shareaccept",
                title = Config.PriceForAcceptOutfit and Config.PriceForAcceptOutfit >= 1 and (Config.Translate['title_share'].name):format(outfitTable.label, Config.PriceForAcceptOutfit) or (Config.Translate['title_share_free'].name):format(outfitTable.label),
                options = elements,
                onExit = function()
                    isMenuOpened = false
                end
            })
            lib.showContext('clothestore-shareaccept')
        end
    end
end)

function OpenShare()
    if Config.Core == "ESX" then
        if Config.Menu == "esx_context" then
            ESX.TriggerServerCallback("vms_clothestore:getPlayerDressing", function(dressing)
                local elements = {
                    {unselectable = true, icon = Config.Translate['share_header'].icon, title = Config.Translate['share_header'].name}
                }
                if Config.SkinManager == "esx_skin" then
                    for i = 1, #dressing, 1 do
                        elements[#elements + 1] = {title = dressing[i].label, label = dressing[i].label, skin = dressing[i].skin}
                    end
                elseif Config.SkinManager == "fivem-appearance" then
                    for i = 1, #dressing, 1 do
                        elements[#elements + 1] = {title = dressing[i].name, label = dressing[i].name, ped = dressing[i].ped, components = dressing[i].components, props = dressing[i].props}
                    end
                elseif Config.SkinManager == "illenium-appearance" then
                    for i = 1, #dressing, 1 do
                        elements[#elements + 1] = {title = dressing[i].outfitname, label = dressing[i].outfitname, model = dressing[i].model, components = dressing[i].components, props = dressing[i].props}
                    end
                end
                local playerInArea = Config.GetClosestPlayersFunction()
                if not playerInArea then
                    isMenuOpened = false
                    Config.Notification(Config.Translate['no_players_around'], 3000, 'error')
                    return
                end
                ESX.OpenContext(Config.ESXContext_Align, elements, function(menu, element)
                    local selectedOutfit = element
                    local elements2 = {
                        {unselectable = true, title = (Config.Translate['share_outfit_to_player'].name):format(selectedOutfit.label), icon = Config.Translate['share_outfit_to_player'].icon},
                    }
                    for k, v in pairs(playerInArea) do
                        elements2[#elements2 + 1] = {title = (Config.Translate['share_outfit_to_player_id']):format(GetPlayerServerId(v)), playerid = GetPlayerServerId(v)}
                    end
                    ESX.OpenContext(Config.ESXContext_Align, elements2, function(menu2, element2)
                        if element2.playerid then
                            TriggerServerEvent('vms_clothestore:sendOutfit', element2.playerid, selectedOutfit)
                            ESX.CloseContext()
                            isMenuOpened = false
                        end
                    end, function(menu)
                        isMenuOpened = false
                    end)
                end, function(menu)
                    isMenuOpened = false
                end)
            end)
        elseif Config.Menu == "esx_menu_default" then
           ESX.TriggerServerCallback("vms_clothestore:getPlayerDressing", function(dressing)
               local elements = {}
               if Config.SkinManager == "esx_skin" then
                   for i = 1, #dressing, 1 do
                       elements[#elements + 1] = {label = dressing[i].label, skin = dressing[i].skin}
                   end
               elseif Config.SkinManager == "fivem-appearance" then
                   for i = 1, #dressing, 1 do
                       elements[#elements + 1] = {label = dressing[i].name, ped = dressing[i].ped, components = dressing[i].components, props = dressing[i].props}
                   end
                elseif Config.SkinManager == "illenium-appearance" then
                    for i = 1, #dressing, 1 do
                        elements[#elements + 1] = {label = dressing[i].outfitname, model = dressing[i].model, components = dressing[i].components, props = dressing[i].props}
                    end
                end
                local playerInArea = Config.GetClosestPlayersFunction()
                if not playerInArea then
                    isMenuOpened = false
                    Config.Notification(Config.Translate['no_players_around'], 3000, 'error')
                    return
                end
                ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'select_option', {
                    title = Config.Translate['share_header'].name, 
                    elements = elements, 
                    align = Config.ESXMenuDefault_Align
                }, function(data, menu)
                    local selectedOutfit = data.current
                    if selectedOutfit.label then
                        local elements2 = {}
                        for k, v in pairs(playerInArea) do
                            elements2[#elements2 + 1] = {label = Config.Translate['share_outfit_to_player_id']:format(GetPlayerServerId(v)), playerid = GetPlayerServerId(v)}
                        end
                        ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'select_option2', {
                            title = (Config.Translate['share_outfit_to_player'].name):format(selectedOutfit.label), 
                            elements = elements2, 
                            align = Config.ESXMenuDefault_Align
                        }, function(data2, menu2)
                            if data2.current.playerid then
                                TriggerServerEvent('vms_clothestore:sendOutfit', data2.current.playerid, selectedOutfit)
                                menu2.close()
                                isMenuOpened = false
                            end
                        end, function(data2, menu2)
                            menu2.close()
                            isMenuOpened = false
                        end)
                        menu.close()
                    end
                end, function(data, menu)
                    isMenuOpened = false
                    menu.close()
                end)
            end)
        elseif Config.Menu == "ox_lib" then
            ESX.TriggerServerCallback("vms_clothestore:getPlayerDressing", function(dressing)
                local elements = {}
                for i = 1, #dressing, 1 do
                    dressing[i].label = Config.SkinManager == "esx_skin" and dressing[i].label or Config.SkinManager == "fivem-appearance" and dressing[i].name or Config.SkinManager == "illenium-appearance" and dressing[i].outfitname
                    elements[#elements + 1] = {
                        title = dressing[i].label, 
                        onSelect = function()
                            local playerInArea = Config.GetClosestPlayersFunction()
                            if not playerInArea then
                                isMenuOpened = false
                                Config.Notification(Config.Translate['no_players_around'], 3000, 'error')
                                return
                            end
                            local elements2 = {}
                            for k, v in pairs(playerInArea) do
                                elements2[#elements2 + 1] = {
                                    title = Config.Translate['share_outfit_to_player_id']:format(GetPlayerServerId(v)),
                                    onSelect = function()
                                        TriggerServerEvent('vms_clothestore:sendOutfit', GetPlayerServerId(v), dressing[i])
                                        isMenuOpened = false
                                    end,
                                    onExit = function()
                                        isMenuOpened = false
                                    end
                                }
                            end
                            lib.registerContext({
                                id = "clothestore-shareclothe",
                                title = (Config.Translate['share_outfit_to_player'].name):format(dressing[i].label),
                                options = elements2,
                                onExit = function()
                                    isMenuOpened = false
                                end
                            })
                            lib.showContext('clothestore-shareclothe')
                        end,
                        onExit = function()
                            isMenuOpened = false
                        end
                    }
                end
                lib.registerContext({
                    id = "clothestore-share",
                    title = Config.Translate['share_header'].name,
                    options = elements,
                    onExit = function()
                        isMenuOpened = false
                    end
                })
                lib.showContext('clothestore-share')
            end)
        end
    elseif Config.Core == "QB-Core" then
        if Config.Menu == "qb-menu" then
            QBCore.Functions.TriggerCallback(Config.SkinManager == "qb-clothing" and 'qb-clothing:server:getOutfits' or 'vms_clothestore:getPlayerDressing', function(result)
                local elements = {
                    {
                        isMenuHeader = true,
                        header = Config.Translate['share_header'].name,
                        icon = Config.Translate['share_header'].icon,
                    }
                }
                for k, v in pairs(result) do
                    elements[#elements+1] = {
                        header = v.outfitname,
                        params = {
                            isAction = true,
                            event = function()
                                local playerInArea = Config.GetClosestPlayersFunction()
                                if not playerInArea then
                                    isMenuOpened = false
                                    Config.Notification(Config.Translate['no_players_around'], 3000, 'error')
                                    return
                                end
                                local elements2 = {
                                    {
                                        header = (Config.Translate['share_outfit_to_player'].name):format(v.outfitname),
                                        icon = Config.Translate['share_outfit_to_player'].icon,
                                        isMenuHeader = true,
                                    },
                                }
                                v.label = v.outfitname
                                for _k, _v in pairs(playerInArea) do
                                    if GetPlayerServerId(_v) ~= GetPlayerServerId(PlayerId()) then
                                        elements2[#elements2 + 1] = {
                                            header = Config.Translate['share_outfit_to_player_id']:format(GetPlayerServerId(_v)),
                                            params = {
                                                isAction = true,
                                                event = function()
                                                    TriggerServerEvent('vms_clothestore:sendOutfit', GetPlayerServerId(_v), v)
                                                    isMenuOpened = false
                                                end
                                            },
                                        }
                                    end
                                end
                                exports['qb-menu']:openMenu(elements2)
                            end,
                        }
                    }
                end
                exports['qb-menu']:openMenu(elements)
            end)
        elseif Config.Menu == "ox_lib" then
            QBCore.Functions.TriggerCallback(Config.SkinManager == "qb-clothing" and 'qb-clothing:server:getOutfits' or 'vms_clothestore:getPlayerDressing', function(result)
                local elements = {}
                for k, v in pairs(result) do
                    v.label = v.outfitname
                    elements[#elements + 1] = {
                        title = v.label, 
                        onSelect = function()
                            local playerInArea = Config.GetClosestPlayersFunction()
                            if not playerInArea then
                                isMenuOpened = false
                                Config.Notification(Config.Translate['no_players_around'], 3000, 'error')
                                return
                            end
                            local elements2 = {}
                            for _k, _v in pairs(playerInArea) do
                                if GetPlayerServerId(_v) ~= GetPlayerServerId(PlayerId()) then
                                    elements2[#elements2 + 1] = {
                                        title = Config.Translate['share_outfit_to_player_id']:format(GetPlayerServerId(_v)),
                                        onSelect = function()
                                            TriggerServerEvent('vms_clothestore:sendOutfit', GetPlayerServerId(_v), v)
                                            isMenuOpened = false
                                        end,
                                        onExit = function()
                                            isMenuOpened = false
                                        end
                                    }
                                end
                            end
                            lib.registerContext({
                                id = "clothestore-shareclothe",
                                title = (Config.Translate['share_outfit_to_player'].name):format(v.label),
                                options = elements2,
                                onExit = function()
                                    isMenuOpened = false
                                end
                            })
                            lib.showContext('clothestore-shareclothe')
                        end,
                        onExit = function()
                            isMenuOpened = false
                        end
                    }
                end
                lib.registerContext({
                    id = "clothestore-share",
                    title = Config.Translate['share_header'].name,
                    options = elements,
                    onExit = function()
                        isMenuOpened = false
                    end
                })
                lib.showContext('clothestore-share')
            end)
        end
    end
end

function OpenManage()
    if Config.Core == "ESX" then
        if Config.Menu == "esx_context" then
            ESX.TriggerServerCallback("vms_clothestore:getPlayerDressing", function(dressing)
                local elements = {{unselectable = true, icon = Config.Translate['manage_header'].icon, title = Config.Translate['manage_header'].name}}
                if Config.SkinManager == "esx_skin" then
                    for i = 1, #dressing, 1 do
                        elements[#elements + 1] = {title = dressing[i].label}
                    end
                elseif Config.SkinManager == "fivem-appearance" then
                    for i = 1, #dressing, 1 do
                        elements[#elements + 1] = {title = dressing[i].name}
                    end
                elseif Config.SkinManager == "illenium-appearance" then
                    for i = 1, #dressing, 1 do
                        elements[#elements + 1] = {title = dressing[i].outfitname}
                    end
                end
                ESX.OpenContext(Config.ESXContext_Align, elements, function(menu, element)
                    local elements2 = {
                        {unselectable = true, title = (Config.Translate['title_remove'].name):format(element.title), icon = Config.Translate['title_remove'].icon},
                        {title = Config.Translate['remove_yes'].name, icon = Config.Translate['remove_yes'].icon, value = "yes", id = element.title},
                        {title = Config.Translate['remove_no'].name, icon = Config.Translate['remove_no'].icon, value = "no"}
                    }
                    ESX.OpenContext(Config.ESXContext_Align, elements2, function(menu2, element2)
                        if element2.value == "yes" and element2.id then
                            TriggerServerEvent('vms_clothestore:removeClothe', element2.id)
                            ESX.CloseContext()
                        else
                            OpenManage()
                        end
                    end, function(menu)
                        isMenuOpened = false
                    end)
                end, function(menu)
                    isMenuOpened = false
                end)
            end)
        elseif Config.Menu == "esx_menu_default" then
           ESX.TriggerServerCallback("vms_clothestore:getPlayerDressing", function(dressing)
               local elements = {}
               if Config.SkinManager == "esx_skin" then
                   for i = 1, #dressing, 1 do
                       elements[#elements + 1] = {label = dressing[i].label}
                   end
               elseif Config.SkinManager == "fivem-appearance" then
                   for i = 1, #dressing, 1 do
                       elements[#elements + 1] = {label = dressing[i].name}
                   end
                elseif Config.SkinManager == "illenium-appearance" then
                    for i = 1, #dressing, 1 do
                        elements[#elements + 1] = {label = dressing[i].outfitname}
                    end
                end
                ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'select_option', {
                    title = Config.Translate['manage_header'].name, 
                    elements = elements, 
                    align = Config.ESXMenuDefault_Align
                }, function(data, menu)
                    if data.current.label then
                        local elements2 = {
                            {label = Config.Translate['remove_yes'].name, value = "yes", id = data.current.label},
                            {label = Config.Translate['remove_no'].name, value = "no"}
                        }
                        ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'select_option2', {
                            title = (Config.Translate['title_remove'].name):format(data.current.label), 
                            elements = elements2, 
                            align = Config.ESXMenuDefault_Align
                        }, function(data2, menu2)
                            if data2.current.value == "yes" and data2.current.id then
                                TriggerServerEvent('vms_clothestore:removeClothe', data2.current.id)
                                menu2.close()
                                isMenuOpened = false
                            else
                                menu2.close()
                                OpenManage()
                            end
                        end, function(data2, menu2)
                            menu2.close()
                            isMenuOpened = false
                        end)
                        menu.close()
                    end
                end, function(data, menu)
                    isMenuOpened = false
                    menu.close()
                end)
            end)
        elseif Config.Menu == "ox_lib" then
            ESX.TriggerServerCallback("vms_clothestore:getPlayerDressing", function(dressing)
                local elements = {}
                if Config.SkinManager == "esx_skin" then
                    for i = 1, #dressing, 1 do
                        elements[#elements + 1] = {
                            title = dressing[i].label, 
                            onSelect = function()
                                local elements2 = {
                                    {
                                        icon = Config.Translate['remove_yes'].icon,
                                        title = Config.Translate['remove_yes'].name, 
                                        onSelect = function()
                                            TriggerServerEvent('vms_clothestore:removeClothe', dressing[i].label)
                                            isMenuOpened = false
                                        end,
                                        onExit = function()
                                            isMenuOpened = false
                                        end
                                    },
                                    {
                                        icon = Config.Translate['remove_no'].icon,
                                        title = Config.Translate['remove_no'].name, 
                                        onSelect = function()
                                            OpenManage()
                                        end,
                                        onExit = function()
                                            isMenuOpened = false
                                        end
                                    },
                                }
                                lib.registerContext({
                                    id = "clothestore-manageclothe",
                                    title = (Config.Translate['title_remove'].name):format(dressing[i].label),
                                    options = elements2,
                                    onExit = function()
                                        isMenuOpened = false
                                    end
                                })
                                lib.showContext('clothestore-manageclothe')
                            end,
                            onExit = function()
                                isMenuOpened = false
                            end
                        }
                    end
                elseif Config.SkinManager == "fivem-appearance" then
                    for i = 1, #dressing, 1 do
                        elements[#elements + 1] = {
                            title = dressing[i].name, 
                            onSelect = function()
                                local elements2 = {
                                    {
                                        icon = Config.Translate['remove_yes'].icon,
                                        title = Config.Translate['remove_yes'].name, 
                                        onSelect = function()
                                            TriggerServerEvent('vms_clothestore:removeClothe', dressing[i].name)
                                            isMenuOpened = false
                                        end,
                                        onExit = function()
                                            isMenuOpened = false
                                        end
                                    },
                                    {
                                        icon = Config.Translate['remove_no'].icon,
                                        title = Config.Translate['remove_no'].name, 
                                        onSelect = function()
                                            OpenManage()
                                        end,
                                        onExit = function()
                                            isMenuOpened = false
                                        end
                                    },
                                }
                                lib.registerContext({
                                    id = "clothestore-manageclothe",
                                    title = (Config.Translate['title_remove'].name):format(dressing[i].name),
                                    options = elements2,
                                    onExit = function()
                                        isMenuOpened = false
                                    end
                                })
                                lib.showContext('clothestore-manageclothe')
                            end,
                            onExit = function()
                                isMenuOpened = false
                            end
                        }
                    end
                elseif Config.SkinManager == "illenium-appearance" then
                    for i = 1, #dressing, 1 do
                        elements[#elements + 1] = {
                            title = dressing[i].outfitname, 
                            onSelect = function()
                                local elements2 = {
                                    {
                                        icon = Config.Translate['remove_yes'].icon,
                                        title = Config.Translate['remove_yes'].name, 
                                        onSelect = function()
                                            TriggerServerEvent('vms_clothestore:removeClothe', dressing[i].outfitname)
                                            isMenuOpened = false
                                        end,
                                        onExit = function()
                                            isMenuOpened = false
                                        end
                                    },
                                    {
                                        icon = Config.Translate['remove_no'].icon,
                                        title = Config.Translate['remove_no'].name, 
                                        onSelect = function()
                                            OpenManage()
                                        end,
                                        onExit = function()
                                            isMenuOpened = false
                                        end
                                    },
                                }
                                lib.registerContext({
                                    id = "clothestore-manageclothe",
                                    title = (Config.Translate['title_remove'].name):format(dressing[i].outfitname),
                                    options = elements2,
                                    onExit = function()
                                        isMenuOpened = false
                                    end
                                })
                                lib.showContext('clothestore-manageclothe')
                            end,
                            onExit = function()
                                isMenuOpened = false
                            end
                        }
                    end
                end
                lib.registerContext({
                    id = "clothestore-manage",
                    title = Config.Translate['manage_header'].name,
                    options = elements,
                    onExit = function()
                        isMenuOpened = false
                    end
                })
                lib.showContext('clothestore-manage')
            end)
        end
    elseif Config.Core == "QB-Core" then
        if Config.SkinManager == "qb-clothing" then
            if Config.Menu == "qb-menu" then
                QBCore.Functions.TriggerCallback('qb-clothing:server:getOutfits', function(result)
                    local elements = {{
                        header = Config.Translate['manage_header'].name,
                        icon = Config.Translate['manage_header'].icon,
                        isMenuHeader = true,
                    }}
                    for k, v in pairs(result) do
                        elements[#elements+1] = {
                            header = v.outfitname,
                            icon = "fas fa-shirt",
                            params = {
                                isAction = true,
                                event = function()
                                    local elements2 = {
                                        {
                                            header = (Config.Translate['title_remove'].name):format(v.outfitname),
                                            icon = Config.Translate['title_remove'].icon,
                                            isMenuHeader = true,
                                        },
                                        {
                                            header = Config.Translate['remove_yes'].name,
                                            icon = Config.Translate['remove_yes'].icon,
                                            params = {
                                                isAction = true,
                                                event = function()
                                                    TriggerServerEvent('vms_clothestore:removeClothe', v.outfitId)
                                                    isMenuOpened = false
                                                end
                                            }
                                        },
                                        {
                                            header = Config.Translate['remove_no'].name,
                                            icon = Config.Translate['remove_no'].icon,
                                            params = {
                                                isAction = true,
                                                event = function()
                                                    OpenManage()
                                                end
                                            }
                                        },
                                    }
                                    exports['qb-menu']:openMenu(elements2)
                                end,
                            }
                        }
                    end
                    exports['qb-menu']:openMenu(elements)
                end)
            elseif Config.Menu == "ox_lib" then
                QBCore.Functions.TriggerCallback('qb-clothing:server:getOutfits', function(result)
                    local elements = {}
                    for k, v in pairs(result) do
                        elements[#elements + 1] = {
                            title = v.outfitname, 
                            onSelect = function()
                                local elements2 = {
                                    {
                                        icon = Config.Translate['remove_yes'].icon,
                                        title = Config.Translate['remove_yes'].name, 
                                        onSelect = function()
                                            TriggerServerEvent('vms_clothestore:removeClothe', v.outfitId)
                                            isMenuOpened = false
                                        end,
                                        onExit = function()
                                            isMenuOpened = false
                                        end
                                    },
                                    {
                                        icon = Config.Translate['remove_no'].icon,
                                        title = Config.Translate['remove_no'].name, 
                                        onSelect = function()
                                            OpenManage()
                                        end,
                                        onExit = function()
                                            isMenuOpened = false
                                        end
                                    },
                                }
                                lib.registerContext({
                                    id = "clothestore-manageclothe",
                                    title = (Config.Translate['title_remove'].name):format(v.outfitname),
                                    options = elements2,
                                    onExit = function()
                                        isMenuOpened = false
                                    end
                                })
                                lib.showContext('clothestore-manageclothe')
                            end,
                            onExit = function()
                                isMenuOpened = false
                            end
                        }
                    end
                    lib.registerContext({
                        id = "clothestore-manage",
                        title = Config.Translate['manage_header'].name,
                        options = elements,
                        onExit = function()
                            isMenuOpened = false
                        end
                    })
                    lib.showContext('clothestore-manage')
                end)
            end
        elseif Config.SkinManager == "illenium-appearance" then
            if Config.Menu == "qb-menu" then
                QBCore.Functions.TriggerCallback('vms_clothestore:getPlayerDressing', function(result)
                    local elements = {{
                        header = Config.Translate['manage_header'].name,
                        icon = Config.Translate['manage_header'].icon,
                        isMenuHeader = true,
                    }}
                    for k, v in pairs(result) do
                        elements[#elements+1] = {
                            header = v.outfitname,
                            icon = "fas fa-shirt",
                            params = {
                                isAction = true,
                                event = function()
                                    local elements2 = {
                                        {
                                            header = (Config.Translate['title_remove'].name):format(v.outfitname),
                                            icon = Config.Translate['title_remove'].icon,
                                            isMenuHeader = true,
                                        },
                                        {
                                            header = Config.Translate['remove_yes'].name,
                                            icon = Config.Translate['remove_yes'].icon,
                                            params = {
                                                isAction = true,
                                                event = function()
                                                    TriggerServerEvent('vms_clothestore:removeClothe', v.id)
                                                    isMenuOpened = false
                                                end
                                            }
                                        },
                                        {
                                            header = Config.Translate['remove_no'].name,
                                            icon = Config.Translate['remove_no'].icon,
                                            params = {
                                                isAction = true,
                                                event = function()
                                                    OpenManage()
                                                end
                                            }
                                        },
                                    }
                                    exports['qb-menu']:openMenu(elements2)
                                end,
                            }
                        }
                    end
                    exports['qb-menu']:openMenu(elements)
                end)
            elseif Config.Menu == "ox_lib" then
                QBCore.Functions.TriggerCallback('vms_clothestore:getPlayerDressing', function(result)
                    local elements = {}
                    for k, v in pairs(result) do
                        elements[#elements + 1] = {
                            title = v.outfitname, 
                            onSelect = function()
                                local elements2 = {
                                    {
                                        icon = Config.Translate['remove_yes'].icon,
                                        title = Config.Translate['remove_yes'].name, 
                                        onSelect = function()
                                            TriggerServerEvent('vms_clothestore:removeClothe', v.id)
                                            isMenuOpened = false
                                        end,
                                        onExit = function()
                                            isMenuOpened = false
                                        end
                                    },
                                    {
                                        icon = Config.Translate['remove_no'].icon,
                                        title = Config.Translate['remove_no'].name, 
                                        onSelect = function()
                                            OpenManage()
                                        end,
                                        onExit = function()
                                            isMenuOpened = false
                                        end
                                    },
                                }
                                lib.registerContext({
                                    id = "clothestore-manageclothe",
                                    title = (Config.Translate['title_remove'].name):format(v.outfitname),
                                    options = elements2,
                                    onExit = function()
                                        isMenuOpened = false
                                    end
                                })
                                lib.showContext('clothestore-manageclothe')
                            end,
                            onExit = function()
                                isMenuOpened = false
                            end
                        }
                    end
                    lib.registerContext({
                        id = "clothestore-manage",
                        title = Config.Translate['manage_header'].name,
                        options = elements,
                        onExit = function()
                            isMenuOpened = false
                        end
                    })
                    lib.showContext('clothestore-manage')
                end)
            end
        end
    end
end

function OpenWardrobe()
    if Config.UseQSInventory then
        exports[Config.QSInventoryName]:setInClothing(true)
    end
    if Config.Core == "ESX" then
        if Config.Menu == "esx_context" then
            if Config.SkinManager == "esx_skin" then
                ESX.TriggerServerCallback("vms_clothestore:getPlayerDressing", function(dressing)
                    local elements = {{unselectable = true, icon = Config.Translate['wardrobe_header'].icon, title = Config.Translate['wardrobe_header'].name}}
                    for i = 1, #dressing, 1 do
                        elements[#elements + 1] = {title = dressing[i].label, value = i}
                    end
                    ESX.OpenContext(Config.ESXContext_Align, elements, function(menu, element)
                        TriggerEvent("skinchanger:getSkin", function(skin)
                            ESX.TriggerServerCallback("vms_clothestore:getPlayerOutfit", function(clothes)
                                TriggerEvent("skinchanger:loadClothes", skin, clothes)
                                TriggerEvent("esx_skin:setLastSkin", skin)
                                TriggerEvent('skinchanger:getSkin', function(skin)
                                    TriggerServerEvent('esx_skin:save', skin)
                                end)
                            end, element.value)
                        end)
                    end, function(menu)
                        isMenuOpened = false
                        if Config.UseQSInventory then
                            exports[Config.QSInventoryName]:setInClothing(false)
                        end
                    end)
                end)
            elseif Config.SkinManager == "fivem-appearance" then
                ESX.TriggerServerCallback("vms_clothestore:getPlayerDressing", function(dressing)
                    local elements = {{unselectable = true, icon = Config.Translate['wardrobe_header'].icon, title = Config.Translate['wardrobe_header'].name}}
                    for i = 1, #dressing, 1 do
                        elements[#elements + 1] = {
                            title = dressing[i].name, 
                            value = {
                                ped = dressing[i].ped,
                                components = dressing[i].components,
                                props = dressing[i].props
                            }
                        }
                    end
                    ESX.OpenContext(Config.ESXContext_Align, elements, function(menu, element)
                        TriggerEvent('fivem-appearance:setOutfit', element.value)
                    end, function(menu)
                        isMenuOpened = false
                        if Config.UseQSInventory then
                            exports[Config.QSInventoryName]:setInClothing(false)
                        end
                    end)
                end)
            elseif Config.SkinManager == "illenium-appearance" then
                ESX.TriggerServerCallback("vms_clothestore:getPlayerDressing", function(dressing)
                    local elements = {{unselectable = true, icon = Config.Translate['wardrobe_header'].icon, title = Config.Translate['wardrobe_header'].name}}
                    for i = 1, #dressing, 1 do
                        elements[#elements + 1] = {
                            title = dressing[i].outfitname, 
                            value = {
                                model = dressing[i].model,
                                components = dressing[i].components,
                                props = dressing[i].props
                            }
                        }
                    end
                    ESX.OpenContext(Config.ESXContext_Align, elements, function(menu, element)
                        TriggerEvent('illenium-appearance:client:changeOutfit', element.value)
                    end, function(menu)
                        isMenuOpened = false
                        if Config.UseQSInventory then
                            exports[Config.QSInventoryName]:setInClothing(false)
                        end
                    end)
                end)
            end
        elseif Config.Menu == "esx_menu_default" then
            if Config.SkinManager == "esx_skin" then
                ESX.TriggerServerCallback("vms_clothestore:getPlayerDressing", function(dressing)
                    local elements = {}
                    for i = 1, #dressing, 1 do
                        elements[#elements + 1] = {label = dressing[i].label, value = i}
                    end
                    ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'select_option', {title = Config.Translate['wardrobe_header'].name, elements = elements, align = Config.ESXMenuDefault_Align}, function(data, menu)
                        if data.current.value then
                            TriggerEvent("skinchanger:getSkin", function(skin)
                                ESX.TriggerServerCallback("vms_clothestore:getPlayerOutfit", function(clothes)
                                    TriggerEvent("skinchanger:loadClothes", skin, clothes)
                                    TriggerEvent("esx_skin:setLastSkin", skin)
                                    TriggerEvent('skinchanger:getSkin', function(skin)
                                        TriggerServerEvent('esx_skin:save', skin)
                                    end)
                                end, data.current.value) 
                            end)
                        end
                    end, function(data, menu)
                        isMenuOpened = false
                        if Config.UseQSInventory then
                            exports[Config.QSInventoryName]:setInClothing(false)
                        end
                        menu.close()
                    end)
                end)
            elseif Config.SkinManager == "fivem-appearance" then
                ESX.TriggerServerCallback("vms_clothestore:getPlayerDressing", function(dressing)
                    local elements = {}
                    for i = 1, #dressing, 1 do
                        elements[#elements + 1] = {
                            label = dressing[i].name, 
                            value = {
                                ped = dressing[i].ped,
                                components = dressing[i].components,
                                props = dressing[i].props
                            }
                        }
                    end
                    ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'select_option', {title = Config.Translate['wardrobe_header'].name, elements = elements, align = Config.ESXMenuDefault_Align}, function(data, menu)
                        if data.current.value then
                            TriggerEvent('fivem-appearance:setOutfit', data.current.value)
                        end
                    end, function(data, menu)
                        isMenuOpened = false
                        if Config.UseQSInventory then
                            exports[Config.QSInventoryName]:setInClothing(false)
                        end
                        menu.close()
                    end)
                end)
            elseif Config.SkinManager == "illenium-appearance" then
                ESX.TriggerServerCallback("vms_clothestore:getPlayerDressing", function(dressing)
                    local elements = {}
                    for i = 1, #dressing, 1 do
                        elements[#elements + 1] = {
                            label = dressing[i].outfitname, 
                            value = {
                                model = dressing[i].model,
                                components = dressing[i].components,
                                props = dressing[i].props
                            }
                        }
                    end
                    ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'select_option', {title = Config.Translate['wardrobe_header'].name, elements = elements, align = Config.ESXMenuDefault_Align}, function(data, menu)
                        if data.current.value then
                            TriggerEvent('illenium-appearance:client:changeOutfit', data.current.value)
                        end
                    end, function(data, menu)
                        isMenuOpened = false
                        if Config.UseQSInventory then
                            exports[Config.QSInventoryName]:setInClothing(false)
                        end
                        menu.close()
                    end)
                end)
            end
        elseif Config.Menu == "ox_lib" then
            local elements = {}
            if Config.SkinManager == "esx_skin" then
                ESX.TriggerServerCallback("vms_clothestore:getPlayerDressing", function(dressing)
                    for i = 1, #dressing, 1 do
                        elements[#elements + 1] = {
                            title = dressing[i].label, 
                            onSelect = function()
                                TriggerEvent("skinchanger:getSkin", function(skin)
                                    ESX.TriggerServerCallback("vms_clothestore:getPlayerOutfit", function(clothes)
                                        TriggerEvent("skinchanger:loadClothes", skin, clothes)
                                        TriggerEvent("esx_skin:setLastSkin", skin)
                                        TriggerEvent('skinchanger:getSkin', function(skin)
                                            TriggerServerEvent('esx_skin:save', skin)
                                        end)
                                        if Config.UseQSInventory then
                                            exports[Config.QSInventoryName]:setInClothing(false)
                                        end
                                        isMenuOpened = false
                                    end, i)
                                end)
                            end,
                            onExit = function()
                                if Config.UseQSInventory then
                                    exports[Config.QSInventoryName]:setInClothing(false)
                                end
                                isMenuOpened = false
                            end
                        }
                    end
                    lib.registerContext({
                        id = "clothestore-wardrobe",
                        title = Config.Translate['wardrobe_header'].name,
                        options = elements,
                        onExit = function()
                            if Config.UseQSInventory then
                                exports[Config.QSInventoryName]:setInClothing(false)
                            end
                            isMenuOpened = false
                        end
                    })
                    lib.showContext('clothestore-wardrobe')
                end)
            elseif Config.SkinManager == "fivem-appearance" then
                ESX.TriggerServerCallback("vms_clothestore:getPlayerDressing", function(dressing)
                    for i = 1, #dressing, 1 do
                        elements[#elements + 1] = {
                            title = dressing[i].name, 
                            onSelect = function()
                                TriggerEvent('fivem-appearance:setOutfit', {
                                    ped = dressing[i].ped,
                                    components = dressing[i].components,
                                    props = dressing[i].props
                                })
                                if Config.UseQSInventory then
                                    exports[Config.QSInventoryName]:setInClothing(false)
                                end
                                isMenuOpened = false
                            end,
                            onExit = function()
                                if Config.UseQSInventory then
                                    exports[Config.QSInventoryName]:setInClothing(false)
                                end
                                isMenuOpened = false
                            end
                        }
                    end
                    lib.registerContext({
                        id = "clothestore-wardrobe",
                        title = Config.Translate['wardrobe_header'].name,
                        options = elements,
                        onExit = function()
                            if Config.UseQSInventory then
                                exports[Config.QSInventoryName]:setInClothing(false)
                            end
                            isMenuOpened = false
                        end
                    })
                    lib.showContext('clothestore-wardrobe')
                end)
            elseif Config.SkinManager == "illenium-appearance" then
                ESX.TriggerServerCallback("vms_clothestore:getPlayerDressing", function(dressing)
                    for i = 1, #dressing, 1 do
                        elements[#elements + 1] = {
                            title = dressing[i].outfitname, 
                            onSelect = function()
                                TriggerEvent('illenium-appearance:client:changeOutfit', {
                                    model = dressing[i].model,
                                    components = dressing[i].components,
                                    props = dressing[i].props
                                })
                                if Config.UseQSInventory then
                                    exports[Config.QSInventoryName]:setInClothing(false)
                                end
                                isMenuOpened = false
                            end,
                            onExit = function()
                                if Config.UseQSInventory then
                                    exports[Config.QSInventoryName]:setInClothing(false)
                                end
                                isMenuOpened = false
                            end
                        }
                    end
                    lib.registerContext({
                        id = "clothestore-wardrobe",
                        title = Config.Translate['wardrobe_header'].name,
                        options = elements,
                        onExit = function()
                            if Config.UseQSInventory then
                                exports[Config.QSInventoryName]:setInClothing(false)
                            end
                            isMenuOpened = false
                        end
                    })
                    lib.showContext('clothestore-wardrobe')
                end)
            end
        end
    elseif Config.Core == "QB-Core" then
        if Config.Menu == "qb-menu" then
            if Config.SkinManager == "fivem-appearance" then
                TriggerEvent('qb-clothing:client:openOutfitMenu')
                isMenuOpened = false
                if Config.UseQSInventory then
                    exports[Config.QSInventoryName]:setInClothing(false)
                end
            elseif Config.SkinManager == "qb-clothing" then
                QBCore.Functions.TriggerCallback('qb-clothing:server:getOutfits', function(result)
                    local elements = {
                        {
                            header = Config.Translate['select_option'].name,
                            icon = Config.Translate['select_option'].icon,
                            isMenuHeader = true,
                        },
                    }
                    for k, v in pairs(result) do
                        elements[#elements+1] = {
                            header = v.outfitname,
                            icon = "fas fa-shirt",
                            params = {
                                isAction = true,
                                event = function()
                                    local skinToSave = v.skin
                                    TriggerEvent('qb-clothing:client:loadOutfit', { outfitData = v.skin, outfitId = v.outfitId })
                                    QBCore.Functions.TriggerCallback('vms_clothestore:getCurrentSkin', function(skin)
                                        local currentSkin = json.decode(skin)
                                        local valuesToSkip = {
                                            ['t-shirt'] = true, ['torso2'] = true,  ['arms'] = true,        ['pants'] = true,
                                            ['shoes'] = true,   ['bag'] = true,     ['hat'] = true,         ['mask'] = true,
                                            ['glass'] = true,   ['watch'] = true,   ['bracelet'] = true,    ['decals'] = true,
                                            ['vest'] = true,    ['ear'] = true,     ['accessory'] = true
                                        }
                                        if currentSkin then
                                            for k, v in pairs(currentSkin) do
                                                if not valuesToSkip[k] then
                                                    skinToSave[k] = currentSkin[k]
                                                end
                                            end
                                            TriggerServerEvent("qb-clothing:saveSkin", GetEntityModel(PlayerPedId()), json.encode(skinToSave))
                                        end
                                    end)
                                    if Config.UseQSInventory then
                                        exports[Config.QSInventoryName]:setInClothing(false)
                                    end
                                    isMenuOpened = false
                                end,
                            }
                        }
                    end
                    exports['qb-menu']:openMenu(elements)
                end)
            elseif Config.SkinManager == "illenium-appearance" then
                QBCore.Functions.TriggerCallback('vms_clothestore:getPlayerDressing', function(dressing)
                    local elements = {
                        {
                            header = Config.Translate['select_option'].name,
                            icon = Config.Translate['select_option'].icon,
                            isMenuHeader = true,
                        },
                    }
                    for k, v in pairs(dressing) do
                        local value = {
                            model = v.model,
                            components = v.components,
                            props = v.props
                        }
                        elements[#elements + 1] = {
                            header = v.outfitname, 
                            icon = "fas fa-shirt",
                            params = {
                                isAction = true,
                                event = function()
                                    TriggerEvent('illenium-appearance:client:changeOutfit', value)
                                    if Config.UseQSInventory then
                                        exports[Config.QSInventoryName]:setInClothing(false)
                                    end
                                    isMenuOpened = false
                                end,
                            },
                        }
                    end
                    exports['qb-menu']:openMenu(elements)
                end)
            end
        elseif Config.Menu == "ox_lib" then
            local elements = {}
            if Config.SkinManager == "fivem-appearance" then
                TriggerEvent('qb-clothing:client:openOutfitMenu')
                if Config.UseQSInventory then
                    exports[Config.QSInventoryName]:setInClothing(false)
                end
                isMenuOpened = false
            elseif Config.SkinManager == "qb-clothing" then
                QBCore.Functions.TriggerCallback('qb-clothing:server:getOutfits', function(result)
                    for k, v in pairs(result) do
                        elements[#elements + 1] = {
                            title = v.outfitname, 
                            onSelect = function()
                                local skinToSave = v.skin
                                TriggerEvent('qb-clothing:client:loadOutfit', { outfitData = v.skin, outfitId = v.outfitId })
                                QBCore.Functions.TriggerCallback('vms_clothestore:getCurrentSkin', function(skin)
                                    local currentSkin = json.decode(skin)
                                    local valuesToSkip = {
                                        ['t-shirt'] = true, ['torso2'] = true,  ['arms'] = true,        ['pants'] = true,
                                        ['shoes'] = true,   ['bag'] = true,     ['hat'] = true,         ['mask'] = true,
                                        ['glass'] = true,   ['watch'] = true,   ['bracelet'] = true,    ['decals'] = true,
                                        ['vest'] = true,    ['ear'] = true,     ['accessory'] = true
                                    }
                                    if currentSkin then
                                        for k, v in pairs(currentSkin) do
                                            if not valuesToSkip[k] then
                                                skinToSave[k] = currentSkin[k]
                                            end
                                        end
                                        TriggerServerEvent("qb-clothing:saveSkin", GetEntityModel(PlayerPedId()), json.encode(skinToSave))
                                    end
                                end)
                                if Config.UseQSInventory then
                                    exports[Config.QSInventoryName]:setInClothing(false)
                                end
                                isMenuOpened = false
                            end,
                            onExit = function()
                                if Config.UseQSInventory then
                                    exports[Config.QSInventoryName]:setInClothing(false)
                                end
                                isMenuOpened = false
                            end
                        }
                    end
                    lib.registerContext({
                        id = "clothestore-wardrobe",
                        title = Config.Translate['wardrobe_header'].name,
                        options = elements,
                        onExit = function()
                            if Config.UseQSInventory then
                                exports[Config.QSInventoryName]:setInClothing(false)
                            end
                            isMenuOpened = false
                        end
                    })
                    lib.showContext('clothestore-wardrobe')
                end)
            elseif Config.SkinManager == "illenium-appearance" then
                QBCore.Functions.TriggerCallback('vms_clothestore:getPlayerDressing', function(dressing)
                    for k, v in pairs(dressing) do
                        elements[#elements + 1] = {
                            title = v.outfitname, 
                            onSelect = function()
                                TriggerEvent('illenium-appearance:client:changeOutfit', {
                                    model = v.model,
                                    components = v.components,
                                    props = v.props
                                })
                                if Config.UseQSInventory then
                                    exports[Config.QSInventoryName]:setInClothing(false)
                                end
                                isMenuOpened = false
                            end,
                            onExit = function()
                                if Config.UseQSInventory then
                                    exports[Config.QSInventoryName]:setInClothing(false)
                                end
                                isMenuOpened = false
                            end
                        }
                    end
                    lib.registerContext({
                        id = "clothestore-wardrobe",
                        title = Config.Translate['wardrobe_header'].name,
                        options = elements,
                        onExit = function()
                            if Config.UseQSInventory then
                                exports[Config.QSInventoryName]:setInClothing(false)
                            end
                            isMenuOpened = false
                        end
                    })
                    lib.showContext('clothestore-wardrobe')
                end)
            end
        end
    end
end

function SelectCategory(store, storeId)
    if not Config.ChangeClothes and not Config.ManageClothes and not Config.ShareOutfit then
        OpenClothestore(store, storeId)
        isMenuOpened = true
        return
    end
    if Config.Menu == "esx_context" then
        local elements = {
            {unselectable = true, icon = Config.Translate['select_option'].icon, title = Config.Translate['select_option'].name},
            {icon = Config.Translate['open_store'].icon, title = Config.Translate['open_store'].name, value = "store"}
        }
        if Config.ChangeClothes then
            elements[#elements + 1] = {icon = Config.Translate['open_wardrobe'].icon, title = Config.Translate['open_wardrobe'].name, value = "wardrobe"}
        end
        if Config.ManageClothes then
            elements[#elements + 1] = {icon = Config.Translate['open_manage'].icon, title = Config.Translate['open_manage'].name, value = "manage"}
        end
        if Config.ShareOutfit then
            elements[#elements + 1] = {icon = Config.Translate['open_share'].icon, title = Config.Translate['open_share'].name, value = "share"}
        end
        ESX.OpenContext(Config.ESXContext_Align, elements, function(menu, element)
            if element.value == "wardrobe" then
                ESX.CloseContext()
                OpenWardrobe()
                isMenuOpened = true
            elseif element.value == "store" then
                ESX.CloseContext()
                OpenClothestore(store, storeId)
                isMenuOpened = true
            elseif element.value == "share" then
                ESX.CloseContext()
                OpenShare()
                isMenuOpened = true
            elseif element.value == "manage" then
                ESX.CloseContext()
                OpenManage()
                isMenuOpened = true
            end
        end, function(menu)
            isMenuOpened = false
        end)
    elseif Config.Menu == "esx_menu_default" then
        local elements = {
            {icon = Config.Translate['open_store'].icon, label = Config.Translate['open_store'].name, value = "store"},
        }
        if Config.ChangeClothes then
            elements[#elements + 1] = {icon = Config.Translate['open_wardrobe'].icon, label = Config.Translate['open_wardrobe'].name, value = "wardrobe"}
        end
        if Config.ManageClothes then
            elements[#elements + 1] = {icon = Config.Translate['open_manage'].icon, label = Config.Translate['open_manage'].name, value = "manage"}
        end
        if Config.ShareOutfit then
            elements[#elements + 1] = {icon = Config.Translate['open_share'].icon, label = Config.Translate['open_share'].name, value = "share"}
        end
        ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'select_option', {title = Config.Translate['select_option'].name, elements = elements, align = Config.ESXMenuDefault_Align}, function(data, menu)
            if data.current.value == 'wardrobe' then
                menu.close()
                OpenWardrobe()
                isMenuOpened = true
            elseif data.current.value == 'store' then
                menu.close()
                OpenClothestore(store, storeId)
                isMenuOpened = true
            elseif data.current.value == "share" then
                menu.close()
                OpenShare()
                isMenuOpened = true
            elseif data.current.value == "manage" then
                menu.close()
                OpenManage()
                isMenuOpened = true
            end
        end, function(data, menu)
            isMenuOpened = false
            menu.close()
        end)
    elseif Config.Menu == "qb-menu" then
        if Config.SkinManager == 'qb-clothing' or Config.SkinManager == "illenium-appearance" then
            local elements = {
                {
                    header = Config.Translate['select_option'].name,
                    icon = Config.Translate['select_option'].icon,
                    isMenuHeader = true,
                },
                {
                    header = "",
                    txt = Config.Translate['open_store'].name,
                    icon = Config.Translate['open_store'].icon,
                    params = {
                        isAction = true,
                        event = function()
                            OpenClothestore(store, storeId)
                            isMenuOpened = true
                        end,
                    }
                },
            }
            if Config.ChangeClothes then
                elements[#elements + 1] = {
                    header = "",
                    txt = Config.Translate['open_wardrobe'].name,
                    icon = Config.Translate['open_wardrobe'].icon,
                    params = {
                        isAction = true,
                        event = function()
                            OpenWardrobe()
                            isMenuOpened = true
                        end,
                    }
                }
            end
            if Config.ManageClothes then
                elements[#elements + 1] = {
                    header = "",
                    txt = Config.Translate['open_manage'].name,
                    icon = Config.Translate['open_manage'].icon,
                    params = {
                        isAction = true,
                        event = function()
                            OpenManage()
                            isMenuOpened = true
                        end,
                    }
                }
            end
            if Config.ShareOutfit then
                elements[#elements + 1] = {
                    header = "",
                    txt = Config.Translate['open_share'].name,
                    icon = Config.Translate['open_share'].icon,
                    params = {
                        isAction = true,
                        event = function()
                            OpenShare()
                            isMenuOpened = true
                        end,
                    }
                }
            end
            exports['qb-menu']:openMenu(elements)
        elseif Config.SkinManager == 'fivem-appearance' then
            local elements = {
                {
                    header = Config.Translate['select_option'].name,
                    icon = Config.Translate['select_option'].icon,
                    isMenuHeader = true,
                },
                {
                    header = "",
                    txt = Config.Translate['open_store'].name,
                    icon = Config.Translate['open_store'].icon,
                    params = {
                        isAction = true,
                        event = function()
                            OpenClothestore(store, storeId)
                            isMenuOpened = true
                        end,
                    }
                },
            }
            if Config.ChangeClothes then
                elements[#elements + 1] = {
                    header = "",
                    txt = Config.Translate['open_wardrobe'].name,
                    icon = Config.Translate['open_wardrobe'].icon,
                    params = {
                        isAction = true,
                        event = function()
                            OpenWardrobe()
                            isMenuOpened = true
                        end,
                    }
                }
            end
            if Config.ShareOutfit then
                elements[#elements + 1] = {
                    header = "",
                    txt = Config.Translate['open_share'].name,
                    icon = Config.Translate['open_share'].icon,
                    params = {
                        isAction = true,
                        event = function()
                            OpenShare()
                            isMenuOpened = true
                        end,
                    }
                }
            end
            exports['qb-menu']:openMenu(elements)
        end
    elseif Config.Menu == "ox_lib" then
        local elements = {
            {
                icon = Config.Translate['open_store'].icon, 
                title = Config.Translate['open_store'].name,
                onSelect = function()
                    OpenClothestore(store, storeId)
                    isMenuOpened = true
                end,
                onExit = function()
                    isMenuOpened = false
                end
            },
        }
        if Config.Core == "QB-Core" and Config.SkinManager == 'fivem-appearance' then
            if Config.ChangeClothes then
                elements[#elements + 1] = {
                    icon = Config.Translate['open_wardrobe'].icon, 
                    title = Config.Translate['open_wardrobe'].name,
                    onSelect = function()
                        OpenWardrobe()
                        isMenuOpened = true
                    end,
                    onExit = function()
                        isMenuOpened = false
                    end
                }
            end
            if Config.ShareOutfit then
                elements[#elements + 1] = {
                    icon = Config.Translate['open_share'].icon, 
                    title = Config.Translate['open_share'].name,
                    onSelect = function()
                        OpenShare()
                        isMenuOpened = true
                    end,
                    onExit = function()
                        isMenuOpened = false
                    end
                }
            end
        else
            if Config.ChangeClothes then
                elements[#elements + 1] = {
                    icon = Config.Translate['open_wardrobe'].icon, 
                    title = Config.Translate['open_wardrobe'].name,
                    onSelect = function()
                        OpenWardrobe()
                        isMenuOpened = true
                    end,
                    onExit = function()
                        isMenuOpened = false
                    end
                }
            end
            if Config.ManageClothes then
                elements[#elements + 1] = {
                    icon = Config.Translate['open_manage'].icon, 
                    title = Config.Translate['open_manage'].name,
                    onSelect = function()
                        OpenManage()
                        isMenuOpened = true
                    end,
                    onExit = function()
                        isMenuOpened = false
                    end
                }
            end
            if Config.ShareOutfit then
                elements[#elements + 1] = {
                    icon = Config.Translate['open_share'].icon, 
                    title = Config.Translate['open_share'].name,
                    onSelect = function()
                        OpenShare()
                        isMenuOpened = true
                    end,
                    onExit = function()
                        isMenuOpened = false
                    end
                }
            end
        end
        lib.registerContext({
            id = "clothestore-select",
            title = Config.Translate['select_option'].name,
            options = elements,
            onExit = function()
                isMenuOpened = false
            end
        })
        lib.showContext('clothestore-select')
    end
end

function openSaveMenu()
    if not Config.SaveClothesMenu then
        return
    end
    isMenuOpened = true
    if Config.Core == "ESX" then
        ESX.TriggerServerCallback('vms_clothestore:checkPropertyDataStore', function(foundStore)
            if foundStore then
                if Config.Menu == "esx_context" then
                    local elements = {
                        {unselectable = true, icon = Config.Translate['menu:header'].icon, title = Config.Translate['menu:header'].name},
                        {icon = Config.Translate['menu:yes'].icon, title = Config.Translate['menu:yes'].name, value = "yes"},
                        {icon = Config.Translate['menu:no'].icon, title = Config.Translate['menu:no'].name, value = "no"},
                    }
                    ESX.OpenContext(Config.ESXContext_Align, elements, function(menu, element)
                        if element.value == "yes" then
                            local elements2 = {
                                {unselectable = true, title = Config.Translate['esx_context:title'].name, icon = Config.Translate['esx_context:title'].icon},
                                {title = Config.Translate['esx_context:placeholder_title'], input = true, inputType = "text", inputPlaceholder = Config.Translate['esx_context:placeholder']},
                                {title = Config.Translate['esx_context:confirm'].name, icon = Config.Translate['esx_context:confirm'].icon, value = "confirm"}
                            }
                            ESX.OpenContext(Config.ESXContext_Align, elements2, function(menu2,element2)
                                if not menu2.eles[2].inputValue or string.len(menu2.eles[2].inputValue) < 1 then
                                    return Config.Notification(Config.Translate['name_is_too_short'], 3500, 'error')
                                end
                                if Config.SkinManager == "esx_skin" then
                                    TriggerEvent('skinchanger:getSkin', function(skin)
                                        TriggerServerEvent('vms_clothestore:saveOutfit', menu2.eles[2].inputValue, skin)
                                    end)
                                elseif Config.SkinManager == "fivem-appearance" or Config.SkinManager == "illenium-appearance" then
                                    local playerPed = PlayerPedId()
                                    local pedModel = exports[Config.SkinManager]:getPedModel(playerPed)
                                    local pedComponents = exports[Config.SkinManager]:getPedComponents(playerPed)
                                    local pedProps = exports[Config.SkinManager]:getPedProps(playerPed)
                                    if Config.SkinManager == "fivem-appearance" then
                                        TriggerServerEvent('fivem-appearance:saveOutfit', menu2.eles[2].inputValue, pedModel, pedComponents, pedProps)
                                    elseif Config.SkinManager == "illenium-appearance" then
                                        TriggerServerEvent('illenium-appearance:server:saveOutfit', menu2.eles[2].inputValue, pedModel, pedComponents, pedProps)
                                    end
                                end
                                isMenuOpened = false
                                ESX.CloseContext()
                            end, function(menu2)
                                isMenuOpened = false
                            end)
                        elseif element.value == "no" then
                            isMenuOpened = false
                            ESX.CloseContext()
                        end
                    end, function(menu)
                        isMenuOpened = false
                    end)
                elseif Config.Menu == "esx_menu_default" then
                    local elements = {
                        {label = Config.Translate['menu:yes'].name, value = 'yes'},
                        {label = Config.Translate['menu:no'].name, value = 'no'},
                    }
                    ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'shop', {title = Config.Translate['menu:header'].name, elements = elements, align = Config.ESXMenuDefault_Align}, function(data, menu)
                        if data.current.value == 'yes' then
                            ESX.UI.Menu.Open('dialog', GetCurrentResourceName(), 'input_name', {title = Config.Translate['esx_menu_default:header']}, function(data2, menu2)
                                if not data2.value or string.len(data2.value) < 1 then
                                    return Config.Notification(Config.Translate['name_is_too_short'], 3500, 'error')
                                end
                                if data2.value then
                                    if Config.SkinManager == "esx_skin" then
                                        TriggerEvent('skinchanger:getSkin', function(skin)
                                            TriggerServerEvent('vms_clothestore:saveOutfit', data2.value, skin)
                                        end)
                                    elseif Config.SkinManager == "fivem-appearance" or Config.SkinManager == "illenium-appearance" then
                                        local playerPed = PlayerPedId()
                                        local pedModel = exports[Config.SkinManager]:getPedModel(playerPed)
                                        local pedComponents = exports[Config.SkinManager]:getPedComponents(playerPed)
                                        local pedProps = exports[Config.SkinManager]:getPedProps(playerPed)
                                        if Config.SkinManager == "fivem-appearance" then
                                            TriggerServerEvent('fivem-appearance:saveOutfit', data2.value, pedModel, pedComponents, pedProps)
                                        elseif Config.SkinManager == "illenium-appearance" then
                                            TriggerServerEvent('illenium-appearance:server:saveOutfit', data2.value, pedModel, pedComponents, pedProps)
                                        end
                                    end
                                    menu2.close()
                                    menu.close()
                                    isMenuOpened = false
                                end
                            end, function(data2, menu2)
                                menu2.close()
                            end)
                        elseif data.current.value == 'no' then
                            isMenuOpened = false
                            menu.close()
                        end
                    end, function(data, menu)
                        isMenuOpened = false
                        menu.close()
                    end)
                elseif Config.Menu == "ox_lib" then
                    local elements = {
                        {
                            icon = Config.Translate['menu:yes'].icon, 
                            title = Config.Translate['menu:yes'].name,
                            onSelect = function()
                                isMenuOpened = true
                                local input = lib.inputDialog('', {
                                    {type = 'textarea', label = Config.Translate['esx_context:title'].name, required = true}
                                })
                                if not input then return end
                                if input[1] then
                                    if Config.SkinManager == "esx_skin" then
                                        TriggerEvent('skinchanger:getSkin', function(skin)
                                            TriggerServerEvent('vms_clothestore:saveOutfit', input[1], skin)
                                        end)
                                        isMenuOpened = false
                                    elseif Config.SkinManager == "fivem-appearance" or Config.SkinManager == "illenium-appearance" then
                                        local playerPed = PlayerPedId()
                                        local pedModel = exports[Config.SkinManager]:getPedModel(playerPed)
                                        local pedComponents = exports[Config.SkinManager]:getPedComponents(playerPed)
                                        local pedProps = exports[Config.SkinManager]:getPedProps(playerPed)
                                        if Config.SkinManager == "fivem-appearance" then
                                            TriggerServerEvent('fivem-appearance:saveOutfit', input[1], pedModel, pedComponents, pedProps)
                                        elseif Config.SkinManager == "illenium-appearance" then
                                            TriggerServerEvent('illenium-appearance:server:saveOutfit', input[1], pedModel, pedComponents, pedProps)
                                        end
                                        isMenuOpened = false
                                    end
                                end
                            end,
                            onExit = function()
                                isMenuOpened = false
                            end
                        },
                        {
                            icon = Config.Translate['menu:no'].icon, 
                            title = Config.Translate['menu:no'].name,
                            onSelect = function()
                                isMenuOpened = false
                            end,
                            onExit = function()
                                isMenuOpened = false
                            end
                        },
                    }
                    lib.registerContext({
                        id = "clothestore-save",
                        title = Config.Translate['menu:header'].name,
                        options = elements,
                        onExit = function()
                            isMenuOpened = false
                        end
                    })
                    lib.showContext('clothestore-save')
                end
            end
        end)
    elseif Config.Core == "QB-Core" then
        if Config.SkinManager == "fivem-appearance" then
            TriggerEvent('fivem-appearance:client:saveOutfit')
            isMenuOpened = false
        elseif Config.SkinManager == 'qb-clothing' or Config.SkinManager == "illenium-appearance" then
            if Config.Menu == "qb-menu" then
                exports['qb-menu']:openMenu({
                    {
                        header = Config.Translate['menu:header'].name,
                        icon = Config.Translate['menu:header'].icon,
                        isMenuHeader = true,
                    },
                    {
                        header = "",
                        txt = Config.Translate['menu:yes'].name,
                        icon = Config.Translate['menu:yes'].icon,
                        params = {
                            isAction = true,
                            event = function()
                                local keyboard = exports['qb-input']:ShowInput({
                                    header = Config.Translate['qb-input:header'],
                                    submitText = Config.Translate['qb-input:submitText'],
                                    inputs = {{
                                        text = Config.Translate['qb-input:text'],
                                        name = "input",
                                        type = "text",
                                        isRequired = true
                                    }}
                                })
                                if keyboard ~= nil then
                                    if Config.SkinManager == 'qb-clothing' then
                                        local ped = PlayerPedId()
                                        local model = GetEntityModel(ped)
                                        TriggerServerEvent('qb-clothes:saveOutfit', keyboard.input, model, Character_QB)
                                    elseif Config.SkinManager == "illenium-appearance" then
                                        local playerPed = PlayerPedId()
                                        local pedModel = exports[Config.SkinManager]:getPedModel(playerPed)
                                        local pedComponents = exports[Config.SkinManager]:getPedComponents(playerPed)
                                        local pedProps = exports[Config.SkinManager]:getPedProps(playerPed)
                                        TriggerServerEvent('illenium-appearance:server:saveOutfit', keyboard.input, pedModel, pedComponents, pedProps)
                                    end
                                    isMenuOpened = false
                                end
                            end,
                        }
                    },
                    {
                        header = "",
                        txt = Config.Translate['menu:no'].name,
                        icon = Config.Translate['menu:no'].icon,
                        params = {
                            isAction = true,
                            event = function()
                                isMenuOpened = false
                            end
                        }
                    },
                })
            elseif Config.Menu == "ox_lib" then
                local elements = {
                    {
                        icon = Config.Translate['menu:yes'].icon, 
                        title = Config.Translate['menu:yes'].name,
                        onSelect = function()
                            isMenuOpened = true
                            local input = lib.inputDialog('', {
                                {type = 'textarea', label = Config.Translate['esx_context:title'].name, required = true}
                            })
                            if not input then return end
                            if input[1] then
                                if Config.SkinManager == 'qb-clothing' then
                                    local ped = PlayerPedId()
                                    local model = GetEntityModel(ped)
                                    TriggerServerEvent('qb-clothes:saveOutfit', input[1], model, Character_QB)
                                    isMenuOpened = false
                                elseif Config.SkinManager == "illenium-appearance" then
                                    local playerPed = PlayerPedId()
                                    local pedModel = exports[Config.SkinManager]:getPedModel(playerPed)
                                    local pedComponents = exports[Config.SkinManager]:getPedComponents(playerPed)
                                    local pedProps = exports[Config.SkinManager]:getPedProps(playerPed)
                                    TriggerServerEvent('illenium-appearance:server:saveOutfit', input[1], pedModel, pedComponents, pedProps)
                                    isMenuOpened = false
                                end
                            end
                        end,
                        onExit = function()
                            isMenuOpened = false
                        end
                    },
                    {
                        icon = Config.Translate['menu:no'].icon, 
                        title = Config.Translate['menu:no'].name,
                        onSelect = function()
                            isMenuOpened = false
                        end,
                        onExit = function()
                            isMenuOpened = false
                        end
                    },
                }
                lib.registerContext({
                    id = "clothestore-save",
                    title = Config.Translate['menu:header'].name,
                    options = elements,
                    onExit = function()
                        isMenuOpened = false
                    end
                })
                lib.showContext('clothestore-save')
            end
        end
    end
end

function OpenClothestore(store, storeId)
    storeIsIn = storeId
    if Config.Core == "ESX" then
        if Config.SkinManager == "esx_skin" or Config.SkinManager == "fivem-appearance" or Config.SkinManager == "illenium-appearance" then
            TriggerEvent('skinchanger:getSkin', function(skin)
                if Config.SkinManager == "esx_skin" then
                    gender = skin.sex == 0 and 'male' or 'female'
                else
                    gender = skin.model == 'mp_m_freemode_01' and 'male' or 'female'
                end
                lastSkin = skin
            end)
            while not gender do
                Citizen.Wait(20)
            end
        end
        if Config.SkinManager == "esx_skin" then
            refreshValues()
        end
    end
    local data = {}
    local hasSkin = false
    local components, maxVals = getMaxValues()
    for i=1, #components, 1 do
        data[components[i].name] = {
            newValue = components[i].value,
            value = components[i].value,
            min = components[i].min,
        }
        for k,v in pairs(maxVals) do
            if k == components[i].name then
                data[k].max = v
                break
            end
        end
    end
    if Config.SkinManager == "esx_skin" then
        TriggerEvent('skinchanger:getData', function(comp, max)
            for k, v in pairs(comp) do
                if data[v.name] then
                    data[v.name].newValue = tonumber(v.value)
                    data[v.name].value = tonumber(v.value)
                end
            end
            hasSkin = true
        end)
    elseif Config.SkinManager == "fivem-appearance" or Config.SkinManager == "illenium-appearance" then
        Character_AP = exports[Config.SkinManager]:getPedAppearance(PlayerPedId())
        if Config.Core == "QB-Core" then
            gender = QBCore.Functions.GetPlayerData().charinfo.gender == 0 and 'male' or 'female'
        end
        hasSkin = true
        for k, v in pairs(Character_AP['components']) do
            local fName, fValue, sName, sValue = getCurrentValues("components", k-1, v)
            if fName and fValue then
                data[fName].newValue = tonumber(fValue)
                data[fName].value = tonumber(fValue)
            end
            if sName and sValue then
                data[sName].newValue = tonumber(sValue)
                data[sName].value = tonumber(sValue)
            end
        end
        for k, v in pairs(Character_AP['props']) do
            local fName, fValue, sName, sValue = getCurrentValues("props", k-1, v)
            if fName and fValue then
                data[fName].newValue = tonumber(fValue)
                data[fName].value = tonumber(fValue)
            end
            if sName and sValue then
                data[sName].newValue = tonumber(sValue)
                data[sName].value = tonumber(sValue)
            end
        end
    elseif Config.SkinManager == "qb-clothing" then
        QBCore.Functions.TriggerCallback('vms_clothestore:getCurrentSkin', function(skin)
            Character_QB = json.decode(skin)
            gender = QBCore.Functions.GetPlayerData().charinfo.gender == 0 and 'male' or 'female'
            lastSkin = Character_QB
            hasSkin = true
        end)
        while not hasSkin do
            Citizen.Wait(125)
        end
        for k, v in pairs(Character_QB) do
            local fName, fValue, sName, sValue = getCurrentValues(k, v)
            if fName and fValue then
                data[fName].newValue = tonumber(fValue)
                data[fName].value = tonumber(fValue)
            end
            if sName and sValue then
                data[sName].newValue = tonumber(sValue)
                data[sName].value = tonumber(sValue)
            end
        end
    end
    while not hasSkin do
        Citizen.Wait(125)
    end
    local myPed = PlayerPedId()
    CreateCamera()
    RequestAnimDict(Config.ClothingPedAnimation[1])
    while not HasAnimDictLoaded(Config.ClothingPedAnimation[1]) do
        Wait(1)
    end
    TaskPlayAnim(myPed, Config.ClothingPedAnimation[1], Config.ClothingPedAnimation[2], 8.0, 0.0, -1, 1, 0, 0, 0, 0)
    Config.Hud:Disable()
    if Config.UseQSInventory then
        exports[Config.QSInventoryName]:setInClothing(true)
    end
    local BlockedClothes = store.blockedClothes and store.blockedClothes[gender] or {}

    local pricesForComponentSpecificStores = Config.PricesForComponentSpecificStores[storeIsIn] and Config.PricesForComponentSpecificStores[storeIsIn][gender] or nil
    local pricesForIdsSpecificStores = Config.PricesForIdsSpecificStores[storeIsIn] and Config.PricesForIdsSpecificStores[storeIsIn][gender] or nil

    SendNUIMessage({
        action = 'openClothestore',
        disabledValues = BlockedClothes,
        handsUpKey = Config.HandsUpKey,
        enableHandsUpButton = Config.EnableHandsUpButtonUI,
        categories = store.categories,
        defaultPrice = Config.DefaultPrice,
        componentsPrices = Config.PricesForComponent,
        idsPrices = Config.PricesForIds[gender] or {},
        componentsPricesStore = pricesForComponentSpecificStores,
        idsPricesStore = pricesForIdsSpecificStores,
        data = data,
    })
    SetNuiFocus(true, true)
end

function DeleteSkinCam()
    FreezeEntityPosition(PlayerPedId(), false)
    ClearPedTasks(PlayerPedId())
    ClearPedTasksImmediately(PlayerPedId())
    DeleteCamera()
    SetNuiFocus(false, false)
    SendNUIMessage({action = 'close'})
    ClearPedTasks(PlayerPedId())
    isMenuOpened = false
    storeIsIn = nil
    Config.Hud:Enable()
    if Config.UseQSInventory then
        exports[Config.QSInventoryName]:setInClothing(false)
    end
end

Citizen.CreateThread(function()
	for k, v in pairs(Config.Stores) do
        if v and v.blip then
		    local blip = AddBlipForCoord(v.coords)
		    SetBlipSprite(blip, v.blip.sprite)
		    SetBlipDisplay(blip, v.blip.display)
		    SetBlipScale(blip, v.blip.scale)
		    SetBlipColour(blip, v.blip.color)
		    SetBlipAsShortRange(blip, true)
		    BeginTextCommandSetBlipName("STRING")
		    AddTextComponentString('<font face="Roboto">' .. v.blip.name .. '</font>')
		    EndTextCommandSetBlipName(blip)
        end
	end
end)

Citizen.CreateThread(function()
    local inRange = false
    local shown = false
    while not Config.UseTarget do
        inRange = false
        local sleep = true
        local myPed = PlayerPedId()
        local myCoords = GetEntityCoords(myPed)
        for k, v in pairs(Config.Stores) do
            local distance = #(myCoords - v.coords)
            if distance < 10.0 then
                sleep = false
                DrawMarker(v.marker.id, v.coords.x, v.coords.y, v.coords.z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, v.marker.size, v.marker.color[1], v.marker.color[2], v.marker.color[3], v.marker.color[4], v.marker.bobUpAndDown, false, false, v.marker.rotate, nil, nil, false)
                if not isMenuOpened and distance < v.marker.size.x then
                    inRange = true
                    if not Config.Interact.Enabled and Config.Core == "ESX" then
                        ESX.ShowHelpNotification(Config.Translate['press_to_open'])
                    end
                    if IsControlJustPressed(0, Config.KeyOpen) then
                        isMenuOpened = true
                        SelectCategory(v, k)
                    end
                end
                if isMenuOpened and distance > v.marker.size.x then
                    isMenuOpened = false
                end
            end
        end
        if inRange and not shown then
            shown = true
            if Config.Interact.Enabled then
                Config.Interact.Open()
            end
        elseif not inRange and shown then
            shown = false
            if Config.Interact.Enabled then
                Config.Interact.Close()
            end
        end
        Citizen.Wait(sleep and 1500 or 1)
    end
end)

Citizen.CreateThread(function()
    if Config.UseTarget then
        for k, v in pairs(Config.Stores) do
            v.targetId = Config.Target({
                coords = v.coords,
                targetRotation = v.targetRotation,
                targetSize = v.targetSize
            }, function()
                SelectCategory(v, k)
            end)
        end
    end
end)

RegisterNetEvent('vms_clothestore:open')
AddEventHandler('vms_clothestore:open', function(storeId)
    local store = Config.Stores[storeId]
    OpenClothestore(store, storeId)
end)

RegisterNetEvent('vms_clothestore:notification')
AddEventHandler('vms_clothestore:notification', function(message, time, type)
    Config.Notification(message, time, type)
end)

exports('OpenShare', OpenShare)
exports('OpenManage', OpenManage)
exports('OpenWardrobe', OpenWardrobe)