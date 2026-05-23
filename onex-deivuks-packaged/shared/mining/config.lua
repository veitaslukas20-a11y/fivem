Config = {
    NPC = {
        coords = vec4(2944.2495, 2746.7200, 43.3628, 281.1864),
        model = `cs_joeminuteman`,
    },

    PickaxePrice = 800,

    Prices = {
        diamond = 30,
        copper = 15,
        gold = 20, -- FIXED: Now a single number instead of a table
        iron = 45,
    },

    Items = {
        { item = 'diamond', difficulty = {'easy', 'easy', 'easy'} },
        { item = 'copper', difficulty = {'easy', 'easy'} },
        { item = 'gold', difficulty = {'easy', 'easy'} },
        { item = 'iron', difficulty = {'easy', 'easy'} },
    },

    Stones = {
        vec3(2977.45, 2741.62, 44.62),
        vec3(2982.64, 2750.89, 42.99),
        vec3(2994.92, 2750.43, 44.04),
        vec3(2958.21, 2725.44, 50.16),
        vec3(2946.3, 2725.36, 47.94),
        vec3(3004.01, 2763.27, 43.56),
        vec3(3001.79, 2791.01, 44.82)
    },

    Pickaxe = {
        item = 'pickaxe',
        prop = prop_tool_pickaxe,
        durability = {
            success = { min = 1, max = 2 },
            fail = { min = 5, max = 10 }
        }
    },

    Zone = vec3(2931.74, 2742.64, 44.09),
}

lib.callback.register('d-kasykla:getConfig', function()
    return Config
end)