ConfigDrugs = {}

-- 🌱 Plant configurations
ConfigDrugs.Plants = {
    {
        Type = { value = "weed", label = "Kanapės" },
        Item = "weed",
        Model = `prop_weed_02`,
        Time = 300,
        Yield = {min = 1, max = 4},
        Locations = {
            {
                Coords = vector3(2222.2, 3333.3, 45.5),
                MaxPlants = 5,
                Range = 5.0  -- ✅ Added
            }
        }
    },
    {
        Type = { value = "coke", label = "Kokainas" },
        Item = "coke_proc",
        Model = `prop_coke_block_01`,
        Time = 600,
        Yield = {min = 2, max = 5},
        Locations = {
            {
                Coords = vector3(1111.1, 2222.2, 40.5),
                MaxPlants = 4,
                Range = 5.0  -- ✅ Added
            }
        }
    },
    {
        Type = { value = "heroin", label = "Heroinas" },
        Item = "heroin",
        Model = `prop_cs_syringe_01`,
        Time = 900,
        Yield = {min = 1, max = 3},
        Locations = {
            {
                Coords = vector3(3333.1, 4444.2, 50.5),
                MaxPlants = 3,
                Range = 5.0  -- ✅ Added
            }
        }
    }
}

-- 🧪 Processing tables
ConfigDrugs.Tables = {
    -- Weed processing (weed -> weed_proc)
    {
        Model = `prop_table_03`,
        Icon = "cannabis",
        Progreses = {
            { Label = "Džiovinama kanapė...", Duration = 8000, Anim = {dict = "amb@prop_human_parking_meter@male@base", name = "base"} }
        },
        Items = {
            {name = "weed_proc", max = 3}, -- ✅ result
        },
        Required = {
            {name = "weed", count = 2}, -- ✅ input
        },
        Locations = {
            { Coords = vector3(1234.5, 5678.9, 32.1), Tables = 2, Range = 10.0 }
        }
    },

    -- Coke processing (coke_proc -> coke)
    {
        Model = `prop_table_02`,
        Icon = "vial",
        Progreses = {
            { Label = "Apdirbamas kokainas...", Duration = 10000, Anim = {dict = "amb@prop_human_parking_meter@male@base", name = "base"} }
        },
        Items = {
            {name = "coke_proc", max = 3},
        },
        Required = {
            {name = "weed_proc", count = 1}, -- optional cut with weed
        },
        Locations = {
            { Coords = vector3(1350.5, 6600.9, 32.5), Tables = 1, Range = 10.0 }
        }
    },

    -- Heroin processing (heroin -> heroin_pack / heroin_syringe is done via item button)
    {
        Model = `prop_table_04`,
        Icon = "syringe",
        Progreses = {
            { Label = "Apdirbamas heroinas...", Duration = 12000, Anim = {dict = "amb@prop_human_parking_meter@male@base", name = "base"} }
        },
        Items = {
            {name = "heroin", max = 2},
        },
        Required = {
            {name = "weed_proc", count = 1}, -- maybe mix (optional)
        },
        Locations = {
            { Coords = vector3(1450.5, 5500.9, 28.1), Tables = 1, Range = 10.0 }
        }
    }
}

-- 👥 Gangs who can manage workers
ConfigDrugs.Gangs = {
    Official = {
        ["police"] = true,
        ["vagos"] = true,
    },
    Unofficial = {
        ["streetgang"] = true
    }
}

-- 👷 Worker multipliers
ConfigDrugs.Workers = {
    weed = 1.5,
    coke = 1.8,
    heroin = 2.0
}

lib.callback.register('drugs:getConfig', function(source)
    return ConfigDrugs
end)