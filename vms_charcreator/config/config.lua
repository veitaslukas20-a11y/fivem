Config = {}

-- We also recommend vms_multichars for use on ESX, it fits perfectly with the style of the vms_charcreator!
--|  Client trigger to open the creator is: "vms_charcreator:openCreator"

------------------------------ █▀ █▀▄ ▄▀▄ █▄ ▄█ ██▀ █   █ ▄▀▄ █▀▄ █▄▀ ------------------------------
------------------------------ █▀ █▀▄ █▀█ █ ▀ █ █▄▄ ▀▄▀▄▀ ▀▄▀ █▀▄ █ █ ------------------------------
local frameworkAutoFind = function()
    if GetResourceState('es_extended') ~= 'missing' then
        return "ESX"
    elseif GetResourceState('qb-core') ~= 'missing' then
        return "QB-Core"
    end
end

Config.Core = frameworkAutoFind()
Config.CoreExport = function()
    if Config.Core == "ESX" then
        return exports['es_extended']:getSharedObject()
    elseif Config.Core == "QB-Core" then
        return exports['qb-core']:GetCoreObject()
    end
end


-------------------------- ▄▀▀ █▄▀ █ █▄ █ █▄ ▄█ ▄▀▄ █▄ █ ▄▀▄ ▄▀  ██▀ █▀▄ ---------------------------
-------------------------- ▄██ █ █ █ █ ▀█ █ ▀ █ █▀█ █ ▀█ █▀█ ▀▄█ █▄▄ █▀▄ ---------------------------
local skinmanagerAutoFind = function()
    if GetResourceState('esx_skin') ~= 'missing' then
        return "esx_skin"
    elseif GetResourceState('qb-clothing') ~= 'missing' then
        return "qb-clothing"
    elseif GetResourceState('fivem-appearance') ~= 'missing' then
        return "fivem-appearance"
    elseif GetResourceState('illenium-appearance') ~= 'missing' then
        return "illenium-appearance"
    end
end

-- @SkinManager: "esx_skin" / "qb-clothing" /  "fivem-appearance" / "illenium-appearance"
Config.SkinManager = skinmanagerAutoFind()


------------------------- ▄▀▄ ▄▀▀    █ █▄ █ █ █ ██▀ █▄ █ ▀█▀ ▄▀▄ █▀▄ ▀▄▀ --------------------------
------------------------- ▀▄█ ▄██ ▀▀ █ █ ▀█ ▀▄▀ █▄▄ █ ▀█  █  ▀▄▀ █▀▄  █  --------------------------
-- @UseQSInventory - if you use qs-inventory and clothing options
Config.UseQSInventory = false
Config.QSInventoryName = 'qs-inventory'


------------------------------ ▄▀▀ ▄▀▄ █▄ ▄█ █▄ ▄█ ▄▀▄ █▄ █ █▀▄ ▄▀▀ -------------------------------
------------------------------ ▀▄▄ ▀▄▀ █ ▀ █ █ ▀ █ █▀█ █ ▀█ █▄▀ ▄██ -------------------------------
Config.TestCommand = false -- /character -- command to test the character creator **(We do not recommend using this on the main server)**
if Config.TestCommand then
    RegisterCommand('character', function()
        TriggerEvent('vms_charcreator:openCreator')
    end)
end

Config.AdminCommand = {
    Enabled = true,
    Group = "admin",
    Name = "char",
    Help = "Give the character creator to the player",
    ArgHelp = "Player ID",
}

------------------------ █▄ ▄█ ▄▀▄ █ █▄ █   ▄▀▀ ██▀ ▀█▀ ▀█▀ █ █▄ █ ▄▀  ▄▀▀ ------------------------
------------------------ █ ▀ █ █▀█ █ █ ▀█   ▄██ █▄▄  █   █  █ █ ▀█ ▀▄█ ▄██ ------------------------
Config.Hud = {
    Enable = function()
        if GetResourceState('vms_hud') == 'started' then
            exports['vms_hud']:Display(true)
        end
        
    end,
    Disable = function()
        if GetResourceState('vms_hud') == 'started' then
            exports['vms_hud']:Display(false)
        end
        
    end
}

Config.Notification = function(title, message, time, type)
    if type == "success" then
        if GetResourceState("vms_notify") == 'started' then
            exports["vms_notify"]:Notification(title, message, time, "#27FF09", "fa-solid fa-stethoscope")
        else
            TriggerEvent('esx:showNotification', message)
            TriggerEvent('QBCore:Notify', message, 'success', time)
        end
    elseif type == "error" then
        if GetResourceState("vms_notify") == 'started' then
            exports["vms_notify"]:Notification(title, message, time, "#FF0909", "fa-solid fa-stethoscope")
        else
            TriggerEvent('esx:showNotification', message)
            TriggerEvent('QBCore:Notify', message, 'error', time)
        end
    end
