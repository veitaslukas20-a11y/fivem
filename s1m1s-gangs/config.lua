
Config                            = {}

Config.DrawDistance               = 5.0 -- How close do you need to be for the markers to be drawn (in GTA units).
Config.MarkerType                 = {Cloakrooms = 20, Armories = 21, BossActions = 22, Vehicles = 36, Helicopters = 34}
Config.MarkerSize                 = {x = 1.5, y = 1.5, z = 0.5}
Config.MarkerColor                = {r = 204, g = 153, b = 0}

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
	'gauja1',
	'gauja2',
	'cartel',
	'gauja10',
	'mafia',
	'gauja4',
	'gauja5',
	'gauja3', 
	'gauja1',
	'gauja7',
	'gauja8'
}

Config.Stations = {

	gauja1 = {
		Cloakrooms = {
			vector3(78.0747, 1236.3638, 201.2101)
		},

		BossActions = {
			vector3(106.6442, 1204.9158, 207.1743)
		},

		Stash = {
			regular = vec3(78.4928, 1240.7706, 201.2035),
			boss = vec3(91.0740, 1226.2653, 201.2086),
		},
	},

	gauja2 = {
		Cloakrooms = {
			vector3(3082.9968, 5466.5347, 23.5893)
		},

		BossActions = {
			vector3(3112.4131, 5427.1934, 19.5897)
		},

		Stash = {
			regular = vec3(3082.6228, 5460.9331, 23.6412),
			boss = vec3(3094.7961, 5466.1035, 23.5892),
		},
	},

	gauja3 = {
		Cloakrooms = {
			vector3(567.9837, -2780.3362, 6.0907)
		},


		BossActions = {
			vector3(518.5361, -2757.8896, 6.6410)
		},

		Stash = {
			regular = vec3(505.9823, -2756.2188, 3.0706),
			boss = vec3(554.8530, -2769.8792, 6.0907),
		},
	},

	mafia = {
		Cloakrooms = {
			vector3(-3489.4648, 951.4025, 12.9913)
		},

		BossActions = {
			vector3(-2204.4175, 3518.6116, 17.4849)
		},

		Stash = {
			regular = vec3(-3489.3066, 983.8500, 12.9913),
			boss = vec3(-3489.5249, 981.0076, 12.9913),
		},
	},

	gauja4 = {
		Cloakrooms = {
			vector3(-2987.3926, 2189.4119, 45.1010)
		},

		BossActions = {
			vector3(-3002.9370, 2184.1277, 45.1010)
		},

		Stash = {
			regular = vec3(-3003.5088, 2178.9087, 41.4999),
			boss = vec3(-3009.1472, 2181.9854, 45.1011),
		},
	},

--	gauja5 = {
--		Cloakrooms = {
--			vector3(-73.2017, 1280.4885, 272.8772)
--		},
--
--		BossActions = {
--			vector3(-78.0437, 1300.1759, 272.8772)
--		},
--
--		Stash = {
--			regular = vec3(-71.1400, 1271.1858, 272.8772),
--			boss = vec3(-86.2027, 1298.0675, 272.8770),
--		},
--	},

	gauja7 = {
		Cloakrooms = {
			vector3(-2619.7175, 1713.2457, 146.3228)
		},

		BossActions = {
			vector3(-2614.9871, 1695.1919, 142.3670)
		},

		Stash = {
			regular = vec3(-2607.3916, 1702.1614, 142.3729),
			boss = vec3(-2619.4243, 1714.4998, 142.3725),
		},
	},

	gauja8 = {
		Cloakrooms = {
			vector3(738.5867, -1056.9799, 0.9684)
		},

		BossActions = {
			vector3(725.9108, -1032.2720, 5.2556)
		},

		Stash = {
			regular = vec3(728.5191, -1039.6582, 0.9684),
			boss = vec3(748.0723, -1055.5483, 6.8542),
		},
	},

	gauja10 = {
		Cloakrooms = {
			vector3(-138.1361, 871.0663, 232.6939)
		},

		BossActions = {
			vector3(-130.6860, 867.4755, 232.6955)
		},

		Stash = {
			regular = vec3(-132.5457, 870.2560, 232.6895),
			boss = vec3(-134.9563, 865.1871, 232.6948),
		},
	},
	
--	security = {
--		Cloakrooms = {
--			vector3(279888888.4182, -670.2635, 29.2695)
--		},
--
--		BossActions = {
--			vector3(285.3997, -672.9662, 29.2746)
--		}
--	},

}

Config.Uniforms = {
	bullet_wear = {
		male = {
			['bproof_1'] = 0,  ['bproof_2'] = 0
		},
		female = {
			['bproof_1'] = 0,  ['bproof_2'] = 0
		}
	}
}