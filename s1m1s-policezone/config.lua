Config = {}

-- Police Jobs Configuration
Config.PoliceJobs = {
    ['police'] = true,
    ['sheriff'] = true,
    ['statepolice'] = true,
    ['lsdp'] = true
}

-- Police Zones Settings
Config.PoliceZones = {
    enableBlips = true,
    enableMarkers = true,
    zoneRadius = 100.0,
    
    -- Colors
    zoneColor = {0, 0, 255, 100},      -- Blue for police zones
    restrictedColor = {255, 0, 0, 100}, -- Red for restricted
    
    -- Zone types
    zoneTypes = {
        ['headquarters'] = {
            label = 'Police HQ',
            restricted = false
        },
        ['locker'] = {
            label = 'Locker Room',
            restricted = true
        },
        ['armory'] = {
            label = 'Armory',
            restricted = true
        },
        ['garage'] = {
            label = 'Police Garage',
            restricted = true
        },
        ['heli'] = {
            label = 'Helipad',
            restricted = true
        }
    }
}

-- Blip Settings
Config.BlipSettings = {
    sprite = 60,      -- Police blip
    color = 3,        -- Blue
    scale = 0.8,
    display = 4
}

-- Debug Mode
Config.Debug = false