end

Config.creatingCharacterCoords = vector4(916.7, 46.18, 110.66, 57.78) -- this is where the player player will stand during character creation
Config.CreatingIsNotInInterior = true -- If you have problems loading the camera in the interiors, you can use this option on false to have it rendered correctly
Config.CharacterCreationPedAnimation = {"missclothing", "idle_storeclerk"} -- animation of the player during character creation

-- @TeleportPlayerByCommand: when the player is given the character creation menu by the admin whether to be teleported to Config.creatingCharacterCoords
Config.TeleportPlayerByCommand = false --

Config.afterCreateCharSpawn = vector4(-258.9513, -977.5356, 31.2200, 213.1378) -- this is where the player will spawn after completing character creation

Config.soundsEffects = true -- if you want to sound effects by clicks set true
Config.BlurBehindPlayer = true -- to see it you need to have PostFX upper Very High or Ultra

-- @DefaultRoutingBucket: Routing bucket in which every player is, the default is 0
Config.DefaultRoutingBucket = 0
Config.UseRoutingBuckets = true -- When editing a character, the player is moved to an individual virtual world to not see or hear other players
 

Config.EnableHandsUpButtonUI = true -- Is there to be a button to raise hands on the UI
Config.HandsUpKey = 'x' -- Key JS (key.code) - https://www.toptal.com/developers/keycode
Config.HandsUpAnimation = {'missminuteman_1ig_2', 'handsup_enter', 50}

-- @EnableCancelButtonUI: this is only displayed when the player is in the character creator via the admin command
Config.EnableCancelButtonUI = true

-- @DadMin, DadMax: If you use custom faces that add more value, you can customize it here.
Config.DadMin = 0
Config.DadMax = 44

-- @MomMin, MomMax: If you use custom faces that add more value, you can customize it here.
Config.MomMin = 21
Config.MomMax = 45

-- @PedsList: Only for qb-clothing, fivem-appearance, illenium-appearance
Config.PedsList = {
    [1] = 'a_f_m_beach_01',
    [2] = 'a_f_m_bodybuild_01',
    [3] = 'a_m_m_afriamer_01',
    [4] = 'a_m_m_fatlatin_01',
}


Config.defaultCamDistance = 0.95 -- camera distance from player location (during character creation)
Config.CameraHeight = {
    ['parents'] = {z_height = 0.65, fov = 30.0}, -- default is camera on the face
    ['face'] = {z_height = 0.65, fov = 30.0}, -- default is camera on the face
    ['hairs'] = {z_height = 0.65, fov = 30.0}, -- default is camera on the face
    ['clothes'] = {z_height = -0.1, fov = 100.0}, -- default is camera on the torso
    ['clothesets'] = {z_height = -0.1, fov = 100.0}, -- default is camera on the torso
    ['makeup'] = {z_height = 0.65, fov = 30.0}, -- default is camera on the face
}

Config.CameraSettings = {
    startingFov = 25.0,
    maxCameraFov = 120.0,
    minCameraFov = 10.0,
    maxCameraHeight = 2.5,
    minCameraHeight = -0.85
}


Config.EnableFirstCreationClothes = true -- You can set a default for the character the first outfit the player will be reborn with in the character creator - the default was laid out for both genders in just underwear so the player can see all the details of the character
Config.FirstCreationClothes = {
    ['m'] = {
        tshirt_1 = 15, tshirt_2 = 0, 
        torso_1 = 15, torso_2 = 0,
        arms = 15, arms_2 = 0,
        pants_1 = 14, pants_2 = 1,
        shoes_1 = 34, shoes_2 = 0,
        helmet_1 = -1, helmet_2 = 0, 
        chain_1 = 0, chain_2 = 0, 
    },
    ['f'] = {
        tshirt_1 = 15, tshirt_2 = 0, 
        torso_1 = 15, torso_2 = 0,
        arms = 15, arms_2 = 0,
        pants_1 = 15, pants_2 = 0,
        shoes_1 = 35, shoes_2 = 0,
        helmet_1 = -1, helmet_2 = 0, 
        chain_1 = 0, chain_2 = 0, 
        glasses_1 = 5, glasses_2 = 0,
    }
}


