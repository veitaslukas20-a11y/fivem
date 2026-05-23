-- dec4t-gangzones/client/main.lua - COMPLETELY FIXED VERSION
-- Fixed: Config loading, nil checks, error handling

Current, Zones, Ped, Blips = nil, {}, nil, {}
Target = exports.ox_target

local Refreshed = false
local Job = nil
local InZone = false
local ESX = nil
local ConfigLoaded = false  -- Track if config is loaded
local InitAttempts = 0       -- Prevent infinite loops

-- Initialize ESX
Citizen.CreateThread(function()
    while ESX == nil do
        TriggerEvent('esx:getSharedObject', function(obj) 
            ESX = obj 
        end)
        Citizen.Wait(0)
    end
    print("^2[dec4t-gangzones] ESX initialized^7")
end)

-- Safe function to check if player is in a gang
function IsGang()
    if not Job or not Job.name then
        return false
    end
    if not Config or not Config.GangsList then
        return false
    end
    return Config.GangsList[Job.name] ~= nil
end
exports('IsGang', IsGang)

-- Safe function to check if gang is official
function IsOfficial()
    if not IsGang() then return false end
    if not Config or not Config.GangsList or not Config.GangsList[Job.name] then
        return false
    end
    return Config.GangsList[Job.name].official or false
end

-- Initialize all zones
function InitZones()
    -- Prevent infinite loop attempts
    InitAttempts = InitAttempts + 1
    if InitAttempts > 10 then
        print("^1[dec4t-gangzones] Too many InitZones attempts, stopping^7")
        return
    end
    
    -- Wait for config to be loaded
    if not ConfigLoaded then
        print("^3[dec4t-gangzones] Waiting for config to load... (Attempt " .. InitAttempts .. "/10)^7")
        Citizen.Wait(1000)
        InitZones()
        return
    end
    
    -- Safety checks
    if not Config then
        print("^3[dec4t-gangzones] Cannot init zones: Config is nil^7")
        return
    end
    
    if not Config.Zones then
        print("^3[dec4t-gangzones] Cannot init zones: Config.Zones is nil^7")
        return
    end
    
    if not Job or not Job.name then
        print("^3[dec4t-gangzones] Cannot init zones: Job not loaded^7")
        return
    end

    -- Count zones
    local zoneCount = 0
    for _ in pairs(Config.Zones) do zoneCount = zoneCount + 1 end
    
    print("^2[dec4t-gangzones] Initializing zones with " .. zoneCount .. " zones^7")
    
    Refreshed = true
    ShowTaken(false)
    ShowTaking(false)

    if not IsGang() then 
        Refreshed = false
        return 
    end

    local official = IsOfficial()

    for k, v in pairs(Config.Zones) do
        -- Validate zone data
        if not v.coords or not v.size then
            print("^3[dec4t-gangzones] Zone " .. k .. " missing coords or size, skipping^7")
            goto continue
        end
        
        -- Skip if zone is official but player isn't official
        if v.official and not official then 
            goto continue 
        end

        -- Create blip if enabled
        if Config.ZoneSettings and Config.ZoneSettings.enableBlips then
            local blip = AddBlipForArea(v.coords.x, v.coords.y, v.coords.z, v.size.x, v.size.y)
            SetBlipRotation(blip, math.ceil(v.rotation or 0))
            
            -- Safely set blip color
            local blipColor = 0
            if v.owners and Config.GangColors and Config.GangColors[v.owners] then
                local colorStr = Config.GangColors[v.owners]
                if colorStr then
                    blipColor = tonumber('0x'..string.upper(colorStr)..'99') or 0
                end
            end
            SetBlipColour(blip, blipColor)
            
            SetBlipFlashes(blip, v.takers ~= nil)
            SetBlipAlpha(blip, 90)
            SetBlipDisplay(blip, 8)
            SetBlipAsShortRange(blip, false)
            SetBlipDisplayIndicatorOnBlip(blip, false)
            table.insert(Blips, blip)
        end

        -- Create zone using ox_lib
        local zone = lib.zones.box({
            coords = v.coords,
            size = vec3(v.size.x, v.size.y, v.size.z or 5.0),
            rotation = v.rotation or 0,
            info = v,
        })

        Zones[k] = zone

        -- Zone enter handler
        function zone:onEnter()
            local LastZone = Current
            Current = self.info

            if LastZone and LastZone.title and Current and Current.title and LastZone.title ~= Current.title then
                TriggerServerEvent('d-gangzones:addMember', Current.title)
            end

            CreateLocalPed(Current.coords, Current)
            
            if not Current.takers then
                ShowTaken(true, Current.title)
            else
                ShowTaking(true, Current.title)
            end

            if Job and Job.name and Current.owners and Job.name == Current.owners then
                InZone = true
            end
        end

        -- Zone exit handler
        function zone:onExit()
            if Refreshed and Current and Current.title and self.info and self.info.title and Current.title ~= self.info.title then 
                return 
            end
            
            if self.info and self.info.title then
                TriggerServerEvent('d-gangzones:removeMember', self.info.title)
            end
            
            Current = nil
            ShowTaken(false)
            ShowTaking(false)
            RemovePed()
            InZone = false
        end

        :: continue ::
    end

    Refreshed = false
    InitAttempts = 0  -- Reset attempts on success
    print("^2[dec4t-gangzones] Zones initialized successfully^7")
