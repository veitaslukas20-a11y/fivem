local hidePlayers = false
local lastSkin = nil
local lastCoords = nil
local gender = nil
local isInSurgery = false
tempSkinTable = {}
playerHasAlreadySkin = false

if Config.Core == "ESX" then
    ESX = Config.CoreExport()
elseif Config.Core == "QB-Core" then
    QBCore = Config.CoreExport()
end

Citizen.CreateThread(function()
    local sleep = true
    local inRange = false
    local shown = false
    if Config.PlasticSurgery.Enabled and Config.PlasticSurgery.Blip and Config.PlasticSurgery.Blip.Enabled then
        if Config.PlasticSurgery.PointCoords then
            local blip = AddBlipForCoord(Config.PlasticSurgery.PointCoords)
            SetBlipSprite(blip, Config.PlasticSurgery.Blip.Sprite)
            SetBlipDisplay(blip, Config.PlasticSurgery.Blip.Display)
            SetBlipScale(blip, Config.PlasticSurgery.Blip.Scale)
            SetBlipColour(blip, Config.PlasticSurgery.Blip.Color)
            SetBlipAsShortRange(blip, true)
            BeginTextCommandSetBlipName("STRING")
            AddTextComponentString(Config.PlasticSurgery.Blip.Name)
            EndTextCommandSetBlipName(blip)
        end
    end
    while Config.PlasticSurgery.Enabled do
        inRange = false
        sleep = true
        if Config.PlasticSurgery.PointCoords then
            local myPed = PlayerPedId()
            local myCoords = GetEntityCoords(myPed)
            local distance = #(myCoords - Config.PlasticSurgery.PointCoords)
            if Config.PlasticSurgery.Marker and Config.PlasticSurgery.Marker.Enabled and distance <= Config.PlasticSurgery.Marker.DrawDistance then
                sleep = false
                DrawMarker(Config.PlasticSurgery.Marker.Type, Config.PlasticSurgery.PointCoords, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, Config.PlasticSurgery.Marker.Scale, Config.PlasticSurgery.Marker.Color[1], Config.PlasticSurgery.Marker.Color[2], Config.PlasticSurgery.Marker.Color[3], Config.PlasticSurgery.Marker.Color[4], Config.PlasticSurgery.Marker.BobUpAndDown, false, false, Config.PlasticSurgery.Marker.Rotate, nil, nil, nil)
            end
            if Config.PlasticSurgery.Text3D and Config.PlasticSurgery.Text3D.Enabled and distance <= Config.PlasticSurgery.Text3D.DrawDistance then
                sleep = false
                if Config.PlasticSurgery.Price and Config.PlasticSurgery.Price > 0 then
                    Config.PlasticSurgery.Text3D.Action(Config.Translate[Config.Language]['action.text3d.plastic_surgery_paid']:format(Config.PlasticSurgery.Price))
                else
                    Config.PlasticSurgery.Text3D.Action(Config.Translate[Config.Language]['action.text3d.plastic_surgery_free'])
                end
            end
            if distance <= Config.PlasticSurgery.AccessDistance then
                sleep = false
                inRange = true
                if Config.Core == "ESX" and Config.PlasticSurgery.UseESXHelpNotification then
                    if Config.PlasticSurgery.Price and Config.PlasticSurgery.Price > 0 then
                        ESX.ShowHelpNotification(Config.Translate[Config.Language]['action.help.plastic_surgery_paid']:format(Config.PlasticSurgery.Price))
                    else
                        ESX.ShowHelpNotification(Config.Translate[Config.Language]['action.help.plastic_surgery_free'])
                    end
                end
                if Config.PlasticSurgery.AccessControl then
                    if IsControlJustPressed(0, Config.PlasticSurgery.AccessControl) then
                        TriggerEvent("vms_charcreator:plasticSurgery")
                    end
                end
            end
            if inRange and not shown then
                shown = true
                if Config.PlasticSurgery.Interact.Enabled then
                    Config.PlasticSurgery.Interact.Open(Config.PlasticSurgery.Price and Config.PlasticSurgery.Price > 0 and Config.Translate[Config.Language]['action.help.plastic_surgery_paid']:format(Config.PlasticSurgery.Price) or Config.Translate[Config.Language]['action.help.plastic_surgery_free'])
                end
            elseif not inRange and shown then
                shown = false
                if Config.PlasticSurgery.Interact.Enabled then
                    Config.PlasticSurgery.Interact.Close()
                end
            end
        end
        Citizen.Wait(sleep and 2500 or 1)
    end
end)

