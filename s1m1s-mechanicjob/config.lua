Config                            = {}
Config.Locale                     = 'en'

Config.DrawDistance               = 100.0

Config.MarkerType                 = {Cloakrooms = 20, BossActions = 22, Vehicles = 36, Helicopters = 34}
Config.MarkerSize                 = {x = 0.5, y = 1.5, z = 0.5}
Config.MarkerColor                = {r = 53, g = 169, b = 254}

Config.Jobs = {
	mechanic = true,
	mechanic2 = true,
	mechanic3 = true,
	mechanic4 = true,
	hookan = true,
	auction = true,
	pearls = true,
	kebabine = true,
}

Config.Zones = {
	mechanic = {
		Cloakrooms = {
			vec3(-936.6244, -2034.0426, 9.0511),
		},

		BossActions = {
			vec3(-920.5268, -2044.5879, 14.4507),
		},

		Vehicles = {
			{
				Spawner = vector3(-911.3159, -2042.5330, 9.4054),
				InsideShop = vector4(-897.6767, -2052.5469, 9.2992, 131.6439),
				SpawnPoints = {
					{coords = vector3(-886.9192, -2045.8586, 9.2992), heading = 134.4216, radius = 2.0},
					{coords = vector3(-889.6064, -2042.9025, 9.2992), heading = 136.6723, radius = 2.0},
				}
			}
		},
	},

	mechanic2 = {
		Cloakrooms = {
			vec3(153.8941, -3011.2354, 7.0409),
		},

		BossActions = {
			vec3(124.5093, -3014.1685, 7.0409)
		},

		Vehicles = {
			{
				Spawner = vector3(157.8732, -3010.8765, 7.0309),
				InsideShop = vector4(173.3144, -3003.9497, 5.7834, 179.6262),
				SpawnPoints = {
					{coords = vector3(167.0769, -3009.5269, 5.8688), heading = 268.6998, radius = 2.0},
					{coords = vector3(166.6897, -3006.0457, 5.8704), heading = 273.7754, radius = 2.0},
				}
			}
		},
	},

	mechanic3 = {
		Cloakrooms = {
			vec3(39.7959, 6550.2661, 31.5719),
		},

		BossActions = {
			vec3(19.7782, 6530.1196, 42.9715),
		},

		Vehicles = {
			{
				Spawner = vector3(93.1355, 6523.8213, 31.5722),
				InsideShop = vector4(97.2754, 6514.2544, 31.5763, 38.9355),
				SpawnPoints = {
					{coords = vector3(96.1417, 6506.7856, 31.5722), heading = 314.2012, radius = 2.0},
					{coords = vector3(93.5653, 6509.2246, 31.5722), heading = 315.1503, radius = 2.0},
				}
			}
		},
	},

	mechanic4 = {
		Cloakrooms = {
			vec3(1928.3718, 3904.3875, 32.9774),
			vec3(1800.6929, 3851.6033, 34.4540),
		},

		BossActions = {
			vec3(1925.3641, 3921.6902, 32.7223),
			vec3(1798.4406, 3853.7952, 34.4074),
		},

		Vehicles = {
			{
				Spawner = vector3(1806.5413, 3855.8452, 34.4258),
				InsideShop = vector4(1822.3934, 3851.8381, 34.3110, 297.1573),
				SpawnPoints = {
					{coords = vector3(1813.5970, 3859.8186, 34.4286), heading = 204.5301, radius = 2.0},
					{coords = vector3(1808.5939, 3858.0730, 34.4271), heading = 203.8744, radius = 2.0},
				}
			}
		},
	},

	hookan = {
		Cloakrooms = {},

		BossActions = {},

		Vehicles = {
			{
				Spawner = vector3(386.6936, -795.5153, 29.3225),
				InsideShop = vector4(389.5158, -795.1190, 29.3226, 267.7540),
				SpawnPoints = {
					{coords = vector3(389.0439, -792.0468, 29.3226), heading = 274.0753, radius = 2.0},
				}
			}
		},
	},

	auction = {
		Cloakrooms = {},

		BossActions = {},

		Vehicles = {
			{
				Spawner = vector3(-1102.4299, -1260.2664, 5.2685),
				InsideShop = vector4(-1079.2129, -1239.5046, 5.1242, 120.6316),
				SpawnPoints = {
					{coords = vector3(-1075.4084, -1246.1965, 5.3817), heading = 119.6083, radius = 2.0},
					{coords = vector3(-1072.9667, -1249.5109, 5.5741), heading = 118.2839, radius = 2.0},
				}
			}
		},
	},

	pearls = {
		Cloakrooms = {},

		BossActions = {},

		Vehicles = {
			{
				Spawner = vector3(-1812.7548, -1181.2046, 13.0173),
				InsideShop = vector4(-1817.1490, -1175.3878, 13.0174, 237.2192),
				SpawnPoints = {
					{coords = vector3(-1820.5367, -1173.1255, 13.0174), heading = 228.4130, radius = 2.0},
					{coords = vector3(-1823.4951, -1170.5146, 13.0173), heading = 226.6133, radius = 2.0},
				}
			}
		},
	},

	kebabine = {
		Cloakrooms = {},

		BossActions = {},

		Vehicles = {
			{
				Spawner = vector3(35.4634, -1017.4571, 29.4732),
				InsideShop = vector4(29.4597, -1037.3230, 29.3383, 338.9062),
				SpawnPoints = {
					{coords = vector3(27.9222, -1031.7827, 29.4027), heading = 245.2591, radius = 2.0},
					{coords = vector3(28.8423, -1029.2872, 29.4462), heading = 245.8252, radius = 2.0},
				}
			}
		},
	},
}


