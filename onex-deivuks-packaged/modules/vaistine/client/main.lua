Pharmacy, Ped = nil, nil
local Vaistine = {}

local function OpenMenu()
    --[[lib.callback('s1m1s-vaistine:getAmbulance', false, function(medic)
        if not medic then ]]
            Vaistine.Prices = lib.callback.await('s1m1s-vaistine:returnPrices', false)
            lib.registerContext({
                id = 's1m1s_vaistine',
                title = 'Vaistinė',
                options = {
                    {
                        title = 'Vaistinėlė',
                        description = 'Pirkti vaistinėlę už '.. Vaistine.Prices.medikitas ..'€',
                        icon = "fa-solid fa-suitcase-medical",
                        onSelect = function()
                            local input = lib.inputDialog('Pasirinkite kiekį', {'Įveskite kiekį'})
                            if not input then return end
                            lib.callback.await('s1m1s-vaistine:buy', false, 'medikitas', input[1])
                        end,
                    },
                    {
                        title = 'Tvarsčiai',
                        description = 'Pirkti tvarsčius už '.. Vaistine.Prices.bandage ..'€',
                        icon = "fa-solid fa-bandage",
                        onSelect = function()
                            local input = lib.inputDialog('Pasirinkite kiekį', {'Įveskite kiekį'})
                            if not input then return end
                            lib.callback.await('s1m1s-vaistine:buy', false, 'bandage', input[1])
                        end,
                    },
                }
            })
            lib.showContext('s1m1s_vaistine')
        --[[else
            exports['1x-hud']:sendNotification({
                type = 'ERROR',
                title = 'Vaistinė',
                message = 'Deja, šiuo metu yra perdaug medikų, kurie jus gali aptarnauti ligoninėje. Jeigu norite nusipirkti medikamentų vykite į ligoninę.',
                duration = 6000,
                icon = 'staff-snake'
            })
        end
    end)]]
end

local function CreateLocalPed(coords)
    if not Ped then
        RequestModel(`s_m_m_doctor_01`)
        while not HasModelLoaded(`s_m_m_doctor_01`) do
            Wait(100)
        end
        Ped = CreatePed(4, `s_m_m_doctor_01`, coords.x, coords.y, coords.z -1.0, coords.w, false, true)
        FreezeEntityPosition(Ped, true)
        SetEntityInvincible(Ped, true)
        SetBlockingOfNonTemporaryEvents(Ped, true)
        NetworkFadeInEntity(Ped, true)


        exports.qtarget:AddTargetEntity(Ped, {
            options = {
                {
                    icon = "fa-solid fa-hand-holding-medical",
                    action = function()
                        OpenMenu()
                    end,
                    label = 'Teirautis pas vaistininką',
                },
            },
            distance = 2.0
        })
    end
end

Citizen.CreateThread(function()
    while not ESX.IsPlayerLoaded() do Wait(500) end
    Vaistine = lib.callback.await('vaistine:getConfig', false)

    for k,v in pairs(Vaistine.Pharmacies) do
        local blip = AddBlipForCoord(vec3(Vaistine.Pharmacies[k].x, Vaistine.Pharmacies[k].y, Vaistine.Pharmacies[k].z))
        SetBlipSprite(blip, 403)
        SetBlipColour(blip, 1)
        SetBlipScale(blip, 0.8)
        SetBlipAsShortRange(blip, true)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString('<font face="Roboto">Vaistinė</font>')
        EndTextCommandSetBlipName(blip)

        local point = lib.points.new({
            coords = vec3(Vaistine.Pharmacies[k].x, Vaistine.Pharmacies[k].y, Vaistine.Pharmacies[k].z),
            distance = 15,
        })

        function point:onEnter()
            CreateLocalPed(v)
        end

        function point:onExit()
            if Ped then
                exports.qtarget:RemoveTargetEntity(Ped)
                DeletePed(Ped)
                Ped = nil
            end
        end
    end
end)