local cooldown = false

RegisterNetEvent("CEventGunShot", function(entities, entity, data)
    if not ESX.IsPlayerLoaded() then return end 

    local pPed = PlayerPedId()

    if entity ~= pPed then return end
    if not IsPedShooting(pPed) then return end 
    if cooldown then return end 

    local pJob = ESX.GetPlayerData().job.name
    if Config.whitelistedJobs[pJob] then return end

    local gunHash = GetSelectedPedWeapon(pPed)
    if Config.whitelistedGuns[gunHash] then return end 
    if IsPedCurrentWeaponSilenced(pPed) then return end

    local pCoords = GetEntityCoords(pPed)
    for k, v in pairs(Config.objects) do
        local obj = GetClosestObjectOfType(pCoords.x, pCoords.y, pCoords.z, Config.cameraRange, v, false, false, false)
        if obj ~= 0 then
            local data = exports['cd_dispatch']:GetPlayerInfo()
            TriggerServerEvent('cd_dispatch:AddNotification', {
                job_table = {'police'}, 
                coords = data.coords,
                title = '10-71 - Paleisti šūviai',
                message = data.street.." kamera užfiksavo jog, "..data.sex.." paleido šūvius", 
                flash = 0,
                unique_id = tostring(math.random(99999999999)),
                sound = 2,
                blip = {
                    sprite = 110, 
                    scale = 1.2, 
                    colour = 3,
                    flashes = true, 
                    text = '10-71 - Paleisti šūviai',
                    time = 5,
                    radius = 0,
                }
            })
            cooldown = true
            SetTimeout(30000, function()
                cooldown = false
            end)
            break
        end
    end
end)