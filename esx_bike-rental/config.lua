Config = {}
-- If you want people to have cooldown on renting a bike
-- You can put 0 if you dont
Config.Cooldowntime = 100 -- Seconds
-- Blips
Config.EnableBlips = true
Config.BlipSprite = 376
Config.BlipDisplay = 4
Config.BlipScale = 0.65
Config.BlipColour = 2
Config.BlipName = "Dviračių nuoma"
-- Points for bikes
Config.RentPoints = {
    vector3(-769.36, 5592.66, 33.49),
    vector3(-353.89, 6152.79, 31.48),
    vector3(-62.64, 6444.44, 31.49),
    vector3(1695.78, 4792.77, 41.92),
    vector3(2750.18, 3453.73, 56.01),
    vector3(1890.16, 3711.75, 32.85),
    vector3(207.5990, -929.0873, 30.6920),
    vec3(-283.3542, -989.7288, 31.1824),
    vec3(1839.4027, 2542.0869, 45.8738)
}

Config.Bikes = {
    {
        name = 'BMX ',
        price = 150,
        spawncode = 'bmx'
    },
    {
        name = 'Cruiser ',
        price = 80,
        spawncode = 'cruiser'
    },
    {
        name = 'Fixter ',
        price = 80,
        spawncode = 'fixter'
    },
    {
        name = 'TriBike ',
        price = 200,
        spawncode = 'tribike3'
    }
}