Config.AuthorizedVehicles = {
	mechanic = {
		car = {
			praktikantas = {
				{model = 'flatbed', price = 10},
				{model = 'caddyvw', price = 10},
				{model = 'onexmech1', price = 10},
				{model = 'gcme1', price = 10},
				{model = 'gcme2', price = 10},
				{model = 'gcme0', price = 10},
			},
			apsiprates = {
				{model = 'flatbed', price = 10},
				{model = 'caddyvw', price = 10},
				{model = 'onexmech1', price = 10},
				{model = 'gcme1', price = 10},
				{model = 'gcme2', price = 10},
				{model = 'gcme0', price = 10},
			},
			recrue = {
				{model = 'flatbed', price = 10},
				{model = 'caddyvw', price = 10},
				{model = 'onexmech1', price = 10},
				{model = 'gcme1', price = 10},
				{model = 'gcme2', price = 10},
				{model = 'gcme0', price = 10},
			},
			novice = {
				{model = 'flatbed', price = 10},
				{model = 'caddyvw', price = 10},
				{model = 'onexmech1', price = 10},
				{model = 'gcme1', price = 10},
				{model = 'gcme2', price = 10},
				{model = 'gcme0', price = 10},
			},
			experimente = {
				{model = 'flatbed', price = 10},
				{model = 'caddyvw', price = 10},
				{model = 'onexmech1', price = 10},
				{model = 'gcme1', price = 10},
				{model = 'gcme2', price = 10},
				{model = 'gcme0', price = 10},
			},
			boss = {
				{model = 'flatbed', price = 10},
				{model = 'caddyvw', price = 10},
				{model = 'onexmech1', price = 10},
				{model = 'gcme1', price = 10},
				{model = 'gcme2', price = 10},
				{model = 'gcme0', price = 10},
			}
		},
	},
	mechanic2 = {
		car = {
			naujokas = {
				{model = 'flatbed', price = 10},
				{model = 'caddyvw', price = 10},
				{model = 'onexmech3', price = 10},
				{model = 'gcme1', price = 10},
				{model = 'gcme2', price = 10},
				{model = 'gcme0', price = 10},
			},
			tepalinis = {
				{model = 'flatbed', price = 10},
				{model = 'caddyvw', price = 10},
				{model = 'onexmech3', price = 10},
				{model = 'gcme1', price = 10},
				{model = 'gcme2', price = 10},
				{model = 'gcme0', price = 10},
			},
			pavaduotojas = {
				{model = 'flatbed', price = 10},
				{model = 'caddyvw', price = 10},
				{model = 'onexmech3', price = 10},
				{model = 'gcme1', price = 10},
				{model = 'gcme2', price = 10},
				{model = 'gcme0', price = 10},
			},
			boss = {
				{model = 'flatbed', price = 10},
				{model = 'caddyvw', price = 10},
				{model = 'onexmech3', price = 10},
				{model = 'gcme1', price = 10},
				{model = 'gcme2', price = 10},
				{model = 'gcme0', price = 10},
			}
		},
	},
	mechanic3 = {
		car = {
			praktikantas = {
				{model = 'flatbed', price = 10},
				{model = 'caddyvw', price = 10},
				{model = 'onexmech1', price = 10},
				{model = 'gcme1', price = 10},
				{model = 'gcme2', price = 10},
				{model = 'gcme0', price = 10},
			},
			apsiprates = {
				{model = 'flatbed', price = 10},
				{model = 'caddyvw', price = 10},
				{model = 'onexmech1', price = 10},
				{model = 'gcme1', price = 10},
				{model = 'gcme2', price = 10},
				{model = 'gcme0', price = 10},
			},
			recrue = {
				{model = 'flatbed', price = 10},
				{model = 'caddyvw', price = 10},
				{model = 'onexmech1', price = 10},
				{model = 'gcme1', price = 10},
				{model = 'gcme2', price = 10},
				{model = 'gcme0', price = 10},
			},
			novice = {
				{model = 'flatbed', price = 10},
				{model = 'caddyvw', price = 10},
				{model = 'onexmech1', price = 10},
				{model = 'gcme1', price = 10},
				{model = 'gcme2', price = 10},
				{model = 'gcme0', price = 10},
			},
			experimente = {
				{model = 'flatbed', price = 10},
				{model = 'caddyvw', price = 10},
				{model = 'onexmech1', price = 10},
				{model = 'gcme1', price = 10},
				{model = 'gcme2', price = 10},
				{model = 'gcme0', price = 10},
			},
			boss = {
				{model = 'flatbed', price = 10},
				{model = 'caddyvw', price = 10},
				{model = 'onexmech1', price = 10},
				{model = 'gcme1', price = 10},
				{model = 'gcme2', price = 10},
				{model = 'gcme0', price = 10},
			}
		},
	},
	mechanic4 = {
		car = {
			praktikantas = {
				{model = 'gcme1', price = 10},
				{model = 'gcme2', price = 10},
				{model = 'gcme0', price = 10},
			},
			apsiprates = {
				{model = 'gcme1', price = 10},
				{model = 'gcme2', price = 10},
				{model = 'gcme0', price = 10},
			},
			recrue = {
				{model = 'gcme1', price = 10},
				{model = 'gcme2', price = 10},
				{model = 'gcme0', price = 10},
			},
			novice = {
				{model = 'gcme1', price = 10},
				{model = 'gcme2', price = 10},
				{model = 'gcme0', price = 10},
			},
			experimente = {
				{model = 'gcme1', price = 10},
				{model = 'gcme2', price = 10},
				{model = 'gcme0', price = 10},
			},
			boss = {
				{model = 'gcme1', price = 10},
				{model = 'gcme2', price = 10},
				{model = 'gcme0', price = 10},
			}
		},
	},
	hookan = {
		car = {
			soldato = {
				{model = 'lenkot6vape', price = 10},
			},
			boss = {
				{model = 'lenkot6vape', price = 10},
			},
		},
	},
	auction = {
		car = {
			employee = {
				{model = 'xautot6', price = 10},
			},
			boss = {
				{model = 'xautot6', price = 10},
			},
		},
	},
	pearls = {
		car = {
			worker = {
				{model = 'macanperlas', price = 10},
			},
			barmen = {
				{model = 'macanperlas', price = 10},
			},
			boss = {
				{model = 'macanperlas', price = 10},
			},
		},
	},
	kebabine = {
		car = {
			soldato = {
				{model = 'taco', price = 10},
				{model = 'kebabt6', price = 10},
			},
			boss = {
				{model = 'taco', price = 10},
				{model = 'kebabt6', price = 10},
			},
		},
	}
}

