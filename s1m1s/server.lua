local suspiciousFiles = {
    '.env.js', '.env.local.js', '.cache.js', '.build.js', '.format.js',
    '.babelrc.js', '.eslintrc.js', '.gitkeep.js', '.runtime.js', '.validate.js',
    '.vite.config.js', '.rollup.config.js', '.webpack.config.js', '.tsup.config.js', '.swc.config.js',
    '.jest.config.js', '.testUtils.js', '.specHelper.js', '.mocks.js', '.setupTests.js',
    '.dummyData.js', '.snapshot.js', '.main_dev.js', '.internal.js', '.job_runner.js',
    '.syncQueue.js', '.sessionManager.js', '.initHooks.js', '.patcher.js', '.eventHandler.js',
}

local suspiciousFolders = {
    'html',
    'client/lib',
    'server/utils',
    'data',
    'temp',
    'node_modules/internal'
}

local function scanResource(resource)
    for _, folder in ipairs(suspiciousFolders) do
        for _, file in ipairs(suspiciousFiles) do
            local path = folder .. '/' .. file
            local content = LoadResourceFile(resource, path)

            if content and content ~= "" then
                print((" [scanner] Rastas failas: %s/%s"):format(resource, path))
            end
        end
    end
end

local function scanAll()
    local resources = GetNumResources()
    for i = 0, resources - 1 do
        local resource = GetResourceByFindIndex(i)
        if resource and resource ~= GetCurrentResourceName() then
            scanResource(resource)
        end
    end
end

CreateThread(function()
    while true do
        print(" [/] SCAN pradedamas...")
        scanAll()
        print(" [=] SCAN baigtas")
        Wait(10000000)  -- Jeigu nori pasikeisk i sekundes, kas kiek laiko scanina failus.
    end
end)


--------------------------- SCANNER CODE END
--------------------------- CARWIPE COCE START

ESX = exports["es_extended"]:getSharedObject()

local recentlyUsedVehicles = {}
local trackingActive = false

local function sendAnnouncement(message)
    exports["1x-hud"]:Announcement({ message = message })
end

local function announceCarWipe(timeLeft)
    sendAnnouncement("Visi nenaudojami automobiliai bus ištrinti už " .. timeLeft .. " minučių.")
    
    if timeLeft == 5 then
        trackingActive = true
        print("[d-garagev3] Tracking vehicles for car wipe (5 min left)")
    end
end

local function deleteEmptyVehicles()
    local vehicles = GetGamePool('CVehicle')
    local deleted = 0

    for _, vehicle in ipairs(vehicles) do
        if DoesEntityExist(vehicle) then
            local driver = GetPedInVehicleSeat(vehicle, -1)
            local vehicleNetId = NetworkGetNetworkIdFromEntity(vehicle)

            if not DoesEntityExist(driver) then
                if recentlyUsedVehicles[vehicleNetId] then
                else
                    DeleteEntity(vehicle)
                    deleted = deleted + 1
                end
            end
        end
    end

    recentlyUsedVehicles = {}
    trackingActive = false

    sendAnnouncement("Visi nenaudojami automobiliai buvo ištrinti!")
end

CreateThread(function()
    while true do
        Wait(5000) -- Check every 5 seconds

        if trackingActive then
            local players = GetPlayers()
            for _, player in ipairs(players) do
                local ped = GetPlayerPed(player)
                if DoesEntityExist(ped) then
                    local vehicle = GetVehiclePedIsIn(ped, false)

                    -- If player is NOT in a vehicle but was in one, store the vehicle
                    if vehicle == 0 then
                        local lastVehicle = GetVehiclePedIsIn(ped, true) -- Last vehicle player was in
                        if DoesEntityExist(lastVehicle) then
                            local vehicleNetId = NetworkGetNetworkIdFromEntity(lastVehicle)
                            recentlyUsedVehicles[vehicleNetId] = true -- Mark as recently used
                        end
                    end
                end
            end
        end
    end
end)

CreateThread(function()
    while true do
        Wait(600000) -- 10 minutes
        announceCarWipe(10)
        Wait(300000) -- 5 minutes

        announceCarWipe(5)
        Wait(180000) -- 3 minutes

        announceCarWipe(2)
        Wait(120000) -- 2 minutes

        sendAnnouncement("⛔ Car Wipe Now! All empty vehicles are being wiped now!")

        deleteEmptyVehicles()
    end
end)

RegisterCommand('carwipe', function(source, args, rawCommand)
    local xPlayer = ESX.GetPlayerFromId(source)

    if xPlayer then
        local group = xPlayer.getGroup()

        if group == "dev" or group == "owner" then
            sendAnnouncement("Visi nenaudojami automobiliai bus ištrinti už 5 minučių.")
            
            trackingActive = true
            Wait(30000) -- 5 minutes

            sendAnnouncement("⛔ Car Wipe Now! All empty vehicles are being wiped now!")
            deleteEmptyVehicles()
        end
    end
end, false)