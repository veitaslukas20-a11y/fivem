local cooldown = false

local function Cooldown()
    if cooldown then
        ShowNotification('Negalite dėti objektų taip greitai!', 'error')
    else
        cooldown = true
        SetTimeout(4000, function()
            cooldown = false
        end)
        return true
    end
end

local jobs = {
    ['police'] = 0,
}

local function CreateProp(model, freeze)
    local playerPed = PlayerPedId()
    local coords = GetOffsetFromEntityInWorldCoords(playerPed, 0.0, 0.5, 0.0)
    local heading = GetEntityHeading(playerPed)
    
    local netid = lib.callback.await('pdprops:createobj', false, model, coords, heading)
    local object = NetworkGetEntityFromNetworkId(netid)
    PlaceObjectOnGroundProperly(object)
    if freeze then FreezeEntityPosition(object, true) end
end

CreateThread(function()
    exports.ox_target:addModel({ `prop_roadcone02a`, `p_ld_stinger_s`, `prop_barrier_work06a`, `prop_mp_barrier_02b`, `prop_barrier_work01b`, `prop_boxpile_07d`, `prop_mp_arrow_barrier_01`, `prop_mp_conc_barrier_01` }, {
        {
            name = 'remove_prop',
            icon = 'fa-solid fa-trash',
            label = 'Panaikinti objektą',
            groups = jobs,
            onSelect = function(data)
                if lib.progressCircle({
                    duration = 3500,
                    position = 'bottom',
                    label = 'Objektas naikinamas...',
                    useWhileDead = false,
                    canCancel = true,
                    anim = {
                        dict = 'mini@repair',
                        clip = 'fixing_a_player'
                    },
                    disable = {
                        move = true,
                        car = false
                    },
                }) then 
                    lib.callback.await('pdprops:removeobj', false, NetworkGetNetworkIdFromEntity(data.entity))
                end
            end
        }
    })
    lib.registerRadial({
        id = 'pdprops',
        items = {
            {
                icon = 'triangle-exclamation',
                label = 'Kūgis',
                onSelect = function()
                    if not Cooldown() then return end
                    CreateProp(`prop_roadcone02a`)
                end
            },
            {
                
                icon = 'road-spikes',
                label = 'Spygliai',
                onSelect = function()
                    exports['s1m1s-policejob']:deploySpikestrip()
                end
            },
            {
                icon = 'road-barrier',
                label = 'Užtvara',
                onSelect = function()
                    if not Cooldown() then return end
                    CreateProp(`prop_barrier_work06a`)
                end
            },
            {
                icon = 'road-barrier',
                label = 'Užtvara',
                onSelect = function()
                    if not Cooldown() then return end
                    CreateProp(`prop_mp_barrier_02b`)
                end
            },
            {
                icon = 'road-barrier',
                label = 'Užtvara',
                onSelect = function()
                    if not Cooldown() then return end
                    CreateProp(`prop_barrier_work01b`)
                end
            },
            {
                icon = 'fa-solid fa-road-barrier',
                label = 'Užtvara',
                onSelect = function()
                    if not Cooldown() then return end
                    CreateProp(`prop_mp_conc_barrier_01`, true)
                end
            },
            {
                icon = 'fa-solid fa-box',
                label = 'Dėžės',
                onSelect = function()
                    if not Cooldown() then return end
                    CreateProp(`prop_boxpile_07d`)
                end
            },
            {
                icon = 'fa-solid fa-location-arrow',
                label = 'Rodyklė',
                onSelect = function()
                    if not Cooldown() then return end
                    CreateProp(`prop_mp_arrow_barrier_01`)
                end
            },
        }
    })
end)

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded',function(xPlayer, isNew, skin)
    if jobs[xPlayer.job.name] then
        lib.addRadialItem({
            {
                id = 'police',
                label = 'Objektai',
                icon = 'fa-solid fa-box-open',
                menu = 'pdprops'
            },
        })
    end
end)

RegisterNetEvent("esx:setJob") 
AddEventHandler("esx:setJob", function(job) 
    if jobs[job.name] then
        lib.addRadialItem({
            {
                id = 'police',
                label = 'Objektai',
                icon = 'fa-solid fa-box-open',
                menu = 'pdprops'
            },
        })
    end 
end) 

--[[RegisterKeyMapping('pdprops', 'Objektų meniu', 'keyboard', 'F5')

RegisterCommand('pdprops', function()
    if jobs[ESX.GetPlayerData().job.name] == nil then return end
    lib.showContext('pdprops')
end, false)]]