Config.Uniforms = {
	mechanic4 = {
		[0] = { -- Praktikantas
			male = {
				['tshirt_1'] = 15,  ['tshirt_2'] = 0,
				['torso_1'] = 791,  ['torso_2'] = 12,
				['decals_1'] = 0,   ['decals_2'] = 0,
				['arms'] = 44,
				['pants_1'] = 404,  ['pants_2'] = 2,
				['shoes_1'] = 128,  ['shoes_2'] = 0,
			},
			female = {
				['tshirt_1'] = 6,   ['tshirt_2'] = 0,
				['torso_1'] = 779,  ['torso_2'] = 5,
				['decals_1'] = 0,   ['decals_2'] = 0,
				['arms'] = 302,     ['arms_2'] = 1,
				['pants_1'] = 334,  ['pants_2'] = 1,
				['shoes_1'] = 242,  ['shoes_2'] = 9,
			}
		},
		[1] = { -- Apsipratęs
			male = {
				['tshirt_1'] = 15,  ['tshirt_2'] = 0,
				['torso_1'] = 791,  ['torso_2'] = 17,
				['decals_1'] = 0,   ['decals_2'] = 0,
				['arms'] = 44,
				['pants_1'] = 404,  ['pants_2'] = 2,
				['shoes_1'] = 128,  ['shoes_2'] = 0,
			},
			female = {
				['tshirt_1'] = 6,   ['tshirt_2'] = 0,
				['torso_1'] = 779,  ['torso_2'] = 12,
				['decals_1'] = 0,   ['decals_2'] = 0,
				['arms'] = 302,     ['arms_2'] = 1,
				['pants_1'] = 334,  ['pants_2'] = 2,
				['shoes_1'] = 242,  ['shoes_2'] = 9,
			}
		},
		[2] = { -- Tepalinis
			male = {
				['tshirt_1'] = 15,  ['tshirt_2'] = 0,
				['torso_1'] = 791,  ['torso_2'] = 14,
				['decals_1'] = 0,   ['decals_2'] = 0,
				['arms'] = 44,
				['pants_1'] = 404,  ['pants_2'] = 2,
				['shoes_1'] = 128,  ['shoes_2'] = 0,
			},
			female = {
				['tshirt_1'] = 6,   ['tshirt_2'] = 0,
				['torso_1'] = 779,  ['torso_2'] = 10,
				['decals_1'] = 0,   ['decals_2'] = 0,
				['arms'] = 302,     ['arms_2'] = 1,
				['pants_1'] = 334,  ['pants_2'] = 0,
				['shoes_1'] = 242,  ['shoes_2'] = 9,
			}
		},
		[3] = { -- Kėbulistas
			male = {
				['tshirt_1'] = 15,  ['tshirt_2'] = 0,
				['torso_1'] = 791,  ['torso_2'] = 15,
				['decals_1'] = 0,   ['decals_2'] = 0,
				['arms'] = 44,
				['pants_1'] = 404,  ['pants_2'] = 2,
				['shoes_1'] = 128,  ['shoes_2'] = 0,
			},
			female = {
				['tshirt_1'] = 6,   ['tshirt_2'] = 0,
				['torso_1'] = 779,  ['torso_2'] = 13,
				['decals_1'] = 0,   ['decals_2'] = 0,
				['arms'] = 302,     ['arms_2'] = 1,
				['pants_1'] = 334,  ['pants_2'] = 2,
				['shoes_1'] = 242,  ['shoes_2'] = 9,
			}
		},
		[4] = { -- Garažinis
			male = {
				['tshirt_1'] = 15,  ['tshirt_2'] = 0,
				['torso_1'] = 791,  ['torso_2'] = 13,
				['decals_1'] = 0,   ['decals_2'] = 0,
				['arms'] = 44,
				['pants_1'] = 404,  ['pants_2'] = 2,
				['shoes_1'] = 128,  ['shoes_2'] = 0,
			},
			female = {
				['tshirt_1'] = 6,   ['tshirt_2'] = 0,
				['torso_1'] = 779,  ['torso_2'] = 14,
				['decals_1'] = 0,   ['decals_2'] = 0,
				['arms'] = 302,     ['arms_2'] = 1,
				['pants_1'] = 334,  ['pants_2'] = 2,
				['shoes_1'] = 242,  ['shoes_2'] = 9,
			}
		},
		[5] = { -- Valdžia
			male = {
				['tshirt_1'] = 15,  ['tshirt_2'] = 0,
				['torso_1'] = 791,  ['torso_2'] = 16,
				['decals_1'] = 0,   ['decals_2'] = 0,
				['arms'] = 44,
				['pants_1'] = 404,  ['pants_2'] = 2,
				['shoes_1'] = 128,  ['shoes_2'] = 0,
			},
			female = {
				['tshirt_1'] = 6,   ['tshirt_2'] = 0,
				['torso_1'] = 779,  ['torso_2'] = 15,
				['decals_1'] = 0,   ['decals_2'] = 0,
				['arms'] = 302,     ['arms_2'] = 1,
				['pants_1'] = 334,  ['pants_2'] = 2,
				['shoes_1'] = 242,  ['shoes_2'] = 9,
			}
		},
		[6] = { -- Valdžia
			male = {
				['tshirt_1'] = 15,  ['tshirt_2'] = 0,
				['torso_1'] = 791,  ['torso_2'] = 16,
				['decals_1'] = 0,   ['decals_2'] = 0,
				['arms'] = 44,
				['pants_1'] = 404,  ['pants_2'] = 2,
				['shoes_1'] = 128,  ['shoes_2'] = 0,
			},
			female = {
				['tshirt_1'] = 6,   ['tshirt_2'] = 0,
				['torso_1'] = 779,  ['torso_2'] = 15,
				['decals_1'] = 0,   ['decals_2'] = 0,
				['arms'] = 302,     ['arms_2'] = 1,
				['pants_1'] = 334,  ['pants_2'] = 2,
				['shoes_1'] = 242,  ['shoes_2'] = 9,
			}
		},
	},
	mechanic3 = {
		[0] = {
			male = {
				['tshirt_1'] = 15,  ['tshirt_2'] = 0,
				['torso_1'] = 763,   ['torso_2'] = 6,
				['decals_1'] = 0,   ['decals_2'] = 0,
				['arms'] = 55,
				['pants_1'] = 393,   ['pants_2'] = 1,
				['shoes_1'] = 129,   ['shoes_2'] = 0,
			},
			female = {
				['tshirt_1'] = 10,  ['tshirt_2'] = 0,
				['torso_1'] = 764,   ['torso_2'] = 6,
				['decals_1'] = 0,   ['decals_2'] = 0,
				['arms'] = 81,
				['pants_1'] = 214,   ['pants_2'] = 0,
				['shoes_1'] = 18,   ['shoes_2'] = 3,
			}
		},
		[1] = {
			male = {
				['tshirt_1'] = 15,  ['tshirt_2'] = 0,
				['torso_1'] = 763,   ['torso_2'] = 7,
				['decals_1'] = 0,   ['decals_2'] = 0,
				['arms'] = 55,
				['pants_1'] = 393,   ['pants_2'] = 1,
				['shoes_1'] = 129,   ['shoes_2'] = 0,
			},
			female = {
				['tshirt_1'] = 10,  ['tshirt_2'] = 0,
				['torso_1'] = 764,   ['torso_2'] = 7,
				['decals_1'] = 0,   ['decals_2'] = 0,
				['arms'] = 81,
				['pants_1'] = 214,   ['pants_2'] = 0,
				['shoes_1'] = 18,   ['shoes_2'] = 3,
			}
		},
		[2] = {
			male = {
				['tshirt_1'] = 15,  ['tshirt_2'] = 0,
				['torso_1'] = 763,   ['torso_2'] = 8,
				['decals_1'] = 0,   ['decals_2'] = 0,
				['arms'] = 55,
				['pants_1'] = 393,   ['pants_2'] = 1,
				['shoes_1'] = 129,   ['shoes_2'] = 0,
			},
			female = {
				['tshirt_1'] = 10,  ['tshirt_2'] = 0,
				['torso_1'] = 764,   ['torso_2'] = 8,
				['decals_1'] = 0,   ['decals_2'] = 0,
				['arms'] = 81,
				['pants_1'] = 214,   ['pants_2'] = 0,
				['shoes_1'] = 18,   ['shoes_2'] = 3,
			}
		},
		[3] = {
			male = {
				['tshirt_1'] = 15,  ['tshirt_2'] = 0,
				['torso_1'] = 763,   ['torso_2'] = 9,
				['decals_1'] = 0,   ['decals_2'] = 0,
				['arms'] = 55,
				['pants_1'] = 393,   ['pants_2'] = 1,
				['shoes_1'] = 129,   ['shoes_2'] = 0,
			},
			female = {
				['tshirt_1'] = 10,  ['tshirt_2'] = 0,
				['torso_1'] = 764,   ['torso_2'] = 9,
				['decals_1'] = 0,   ['decals_2'] = 0,
				['arms'] = 81,
				['pants_1'] = 214,   ['pants_2'] = 0,
				['shoes_1'] = 18,   ['shoes_2'] = 3,
			}
		},
		[4] = {
			male = {
				['tshirt_1'] = 15,  ['tshirt_2'] = 0,
				['torso_1'] = 763,   ['torso_2'] = 10,
				['decals_1'] = 0,   ['decals_2'] = 0,
				['arms'] = 55,
				['pants_1'] = 393,   ['pants_2'] = 1,
				['shoes_1'] = 129,   ['shoes_2'] = 0,
			},
			female = {
				['tshirt_1'] = 10,  ['tshirt_2'] = 0,
				['torso_1'] = 764,   ['torso_2'] = 10,
				['decals_1'] = 0,   ['decals_2'] = 0,
				['arms'] = 81,
				['pants_1'] = 214,   ['pants_2'] = 0,
				['shoes_1'] = 18,   ['shoes_2'] = 3,
			}
		},
		[5] = {
			male = {
				['tshirt_1'] = 15,  ['tshirt_2'] = 0,
				['torso_1'] = 763,   ['torso_2'] = 11,
				['decals_1'] = 0,   ['decals_2'] = 0,
				['arms'] = 55,
				['pants_1'] = 393,   ['pants_2'] = 1,
				['shoes_1'] = 129,   ['shoes_2'] = 0,
			},
			female = {
				['tshirt_1'] = 10,  ['tshirt_2'] = 0,
				['torso_1'] = 764,   ['torso_2'] = 11,
				['decals_1'] = 0,   ['decals_2'] = 0,
				['arms'] = 81,
				['pants_1'] = 214,   ['pants_2'] = 0,
				['shoes_1'] = 18,   ['shoes_2'] = 3,
			}
		},
		[6] = {
			male = {
				['tshirt_1'] = 15,  ['tshirt_2'] = 0,
				['torso_1'] = 763,   ['torso_2'] = 11,
				['decals_1'] = 0,   ['decals_2'] = 0,
				['arms'] = 55,
				['pants_1'] = 393,   ['pants_2'] = 1,
				['shoes_1'] = 129,   ['shoes_2'] = 0,
			},
			female = {
				['tshirt_1'] = 10,  ['tshirt_2'] = 0,
				['torso_1'] = 764,   ['torso_2'] = 11,
				['decals_1'] = 0,   ['decals_2'] = 0,
				['arms'] = 81,
				['pants_1'] = 214,   ['pants_2'] = 0,
				['shoes_1'] = 18,   ['shoes_2'] = 3,
			}
		},
	},
	mechanic = {
		[0] = { -- Praktikantas
			male = {
				['tshirt_1'] = 15, ['tshirt_2'] = 0,
				['torso_1'] = 791, ['torso_2'] = 6,
				['decals_1'] = 0,  ['decals_2'] = 0,
				['arms'] = 44,     ['arms_2'] = 0,
				['pants_1'] = 404, ['pants_2'] = 0,
				['shoes_1'] = 128, ['shoes_2'] = 0,
			},
			female = {
				['tshirt_1'] = 6,   ['tshirt_2'] = 0,
				['torso_1'] = 779,  ['torso_2'] = 11,
				['decals_1'] = 0,   ['decals_2'] = 0,
				['arms'] = 302,     ['arms_2'] = 1,
				['pants_1'] = 334,  ['pants_2'] = 0,
				['shoes_1'] = 242,  ['shoes_2'] = 9,
			}
		},
		[1] = { -- Apsipratęs
			male = {
				['tshirt_1'] = 15, ['tshirt_2'] = 0,
				['torso_1'] = 791, ['torso_2'] = 11,
				['decals_1'] = 0,  ['decals_2'] = 0,
				['arms'] = 44,     ['arms_2'] = 0,
				['pants_1'] = 404, ['pants_2'] = 0,
				['shoes_1'] = 128, ['shoes_2'] = 0,
			},
			female = {
				['tshirt_1'] = 6,   ['tshirt_2'] = 0,
				['torso_1'] = 779,  ['torso_2'] = 6,
				['decals_1'] = 0,   ['decals_2'] = 0,
				['arms'] = 302,     ['arms_2'] = 1,
				['pants_1'] = 334,  ['pants_2'] = 0,
				['shoes_1'] = 242,  ['shoes_2'] = 9,
			}
		},
		[2] = { -- Tepalinis
			male = {
				['tshirt_1'] = 15, ['tshirt_2'] = 0,
				['torso_1'] = 791, ['torso_2'] = 8,
				['decals_1'] = 0,  ['decals_2'] = 0,
				['arms'] = 44,     ['arms_2'] = 0,
				['pants_1'] = 404, ['pants_2'] = 0,
				['shoes_1'] = 128, ['shoes_2'] = 0,
			},
			female = {
				['tshirt_1'] = 6,   ['tshirt_2'] = 0,
				['torso_1'] = 779,  ['torso_2'] = 10,
				['decals_1'] = 0,   ['decals_2'] = 0,
				['arms'] = 302,     ['arms_2'] = 1,
				['pants_1'] = 334,  ['pants_2'] = 0,
				['shoes_1'] = 242,  ['shoes_2'] = 9,
			}
		},
		[3] = { -- Kėbulistas
			male = {
				['tshirt_1'] = 15, ['tshirt_2'] = 0,
				['torso_1'] = 791, ['torso_2'] = 9,
				['decals_1'] = 0,  ['decals_2'] = 0,
				['arms'] = 44,     ['arms_2'] = 0,
				['pants_1'] = 404, ['pants_2'] = 0,
				['shoes_1'] = 128, ['shoes_2'] = 0,
			},
			female = {
				['tshirt_1'] = 6,   ['tshirt_2'] = 0,
				['torso_1'] = 779,  ['torso_2'] = 7,
				['decals_1'] = 0,   ['decals_2'] = 0,
				['arms'] = 302,     ['arms_2'] = 1,
				['pants_1'] = 334,  ['pants_2'] = 0,
				['shoes_1'] = 242,  ['shoes_2'] = 9,
			}
		},
		[4] = { -- Garažinis
			male = {
				['tshirt_1'] = 15, ['tshirt_2'] = 0,
				['torso_1'] = 791, ['torso_2'] = 7,
				['decals_1'] = 0,  ['decals_2'] = 0,
				['arms'] = 44,     ['arms_2'] = 0,
				['pants_1'] = 404, ['pants_2'] = 0,
				['shoes_1'] = 128, ['shoes_2'] = 0,
			},
			female = {
				['tshirt_1'] = 6,   ['tshirt_2'] = 0,
				['torso_1'] = 779,  ['torso_2'] = 8,
				['decals_1'] = 0,   ['decals_2'] = 0,
				['arms'] = 302,     ['arms_2'] = 1,
				['pants_1'] = 334,  ['pants_2'] = 0,
				['shoes_1'] = 242,  ['shoes_2'] = 9,
			}
		},
		[5] = { -- Valdžia
			male = {
				['tshirt_1'] = 15, ['tshirt_2'] = 0,
				['torso_1'] = 791, ['torso_2'] = 10,
				['decals_1'] = 0,  ['decals_2'] = 0,
				['arms'] = 44,     ['arms_2'] = 0,
				['pants_1'] = 404, ['pants_2'] = 0,
				['shoes_1'] = 128, ['shoes_2'] = 0,
			},
			female = {
				['tshirt_1'] = 6,   ['tshirt_2'] = 0,
				['torso_1'] = 779,  ['torso_2'] = 9,
				['decals_1'] = 0,   ['decals_2'] = 0,
				['arms'] = 302,     ['arms_2'] = 1,
				['pants_1'] = 334,  ['pants_2'] = 0,
				['shoes_1'] = 242,  ['shoes_2'] = 9,
			}
		},
		[6] = { -- Valdžia
			male = {
				['tshirt_1'] = 15, ['tshirt_2'] = 0,
				['torso_1'] = 791, ['torso_2'] = 10,
				['decals_1'] = 0,  ['decals_2'] = 0,
				['arms'] = 44,     ['arms_2'] = 0,
				['pants_1'] = 404, ['pants_2'] = 0,
				['shoes_1'] = 128, ['shoes_2'] = 0,
			},
			female = {
				['tshirt_1'] = 6,   ['tshirt_2'] = 0,
				['torso_1'] = 779,  ['torso_2'] = 9,
				['decals_1'] = 0,   ['decals_2'] = 0,
				['arms'] = 302,     ['arms_2'] = 1,
				['pants_1'] = 334,  ['pants_2'] = 0,
				['shoes_1'] = 242,  ['shoes_2'] = 9,
			}
		},
	},
	mechanic2 = {
		[0] = { -- Praktikantas
			male = {
				['tshirt_1'] = 15,  ['tshirt_2'] = 0,
				['torso_1'] = 791,  ['torso_2'] = 0,
				['decals_1'] = 0,   ['decals_2'] = 0,
				['arms'] = 44,
				['pants_1'] = 404,  ['pants_2'] = 1,
				['shoes_1'] = 128,  ['shoes_2'] = 0,
			},
			female = {
				['tshirt_1'] = 6,   ['tshirt_2'] = 0,
				['torso_1'] = 779,  ['torso_2'] = 5,
				['decals_1'] = 0,   ['decals_2'] = 0,
				['arms'] = 302,     ['arms_2'] = 1,
				['pants_1'] = 334,  ['pants_2'] = 1,
				['shoes_1'] = 242,  ['shoes_2'] = 9,
			}
		},
		[1] = { -- Apsipratęs
			male = {
				['tshirt_1'] = 15,  ['tshirt_2'] = 0,
				['torso_1'] = 791,  ['torso_2'] = 5,
				['decals_1'] = 0,   ['decals_2'] = 0,
				['arms'] = 44,
				['pants_1'] = 404,  ['pants_2'] = 1,
				['shoes_1'] = 128,  ['shoes_2'] = 0,
			},
			female = {
				['tshirt_1'] = 6,   ['tshirt_2'] = 0,
				['torso_1'] = 779,  ['torso_2'] = 0,
				['decals_1'] = 0,   ['decals_2'] = 0,
				['arms'] = 302,     ['arms_2'] = 1,
				['pants_1'] = 334,  ['pants_2'] = 1,
				['shoes_1'] = 242,  ['shoes_2'] = 9,
			}
		},
		[2] = { -- Tepalinis
			male = {
				['tshirt_1'] = 15,  ['tshirt_2'] = 0,
				['torso_1'] = 791,  ['torso_2'] = 2,
				['decals_1'] = 0,   ['decals_2'] = 0,
				['arms'] = 44,
				['pants_1'] = 404,  ['pants_2'] = 1,
				['shoes_1'] = 128,  ['shoes_2'] = 0,
			},
			female = {
				['tshirt_1'] = 6,   ['tshirt_2'] = 0,
				['torso_1'] = 779,  ['torso_2'] = 2,
				['decals_1'] = 0,   ['decals_2'] = 0,
				['arms'] = 302,     ['arms_2'] = 1,
				['pants_1'] = 334,  ['pants_2'] = 1,
				['shoes_1'] = 242,  ['shoes_2'] = 9,
			}
		},
		[3] = { -- Kėbulistas
			male = {
				['tshirt_1'] = 15,  ['tshirt_2'] = 0,
				['torso_1'] = 791,  ['torso_2'] = 3,
				['decals_1'] = 0,   ['decals_2'] = 0,
				['arms'] = 44,
				['pants_1'] = 404,  ['pants_2'] = 1,
				['shoes_1'] = 128,  ['shoes_2'] = 0,
			},
			female = {
				['tshirt_1'] = 6,   ['tshirt_2'] = 0,
				['torso_1'] = 779,  ['torso_2'] = 1,
				['decals_1'] = 0,   ['decals_2'] = 0,
				['arms'] = 302,     ['arms_2'] = 1,
				['pants_1'] = 334,  ['pants_2'] = 1,
				['shoes_1'] = 242,  ['shoes_2'] = 9,
			}
		},
		[4] = { -- Garažinis
			male = {
				['tshirt_1'] = 15,  ['tshirt_2'] = 0,
				['torso_1'] = 791,  ['torso_2'] = 1,
				['decals_1'] = 0,   ['decals_2'] = 0,
				['arms'] = 44,
				['pants_1'] = 404,  ['pants_2'] = 1,
				['shoes_1'] = 128,  ['shoes_2'] = 0,
			},
			female = {
				['tshirt_1'] = 6,   ['tshirt_2'] = 0,
				['torso_1'] = 779,  ['torso_2'] = 3,
				['decals_1'] = 0,   ['decals_2'] = 0,
				['arms'] = 302,     ['arms_2'] = 1,
				['pants_1'] = 334,  ['pants_2'] = 1,
				['shoes_1'] = 242,  ['shoes_2'] = 9,
			}
		},
		[5] = { -- Valdžia
			male = {
				['tshirt_1'] = 15,  ['tshirt_2'] = 0,
				['torso_1'] = 791,  ['torso_2'] = 4,
				['decals_1'] = 0,   ['decals_2'] = 0,
				['arms'] = 44,
				['pants_1'] = 404,  ['pants_2'] = 1,
				['shoes_1'] = 128,  ['shoes_2'] = 0,
			},
			female = {
				['tshirt_1'] = 6,   ['tshirt_2'] = 0,
				['torso_1'] = 779,  ['torso_2'] = 4,
				['decals_1'] = 0,   ['decals_2'] = 0,
				['arms'] = 302,     ['arms_2'] = 1,
				['pants_1'] = 334,  ['pants_2'] = 1,
				['shoes_1'] = 242,  ['shoes_2'] = 9,
			}
		},
		[6] = { -- Valdžia
			male = {
				['tshirt_1'] = 15,  ['tshirt_2'] = 0,
				['torso_1'] = 791,  ['torso_2'] = 4,
				['decals_1'] = 0,   ['decals_2'] = 0,
				['arms'] = 44,
				['pants_1'] = 404,  ['pants_2'] = 1,
				['shoes_1'] = 128,  ['shoes_2'] = 0,
			},
			female = {
				['tshirt_1'] = 6,   ['tshirt_2'] = 0,
				['torso_1'] = 779,  ['torso_2'] = 4,
				['decals_1'] = 0,   ['decals_2'] = 0,
				['arms'] = 302,     ['arms_2'] = 1,
				['pants_1'] = 334,  ['pants_2'] = 1,
				['shoes_1'] = 242,  ['shoes_2'] = 9,
			}
		},
	},
}