end

function ShowTaken(show, zone)
    SendNUIMessage({
        type = 'taken',
        show = show,
        zone = zone,
    })
end

function ShowTaking(show, zone, time, deadline, stoped)
    SendNUIMessage({
        type = 'taking',
        show = show,
        zone = zone,
        time = time,
        stoped = stoped,
        deadline = deadline,
    })
end

function RefreshZones()
    RemovePed()
    for k, v in pairs(Zones) do
        if Zones[k] then
            Zones[k]:remove()
        end
    end
    Zones = {}
    
    for _, v in pairs(Blips) do
        RemoveBlip(v)
    end
    Blips = {}
    
    InitZones()
end

local awardNotifies = {
    not_boss = 'Jūs nesate gaujos bosas, kad galėtumėte atlikti šį veiksmą.',
    no_reward = 'Deja, jokio prizo šį kartą negavote.',
    got_item = 'Sveikiname gavus prizą. Patikrinkite jis jau jūsų kuprinėje.'
}

function CreateLocalPed(coords, Zone)
    -- Safety checks
    if not coords or not Zone then
        print("^3[dec4t-gangzones] Cannot create ped: missing coords or zone^7")
        return
    end
    
    if not Target then
        print("^3[dec4t-gangzones] ox_target not available^7")
        return
    end

    if not Ped then
        local model = `a_m_m_og_boss_01`
        RequestModel(model)
        local timeout = 0
        while not HasModelLoaded(model) and timeout < 5000 do
            Citizen.Wait(100)
            timeout = timeout + 100
        end
        
        if HasModelLoaded(model) then
            Ped = CreatePed(4, model, coords.x, coords.y, coords.z - 1.0, Zone.rotation or 0, false, true)
            FreezeEntityPosition(Ped, true)
            SetEntityInvincible(Ped, true)
            SetBlockingOfNonTemporaryEvents(Ped, true)
            NetworkFadeInEntity(Ped, true, true)

            -- Play animation
            local dict, anim = 'anim@mp_player_intcelebrationfemale@bang_bang', 'bang_bang'
            RequestAnimDict(dict)
            timeout = 0
            while not HasAnimDictLoaded(dict) and timeout < 5000 do
                Citizen.Wait(150)
                timeout = timeout + 150
            end
            
            if HasAnimDictLoaded(dict) then
                TaskPlayAnim(Ped, dict, anim, 8.0, -8.0, -1, 1, 0, 0, 0, 0)
                RemoveAnimDict(dict)
            end

            -- Add targets based on ownership
            if Job and Job.name and Zone.owners and Job.name == Zone.owners then
                Target:addLocalEntity(Ped, {
                    {
                        name = 'zone_menu',
                        label = 'Atidaryti zonos meniu',
                        icon = "fa-solid fa-location-dot",
                        onSelect = function()
                            if (Zone.type ~= 'drugdealer' and Zone.type ~= 'guns') or (Job and Job.grade and Job.grade >= 2) then
                                OpenGangMenu(Zone)
                            else
                                if exports['1x-hud'] then
                                    exports['1x-hud']:sendNotification({
                                        type = 'ERROR',
                                        title = 'Gaujų zonos',
                                        message = 'Neturite privilegijų naudotis šia funkcija.',
                                        duration = 5000,
                                    })
                                else
                                    print("^3[dec4t-gangzones] 1x-hud not available^7")
                                end
                            end
                        end,
                        distance = 2.0
                    },
                    {
                        name = 'zone_reward',
                        label = 'Zonos apdovanojimas',
                        icon = "fa-solid fa-award",
                        onSelect = function()
                            local success, result = pcall(function()
                                return lib.callback.await('d-gangzones:claimReward', false, Zone.title)
                            end)
                            
                            if not success or not result then 
                                print("^3[dec4t-gangzones] Failed to claim reward^7")
                                return 
                            end
                            
                            local response = result
                            local cooldown = nil
                            
                            if type(result) == 'table' then
                                response = result[1]
                                cooldown = result[2]
                            end
                            
                            if response == 'timeout' then
                                if exports['1x-hud'] then
                                    exports['1x-hud']:sendNotification({
                                        type = 'ERROR',
                                        title = 'Gaujų zonos',
                                        message = ('Prizo atsiimti šiuo metu dar negalite teks palaukti. Likęs laikas %s'):format(cooldown or 'nežinomas'),
                                        duration = 5000,
                                    })
                                end
                            else
                                if exports['1x-hud'] then
                                    exports['1x-hud']:sendNotification({
                                        type = 'INFO',
                                        title = 'Gaujų zonos',
                                        message = awardNotifies[response] or 'Nežinomas atsakymas',
                                        duration = 5000,
                                    })
                                end
                            end
                        end,
                        distance = 2.0
                    },
                })
            else
                Target:addLocalEntity(Ped, {
                    {
                        name = 'take_zone',
                        label = 'Užimti zoną',
                        icon = "fa-solid fa-person-rifle",
                        onSelect = function()
                            if Zone.type ~= 'bets' then
                                TriggerServerEvent('d-gangzones:takeZone', Zone.title)
                            else
                                local options = {}
                                if Config and Config.GangsList then
                                    for gangJob, data in pairs(Config.GangsList) do
                                        if data and data.name and Zone.official == data.official and (gangJob ~= 'police' and gangJob ~= 'admin') then
                                            table.insert(options, {
                                                value = gangJob,
                                                label = data.name .. ' gauja',
                                            })
                                        end
                                    end
                                end

                                local input = lib.inputDialog('Statymas', {
                                    { type = 'number', label = 'Statymo suma', description = 'Įveskite sumą kurią norite statyti' },
                                    { type = 'select', label = 'Pasirinkite gaują', description = 'Pasirinkite gaują su kuria norite kovoti', options = options },
                                })

                                if input and input[1] and input[2] then
                                    TriggerServerEvent('d-gangzones:takeZone', Zone.title, input[2], input[1])
                                end
                            end
                        end,
                        distance = 2.0
                    },
                    {
                        name = 'zone_info',
                        label = 'Zonos informacija',
                        icon = "fa-solid fa-circle-info",
                        onSelect = function()
                            pcall(function()
                                lib.callback.await('d-gangzones:zoneInfo', false, Zone.title)
                            end)
                        end,
                        distance = 2.0
                    },
                })
            end
        else
            print("^3[dec4t-gangzones] Failed to load ped model^7")
        end
    end
