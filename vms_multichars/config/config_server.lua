Config.Slots = 2
Config.Prefix = 'char'
Config.Identifier = "license" -- this is the identifier you use in the users table, if you use R* license set "license", if steam set "steam"
Config.UsersDatabase = { -- is the option where you add the tables to be cleared when a player removes a character by himself > {table = column}
    users = 'identifier',
    -- datastore_data = 'owner',
    -- owned_vehicles = 'owner',
    -- user_licenses = 'owner',

    -- vms_marketplaces = 'owner',
}


Config.EnableStarterItems = true
Config.StarterItems = {
    {name = 'koldunai', count = 10},
    {name = 'water', count = 10},
    {name = 'fixkitas', count = 2},
    {name = 'medikitas', count = 2},
    {name = 'phone', count = 1},
    {name = 'radio', count = 1},
}

Config.EnableStarterMoney = true
Config.StarterMoney = {
    {account = 'money', amount = 150000},
    -- {account = 'black_money', amount = 100},
}