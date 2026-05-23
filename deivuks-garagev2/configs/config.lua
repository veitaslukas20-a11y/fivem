Config = {}

Config.Framework = 'esx' -- esx / qb frameworks
Config.Cooldown = 300

Config.ConvertV1 = false -- If you were using first version of deivuks-garage when turn it on

Config.Management = {
    DrawText3D = {
        using = false, -- Draw 3d text instead of target
        wait = 1000, -- Text wait time when player is not near text
    }, 
    Target = {
        using = true, -- Use target instead of Draw 3d text
        resource = 'qtarget', -- qtarget / bt-target / qb-target targets
        storage = false -- If not then storage will be on marker
    },
    Ped = {
        model = 's_m_y_xmech_01',
        loadped = 'distance', -- distance/default Load ped when player is near it (it prevents player from don't seeing ped) or load it just once (default).
        default = {
            enable = true, -- Play custom ped anim when ped is just standing
            anim = 'base', -- You can find animations and dists here -> https://wiki.gtanet.work/index.php?title=Animations
            dist = 'missfam4',
            props = {
                prop = 'p_cs_clipboard', -- You can find props here -> https://gta-objects.xyz/
                bone = 36029, -- You can find ped bones here -> https://wiki.gtanet.work/index.php?title=Bones
                placement = {0.16, 0.08, 0.1, -130.0, -50.0, 0.0},
            },
            speak = {
                enable = true, -- Play custom ped sound when player has no vehicle
                name = 'Generic_Hi', -- You can find speach name and param here -> https://pastebin.com/1GZS5dCL
                param = 'Speech_Params_Force', 
                anim = 'gesture_hello',
                dist = 'gestures@m@standing@casual',
            },
        },
        noveh = {
            anims = {
                enable = true, -- Play custom ped anim when player has no vehicle
                anim = 'fail', -- You can find animations and dists here -> https://wiki.gtanet.work/index.php?title=Animations
                dist = 'anim@heists@ornate_bank@chat_manager',
            },
            speak = {
                enable = true, -- Play custom ped sound when player has no vehicle
                name = 'Apology_No_Trouble', -- You can find speach name and param here -> https://pastebin.com/1GZS5dCL
                param = 'Speech_Params_Force_Shouted_Critical', 
            },
        },
    },
}

Config.Basic = {
    language = 'lt', -- lt/en [You can add your language]
    Currency = '€',
    PayWhen = 'takeout', -- Choose when to pay money then taking out ['takeout'] or when storing vehicle ['store']
    RadiusBetweeen = 3.0, -- Space between vehicles, it prevents spawn vehicles on top of another
    TeleportForward = true, -- If vehicle class is [Commercials, Industrial, Military, Service] then it teleports more forward
    LockVehicle = false, -- Lock Vehicle after taking it out
    StartEngine = true, -- Start engine automaticly after taking out vehicle
    OneCamera = true, --If not OneCamera then you will need to set cameras for every garage or impounds
    ColorPicker = true, -- If you want to let player to change color of the menu
    DefaultColor = '#001753', -- Default color of menu in hex
    SpawnVehicles = 'client', -- Spawn vehicles in server or client side?
    DeleteVehicles = 'client', -- Delete vehicles in server or client side?
}

Config.Commands = {
    enable = true, -- Enable opening garage with commands (keymaping)
    open = {
        name = 'openDGarage', -- Command to open command
        description = 'Open garage.', -- Command description
        key = 'e', -- Keybing to open garage
    },
    store = {
        name = 'storeDGarage', -- Command to open command
        description = 'Store vehicle.', -- Command description
        key = 'e', -- Keybing to open garage
    },
}

Config.Interactions = {
    QBVehicleKeys = {using = false, resource = 'qb-vehiclekeys'}, -- qb-vehiclekeys option
    SQZKeys = {using = true, resource = 'sqz_carkeys'}, -- SQZ Keys option
    EngineToggle = {using = true, resource = 'variklis'}, -- EngineToggle option
    LegacyFuel = {using = true, resource = 'LegacyFuel'}, -- LegacyFuel option
}

Config.Marker = {
    type = 27, -- Marker type of storage
    color = {r = 0, g = 102, b = 255}, -- Marker color
    wait = 1500 -- Marker wait time when player is not in vehicle
}

Config.Blip = {
    garage = {
        land = {
            spirite = 289,
            color = 38,
        },
        sky = {
            spirite = 307,
            color = 38,
        },
        water = {
            spirite = 427,
            color = 38,
        },
    },
    impound = {
        land = {
            spirite = 380,
            color = 47,
        },
        sky = {
            spirite = 307,
            color = 47,
        },
        water = {
            spirite = 427,
            color = 47,
        },
    }
}

Config.LocalVehicle = {
    land = {
        Cam = {
            coords = vec4(-836.9227, -2498.2158, 15.3847, 245.5188),
            rotation = vec3(0, -0, -114.4812),
        },
        Vehicle = {
            coords = vec4(-829.4379, -2501.8188, 13.8305, 84.6538),
        },
        Player = {
            coords = vec3(-846.6269, -2515.7927, 13.9806),
        }
    },
    sky = {
        Cam = {
            coords = vec4(-997.7502, -2977.3530, 19.2122, 227.2431),
            rotation = vec3(0.000000, 0.000000, -130.393708),
        },
        Vehicle = {
            coords = vec4(-979.1551, -2996.8418, 13.9451, 74.5326),
        },
        Player = {
            coords = vec3(-993.2526, -2949.9258, 13.9579),
        }
    },
    water = {
        Cam = {
            coords = vec4(-785.8202, -1497.1970, 5.4660, 112.2597),
            rotation = vec3(0.000000, 0.000000, 110.551186),
        },
        Vehicle = {
            coords = vec4(-805.0740, -1505.0340, 0.0746, 290.1941),
        },
        Player = {
            coords = vec3(-804.6425, -1496.6198, 1.5952),
        }
    },
}

Config.notify = 'esx' -- esx/qb/okokNotify/mythic/custom

function notify(message)
    if Config.notify == 'esx' then
        Config.FrameWorkObj.ShowNotification(message)
    elseif Config.notify == 'qb' then
        Config.FrameWorkObj.Functions.Notify(message, 'primary', 5000)
    elseif Config.notify == 'okokNofity' then
        exports['okokNotify']:Alert('Garage', message, 4000, type)
    elseif Config.notify == 'mythic' then
        exports['mythic_notify']:DoHudText(type, message)
    elseif Config.notify == 'custom' then
        exports["dec4t-notify"]:notify('Garažas', message, 4000, 'info')
    end
end

Config.DisableRadar = true -- Disable minimap while in menu
function DisableHud(toggle)
    if toggle then
        TriggerEvent('hl-hud:hidehud')
    else
        TriggerEvent('hl-hud:showhud')
        TriggerEvent('codem-hud:isjungti') -- Your event to turn off hud
    end
end

Config.Garages = nil -- DO NOT TOUCH IT

Config.FrameWorkObj = {} -- DO NOT TOUCH IT