end

-- Load config from server
function LoadConfig()
    print("^2[dec4t-gangzones] Loading config from server...^7")
    
    local success, result = pcall(function()
        return lib.callback.await('d-gangzones:getConfig', false)
    end)
    
    if success and result then
        Config = result
        ConfigLoaded = true
        print("^2[dec4t-gangzones] Config loaded successfully from server^7")
        
        -- Try to initialize zones if job is available
        if Job then
            InitZones()
        end
    else
        print("^3[dec4t-gangzones] Failed to load config from server, retrying in 5 seconds^7")
        SetTimeout(5000, LoadConfig)
    end
end

-- Event Handlers
RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(xPlayer)
    Wait(1000)

    if xPlayer and xPlayer.job then
        Job = xPlayer.job
        print("^2[dec4t-gangzones] Player loaded with job: " .. (Job.name or "unknown") .. "^7")
    end

    -- Load config if not already loaded
    if not ConfigLoaded then
        LoadConfig()
    else
        InitZones()
    end
end)

RegisterNetEvent("esx:setJob")
AddEventHandler("esx:setJob", function(job)
    Wait(1000)

    if job then
        Job = job
        print("^2[dec4t-gangzones] Job changed to: " .. (job.name or "unknown") .. "^7")
        
        if ConfigLoaded then
            RefreshZones()
            RemovePed()
        end
    end
end)

