local function GetVehicleModPers(vehicle, mod)
    local count = GetNumVehicleMods(vehicle, mod)
    local modCount = (GetVehicleMod(vehicle, mod) + 1)
    return (count > 0 and modCount > 0) and ((modCount / count) * 100) or 0
end

RegisterCommand("checktune", function()
    local ped = PlayerPedId()
    local vehicle = GetVehiclePedIsIn(ped, false)

    if vehicle == 0 then
        lib.notify({
            title = "Patikrinimas",
            description = "Jūs nesate transporto priemonėje.",
            type = "error"
        })
        return
    end

    lib.registerContext({
        id = 'onex-vehicle-info',
        title = 'Automobilio informacija',
        options = {
            {
                title = 'Variklis',
                description = 'Variklio galingumo lygis ('.. math.floor(GetVehicleModPers(vehicle, 11) + 0.5) .. '%)',
                progress = math.floor(GetVehicleModPers(vehicle, 11) + 0.5),
            },
            {
                title = 'Stabdžiai',
                description = 'Stabdžių galingumo lygis ('.. math.floor(GetVehicleModPers(vehicle, 12) + 0.5) .. '%)',
                progress = math.floor(GetVehicleModPers(vehicle, 12) + 0.5),
            },
            {
                title = 'Turbina',
                description = 'Turbinos galingumo lygis ('.. (IsToggleModOn(vehicle, 18) and 100 or 0) .. '%)',
                progress = IsToggleModOn(vehicle, 18) and 100 or 0,
            },
            {
                title = 'Pavarų dėžė',
                description = 'Pavarų dėžės galingumo lygis ('.. math.floor(GetVehicleModPers(vehicle, 13) + 0.5) .. '%)',
                progress = math.floor(GetVehicleModPers(vehicle, 13) + 0.5),
            },
            {
                title = 'Pakabos nuleidimas',
                description = 'Pakabos nuleidimo lygis ('.. math.floor(GetVehicleModPers(vehicle, 15) + 0.5) .. '%)',
                progress = math.floor(GetVehicleModPers(vehicle, 15) + 0.5),
            },
            {
                title = 'Automobilio apsauga',
                description = 'Automobilio apsauga lygis ('.. math.floor(GetVehicleModPers(vehicle, 16) + 0.5) .. '%)',
                progress = math.floor(GetVehicleModPers(vehicle, 16) + 0.5),
            }
        }
    })
    lib.showContext('onex-vehicle-info')
end, false)