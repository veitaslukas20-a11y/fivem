
Config                            = {}

Config.DrawDistance               = 5.0 -- How close do you need to be for the markers to be drawn (in GTA units).
Config.MarkerType                 = {Cloakrooms = 20, Armories = 21, BossActions = 22, Vehicles = 36, Helicopters = 34}
Config.MarkerSize                 = {x = 1.5, y = 1.5, z = 0.5}
Config.MarkerColor                = {r = 7, g = 121, b = 227}

Config.EnablePlayerManagement     = true -- Enable if you want society managing.
Config.EnableArmoryManagement     = false
Config.EnableESXIdentity          = true -- Enable if you're using esx_identity.
Config.EnableESXOptionalneeds     = false -- Enable if you're using esx_optionalneeds
Config.EnableLicenses             = false -- Enable if you're using esx_license.

Config.EnableHandcuffTimer        = true -- Enable handcuff timer? will unrestrain player after the time ends.
Config.HandcuffTimer              = 10 * 60000 -- 10 minutes.

Config.EnableJobBlip              = false -- Enable blips for cops on duty, requires esx_society.
Config.EnableCustomPeds           = false -- Enable custom peds in cloak room? See Config.CustomPeds below to customize peds.

Config.EnableESXService           = false -- Enable esx service?
Config.MaxInService               = -1 -- How many people can be in service at once? Set as -1 to have no limit

Config.Locale                     = 'en'

Config.Jobs = {
	'neoficiali6',
	'neoficiali4',
	'neoficiali3',
	'neoficiali2',
	'gauja5',
	'neoficiali7',
	'neoficiali8',
	'neoficiali9',
	'neoficiali10',
	'neoficiali11',
	'neoficiali12'
}

Config.Stations = {
	neoficiali12 = {
		BossActions = {
			vector3(-1025.7422, -2192.9858, 9.0713)
		}
	},

	neoficiali11 = {
		BossActions = {
			vector3(907.6873, 1835.9320, 132.8872)
		}
	},

	neoficiali10 = {
		BossActions = {
			vector3(3688.0559, 4563.0132, 25.1831)
		}
	},

	neoficiali9 = {
		BossActions = {
			vector3(-317.9413, -2436.6448, 7.2948)
		}
	},

	neoficiali8 = {
		BossActions = {
			vector3(1959.2347, 5187.6064, 47.8818)
		}
	},

	neoficiali7 = {
		BossActions = {
			vector3(1727.3453, -1535.2479, 113.9467)
		}
	},

	neoficiali6 = {
		BossActions = {
			vector3(518.4747, -2757.7207, 6.6410)
		}
	},

	neoficiali4 = {
		BossActions = {
			vector3(864.8876, -1337.4690, 26.0318)
		}
	},

	neoficiali3 = {
		BossActions = {
			vector3(-440.6337, 1599.0178, 358.4680)
		}
	},

	neoficiali2 = {
		BossActions = {
			vector3(-3108.6938, 303.0181, 8.3810)
		}
	},

	gauja3 = {
		BossActions = {
			vector3(1459.7885, -1046.6533, 43.7285)
		}
	},
}
