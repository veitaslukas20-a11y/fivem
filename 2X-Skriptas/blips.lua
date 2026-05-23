local blips = {
  -- Example {title="", colour=, id=, x=, y=, z=},
-- Postes de polices
  {title= "Kartingai", colour = 36, id=426, x = -158.54, y = -2148.19, z = 16.71},
}

Citizen.CreateThread(function()
  CreateFonts()
  print('Sukuriau fontus')
  Wait(100)
  for _, info in pairs(blips) do
    info.blip = AddBlipForCoord(info.x, info.y, info.z)
    SetBlipSprite(info.blip, info.id)
    SetBlipDisplay(info.blip, 4)
    SetBlipScale(info.blip, 0.6)
    SetBlipColour(info.blip, info.colour)
    SetBlipAsShortRange(info.blip, true)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString('<font face="Roboto">'..info.title..'</font>')
    EndTextCommandSetBlipName(info.blip)
  end
end)

AddEventHandler('onClientResourceStop', function (resourceName)
  if(GetCurrentResourceName() ~= resourceName) then
    return
  end
  for k,v in pairs(blips) do
    RemoveBlip(v.blip)
  end
end)


