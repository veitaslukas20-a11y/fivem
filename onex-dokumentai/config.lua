Config = {}

Config.Locations = {
    {
        coords = vec3(-139.1167, -620.6299, 168.8203),
        teleport = vec3(-268.8703, -962.3306, 31.2231),
        text = '[E] - Išeiti iš ofiso',
        options = {
            icon = 'fa-solid fa-person-arrow-down-to-line',
        },
    },
    {
        coords = vec3(-268.8703, -962.3306, 31.2231),
        teleport = vec3(-139.1167, -620.6299, 168.8203),
        text = '[E] - Įeiti į ofisą',
        options = {
            icon = 'fa-solid fa-person-arrow-up-from-line',
        },
    }
}

Config.Blips = {
    { title = "Registrų centras", colour = 4, id = 525, coords = vec3(-268.8703, -962.3306, 31.2231) }
}

-- 📜 **Documents & Pricing**
Config.DocPrices = {
    Prices = {
        tapatybe = 10000,   -- Identity Card
        teises = 10000,     -- Driver's License
        pavarde = 5000000,  -- Last Name Change
        vardas = 5000000,   -- First Name Change
        policija = 10000    -- Police ID
    },
    RequiredLicenses = {
        teises = 'dmv' -- Requires DMV license before obtaining a driver's license
    }
}

Config.Documents = {
    ['tapatybe'] = {
        header = {
            title = 'Asmens tapatybės dokumentai'
        },
        options = {
            {
                title = 'Paduoti tapatybės kortelę',
                description = 'Paduoti tapatybės kortelę arčiausiai esančiam žaidėjui.'
            },
            {
                title = 'Peržiūrėti tapatybės kortelę',
                description = 'Peržiūrėti turimą tapatybės kortelę.'
            }
        }
    },
    ['teises'] = {
        header = {
            title = 'Vairuotojo pažymėjimai'
        },
        options = {
            {
                title = 'Paduoti vairuotojo pažymėjimą',
                description = 'Paduoti vairuotojo pažymėjimą arčiausiai esančiam žaidėjui.'
            },
            {
                title = 'Peržiūrėti vairuotojo pažymėjimą',
                description = 'Peržiūrėti turimą vairuotojo pažymėjimą.'
            }
        }
    },
    ['policija'] = {
        header = {
            title = 'Policijos pareigūno pažymėjimas'
        },
        options = {
            {
                title = 'Paduoti policijos pareigūno pažymėjimą',
                description = 'Paduoti policijos pareigūno pažymėjimą arčiausiai esančiam žaidėjui.'
            },
            {
                title = 'Peržiūrėti policijos pareigūno pažymėjimą',
                description = 'Peržiūrėti turimą policijos pareigūno pažymėjimą.'
            }
        }
    }
}

Config.HideHelmets = {
    [18] = true,
    [38] = true,
    [48] = true,
    [50] = true,
    [51] = true,
    [52] = true,
    [53] = true,
    [57] = true,
    [62] = true,
    [75] = true,
    [82] = true,
    [91] = true,
    [111] = true,
    [115] = true,
    [123] = true,
}

Config.NotHideMasks = {
    [230] = true,
    [229] = true,
    [227] = true,
    [226] = true,
    [220] = true,
    [165] = true,
    [142] = true,
    [141] = true,
    [134] = true,
    [129] = true,
    [140] = true,
    [47] = true,
    [120] = true,
    [109] = true,
    [73] = true,
    [27] = true,
}

Config.DriverClasses = {
    ['A'] = true,
    ['B'] = true,
    ['CE'] = true,
    ['C1'] = true,
    ['D'] = true,
}