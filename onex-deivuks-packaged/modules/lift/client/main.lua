local ShowText = false
local Teleport = nil
local pState = LocalPlayer.state

Citizen.CreateThread(function()
    ConfigLift = lib.callback.await('lift:getConfig', false)

    for _, v in pairs(ConfigLift.Locations) do
        lib.points.new({
            coords = v.from,
            distance = 3.0,
            nearby = function(self)
                if self.currentDistance and self.currentDistance < 1.2 then
                    if Teleport ~= v.to then
                        Teleport = v.to
                    end
                    if not ShowText then
                        ShowText = true
                        lib.showTextUI('[E] - Naudotis liftu', {
                            position = "bottom-center",
                            icon = 'person-walking-arrow-right',
                        })
                    end
                elseif ShowText then
                    Teleport = nil
                    ShowText = false
                    lib.hideTextUI()
                end
            end,
            onExit = function()
                if Teleport then
                    Teleport = nil
                end
                if ShowText then
                    ShowText = false
                    lib.hideTextUI()
                end
            end
        })
    end
end)

lib.addKeybind({
    name = 'useLift',
    description = 'Naudotis liftu',
    defaultKey = 'E',
    onPressed = function(self)
        if Teleport and not cache.vehicle and not pState.dead then
            SetPedCoordsKeepVehicle(cache.ped, Teleport.x, Teleport.y, Teleport.z)
            Teleport = nil
        end
    end,
})