local function openCharacterCreator(sex, isAlreadyHaveSkin, isSurgery)
    if Config.Core == "ESX" and Config.SkinManager == "esx_skin" then
        refreshValues()
    end
    if Config.UseQSInventory then
        exports[Config.QSInventoryName]:setInClothing(true)
    end
    local data = {}
    local hasSkin = false
    local components, maxVals = getMaxValues()
    for i=1, #components, 1 do
        data[components[i].name] = {
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
    if isAlreadyHaveSkin then
        playerHasAlreadySkin = true
        if Config.SkinManager == "esx_skin" then
            tempSkinTable = Character_ESX
            TriggerEvent('skinchanger:getData', function(comp, max)
                for k, v in pairs(comp) do
    if data[v.name] then
        data[v.name].value = tonumber(v.value)
    else
        data[v.name] = { value = tonumber(v.value), min = 0, max = 0 }
    end
    tempSkinTable[v.name] = tonumber(v.value)
end
                hasSkin = true
            end)
            TriggerEvent('skinchanger:getSkin', function(skin)
                gender = skin.sex == 0 and 'male' or 'female'
                lastSkin = skin
            end)
        elseif Config.SkinManager == "fivem-appearance" or Config.SkinManager == "illenium-appearance" then
            tempSkinTable = exports[Config.SkinManager]:getPedAppearance(PlayerPedId())
            lastSkin = exports[Config.SkinManager]:getPedAppearance(PlayerPedId())
            gender = IsPedModel(PlayerPedId(), GetHashKey('mp_m_freemode_01')) and 'male' or 'female'
            hasSkin = true
        elseif Config.SkinManager == "qb-clothing" then
            QBCore.Functions.TriggerCallback('vms_charcreator:getCurrentSkin', function(skin)
                tempSkinTable = json.decode(skin)
                gender = QBCore.Functions.GetPlayerData().charinfo.gender == 0 and 'male' or 'female'
                hasSkin = true
            end)
        end
    else
        if Config.SkinManager == "esx_skin" then
            tempSkinTable = Character_ESX
            gender = tempSkinTable.sex == 0 and 'male' or 'female'
        elseif Config.SkinManager == "fivem-appearance" or Config.SkinManager == "illenium-appearance" then
            tempSkinTable = Character_AP
            gender = IsPedModel(PlayerPedId(), GetHashKey('mp_m_freemode_01')) and 'male' or 'female' -- tempSkinTable.sex == 0 and 'male' or 'female'
        elseif Config.SkinManager == "qb-clothing" then
            tempSkinTable = Character_QB
            gender = QBCore.Functions.GetPlayerData().charinfo.gender == 0 and 'male' or 'female'
        end
        hasSkin = true
    end
    if tonumber(sex) then
        if Config.Core == "ESX" then
            if Config.SkinManager == "esx_skin" then
                TriggerEvent('skinchanger:loadSkin', {sex = sex})
                Character_ESX['sex'] = sex
            elseif Config.SkinManager == "fivem-appearance" or Config.SkinManager == "illenium-appearance" then
                appearance_switcher('sex', sex)
            end
        elseif Config.Core == "QB-Core" then
            local model = sex == 0 and GetHashKey('mp_m_freemode_01') or GetHashKey('mp_f_freemode_01')
            RequestModel(model)
            while not HasModelLoaded(model) do
                RequestModel(model)
                Citizen.Wait(0)
            end
            SetPlayerModel(PlayerId(), model)
            SetPedComponentVariation(PlayerPedId(), 0, 0, 0, 2)
            if Config.SkinManager == "fivem-appearance" or Config.SkinManager == "illenium-appearance" then
                appearance_switcher('sex', sex)
            end
        end
        data['sex'].value = sex
    end
    if not isAlreadyHaveSkin then
        local mySex = IsPedModel(PlayerPedId(), GetHashKey('mp_m_freemode_01')) and 'm' or 'f'
        gender = mySex == 'm' and 'male' or 'female'
        if Config.SkinManager == "esx_skin" then
            if Config.EnableFirstCreationClothes then
                for k, v in pairs(Config.FirstCreationClothes[mySex]) do
                    tempSkinTable[k] = v
                end
                updateValue(tempSkinTable)
            end
        elseif Config.SkinManager == "fivem-appearance" or Config.SkinManager == "illenium-appearance" then
            if Config.EnableFirstCreationClothes then
                for k, v in pairs(Config.FirstCreationClothes[mySex]) do
                    appearance_switcher(k, v)
                end
            end
        elseif Config.SkinManager == "qb-clothing" then
            if Config.EnableFirstCreationClothes then
                for k, v in pairs(Config.FirstCreationClothes[mySex]) do
                    qbcore_switcher(k, v)
                end
            end
        end
    end
    while not hasSkin do
        Citizen.Wait(125)
    end
    CreateSkinCam(data)
end

RegisterNUICallback('closeCharacter', function()
    SetNuiFocus(false, false)
    ClearPedTasks(PlayerPedId())
    DeleteSkinCam()
end)

RegisterNUICallback('cancel', function()
    if Config.EnableCancelButtonUI then
        SetNuiFocus(false, false)
        ClearPedTasks(PlayerPedId())
        DeleteSkinCam(true)
    end
end)

RegisterNUICallback('loaded', function(data, cb)
    SendNUIMessage({
        action = "loaded",
        lang = Config.Language,
    })
end)

RegisterNUICallback("change", function(data)
    if data.type == 'clotheset' then
        local mySex = IsPedModel(PlayerPedId(), GetHashKey('mp_m_freemode_01')) and 'm' or 'f'
        if Config.clotheSets[tonumber(data.new)] then
            if (Config.Core == "ESX") then
                if Config.SkinManager == "esx_skin" then
                    for k, v in pairs(Config.clotheSets[tonumber(data.new)][mySex]) do
                        tempSkinTable[k] = v
                    end
                    updateValue(tempSkinTable)
                elseif Config.SkinManager == "fivem-appearance" or Config.SkinManager == "illenium-appearance" then
                    for k, v in pairs(Config.clotheSets[tonumber(data.new)][mySex]) do
                        appearance_switcher(k, v)
                    end
                end
            elseif (Config.Core == "QB-Core") then
                if Config.SkinManager == "qb-clothing" then
                    for k, v in pairs(Config.clotheSets[tonumber(data.new)][mySex]) do
                        qbcore_switcher(k, v)
                    end
                elseif Config.SkinManager == "fivem-appearance" or Config.SkinManager == "illenium-appearance" then
                    for k, v in pairs(Config.clotheSets[tonumber(data.new)][mySex]) do
                        appearance_switcher(k, v)
                    end
                end
            end
        end
    else
        if Config.Core == "ESX" then
            if Config.SkinManager == "esx_skin" then
                if data.type == 'sex' then
                    if tempSkinTable.sex ~= tonumber(data.new) then
                        TriggerEvent('skinchanger:loadSkin', {sex = tonumber(data.new)})
                    end
                end
                tempSkinTable[data.type] = tonumber(data.new)
                updateValue(tempSkinTable)
            elseif Config.SkinManager == "fivem-appearance" or Config.SkinManager == "illenium-appearance" then
                appearance_switcher(data.type, data.new)
            end
        elseif (Config.Core == "QB-Core") then
            if data.type == 'sex' then
                local model = data.new == 0 and GetHashKey('mp_m_freemode_01') or GetHashKey('mp_f_freemode_01')
                RequestModel(model)
                while not HasModelLoaded(model) do
                    RequestModel(model)
                    Citizen.Wait(0)
                end
                SetPlayerModel(PlayerId(), model)
                SetPedComponentVariation(PlayerPedId(), 0, 0, 0, 2)
                if Config.SkinManager == "fivem-appearance" or Config.SkinManager == "illenium-appearance" then
                    appearance_switcher(data.type, data.new)
                end
            elseif data.type == 'ped' then
                local model = data.new == 0 and GetHashKey("mp_m_freemode_01") or GetHashKey(Config.PedsList[data.new])
                RequestModel(model)
                while not HasModelLoaded(model) do
                    RequestModel(model)
                    Citizen.Wait(0)
                end
                SetPlayerModel(PlayerId(), model)
                SetPedComponentVariation(PlayerPedId(), 0, 0, 0, 2)
                if Config.SkinManager == "fivem-appearance" or Config.SkinManager == "illenium-appearance" then
                    appearance_switcher(data.type, data.new == 0 and "mp_m_freemode_01" or data.new)
                end
            else
                if Config.SkinManager == "qb-clothing" then
                    qbcore_switcher(data.type, data.new)
                elseif Config.SkinManager == "fivem-appearance" or Config.SkinManager == "illenium-appearance" then
                    appearance_switcher(data.type, data.new)
                end
            end
        end
        local secondItem, secondValue = GetMaxVal(data.type)
        if secondItem and secondValue then
            SendNUIMessage({
                action = 'updateSecondValue',
                secondItem = secondItem,
                secondValue = secondValue
            })
            if Config.Core == "ESX" then
                if Config.SkinManager == "esx_skin" then
                    tempSkinTable[secondItem] = 0
                    updateValue(tempSkinTable)
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
    end
    if Config.soundsEffects then
        PlaySoundFrontend(-1, "NAV_LEFT_RIGHT", "HUD_FRONTEND_DEFAULT_SOUNDSET", true)
    end
end)

RegisterNUICallback("hands_up", function(data)
    local myPed = PlayerPedId()
    if handsup then
        ClearPedTasksImmediately(myPed)
        RequestAnimDict(Config.CharacterCreationPedAnimation[1])
        while not HasAnimDictLoaded(Config.CharacterCreationPedAnimation[1]) do
            Wait(1)
        end
        TaskPlayAnim(myPed, Config.CharacterCreationPedAnimation[1], Config.CharacterCreationPedAnimation[2], 8.0, 0.0, -1, 1, 0, 0, 0, 0)
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

function CreateSkinCam(data)
    local myPed = PlayerPedId()
    CreateCamera()
    RequestAnimDict(Config.CharacterCreationPedAnimation[1])
    while not HasAnimDictLoaded(Config.CharacterCreationPedAnimation[1]) do
        Wait(1)
    end
    TaskPlayAnim(myPed, Config.CharacterCreationPedAnimation[1], Config.CharacterCreationPedAnimation[2], 8.0, 0.0, -1, 1, 0, 0, 0, 0)
    Config.Hud:Disable()
    SendNUIMessage({
        action = 'openCharacter',
        categories = isInSurgery and Config.PlasticSurgery.EnablesCategories or Config.EnablesCategories,
        items = isInSurgery and Config.PlasticSurgery.AvailableItems or Config.AvailableItems,
        skinmanager = Config.SkinManager,
        data = data,
        clotheSets = Config.clotheSets,
        disabledValues = Config.BlockedClothes,
        gender = gender,
        peds = Config.PedsList,
        handsUpKey = Config.HandsUpKey,
        enableHandsUpButton = Config.EnableHandsUpButtonUI,
        enableCancelButtonUI = Config.EnableCancelButtonUI,
        playerHasAlreadySkin = playerHasAlreadySkin,
    })
    SetNuiFocus(true, true)
end

function DeleteSkinCam(isCanceled)
    if not playerHasAlreadySkin or (playerHasAlreadySkin and Config.TeleportPlayerByCommand or isInSurgery and Config.PlasticSurgery.OnFinishTeleportBack) then
        DoScreenFadeOut(500)
    end
    if not isCanceled then
        if Config.Core == "ESX" then
            if Config.SkinManager == "esx_skin" then
                TriggerEvent('skinchanger:loadSkin', tempSkinTable)
                TriggerServerEvent('esx_skin:save', tempSkinTable)
            elseif Config.SkinManager == "fivem-appearance" then
                TriggerServerEvent('fivem-appearance:save', tempSkinTable)
            elseif Config.SkinManager == "illenium-appearance" then
                TriggerServerEvent('illenium-appearance:server:saveAppearance', tempSkinTable)
            end
        elseif (Config.Core == "QB-Core") then
            if Config.SkinManager == 'qb-clothing' then
                local model = GetEntityModel(PlayerPedId())
                local character_encode = json.encode(tempSkinTable)
                TriggerServerEvent("qb-clothing:saveSkin", model, character_encode)
            elseif Config.SkinManager == "fivem-appearance" or Config.SkinManager == "illenium-appearance" then
                TriggerServerEvent(Config.SkinManager..':server:saveAppearance', tempSkinTable)
            end
        end
    else
        if Config.Core == "ESX" then
            if Config.SkinManager == "esx_skin" then
                TriggerEvent('skinchanger:loadSkin', lastSkin)
                TriggerServerEvent('esx_skin:save', lastSkin)
            elseif Config.SkinManager == "fivem-appearance" then
                TriggerEvent('skinchanger:loadSkin', lastSkin)
                TriggerServerEvent('esx_skin:save', lastSkin)
            elseif Config.SkinManager == "illenium-appearance" then
                TriggerEvent('skinchanger:loadSkin', lastSkin)
                TriggerServerEvent('illenium-appearance:server:saveAppearance', lastSkin)
            end
        elseif Config.Core == "QB-Core" then
            if Config.SkinManager == "fivem-appearance" or Config.SkinManager == "illenium-appearance" then
                TriggerEvent(Config.SkinManager..':client:reloadSkin')
            elseif Config.SkinManager == "qb-clothing" then
                TriggerServerEvent("qb-clothes:loadPlayerSkin")
                TriggerServerEvent("qb-clothing:loadPlayerSkin")
            end
        end
    end
    if not playerHasAlreadySkin or (playerHasAlreadySkin and Config.TeleportPlayerByCommand or isInSurgery and Config.PlasticSurgery.OnFinishTeleportBack) then
        Wait(250)
    end
    if Config.soundsEffects then
        PlaySoundFrontend(-1, 'CHECKPOINT_UNDER_THE_BRIDGE', 'HUD_MINI_GAME_SOUNDSET', 0)
    end
    FreezeEntityPosition(PlayerPedId(), false)
    ClearPedTasks(PlayerPedId())
    ClearPedTasksImmediately(PlayerPedId())
    if not playerHasAlreadySkin or (playerHasAlreadySkin and Config.TeleportPlayerByCommand or isInSurgery and Config.PlasticSurgery.OnFinishTeleportBack) then
        Wait(250)
    end
    Config.Hud:Enable()
    DeleteCamera()
    if playerHasAlreadySkin then
        if Config.TeleportPlayerByCommand or isInSurgery and Config.PlasticSurgery.OnFinishTeleportBack then
            SetEntityCoords(PlayerPedId(), lastCoords.x, lastCoords.y, lastCoords.z)
            SetEntityHeading(PlayerPedId(), lastCoords.w)
        end
    else
        if Config.afterCreateCharSpawn then
            SetEntityCoords(PlayerPedId(), Config.afterCreateCharSpawn.x, Config.afterCreateCharSpawn.y, Config.afterCreateCharSpawn.z)
            SetEntityHeading(PlayerPedId(), Config.afterCreateCharSpawn.w)
        end
        Config.AfterCreatedFirstCharacter()
    end
    if not playerHasAlreadySkin or (playerHasAlreadySkin and Config.TeleportPlayerByCommand or isInSurgery and Config.PlasticSurgery.OnFinishTeleportBack) then
        Wait(100)
        DoScreenFadeIn(250)
    end
    if Config.UseQSInventory then
        exports[Config.QSInventoryName]:setInClothing(false)
    end
	hidePlayers = false
    if Config.UseRoutingBuckets then
        TriggerServerEvent("vms_charcreator:setRoutingBucket", true)
    end
    tempSkinTable = {}
    lastSkin = nil
    lastCoords = nil
    isInSurgery = false
    playerHasAlreadySkin = false
end

RegisterNetEvent('vms_charcreator:openCreator')
AddEventHandler('vms_charcreator:openCreator', function(sex, isAlreadyHaveSkin, isSurgery)
    lastCoords = {
        x = GetEntityCoords(PlayerPedId()).x,
        y = GetEntityCoords(PlayerPedId()).y,
        z = GetEntityCoords(PlayerPedId()).z,
        w = GetEntityHeading(PlayerPedId())
    }
    if not isAlreadyHaveSkin or isAlreadyHaveSkin and Config.TeleportPlayerByCommand then
        DoScreenFadeOut(500)
        Wait(1000)

        RequestCollisionAtCoord(Config.creatingCharacterCoords.x, Config.creatingCharacterCoords.y, Config.creatingCharacterCoords.z)

        if Config.creatingCharacterCoords then
            SetEntityCoords(PlayerPedId(), Config.creatingCharacterCoords.x, Config.creatingCharacterCoords.y, Config.creatingCharacterCoords.z)
            SetEntityHeading(PlayerPedId(), Config.creatingCharacterCoords.w) 
        end
    end
    if isSurgery and Config.PlasticSurgery.SurgeryCoords then
        isInSurgery = true
        DoScreenFadeOut(500)
        Wait(1000)
        SetEntityCoords(PlayerPedId(), Config.PlasticSurgery.SurgeryCoords.x, Config.PlasticSurgery.SurgeryCoords.y, Config.PlasticSurgery.SurgeryCoords.z)
        SetEntityHeading(PlayerPedId(), Config.PlasticSurgery.SurgeryCoords.w) 
    end 
    FreezeEntityPosition(PlayerPedId(), true)
    if not sex and not isAlreadyHaveSkin then
        local myModel = GetEntityModel(PlayerPedId()) == GetHashKey('mp_m_freemode_01') or IsModelAPed(GetEntityModel(PlayerPedId())) == GetHashKey('mp_f_freemode_01')
        if not myModel then
            local model = GetHashKey('mp_m_freemode_01')
            RequestModel(model)
            while not HasModelLoaded(model) do
                RequestModel(model)
                Citizen.Wait(0)
            end
            SetPlayerModel(PlayerId(), model)
            SetPedComponentVariation(PlayerPedId(), 0, 0, 0, 2)
        end
    end
    if not isAlreadyHaveSkin or (isAlreadyHaveSkin and Config.TeleportPlayerByCommand or isSurgery and Config.PlasticSurgery.SurgeryCoords) then
        if Config.UseRoutingBuckets then
            TriggerServerEvent("vms_charcreator:setRoutingBucket")
        else
            StartLoop()
        end
        DoScreenFadeIn(250)
    end
    openCharacterCreator(sex, isAlreadyHaveSkin, isSurgery)
end)

RegisterNetEvent('vms_charcreator:plasticSurgery')
AddEventHandler('vms_charcreator:plasticSurgery', function()
    if Config.PlasticSurgery.Price and Config.PlasticSurgery.Price > 0 then
        if Config.Core == "ESX" then
            ESX.TriggerServerCallback("vms_charcreator:getSurgeryPlasticMoney", function(data) 
                if data then
                    TriggerEvent('vms_charcreator:openCreator', nil, true, true)
                    Config.Notification(Config.Translate[Config.Language]['notify.title_plastic_surgery'], Config.Translate[Config.Language]['notify.surgery_paid']:format(Config.PlasticSurgery.Price), 2500, "success")
                else
                    Config.Notification(Config.Translate[Config.Language]['notify.title_plastic_surgery'], Config.Translate[Config.Language]['notify.enought_money'], 4000, "error")
                end
            end)
        elseif Config.Core == "QB-Core" then
            QBCore.Functions.TriggerCallback("vms_charcreator:getSurgeryPlasticMoney", function(data)
                if data then
                    TriggerEvent('vms_charcreator:openCreator', nil, true, true)
                    Config.Notification(Config.Translate[Config.Language]['notify.title_plastic_surgery'], Config.Translate[Config.Language]['notify.surgery_paid']:format(Config.PlasticSurgery.Price), 2500, "success")
                else
                    Config.Notification(Config.Translate[Config.Language]['notify.title_plastic_surgery'], Config.Translate[Config.Language]['notify.enought_money'], 4000, "error")
                end
            end)
        end
    else
        TriggerEvent('vms_charcreator:openCreator', nil, true, true)
    end
end)

StartLoop = function()
	hidePlayers = true
	MumbleSetVolumeOverride(PlayerId(), 0.0)
	CreateThread(function()
		while hidePlayers do
			SetEntityVisible(PlayerPedId(), 0, 0)
			SetLocalPlayerVisibleLocally(1)
			SetPlayerInvincible(PlayerId(), 1)
			ThefeedHideThisFrame()
			HideHudComponentThisFrame(11)
			HideHudComponentThisFrame(12)
			HideHudComponentThisFrame(21)
			HideHudAndRadarThisFrame()
			Wait(0)
			local vehicles = GetGamePool('CVehicle')
			for i = 1, #vehicles do
				SetEntityLocallyInvisible(vehicles[i])
			end
		end
		local playerId, playerPed = PlayerId(), PlayerPedId()
		MumbleSetVolumeOverride(playerId, -1.0)
		SetEntityVisible(playerPed, 1, 0)
		SetPlayerInvincible(playerId, 0)
	end)
	CreateThread(function()
		local playerPool = {}
		while hidePlayers do
			local players = GetActivePlayers()
			for i = 1, #players do
				local player = players[i]
				if player ~= PlayerId() and not playerPool[player] then
					playerPool[player] = true
					NetworkConcealPlayer(player, true, true)
				end
			end
			Wait(500)
		end
		for k in pairs(playerPool) do
			NetworkConcealPlayer(k, false, false)
		end
        FreezeEntityPosition(PlayerPedId(), false)
	end)
end