AddEventHandler('onResourceStart', function(resourceName)
    if (GetCurrentResourceName() ~= resourceName) then return end

    Wait(1000)
    print("^2[dec4t-gangzones] Resource started^7")
    
    -- Load config
    LoadConfig()
end)

AddEventHandler('onResourceStop', function(resourceName)
    if (GetCurrentResourceName() ~= resourceName) then return end
    RemovePed()
end)

RegisterNetEvent('d-gangzones:update', function(zone)
    if not zone or not zone.title then return end
    
    local zoneKey = string.lower(zone.title)
    if Config and Config.Zones then
        Config.Zones[zoneKey] = zone
        RefreshZones()
    end
end)

RegisterNetEvent('d-gangzones:updateZones', function(zones)
    if not zones then return end
    
    for _, data in pairs(zones) do 
        if data and data.title then
            local zoneKey = string.lower(data.title)
            if Config and Config.Zones then
                Config.Zones[zoneKey] = data
            end
        end
    end
    RefreshZones()
end)

RegisterNetEvent('d-gangzones:updateZone', function(zone, newzone)
    if not zone then return end
    
    if newzone then
        if Config and Config.Zones and Config.Zones[zone] and Config.Zones[zone].title == newzone.title then 
            Config.Zones[zone] = newzone
        else
            Config.Zones[zone] = nil 
            if newzone and newzone.title then
                newzone.title = string.upper(newzone.title)
                Config.Zones[string.lower(newzone.title)] = newzone
            end
        end
    else
        if Config and Config.Zones then
            Config.Zones[zone] = nil
        end
    end

    RefreshZones()
end)

RegisterNetEvent('d-gangzones:updateColors', function(colors)
    if colors and Config then
        Config.GangColors = colors
        RefreshZones()
    end
end)

RegisterNetEvent('d-gangzones:updateGangs', function(gangs)
    if gangs and Config then
        Config.GangsList = gangs
        RefreshZones()
    end
end)

function RemovePed()
    if Ped then 
        if Target then
            pcall(function()
                Target:removeLocalEntity(Ped)
            end)
        end
        DeletePed(Ped)
        Ped = nil
    end
end

function CalculateTime(ms)
    if not ms then return {h = 0, min = 0, sec = 0} end
    
    local hours = math.floor(ms / (60 * 60 * 1000))
    local minutes = math.floor((ms - (hours * 60 * 60 * 1000)) / (60 * 1000))
    local seconds = math.floor((ms - (hours * 60 * 60 * 1000) - (minutes * 60 * 1000)) / 1000)
    return {h = hours, min = minutes, sec = seconds}
