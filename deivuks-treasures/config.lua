Config = {}

-- Ped who buys the treasures
Config.Ped = {
    coords = vec4(1733.5895, 3808.7927, 35.1181, 36.3641) -- x, y, z, heading
}

-- Treasure items & their sell price
Config.Shop = {
    { name = "diamond", price = 800 },
    { name = "watch", price = 1000 },
    { name = "ring", price = 1200 },
    { name = "phone", price = 1500 },
    { name = "alexanderskullring", price = 500 },
    { name = "versacejacket", price = 3000 },
    { name = "guccihoodie", price = 1500 },
    { name = "lvsettracksuit", price = 7500 },
    { name = "pradasunglasses", price = 500 },
    { name = "balenciagasneakers", price = 900 },
    { name = "chanelhandbag", price = 5000 },
    { name = "hermesscarf", price = 800 },
    { name = "diorjacket", price = 3500 },
    { name = "fendibelt", price = 700 },
    { name = "tomfordsuit", price = 6000 },
    { name = "saintlaurentboots", price = 1500 },
    { name = "burberrycoat", price = 2500 },
    { name = "givenchytshirt", price = 400 },
    { name = "valentinovendettaboots", price = 1000 },
    { name = "bottegawallet", price = 600 },
    { name = "offwhitebelt", price = 300 },
    { name = "rolexsubmarinewatch", price = 50000 },
    { name = "yeezysneakers", price = 900 },
    { name = "monclernichtjacket", price = 2000 },
}

-- Reward chances when opening a box
Config.Rewards = {
    { name = "diamond", chance = 10 },    -- 10% chance
    { name = "watch", chance = 30 },      -- 30%
    { name = "ring", chance = 15 },      -- 15%
}
