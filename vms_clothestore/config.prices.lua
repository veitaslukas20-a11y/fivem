-- @DefaultPrice: Default price of products when not available in PricesForComponent and PricesForIds.
Config.DefaultPrice = 100

-- @PricesForComponent: Product price of the category.
Config.PricesForComponent = {
    ['helmet_1'] = 80,
    ['helmet_2'] = 0,
    ['mask_1'] = 50,
    ['mask_2'] = 0,
    ['tshirt_1'] = 60,
    ['tshirt_2'] = 0,
    ['torso_1'] = 150,
    ['torso_2'] = 0,
    ['arms'] = 20,
    ['arms_2'] = 0,
    ['decals_1'] = 5,
    ['decals_2'] = 0,
    ['bproof_1'] = 100,
    ['bproof_2'] = 0,
    ['pants_1'] = 110,
    ['pants_2'] = 0,
    ['shoes_1'] = 100,
    ['shoes_2'] = 0,
    ['chain_1'] = 550,
    ['chain_2'] = 0,
    ['glasses_1'] = 90,
    ['glasses_2'] = 0,
    ['watches_1'] = 330,
    ['watches_2'] = 0,
    ['bracelets_1'] = 30,
    ['bracelets_2'] = 0,
    ['ears_1'] = 40,
    ['ears_2'] = 0,
    ['bags_1'] = 65,
    ['bags_2'] = 0,
}

-- @PricesForIds: Product price for a specific ID from the clothing category.
Config.PricesForIds = {
    male = {
        
    },
    female = {
        
    }
}


-- @PricesForComponentSpecificStores: Product price of the category for specific stores.
Config.PricesForComponentSpecificStores = {
    [1] = { -- For store ID: 1 (Config.Stores)
        male = {
            ['mask_1'] = 40,
            ['mask_2'] = 0,
        },
        female = {
            ['mask_1'] = 40,
            ['mask_2'] = 0,
        }
    },
    -- [2] = { -- For store ID: 2 (Config.Stores)
    --     ['torso_1'] = 200
    -- },
}

-- @PricesForIdsSpecificStores: Product price for a specific ID from the clothing category for specific stores.
Config.PricesForIdsSpecificStores = {
    [1] = { -- For store ID: 1 (Config.Stores)
        male = {
            ['mask_1'] = {
                ['3'] = 25,
                ['5'] = 53,
            },
        },
        female = {
            ['mask_1'] = {
                ['3'] = 25,
                ['5'] = 53,
            },
        }
    },
    -- [2] = { -- For store ID: 2 (Config.Stores)
    --     male = {
    --         ['torso_1'] = {
    --             ['80'] = 50,
    --             ['167'] = 300,
    --             ['293'] = 500,
    --         },
    --     },
    --     female = {
    --         ['pants_1'] = {
    --             ['55'] = 30,
    --             ['116'] = 450,
    --         },
    --     }
    -- },
}