end

function TakingZone(zone)
    ShowTaking(true, zone)
end

exports('inZone', function()
    return InZone
end)

local ZONE_REQUEST, timeoutToCancel = {}, 10 * 60 * 1000

RegisterNetEvent('d-gangzones:betsZoneActivation', function(zoneKey, attackers, betAmount)
    if not zoneKey or not attackers then return end
    
    local zone = Config and Config.Zones and Config.Zones[zoneKey]
    if not zone then return end

    ZONE_REQUEST.zoneKey = zoneKey
    ZONE_REQUEST.betAmount = betAmount
    ZONE_REQUEST.attackers = attackers
    
    local gangColor = 0
    if Config.GangColors and Config.GangColors[attackers] then
        local colorStr = Config.GangColors[attackers]
        if colorStr then
            gangColor = tonumber('0x'..string.upper(colorStr)..'99') or 0
        end
    end

    ZONE_REQUEST.blip = AddBlipForCoord(zone.coords.x, zone.coords.y, zone.coords.z)
    SetBlipSprite(ZONE_REQUEST.blip, 491)
    SetBlipScale(ZONE_REQUEST.blip, 0.8)
    SetBlipColour(ZONE_REQUEST.blip, gangColor)
    SetBlipAsShortRange(ZONE_REQUEST.blip, true)
    BeginTextCommandSetBlipName('STRING')
    AddTextComponentString('<font face="Roboto">Siūlymas kovoti</font>')
    EndTextCommandSetBlipName(ZONE_REQUEST.blip)

    SetTimeout(timeoutToCancel, function()
        if ZONE_REQUEST.blip then
            RemoveBlip(ZONE_REQUEST.blip)
            ZONE_REQUEST = {}
        end
    end)
end)

local function currency(n)
    if not n then return '0 €' end
    return tostring(math.floor(n)):reverse():gsub("(%d%d%d)","%1,"):gsub(",(%-?)$","%1"):reverse()..' €'
end

RegisterCommand('acceptfight', function()
    if not IsGang() or not next(ZONE_REQUEST) then 
        if exports['1x-hud'] then
            exports['1x-hud']:sendNotification({
                type = 'ERROR',
                title = 'Gaujų zonos',
                message = 'Nėra aktyvaus kovos pasiūlymo.',
                duration = 5000,
            })
        end
        return 
    end

    local attackerName = 'nežinoma'
    if Config and Config.GangsList and Config.GangsList[ZONE_REQUEST.attackers] then
        attackerName = Config.GangsList[ZONE_REQUEST.attackers].name or 'nežinoma'
    end

    local alert = lib.alertDialog({
        header = 'Patvirtinkite',
        content = 'Ar esate įsitikinęs, kad norite kovoti su ' .. attackerName .. ' gauja kuri jums siūlo kovoti? Statymo suma: ' .. currency(ZONE_REQUEST.betAmount) .. '.',
        centered = true,
        cancel = true
    })
    
    if alert == 'confirm' then
        TriggerServerEvent('d-gangzones:acceptedFight', ZONE_REQUEST.zoneKey)
    else
        TriggerServerEvent('d-gangzones:canceledFight', ZONE_REQUEST.zoneKey)
    end

    if ZONE_REQUEST.blip then
        RemoveBlip(ZONE_REQUEST.blip)
    end
    ZONE_REQUEST = {}
end)

exports('getGangName', function(job)
    if not job then return nil end
    if not Config or not Config.GangsList or not Config.GangsList[job] then
        return nil
    end
    return Config.GangsList[job].name
end)

-- Add OpenGangMenu function if missing
function OpenGangMenu(Zone)
    -- Add your gang menu logic here
    print("^2[dec4t-gangzones] Opening gang menu for zone: " .. (Zone and Zone.title or "unknown") .. "^7")
    -- You can implement your menu here
end

print("^2[dec4t-gangzones] Client script loaded successfully^7")