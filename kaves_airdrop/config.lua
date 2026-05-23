Config = {}

Config.Framework = "esx" -- esx - oldesx - qbcore - oldqb
Config.Target = "ox-target" -- ox-target - qb-target -- drawText
Config.Locales = {
    ["drop-coming"] = "Airdrop atkeliauja į miestą!",
    ["plane-name"] = "Lėktuvas",
    ["crate-name"] = "AirDrop",
    ["open-crate"] = "[E] - Atidaryti dėžę",
    ["time-is-not-up"] = "Reikia šiek tiek palaukti...",
    ["no-weapon"] = "Turite turėti ginklą rankoje, kad atidaryti dėžę",
    ["cant-while-dead"] = "Negalite atidaryti dežės, nes esate miręs.",
    ["cant-open-in-vehicle"] = "Negalite atidaryti dežės sėdint automobilyje.",
    ["drop-not-found"] = "Nieko nerasta!",
    ["collected-money"] = "Gavote ~g~$~w~%s iš air-dropo.",
    ["collected-item"] = "Jūs gavote %sx %s iš air-drop",
}

Config.pilotModel = "a_c_chimp"
Config.planeSpawnCoords = vector4(-2408.64, 5660.53, 553.9, 230.97)
Config.planeReturnCoords = vector3(2751.87, -5059.77, 357.68)
Config.planeBlips = {sprite = 573, color = 4}
Config.planeModels = {
    "titan",
    "avenger",
    "tula",
}

Config.crateModel = "prop_mil_crate_01"
Config.parachuteModel = "p_cargo_chute_s"
Config.crateBlips = {sprite = 94, color = 5}
Config.unlockCooldown = 10 -- 7 min

Config.dropCoords = {
    { coords = vector3(-889.2780, 4808.2295, 300.8981) },
    { coords = vector3(-416.1490, 4689.5747, 258.9284) },
    { coords = vector3(-550.1956, 4189.4243, 190.9137) },
    { coords = vector3(2211.3262, 2073.4048, 130.9070) },
    { coords = vector3(2337.9421, 2546.9009, 46.7048) },
    { coords = vector3(2625.6304, 3659.4902, 101.3481) },
    { coords = vector3(2213.4050, 5596.1108, 52.9086) },
    { coords = vector3(-2491.9822, 807.6789, 286.2168) },
    { coords = vector3(-63.7663, 2317.3000, 149.8909) },
}

Config.dropItems = {
    { -- Tier 1
        { name = "WEAPON_PISTOL", min = 2, max = 4 },
        { name = "WEAPON_SMG", min = 1, max = 3 },
        { name = "WEAPON_ASSAULTRIFLE", min = 1, max = 2 },
        { name = "armour", min = 2, max = 6 },
        { name = "medikitas", min = 5, max = 10 },
    },
    { -- Tier 2
        { name = "ammunition_rifle", min = 500, max = 800 },
        { name = "ammunition_pistol", min = 300, max = 700 },
        { name = "armour", min = 2, max = 6 },
        { name = "medikitas", min = 2, max = 6 },
    },
    { -- Tier 3
        { name = "WEAPON_ASSAULTRIFLE", min = 2, max = 5 },
        { name = "ammunition_rifle2", min = 500, max = 800 },
        { name = "armour", min = 3, max = 5 },
        { name = "medikitas", min = 2, max = 5 },
    },
    { -- Tier 4
        { name = "armour", min = 20, max = 30 },
        { name = "medikitas", min = 15, max = 25 },
        { name = "fixkitas", min = 10, max = 25 },
    },
    { -- Tier 5
        { name = "chaz_pennis", min = 100, max = 300 },
    },
    { -- Tier 6
        { name = "shibacoin", min = 1, max = 1 },
    },
    { -- Tier 7
        { name = "fixkitas", min = 10, max = 30 },
        { name = "medikitas", min = 10, max = 30 },
    },
    { -- Tier 8
        { name = "ammunition_rifle2", min = 800, max = 1000 },
        { name = "ammunition_rifle", min = 800, max = 1000 },
    },
    { -- Tier 9
        { name = "armour", min = 10, max = 20 },
        { name = "ammunition_pistol", min = 1000, max = 2000 },
    },
    { -- Tier 10
        { name = "coke", min = 250, max = 400 },
        { name = "weed_package", min = 250, max = 500 },
    },
    { -- Tier 11
        { name = "paracetamolis", min = 100, max = 200 },
        { name = "ketaminas", min = 100, max = 200 },
        { name = "aspirinas", min = 100, max = 200 },
    },
    { -- Tier 12
        { name = "copper", min = 200, max = 600 },
        { name = "diamond", min = 25, max = 75 },
    },
    { -- Tier 13
        { name = "black_money", min = 500000, max = 750000 },
    },
    { -- Tier 14
        { name = "gold", min = 300, max = 750 },
        { name = "iron", min = 300, max = 750 },
    },
    { -- Tier 15
        { name = "drill", min = 5, max = 30 },
    },
    { -- Tier 16
        { name = "WEAPON_APPISTOL", min = 2, max = 6 },
    },
    { -- Tier 17
        { name = "WEAPON_ASSAULTRIFLE", min = 2, max = 5 },
    },
    { -- Tier 18
        { name = "heavy_armour", min = 5, max = 15 },
    },
    { -- Tier 19
        { name = "WEAPON_ASSAULTSMG", min = 3, max = 6 },
    },
    { -- Tier 20
        { name = "WEAPON_PISTOL50", min = 2, max = 5 },
    },
}

Config.civilDropItems = {
    { -- Tier 1
        { name = "lockpick", min = 63, max = 125 },
        { name = "medikitas", min = 13, max = 38 },
        { name = "fixkitas", min = 13, max = 25 },
        { name = "heroin", min = 38, max = 63 },
    },
    { -- Tier 2
        { name = "copper", min = 125, max = 250 },
        { name = "iron", min = 125, max = 250 },
        { name = "black_money", min = 62500, max = 125000 },
        { name = "griebtuvas", min = 25, max = 63 },
        { name = "gold", min = 25, max = 63 },
    },
    { -- Tier 3
        { name = "spyruokle", min = 63, max = 125 },
        { name = "vamzdis", min = 63, max = 125 },
        { name = "griebtuvas", min = 63, max = 125 },
        { name = "saugiklis", min = 63, max = 125 },
    },
    { -- Tier 4
        { name = "weapon_appistol", min = 3, max = 5 },
        { name = "ammunition_pistol", min = 63, max = 250 },
        { name = "armour", min = 2, max = 5 },
        { name = "medikitas", min = 2, max = 5 },
    },
}