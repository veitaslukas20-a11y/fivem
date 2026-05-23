local postals = {}

Citizen.CreateThread(function()
    postcodes = json.decode(LoadResourceFile(GetCurrentResourceName(), 'postals.json'))
    for k,v in pairs(postcodes) do 
        postals[v.code] = vec2(v.x, v.y)
    end
end)

RegisterCommand('postal', function(source, args)
    if not args[1] then return end
    local coords = postals[args[1]]
    SetNewWaypoint(coords.x, coords.y)
end)