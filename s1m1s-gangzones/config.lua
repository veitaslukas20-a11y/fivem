Config = {}

-- Gang Configuration
Config.Gangs = {
    ['ballas'] = {
        label = 'Ballas',
        color = 145,  -- Purple
        rankLabels = {'Recruit', 'Member', 'Shotcaller', 'Leader'}
    },
    ['vagos'] = {
        label = 'Vagos',
        color = 5,    -- Yellow
        rankLabels = {'Recruit', 'Member', 'Shotcaller', 'Leader'}
    },
    ['families'] = {
        label = 'Families',
        color = 2,    -- Green
        rankLabels = {'Recruit', 'Member', 'Shotcaller', 'Leader'}
    },
    ['lostmc'] = {
        label = 'Lost MC',
        color = 1,    -- Red
        rankLabels = {'Prospect', 'Member', 'Enforcer', 'President'}
    }
}

-- Zone Settings
Config.ZoneSettings = {
    enableBlips = true,
    enableMarkers = true,
    updateInterval = 5000,  -- How often to update zones (ms)
    maxZones = 50,
    
    -- Zone colors (RGBA)
    zoneColors = {
        owned = {0, 255, 0, 100},      -- Green for owned
        contested = {255, 255, 0, 100}, -- Yellow for contested
        neutral = {255, 255, 255, 50}   -- White for neutral
    }
}

-- Capture Settings
Config.CaptureSettings = {
    captureTime = 300,           -- Time to capture zone (seconds)
    minGangMembers = 2,          -- Minimum members needed to capture
    captureRadius = 50.0,        -- Capture radius
    rewardMoney = 1000,          -- Money reward for capturing
    rewardReputation = 10,        -- Reputation reward
    cooldownTime = 600           -- Cooldown between captures (seconds)
}

-- Debug Settings
Config.Debug = false  -- Set to true for development