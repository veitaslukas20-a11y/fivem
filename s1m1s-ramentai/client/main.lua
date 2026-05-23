local crutchModel = `prop_mads_crutch01`
local clipSet = "move_lester_CaneUp"
local isUsingCrutch = false
local crutchObject = nil
local crutchTime = 0

local function createCrutch()
    lib.requestModel(crutchModel)

    crutchObject = lib.callback.await('d-ramentai:prop', false)
    if crutchObject then

        crutchObject = NetworkGetEntityFromNetworkId(crutchObject)
        while not DoesEntityExist(crutchObject) do
            crutchObject = NetworkGetEntityFromNetworkId(crutchObject)
            Wait(100)
        end

        AttachEntityToEntity(crutchObject, cache.ped, 70, 1.18, -0.36, -0.20, -20.0, -87.0, -20.0, true, true, false, true, 1, true)
        SetEntityCollision(crutchObject, false, true)
    end
end

local function crutchThread()
    Citizen.CreateThread(function()
        while isUsingCrutch do
            DisableControlAction(2, 37, true)
            DisableControlAction(1, 141, true)
            DisablePlayerFiring(cache.ped, true)
            DisableControlAction(0, 140, true)
            DisableControlAction(0, 141, true)
            DisableControlAction(0, 142, true)
            DisableControlAction(0, 25, true)
            DisableControlAction(1, 140, true)
            DisableControlAction(0, 106, true)
            DisableControlAction(0, 91, true)
            DisableControlAction(0, 22, true)
            DisableControlAction(0, 21, true)

            SetCurrentPedWeapon(cache.ped, `WEAPON_UNARMED`, true)

            SetPlayerSprint(cache.playerId, false)

            local minutes = math.floor(crutchTime/60000)
            local sec = math.floor((crutchTime - minutes * 60000) / 1000)
            exports['s1m1s-ui']:topText(isUsingCrutch, 'Jums liko '..minutes..'min '..sec..'sec vaikščioti su ramentais.')

            Wait(10)
        end
        exports['s1m1s-ui']:topText(false)
    end)

    Citizen.CreateThread(function()
        while isUsingCrutch do
            if cache.vehicle then
                if crutchObject then
                    TriggerServerEvent('d-ramentai:deleteprop')
                    crutchObject = nil
                end
            else
                if GetPedMovementClipset(cache.ped) ~= GetHashKey(clipSet) then
                    SetPedMovementClipset(cache.ped, clipSet, 1.0)
                end

                if not crutchObject or not DoesEntityExist(crutchObject) then
                    createCrutch()
                end
            end

            Wait(1000)
        end
    end)
end

local function equipCrutch()
    RequestClipSet(clipSet)
    while not HasClipSetLoaded(clipSet) do
        Wait(10)
    end
    SetPedMovementClipset(cache.ped, clipSet, 1.0)
    RemoveClipSet(clipSet)

    createCrutch()
    isUsingCrutch = true
    crutchThread()

    Citizen.CreateThread(function()
        while isUsingCrutch do
            if crutchTime > 0 then
                crutchTime -= 1000
            else
                isUsingCrutch = false
            end
            Wait(1000)
        end

        TriggerServerEvent('d-ramentai:deleteprop')
        ResetPedMovementClipset(cache.ped, 0)
        TriggerServerEvent('d-ramentai:save', 0)
    end)

    Citizen.CreateThread(function()
        while isUsingCrutch do
            TriggerServerEvent('d-ramentai:save', crutchTime)
            Wait(30000)
        end
    end)
end

local function crutchMenu(player)
    local input = lib.inputDialog('Ramentai', {
        {type = 'number', label = 'Laikas minutėmis', description = 'Laikas, kurį pacientas turės naudoti ramentus', icon = 'fa-solid fa-clock', min = 1, max = 30, required = true},
    })

    if not input then return end
    if not input[1] then return end

    if input[1] > 30 then return ESX.ShowNotification('Deja įvedėte neteisingą laiką.') end

    TriggerServerEvent('d-ramentai:equip', player, input[1] * 60000)
end

RegisterNetEvent('d-ramentai:equip', function(time)
    crutchTime = time
    equipCrutch()
end)

exports('ramentai', function(player)
    crutchMenu(player)
end)