Config.PlasticSurgery = {
    Enabled = false,
    Price = 40000, -- Cash
    PointCoords = vector3(294.39, -603.4, 43.2), -- The point at which a player can undertake plastic surgery
    SurgeryCoords = vector4(176.26, -636.66, 46.07, 27.21), -- The point to which the player will be teleported during the plastic surgery, if you don't want to set nil
    OnFinishTeleportBack = true, -- Is the player to be teleported back to the PointCoords
    AccessDistance = 1.0,
    AccessControl = 38, -- 38 = E
    UseESXHelpNotification = false, -- ESX.ShowHelpNotification(...)
    Marker = {
        Enabled = true,
        DrawDistance = 15.0,
        Type = 20,
        Scale = vec(0.35, 0.35, 0.35),
        Color = {91, 162, 91, 135},
        BobUpAndDown = false,
        Rotate = true,
    },
    Text3D = {
        Enabled = true,
        DrawDistance = 3.0,
        Action = function(text)
            SetTextScale(0.35, 0.35)
            SetTextFont(4)
            SetTextDropShadow()
            SetTextProportional(1)
            SetTextColour(255, 255, 255, 215)
            SetTextEntry("STRING")
            SetTextCentre(true)
            AddTextComponentString(text)
            SetDrawOrigin(Config.PlasticSurgery.PointCoords.x, Config.PlasticSurgery.PointCoords.y, Config.PlasticSurgery.PointCoords.z+0.35, 0)
            DrawText(0.0, 0.0)
            local factor = (string.len(text)) / 370
            DrawRect(0.0, 0.0 + 0.0125, 0.017 + factor, 0.03, 0, 0, 0, 75)
            ClearDrawOrigin()
        end,
    },
    Interact = {
        Enabled = false,
        Open = function(text)
            exports["interact"]:Open("E", text) -- Here you can use your TextUI or use my free one - https://github.com/vames-dev/interact
            -- exports['okokTextUI']:Open('[E] '..text, 'darkgreen', 'right')
            -- exports['qb-core']:DrawText(text, 'right')
        end,
        Close = function()
            exports["interact"]:Close() -- Here you can use your TextUI or use my free one - https://github.com/vames-dev/interact
            -- exports['okokTextUI']:Close()
            -- exports['qb-core']:HideText()
        end
    },
    Blip = {
        Enabled = true,
        Sprite = 480,
        Display = 4,
        Scale = 0.85,
        Color = 25,
        Name = "Plastic Surgery",
    },
    EnablesCategories = { -- these are the available categories that the player should have when creating a character, if you don't want any, set it to false
        ['parents'] = true,
        ['face'] = true,
        ['hairs'] = false,
        ['clothes'] = false,
        ['clothesets'] = false,
        ['makeup'] = false,
    },
    AvailableItems = {
        ['parents'] = {
            sex = true,
            peds = true,
            parents = true,
            face_md_weight = true,
            skin_md_weight = true,
        },
        ['face'] = {
            neck_thickness = true,
            age = true,
            eyebrows = true,
            nose = true,
            cheeks = true,
            lip_thickness = true,
            jaw = true,
            chin = true,
            eye_squint = true,
            eye_color = true,
            blemishes = true,
            complexion = true,
            sun = true,
            moles = true,
        },
        ['clothes'] = {
            tshirt = false,
            torso = false,
            decals = false,
            arms = false,
            pants = false,
            shoes = false,
            mask = false,
            bproof = false,
            chain = false,
            helmet = false,
            glasses = false,
            watches = false,
            bracelets = false,
            bags = false,
            ears = false,
        },
        ['hairs'] = {
            hair = false,
            beard = false,
            eyebrow = false,
            chesthair = false,
        },
        ['makeup'] = {
            makeup = false,
            lipstick = false,
            blush = false,
        },
    }
}


Config.EnablesCategories = { -- these are the available categories that the player should have when creating a character, if you don't want any, set it to false
    ['parents'] = true,
    ['face'] = true,
    ['hairs'] = true,
    ['clothes'] = true,
    ['clothesets'] = false,
    ['makeup'] = true,
}

