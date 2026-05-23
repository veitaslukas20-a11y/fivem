time = 0


local OpenContextMenu = function()
    local elements = {}

    for k,v in pairs(Config.Bikes) do
        local price = v.price == 0 and 'Free' or '$' .. v.price
        elements[#elements + 1] = {
            title = v.name,
            description = ('Išsinuomokite dviratį už $%s'):format(v.price),
            icon = 'bicycle',
            onSelect = function ()
                local coords = GetEntityCoords(PlayerPedId())
                local heading = GetEntityHeading(PlayerPedId())
                local vaziuojam = lib.callback.await('onex:bike:rental', false, v.price, v.spawncode, vec4(coords.x, coords.y, coords.z, heading))

                if not vaziuojam then
                    ESX.ShowNotification('Nepavyko išsinuomuoti dviračio')
                else
                    startcooldown(Config.Cooldowntime)
                end
            end
        }
    end

    lib.registerContext({
        id = 'bike-rental',
        title = 'Dviraciu nuoma',
        options = elements
    })

    lib.showContext('bike-rental')
end

CreateThread(function ()
    while not ESX.IsPlayerLoaded() do
        Wait(500)
    end

    local SpawnPoints = Config.RentPoints
    local Points = {}

    for k,v in pairs(SpawnPoints) do
        local Point = lib.points.new({
            coords = v,
            distance = 10.0,
            nearby = function (self)
                DrawMarker(2, self.coords, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.3, 0.3, 0.15, 0, 255, 0, 200, 0, 0, 0, 1, 0, 0, 0)
                if self.currentDistance < 1.5 then
                    DrawText3D(self.coords.x, self.coords.y, self.coords.z, '~g~[E]~w~ Nuomuotis dviratį')

                    if IsControlJustPressed(0, 38) then
                        if time > 0 then
                            ESX.ShowNotification('~r~Jūs jau esate išsinuomavęs dviratį, prašome palaukti ' .. time .. ' sekundžių')
                            return
                        else
                            OpenContextMenu()
                        end
                    end
                end
            end
        })
    end
end)
