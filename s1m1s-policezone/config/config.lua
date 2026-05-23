Config = {}

Config.Zone = {
    coords   = vector3(451.17, -993.21, 30.69), 
    rotation = 0.0,                          
    ped      = vector4(441.83, -981.96, 30.69, 90.0), 

    enabled  = nil,
    started  = nil,
    locked   = nil,

    lock_time_ms = 1 * 30 * 1000,
    deadline_ms  = 1 * 30 * 1000,
}

-- Saugyklos parametrai (ox_inventory)
Config.Inventory = {
    slots  = 60,       
    weight = 200000,   
}
