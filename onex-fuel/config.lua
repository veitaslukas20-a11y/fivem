Config = {}

Config.Debug = { enabled = false, logLevel = 'info', showCoords = false, showBlips = true }

Config.FuelSystem = {
    RegularFuelPrice = 45.0,
    PremiumFuelPrice = 65.0,
    FuelUpdateInterval = 1000,
    PropScanDistance = 100.0,
    InteractionDistance = 3.0
}

Config.FuelPumpProps = {
    `prop_gas_pump_1a`,
    `prop_gas_pump_1b`,
    `prop_gas_pump_1c`,
    `prop_gas_pump_1d`,
    `prop_gas_pump_old2`,
    `prop_gas_pump_old3`,
    `prop_vintage_pump`,
    `prop_gas_pump_old`
}

Config.FuelBlips = {
    { coords = vector3(1181.16, -330.30, 68.35), label = "Degalinė", sprite = 361, color = 46 },
    { coords = vector3(1702.79, 6416.86, 33.64), label = "Degalinė", sprite = 361, color = 46 },
    { coords = vector3(-721.04, -935.52, 23.98), label = "Degalinė", sprite = 361, color = 46 },
    { coords = vector3(-1436.8467, -272.3289, 46.2076), label = "Degalinė", sprite = 361, color = 46 },
    { coords = vector3(626.0980, 263.2478, 103.0894), label = "Degalinė", sprite = 361, color = 46 },
    { coords = vector3(2678.3411, 3267.3586, 55.2405), label = "Degalinė", sprite = 361, color = 46 },
    { coords = vector3(2004.6582, 3777.4792, 32.1808), label = "Degalinė", sprite = 361, color = 46 },
    { coords = vector3(1786.2416, 3331.1511, 41.3770), label = "Degalinė", sprite = 361, color = 46 },
    { coords = vector3(2539.3254, 2594.6177, 37.9448), label = "Degalinė", sprite = 361, color = 46 },
    { coords = vector3(-70.78, -1761.76, 35.85), label = "Degalinė", sprite = 361, color = 46 },
    { coords = vector3(-526.8816, -1210.7415, 18.1849), label = "Degalinė", sprite = 361, color = 46 },
    { coords = vector3(265.04, -1261.87, 35.88), label = "Degalinė", sprite = 361, color = 46 }
}
