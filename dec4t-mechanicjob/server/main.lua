ESX = exports['es_extended']:getSharedObject()

RegisterNetEvent('dec4t-mechanic:deleteveh')
AddEventHandler('dec4t-mechanic:deleteveh', function(netId)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    if not xPlayer then return end
    if not xPlayer.job or not Config.Jobs[xPlayer.job.name] then return end

    local vehicle = NetworkGetEntityFromNetworkId(netId)
    if DoesEntityExist(vehicle) then
        DeleteEntity(vehicle)
    end
end)
