Zone, Blip, Ped = nil, nil, nil
InZone = false
Target = exports.ox_target
Job = nil

local Refreshed = false

function InitZone()
    Refreshed = true
    ShowTaken(false)
    ShowTaking(false)

    if not exports['s1m1s-gangzones']:IsGang() then return end

    Blip = AddBlipForArea(Config.Zone.coords.x, Config.Zone.coords.y, Config.Zone.coords.z, 200.0, 70.0)
    SetBlipRotation(Blip, math.ceil(Config.Zone.rotation))
    SetBlipColour(Blip, 3)
    SetBlipFlashes(Blip, Config.Zone.started)
    SetBlipAlpha(Blip, 90)
    SetBlipDisplay(Blip, 8)
    SetBlipAsShortRange(Blip, false)
    SetBlipDisplayIndicatorOnBlip(Blip, false)

    Zone = lib.zones.box({
        coords = Config.Zone.coords,
        size = vec3(200.0, 70.0, 50.0),
        rotation = Config.Zone.rotation,
    })

    function Zone:onEnter()
        if not InZone then
            TriggerServerEvent('policezone:addMember')
        end

        InZone = true

        CreateLocalPed()
        if not Config.Zone.started then
            ShowTaken(true)
        else
            TakingZone()
        end
    end

    function Zone:onExit()
        if Refreshed then return end
        TriggerServerEvent('policezone:removeMember')
        ShowTaken(false)
        ShowTaking(false)
        RemovePed()
        InZone = false
    end

    Refreshed = false
end

function ShowTaken(show)
    SendNUIMessage({
        type = 'taken',
        show = show,
    })
end

function ShowTaking(show, time, deadline, locked)
    SendNUIMessage({
        type = 'taking',
        show = show,
        time = time,
        deadline = deadline,
        locked = locked,
    })
end

function RefreshZone()
    RemovePed()

    if Zone then
        Zone:remove()
    end
    if Blip then
        RemoveBlip(Blip)
    end

    InitZone()
end

local PedHash = `s_m_y_cop_01`
function CreateLocalPed()
    if Ped then return end
    lib.requestModel(PedHash)

    Ped = CreatePed(4, PedHash, Config.Zone.ped.x, Config.Zone.ped.y, Config.Zone.ped.z -1.0, Config.Zone.ped.w, false, true)

    while not DoesEntityExist(Ped) do
        Wait(100)
    end

    SetModelAsNoLongerNeeded(PedHash)

    FreezeEntityPosition(Ped, true)
    SetEntityInvincible(Ped, true)
    SetBlockingOfNonTemporaryEvents(Ped, true)
    NetworkFadeInEntity(Ped, true)


    Target:addLocalEntity(Ped, {
        {
            label = 'Atidaryti zonos meniu',
            icon = "fa-solid fa-location-dot",
            onSelect = function()
                OpenZoneMenu()
            end,
            distance = 2.0
        },
    })
end

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(xPlayer)
    Wait(1000)

    Job = xPlayer.job

    Config = lib.callback.await('policezone:getConfig', false)
    InitZone()
end)

RegisterNetEvent("esx:setJob")
AddEventHandler("esx:setJob", function(job)
    Wait(1000)

    Job = job

    RefreshZone()

    RemovePed()
end)

AddEventHandler('onResourceStop', function(resourceName)
    if (GetCurrentResourceName() ~= resourceName) then return end

    RemovePed()
end)

AddEventHandler('onResourceStart', function(resourceName)
    if (GetCurrentResourceName() ~= resourceName) then return end

    Wait(1000)

    Config = lib.callback.await('policezone:getConfig', false)
    InitZone()
end)

RegisterNetEvent('policezone:startUtilization', function()
    Config.Zone.started = true
    Config.Zone.locked = true
    RefreshZone()
end)

RegisterNetEvent('policezone:enableZone', function()
    Config.Zone.enabled = true
end)

RegisterNetEvent('policezone:disableZone', function()
    Config.Zone.enabled = nil
end)

RegisterNetEvent('policezone:endUtilization', function()
    Config.Zone.started = nil
    Config.Zone.locked = nil
    Config.Zone.enabled = nil
    RefreshZone()
end)

function RemovePed()
    if Ped then
        Target:removeLocalEntity(Ped)
        DeletePed(Ped)
        Ped = nil
    end
end

function CalculateTime(ms)
    local hours = math.floor(ms / (60 * 60 * 1000))
    local minutes = math.floor((ms - (hours * 60 * 60 * 1000)) / (60 * 1000))
    local seconds = math.floor((ms - (hours * 60 * 60 * 1000) - (minutes * 60 * 1000)) / 1000)
    return {h = hours, min = minutes, sec = seconds}
end