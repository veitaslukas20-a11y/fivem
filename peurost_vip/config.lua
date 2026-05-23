Config = {}

Config.Roles = {
    ['1506979330717388870'] = 1,
    ['1506979566223360031'] = 2,
    ['1506979632409346178'] = 3,
}

Config.Levels = {
    [1] = {
        vehicleNumbers = 30 * 24 * 60 * 60,
    },
    [2] = {
        vehicleNumbers = 30 * 24 * 60 * 60,
        inventory = {
            slots = 80, -- Inventory slots count
            weigth = 60000 -- Weight in grams
        },
        vehicle = 30 * 24 * 60 * 60,
    },
    [3] = {
        vehicleNumbers = 30 * 24 * 60 * 60,
        kit = {
            delay = 24 * 60 * 60,
            items = {
                {item = "fixkitas", amount = 2},
                {item = "breakfast-sandwich", amount = 5},
                {item = "medikitas", amount = 1},
                {item = "water", amount = 5}
            },
        },
        discounts = {
            ['ambulance'] = 50, -- [job] = the percentage of discount
        },
        vehicle = 30 * 24 * 60 * 60,
        inventory = {
            slots = 80, -- Inventory slots count
            weigth = 60000 -- Weight in grams
        },
        legendGift = {
            items = {
                {item = "magicwax", amount = 1}
            },
        }
    }
}

Config.Vehicles = {
    [`murc`] = {
        price = 20000000,
        name = 'Lamborghini Murcielago',
        spawn_name = 'murc'
    }
}