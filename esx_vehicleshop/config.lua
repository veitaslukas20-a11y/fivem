Config                            = {}
Config.DrawDistance               = 100
Config.MarkerColor                = {r = 255, g = 247, b = 0}
Config.EnablePlayerManagement     = false -- enables the actual car dealer job. You'll need esx_addonaccount, esx_billing and esx_society
Config.ResellPercentage           = 50

Config.Locale                     = 'en'

Config.LicenseEnable = false -- require people to own drivers license when buying vehicles? Only applies if EnablePlayerManagement is disabled. Requires esx_license

-- looks like this: 'LLL NNN'
-- The maximum plate length is 8 chars (including spaces & symbols), don't go past it!
Config.PlateLetters  = 3
Config.PlateNumbers  = 3
Config.PlateUseSpace = true

Config.Zones = {

	ShopEntering = {
		Pos   = vector3(-215000.59, 3234444.98, 322222.81),
		Size  = {x = 1.5, y = 1.5, z = 1.0},
		Type  = 1
	},

	ShopInside = {
		Pos     = vector3(-2142.17, 3245.67, 32.81),
		Size    = {x = 1.5, y = 1.5, z = 1.0},
		Heading = 146.98,
		Type    = -1
	},

	ShopOutside = {
		Pos     = vector3(-2142.17, 3245.67, 32.81),
		Size    = {x = 1.5, y = 1.5, z = 1.0},
		Heading = 146.98,
		Type    = -1
	},

	BossActions = {
		Pos   = vector3(-32.0, -1114.2, 25.4),
		Size  = {x = 1.5, y = 1.5, z = 1.0},
		Type  = -1
	},

	GiveBackVehicle = {
		Pos   = vector3(-18.2, -1078.5, 25.6),
		Size  = {x = 3.0, y = 3.0, z = 1.0},
		Type  = (Config.EnablePlayerManagement and 1 or -1)
	}

}