-- @BlockedClothes:
--  For the clothing blockage to work correctly in the table, there must be at least two values. Only one value, for example {10}, cannot exist.
--  To block only one value, you need to set the second value as a number that does not exist, for example {10, 100000}.
Config.BlockedClothes = {
    ['male'] = {
        ['torso_1'] = {2, 786, 787, 788, 789, 790, 792, 793, 794, 795, 796},
        ['tshirt_1'] = {424, 10000},
        ['pants_1'] = {2, 402, 403, 405, 406, 407, 408, 409},
        ['mask_1'] = {316, 317, 318},
        ['helmet_1'] = {254, 256},
        ['shoes_1'] = {295, 295, 296, 297, 298},
        ['bags_1'] = {167, 168},
        ['arms'] = {244, 10000},
        ['decals_1'] = {216, 10000},
    },
    ['female'] = {
        ['torso_1'] = {772, 773, 774, 775, 776, 780, 781, 782, 783, 784, 785, 786, 787},
        ['tshirt_1'] = {437, 10000},
        ['mask_1'] = {391, 10000},
        ['pants_1'] = {331, 335, 336, 337, 338},
        ['hair_1'] = {326, 328, 329, 330, 331},
        ['shoes_1'] = {250, 251, 252, 253, 254},
        ['chain_1'] = {271, 272, 273},
        ['bags_1'] = {217, 10000},
        ['arms'] = {319, 10000},
    },
}

Config.AvailableItems = {
    ['parents'] = {
        sex = true,
        peds = true,
        parents = true,
        face_md_weight = true,
        skin_md_weight = true,
    },
    ['face'] = {
        neck_thickness = true,
        age = true,
        eyebrows = true,
        nose = true,
        cheeks = true,
        lip_thickness = true,
        jaw = true,
        chin = true,
        eye_squint = true,
        eye_color = true,
        blemishes = true,
        complexion = true,
        sun = true,
        moles = true,
    },
    ['clothes'] = {
        tshirt = true,
        torso = true,
        decals = true,
        arms = true,
        pants = true,
        shoes = true,
        mask = true,
        bproof = true,
        chain = true,
        helmet = true,
        glasses = true,
        watches = true,
        bracelets = true,
        bags = true,
        ears = true,
    },
    ['hairs'] = {
        hair = true,
        beard = true,
        eyebrow = true,
        chesthair = true,
    },
    ['makeup'] = {
        makeup = true,
        lipstick = true,
        blush = true,
    },
}

Config.clotheSets = { -- here are sets of clothes, you can create some suggested clothes for the player
    [0] = {
        ['name'] = "FORMAL",
        ['m'] = {
            tshirt_1 = 4, tshirt_2 = 0, 
            torso_1 = 10, torso_2 = 0,
            arms = 1, arms_2 = 0,
            pants_1 = 10, pants_2 = 0,
            shoes_1 = 10, shoes_2 = 0,
            helmet_1 = -1, helmet_2 = 0, 
            chain_1 = 0, chain_2 = 0, 
        },
        ['f'] = {
            tshirt_1 = 41, tshirt_2 = 2, 
            torso_1 = 6, torso_2 = 4,
            arms = 2, arms_2 = 0,
            pants_1 = 6, pants_2 = 0,
            shoes_1 = 29, shoes_2 = 0,
            helmet_1 = -1, helmet_2 = 0, 
            chain_1 = 0, chain_2 = 0, 
        },
    },
    [1] = {
        ['name'] = "NORMAL 1",
        ['m'] = {
            tshirt_1 = 15, tshirt_2 = 0, 
            torso_1 = 80, torso_2 = 0,
            arms = 0, arms_2 = 0,
            pants_1 = 1, pants_2 = 1,
            shoes_1 = 7, shoes_2 = 0,
            helmet_1 = -1, helmet_2 = 0, 
            chain_1 = 0, chain_2 = 0, 
        },
        ['f'] = {
            tshirt_1 = 14, tshirt_2 = 0, 
            torso_1 = 30, torso_2 = 0,
            arms = 2, arms_2 = 0,
            pants_1 = 0, pants_2 = 1,
            shoes_1 = 27, shoes_2 = 0,
            helmet_1 = -1, helmet_2 = 0, 
            chain_1 = 0, chain_2 = 0, 
        },
    },
    [2] = {
        ['name'] = "NORMAL 2",
        ['m'] = {
            tshirt_1 = 15, tshirt_2 = 0, 
            torso_1 = 193, torso_2 = 14,
            arms = 0, arms_2 = 0,
            pants_1 = 105, pants_2 = 0,
            shoes_1 = 57, shoes_2 = 10,
            helmet_1 = 96, helmet_2 = 0, 
            chain_1 = 51, chain_2 = 0, 
        },
        ['f'] = {
            tshirt_1 = 14, tshirt_2 = 0, 
            torso_1 = 195, torso_2 = 0,
            arms = 15, arms_2 = 0,
            pants_1 = 64, pants_2 = 1,
            shoes_1 = 60, shoes_2 = 10,
            helmet_1 = -1, helmet_2 = 0, 
            chain_1 = 0, chain_2 = 0, 
        },
    },
}