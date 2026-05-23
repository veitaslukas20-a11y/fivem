Config = {}

-- Bendra namų informacija
Config.Houses = {
    ["1"] = {
        coords = vector3(345.1, -200.4, 54.2),
        signalization = vector4(344.8, -199.9, 54.2, 180.0),
        isLuxury = false,
        interiorId = 1
    },
    ["2"] = {
        coords = vector3(-1110.2, 793.5, 168.3),
        signalization = vector4(-1111.0, 794.0, 168.3, 90.0),
        isLuxury = true,
        interiorId = 2
    },
}

-- Paprastų namų interjerai
Config.Interiors = {
    [1] = {
        coords = vector3(151.25, -1007.8, -99.0),
        resident = vector4(154.422379, -1004.555298, -98.419403, 79.305969),
        loots = {
            ["loot1"] = vector3(151.2442, -1003.0526, -98.9999),
            ["loot2"] = vector3(151.2763, -1004.9062, -98.9999),
            ["loot3"] = vector3(154.7975, -1005.8481, -99.0000),
            ["loot4"] = vector3(154.3735, -1003.2568, -98.9999),
        }
    }
}

-- Prabangių namų interjerai (galima palikti tuščius jei dar nėra)
Config.LuxuryInteriors = {}

-- NPC modeliai, kurie gyvena prabangiuose namuose
Config.ResidentModels = {
    "a_m_m_business_01",
    "a_f_m_bevhills_01",
    "a_m_y_business_02",
}

-- NPC spawn offsetai interjere
Config.ResidentSpawnOffsets = {
    vector3(154.0288, -1004.5974, -98.4193),
    vector3(-1.0, 0.0, 0.0),
    vector3(0.0, 1.0, 0.0),
    vector3(0.0, -1.0, 0.0),
}

-- NPC animacija (naudojama kai miega)
Config.NPCAnim = {
    dict = "timetable@tracy@sleep@",
    name = "idle_c"
}

return Config
