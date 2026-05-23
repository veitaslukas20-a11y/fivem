
Config                            = {}

Config.DrawDistance               = 10.0
Config.MarkerType                 = {Cloakrooms = 20, Ekipuote = 21, BossActions = 22, Vehicles = 36, Helicopters = 34}
Config.MarkerSize                 = {x = 0.5, y = 1.5, z = 0.5}
Config.MarkerColor                = {r = 50, g = 50, b = 204}

Config.PoliceStations = {

	LSPD = {
		Blip = {
			Coords  = vector3(2512.9714, -354.7151, 95.2793),
			Sprite  = 60,
			Display = 4,
			Scale   = 0.7,
			Colour  = 29
		},
		Cloakrooms = {
			vector3(2519.6912, -333.1389, 94.0926),
			vector3(2515.1223, -421.6534, 106.9130)
		},
		Ekipuote = {
			vector3(2525.9084, -335.5765, 94.0925)
		},
		Vehicles = {
			{
				Spawner = vector3(2535.4946, -370.1464, 93.0604),
				InsideShop = vector4(2545.2981, -367.1235, 92.9944, 82.9844),
				SpawnPoints = {
					{coords = vector3(2538.5298, -372.0459, 92.9940), heading = 344.0850, radius = 2.0},
					{coords = vector3(2542.2397, -372.0670, 92.9940), heading = 351.9215, radius = 2.0},
					{coords = vector3(2545.9021, -372.4214, 92.9940), heading = 6.1135, radius = 2.0},
					{coords = vector3(2549.4688, -372.6601, 92.9940), heading = 337.5555, radius = 2.0},
				}
			}
		},
		Helicopters = {
			{
				Spawner = vector3(2505.1094, -341.3313, 118.0227),
				InsideShop = vector4(2510.6150, -341.9454, 118.1850, 221.4657),
				SpawnPoints = {
					{coords = vector3(2510.6150, -341.9454, 118.1850), heading = 221.4657, radius = 10.0}
				}
			}
		},
		BossActions = {
			vector3(2500.1772, -402.5561, 99.1117)
		}
	},

	LSPD2 = {
		Cloakrooms = {
			vector3(458.465942, -992.874756, 30.678344),
		},
		Ekipuote = {},
		Vehicles = {
			{
				Spawner = vector3(458.4637, -1024.5139, 28.3745),
				InsideShop = vector4(453.1700, -1017.8926, 28.4599, 89.8381),
				SpawnPoints = {
					{coords = vector3(445.8570, -1025.3737, 28.6495), heading = 7.8462, radius = 2.0},
					{coords = vector3(442.0343, -1025.5170, 28.7202), heading = 5.5459, radius = 2.0},
				}
			}
		},
		Helicopters = {},
		BossActions = {}
	},

	Paleto = {
		Blip = {
			Coords  = vector3(-444.5779, 5995.9199, 32.4782),
			Sprite  = 60,
			Display = 4,
			Scale   = 0.7,
			Colour  = 29
		},
		Cloakrooms = {
			vector3(-444.5918, 6008.2290, 31.7165)
		},
		Ekipuote = {
			vector3(-439.8675, 6006.6006, 31.7165)
		},
		Vehicles = {
			{
				Spawner = vector3(-471.2006, 5965.8501, 31.4239),
				InsideShop = vector4(-468.7669, 6023.1289, 31.3404, 224.1152),
				SpawnPoints = {
					{coords = vector3(-473.9626, 5969.7871, 31.4239), heading = 316.8888, radius = 3.0},
					{coords = vector3(-475.8682, 5971.9854, 31.4239), heading = 314.2450, radius = 3.0},
					{coords = vector3(-477.7598, 5974.1509, 31.4239), heading = 313.5041, radius = 3.0},
					{coords = vector3(-479.9066, 5976.1143, 31.4239), heading = 315.3992, radius = 3.0},
					{coords = vector3(-481.8890, 5978.1313, 31.4239), heading = 313.1581, radius = 3.0},
				}
			},
		},
		Helicopters = {
			{
				Spawner = vector3(-474.6396, 6004.3408, 31.3024),
				InsideShop = vector4(-486.7983, 6000.2988, 31.2927, 51.0223),
				SpawnPoints = {
					{coords = vector3(-486.7983, 6000.2988, 31.2927), heading = 51.0223, radius = 10.0}
				}
			}
		},
		BossActions = {
			vector3(-434.3754, 6006.1343, 36.1172)
		}
	},

	Sandy = {
		Blip = {
			Coords  = vector3(1737.5216, 3897.4463, 39.7807),
			Sprite  = 60,
			Display = 4,
			Scale   = 0.7,
			Colour  = 29
		},
		Cloakrooms = {
			vector3(1733.6318, 3890.7576, 31.4519)
		},
		Ekipuote = {
			vector3(1729.1432, 3895.3184, 31.4520)
		},
		Vehicles = {
			{
				Spawner = vector3(1749.6382, 3886.1084, 34.6833),
				InsideShop = vector4(1743.0684, 3882.1487, 34.6807, 212.7650),
				SpawnPoints = {
					{coords = vector3(1735.6519, 3881.1365, 34.7293), heading = 299.1499, radius = 3.0},
					{coords = vector3(1736.8483, 3877.4541, 34.7096), heading = 298.4476, radius = 3.0},
					{coords = vector3(1738.8839, 3874.8618, 34.6783), heading = 296.9514, radius = 3.0},
					{coords = vector3(1740.6743, 3872.0281, 34.6720), heading = 296.3192, radius = 3.0},
				}
			},
		},
		Helicopters = {
			{
				Spawner = vector3(1730.0314, 3872.2822, 41.5831),
				InsideShop = vector4(1729.4313, 3863.3250, 41.5831, 220.5838),
				SpawnPoints = {
					{coords = vector3(1729.4313, 3863.3250, 41.5831), heading = 220.5838, radius = 10.0}
				}
			}
		},
		BossActions = {
			vector3(1737.5216, 3897.4463, 39.7807)
		}
	},

	Krimai = {
		Blip = {
			Coords  = vector3(1853.28, 3685.59, 34.27),
			Sprite  = 60,
			Display = 4,
			Scale   = 0.0,
			Colour  = 29
		},
		Cloakrooms = {
			vector3(-570.5869, -1612.2906, 30.1539)
		},
		Ekipuote = {},
		Vehicles = {
			{
				Spawner = vector3(-575.9349, -1611.4410, 27.0112),
				InsideShop = vector4(-600.0012, -1601.3258, 27.0112, 260.0271),
				SpawnPoints = {
					{coords = vector3(-584.1937, -1607.1486, 27.0112), heading = 79.989, radius = 6.0},
				}
			},
		},
		Helicopters = {},
		BossActions = {}
	},

	Sala = {
		Cloakrooms = {
			vector3(930.8536, -1462.9476, 33.6130)
		},
		Ekipuote = {},
		Vehicles = {
			{
				Spawner = vector3(4931.2964, -5295.6597, 5.6816),
				InsideShop = vector4(4939.6792, -5311.9473, 6.5936, 351.3446),
				SpawnPoints = {
					{coords = vector3(4952.9019, -5290.6543, 5.4768), heading = 82.2855, radius = 3.0},
					{coords = vector3(4953.2808, -5286.6426, 5.2897), heading = 88.5222, radius = 3.0},
					{coords = vector3(4953.0020, -5281.0234, 5.1932), heading = 83.0862, radius = 3.0},
				}
			},
		},
		Helicopters = {
			{
				Spawner = vector3(4896.1138, -5285.7139, 8.4893),
				InsideShop = vector4(4859.7832, -5278.4014, 8.7504, 265.3211),
				SpawnPoints = {
					{coords = vector3(4881.9048, -5282.9175, 8.4299), heading = 268.9354, radius = 10.0}
				}
			},
		},
		BossActions = {}
	},
}

Config.AuthorizedVehicles = {
	car = {
		-- grade 0-1: Jaun.Policininkas, Policininkas
		recruit = {
			{model = 'gcapd1', price = 10},
			{model = 'gcapd2', price = 10},
			{model = 'gcapd3', price = 10},
			{model = 'gcapd4', price = 10},
			{model = 'gcapd5', price = 10},
			{model = 'gcapd6', price = 10},
			{model = 'sspd25', price = 10},
			{model = 'gcapd11', price = 10},
			{model = 'gcpd20', price = 10},
			{model = 'gcpd25', price = 10},
		},

		-- grade 2-3: Vyr.Policininkas, Kriminalistas
		officer = {
			{model = 'gcapd1', price = 10},
			{model = 'gcapd2', price = 10},
			{model = 'gcapd3', price = 10},
			{model = 'gcapd4', price = 10},
			{model = 'gcapd5', price = 10},
			{model = 'gcapd6', price = 10},
			{model = 'sspd25', price = 10},
			{model = 'gcapd11', price = 10},
			{model = 'gcpd20', price = 10},
			{model = 'gcpd25', price = 10},
		},

		-- grade 4-5: Inspektorius, Komisaras
		sergeant = {
			{model = 'gcapd1', price = 10},
			{model = 'gcapd2', price = 10},
			{model = 'gcapd3', price = 10},
			{model = 'gcapd4', price = 10},
			{model = 'gcapd5', price = 10},
			{model = 'gcapd6', price = 10},
			{model = 'sspd25', price = 10},
			{model = 'gcapd11', price = 10},
			{model = 'gcpd20', price = 10},
			{model = 'gcpd25', price = 10},
		},

		-- grade 6-7: Vyr.Komisaras, Aras
		lieutenant = {
			{model = 'gcapd1', price = 10},
			{model = 'gcapd2', price = 10},
			{model = 'gcapd3', price = 10},
			{model = 'gcapd4', price = 10},
			{model = 'gcapd5', price = 10},
			{model = 'gcapd6', price = 10},
			{model = 'sspd25', price = 10},
			{model = 'gcapd11', price = 10},
			{model = 'gcpd20', price = 10},
			{model = 'gcpd25', price = 10},
		},

		-- grade 8-9: Bravo, Charlie
		chef = {
			{model = 'gcapd1', price = 10},
			{model = 'gcapd2', price = 10},
			{model = 'gcapd3', price = 10},
			{model = 'gcapd4', price = 10},
			{model = 'gcapd5', price = 10},
			{model = 'gcapd6', price = 10},
			{model = 'sspd25', price = 10},
			{model = 'gcapd11', price = 10},
			{model = 'gcpd20', price = 10},
			{model = 'gcpd25', price = 10},
		},

		-- grade 10-11: Aro Vadas, Gen.Komisaras
		boss = {
			{model = 'gcapd1', price = 10},
			{model = 'gcapd2', price = 10},
			{model = 'gcapd3', price = 10},
			{model = 'gcapd4', price = 10},
			{model = 'gcapd5', price = 10},
			{model = 'gcapd6', price = 10},
			{model = 'sspd25', price = 10},
			{model = 'gcapd11', price = 10},
			{model = 'gcpd20', price = 10},
			{model = 'gcpd25', price = 10},
		},
	},

	helicopter = {
		vyrpareigunas = {
			{model = 'gcpdhel1', props = {modLivery = 0}, price = 15000},
			{model = 'nnpdhel', props = {modLivery = 0}, price = 15000}
		},
		sergeant = {
			{model = 'gcpdhel1', props = {modLivery = 0}, price = 15000},
			{model = 'nnpdhel', props = {modLivery = 0}, price = 15000}
		},
		aras = {
			{model = 'gcpdhel1', props = {modLivery = 0}, price = 15000},
			{model = 'nnpdhel', props = {modLivery = 0}, price = 15000},
			{model = 'dcpdhel', props = {modLivery = 0}, price = 15000}
		},
		arovadas = {
			{model = 'gcpdhel1', props = {modLivery = 0}, price = 15000},
			{model = 'nnpdhel', props = {modLivery = 0}, price = 15000},
			{model = 'dcpdhel', props = {modLivery = 0}, price = 15000}
		},
		chef = {
			{model = 'gcpdhel1', props = {modLivery = 0}, price = 15000},
			{model = 'nnpdhel', props = {modLivery = 0}, price = 15000},
			{model = 'dcpdhel', props = {modLivery = 0}, price = 15000}
		},
		chef2 = {
			{model = 'gcpdhel1', props = {modLivery = 0}, price = 15000},
			{model = 'nnpdhel', props = {modLivery = 0}, price = 15000},
			{model = 'dcpdhel', props = {modLivery = 0}, price = 15000}
		},
		boss = {
			{model = 'gcpdhel1', props = {modLivery = 0}, price = 15000},
			{model = 'nnpdhel', props = {modLivery = 0}, price = 15000},
			{model = 'dcpdhel', props = {modLivery = 0}, price = 15000}
		},
		boss = {
			{model = 'gcpdhel1', props = {modLivery = 0}, price = 15000},
			{model = 'nnpdhel', props = {modLivery = 0}, price = 15000},
			{model = 'dcpdhel', props = {modLivery = 0}, price = 15000}
		}
	}
}

-- CHECK SKINCHANGER CLIENT MAIN.LUA for matching elements

Config.Uniforms = {

	patrol_wear10 = {
		male = {
			['tshirt_1'] = 15,  ['tshirt_2'] = 0,
			['torso_1'] = 804,   ['torso_2'] = 0,
			['decals_1'] = 0,   ['decals_2'] = 0,
			['arms'] = 39,
			['pants_1'] = 410,   ['pants_2'] = 0,
			['shoes_1'] = 129,   ['shoes_2'] = 0,
			['helmet_1'] = 260,  ['helmet_2'] = 0,
			['chain_1'] = 26,    ['chain_2'] = 0,
			['glasses_1'] = 78,    ['glasses_2'] = 4,
			['mask_1'] = 322, ['mask_2'] = 0,
		},
		female = {
			['tshirt_1'] = 1,  ['tshirt_2'] = 0,
			['torso_1'] = 767,   ['torso_2'] = 0,
			['decals_1'] = 0,   ['decals_2'] = 0,
			['arms'] = 84,
			['pants_1'] = 5,   ['pants_2'] = 0,
			['shoes_1'] = 22,   ['shoes_2'] = 0,
			['helmet_1'] = 231,  ['helmet_2'] = 0,
			['chain_1'] = 8,    ['chain_2'] = 0,
			['glasses_1'] = 36,    ['glasses_2'] = 4,
			['mask_1'] = 102, ['mask_2'] = 0, 
		}
	},

	patrol_wear9 = {
		male = {
			['tshirt_1'] = 165,  ['tshirt_2'] = 0,
			['torso_1'] = 427,   ['torso_2'] = 4,
			['decals_1'] = 0,   ['decals_2'] = 0,
			['arms'] = 38,
			['pants_1'] = 243,   ['pants_2'] = 1,
			['shoes_1'] = 128,   ['shoes_2'] = 0,
			['helmet_1'] = -1,  ['helmet_2'] = 0,
		},
		female = {
			['tshirt_1'] = 1,  ['tshirt_2'] = 0,
			['torso_1'] = 13,   ['torso_2'] = 1,
			['decals_1'] = 0,   ['decals_2'] = 0,
			['arms'] = 78,
			['pants_1'] = 248,   ['pants_2'] = 0,
			['shoes_1'] = 92,   ['shoes_2'] = 0,
			['helmet_1'] = -1,  ['helmet_2'] = 0,
			['chain_1'] = 8,    ['chain_2'] = 0,
			['mask_1'] = -1, ['mask_2'] = 0,
			['bproof_1'] = 182,  ['bproof_2'] = 0
		}
	},

	patrol_wear8 = {
		male = {
			['tshirt_1'] = 165,  ['tshirt_2'] = 0,
			['torso_1'] = 213,   ['torso_2'] = 1,
			['decals_1'] = 0,   ['decals_2'] = 0,
			['arms'] = 106,
			['pants_1'] = 144,   ['pants_2'] = 2,
			['shoes_1'] = 129,   ['shoes_2'] = 0,
			['helmet_1'] = -1,  ['helmet_2'] = 0,
			['chain_1'] = 20,    ['chain_2'] = 0,
			['mask_1'] = 181, ['mask_2'] = 0,
		},
		female = {
			['tshirt_1'] = 145,  ['tshirt_2'] = 0,
			['torso_1'] = 325,   ['torso_2'] = 0,
			['decals_1'] = 0,   ['decals_2'] = 0,
			['arms'] = 77,
			['pants_1'] = 142,   ['pants_2'] = 0,
			['shoes_1'] = 92,   ['shoes_2'] = 0,
			['helmet_1'] = -1,  ['helmet_2'] = 0,
			['chain_1'] = -1,    ['chain_2'] = 0,
			['mask_1'] = -1, ['mask_2'] = 0, 
		}
	},

	patrol_wear7 = {
		male = {
			['tshirt_1'] = 165,  ['tshirt_2'] = 0,
			['torso_1'] = 767,   ['torso_2'] = 2,
			['decals_1'] = 0,   ['decals_2'] = 0,
			['arms'] = 38,
			['pants_1'] = 5,   ['pants_2'] = 0,
			['shoes_1'] = 201,   ['shoes_2'] = 0,
			['helmet_1'] = -1,  ['helmet_2'] = 0,
			['chain_1'] = 20,    ['chain_2'] = 0,
			['mask_1'] = 181, ['mask_2'] = 0,
		},
		female = {
			['tshirt_1'] = 145,  ['tshirt_2'] = 0,
			['torso_1'] = 325,   ['torso_2'] = 0,
			['decals_1'] = 0,   ['decals_2'] = 0,
			['arms'] = 77,
			['pants_1'] = 142,   ['pants_2'] = 0,
			['shoes_1'] = 92,   ['shoes_2'] = 0,
			['helmet_1'] = -1,  ['helmet_2'] = 0,
			['chain_1'] = -1,    ['chain_2'] = 0,
			['mask_1'] = -1, ['mask_2'] = 0, 
		}
	},

	patrol_wear6 = {
		male = {
			['tshirt_1'] = 165,  ['tshirt_2'] = 0,
			['torso_1'] = 213,   ['torso_2'] = 0,
			['decals_1'] = 0,   ['decals_2'] = 0,
			['arms'] = 38,
			['pants_1'] = 200,   ['pants_2'] = 2,
			['shoes_1'] = 129,   ['shoes_2'] = 0,
			['helmet_1'] = -1,  ['helmet_2'] = 0,
			['chain_1'] = 20,    ['chain_2'] = 0,
			['mask_1'] = 181, ['mask_2'] = 0
		},
		female = {
			['tshirt_1'] = 145,  ['tshirt_2'] = 0,
			['torso_1'] = 325,   ['torso_2'] = 0,
			['decals_1'] = 0,   ['decals_2'] = 0,
			['arms'] = 77,
			['pants_1'] = 142,   ['pants_2'] = 0,
			['shoes_1'] = 92,   ['shoes_2'] = 0,
			['helmet_1'] = -1,  ['helmet_2'] = 0,
			['chain_1'] = -1,    ['chain_2'] = 0,
			['mask_1'] = -1, ['mask_2'] = 0, 
		}
	},

	patrol_wear5 = {
		male = {
			['tshirt_1'] = 165,  ['tshirt_2'] = 0,
			['torso_1'] = 214,   ['torso_2'] = 0,
			['decals_1'] = 0,   ['decals_2'] = 0,
			['arms'] = 106,
			['pants_1'] = 243,   ['pants_2'] = 0,
			['shoes_1'] = 129,   ['shoes_2'] = 0,
			['helmet_1'] = -1,  ['helmet_2'] = 0,
			['chain_1'] = 20,    ['chain_2'] = 0,
			['mask_1'] = 181, ['mask_2'] = 0, 
		},
		female = {
			['tshirt_1'] = 145,  ['tshirt_2'] = 0,
			['torso_1'] = 325,   ['torso_2'] = 0,
			['decals_1'] = 0,   ['decals_2'] = 0,
			['arms'] = 77,
			['pants_1'] = 142,   ['pants_2'] = 0,
			['shoes_1'] = 92,   ['shoes_2'] = 0,
			['helmet_1'] = -1,  ['helmet_2'] = 0,
			['chain_1'] = -1,    ['chain_2'] = 0,
			['mask_1'] = -1, ['mask_2'] = 0, 
		}
	},

	patrol_wear4 = {
		male = {
			['tshirt_1'] = 165,  ['tshirt_2'] = 0,
			['torso_1'] = 785,   ['torso_2'] = 0,
			['decals_1'] = 0,   ['decals_2'] = 0,
			['arms'] = 36,
			['pants_1'] = 401,   ['pants_2'] = 0,
			['shoes_1'] = 129,   ['shoes_2'] = 0,
			['helmet_1'] = -1,  ['helmet_2'] = 0,
			['chain_1'] = 20,    ['chain_2'] = 0,
			['mask_1'] = 181, ['mask_2'] = 0, 
		},
		female = {
			['tshirt_1'] = 145,  ['tshirt_2'] = 0,
			['torso_1'] = 325,   ['torso_2'] = 0,
			['decals_1'] = 0,   ['decals_2'] = 0,
			['arms'] = 77,
			['pants_1'] = 142,   ['pants_2'] = 0,
			['shoes_1'] = 92,   ['shoes_2'] = 0,
			['helmet_1'] = -1,  ['helmet_2'] = 0,
			['chain_1'] = -1,    ['chain_2'] = 0,
			['mask_1'] = -1, ['mask_2'] = 0, 
		}
	},

	patrol_wear3 = {
		male = {
			['tshirt_1'] = 159,  ['tshirt_2'] = 0,
			['torso_1'] = 791,   ['torso_2'] = 0,
			['decals_1'] = 0,   ['decals_2'] = 0,
			['arms'] = 34,
			['pants_1'] = 401,   ['pants_2'] = 0,
			['shoes_1'] = 129,   ['shoes_2'] = 0,
			['helmet_1'] = -1,  ['helmet_2'] = 0,
			['chain_1'] = 20,    ['chain_2'] = 0,
			['mask_1'] = 181, ['mask_2'] = 0, 
		},
		female = {
			['tshirt_1'] = 145,  ['tshirt_2'] = 0,
			['torso_1'] = 325,   ['torso_2'] = 0,
			['decals_1'] = 0,   ['decals_2'] = 0,
			['arms'] = 77,
			['pants_1'] = 142,   ['pants_2'] = 0,
			['shoes_1'] = 92,   ['shoes_2'] = 0,
			['helmet_1'] = -1,  ['helmet_2'] = 0,
			['chain_1'] = -1,    ['chain_2'] = 0,
			['mask_1'] = -1, ['mask_2'] = 0, 
		}
	},

	patrol_wear2 = {
		male = {
			['tshirt_1'] = 148,  ['tshirt_2'] = 0,
			['torso_1'] = 653,   ['torso_2'] = 0,
			['decals_1'] = 0,   ['decals_2'] = 0,
			['arms'] = 34,
			['pants_1'] = 5,   ['pants_2'] = 0,
			['shoes_1'] = 128,   ['shoes_2'] = 0,
			['helmet_1'] = -1,  ['helmet_2'] = 0,
			['chain_1'] = 20,    ['chain_2'] = 0,
			['mask_1'] = 181, ['mask_2'] = 0, 
		},
		female = {
			['tshirt_1'] = 148,  ['tshirt_2'] = 0,
			['torso_1'] = 798,   ['torso_2'] = 0,
			['decals_1'] = 0,   ['decals_2'] = 0,
			['arms'] = 34,
			['pants_1'] = 401,   ['pants_2'] = 0,
			['shoes_1'] = 129,   ['shoes_2'] = 0,
			['helmet_1'] = -1,  ['helmet_2'] = 0,
			['chain_1'] = 20,    ['chain_2'] = 0,
			['mask_1'] = -1, ['mask_2'] = 0, 
		}
	},

	patrol_wear = {
		male = {
			['tshirt_1'] = 148,  ['tshirt_2'] = 0,
			['torso_1'] = 797,   ['torso_2'] = 1,
			['decals_1'] = 0,   ['decals_2'] = 0,
			['arms'] = 0,
			['pants_1'] = 401,   ['pants_2'] = 0,
			['shoes_1'] = 129,   ['shoes_2'] = 0,
			['helmet_1'] = -1,  ['helmet_2'] = 0,
			['chain_1'] = 20,    ['chain_2'] = 0,
			['mask_1'] = 181, ['mask_2'] = 0,
			['bproof_1'] = 0,  ['bproof_2'] = 0
		},
		female = {
			['tshirt_1'] = 145,  ['tshirt_2'] = 0,
			['torso_1'] = 325,   ['torso_2'] = 0,
			['decals_1'] = 0,   ['decals_2'] = 0,
			['arms'] = 77,
			['pants_1'] = 142,   ['pants_2'] = 0,
			['shoes_1'] = 92,   ['shoes_2'] = 0,
			['helmet_1'] = -1,  ['helmet_2'] = 0,
			['chain_1'] = -1,    ['chain_2'] = 0,
			['mask_1'] = -1, ['mask_2'] = 0, 
		}
	},

	new_wear4 = {
		male = {
			['tshirt_1'] = 165,  ['tshirt_2'] = 0,
			['torso_1'] = 688,   ['torso_2'] = 0,
			['decals_1'] = 0,   ['decals_2'] = 0,
			['arms'] = 212,
			['pants_1'] = 5,   ['pants_2'] = 0,
			['shoes_1'] = 22,   ['shoes_2'] = 0,
			['helmet_1'] = -1,  ['helmet_2'] = 0,
			['chain_1'] = 1,    ['chain_2'] = 0,
			['mask_1'] = 179, ['mask_2'] = 0, 
		},
		female = {
			['tshirt_1'] = 264,  ['tshirt_2'] = 0,
			['torso_1'] = 13,   ['torso_2'] = 1,
			['decals_1'] = 0,   ['decals_2'] = 0,
			['arms'] = 104,
			['pants_1'] = 248,   ['pants_2'] = 1,
			['shoes_1'] = 113,   ['shoes_2'] = 0,
			['helmet_1'] = -1,  ['helmet_2'] = 0,
			['chain_1'] = -1,    ['chain_2'] = 0,
			['mask_1'] = -1, ['mask_2'] = 0, 
		}
	},

	new_wear5 = {
		male = {
			['tshirt_1'] = 165,  ['tshirt_2'] = 0,
			['torso_1'] = 688,   ['torso_2'] = 1,
			['decals_1'] = 0,   ['decals_2'] = 0,
			['arms'] = 212,
			['pants_1'] = 5,   ['pants_2'] = 0,
			['shoes_1'] = 22,   ['shoes_2'] = 0,
			['helmet_1'] = -1,  ['helmet_2'] = 0,
			['chain_1'] = 1,    ['chain_2'] = 0,
			['mask_1'] = 179, ['mask_2'] = 0, 
		},
		female = {
			['tshirt_1'] = 264,  ['tshirt_2'] = 0,
			['torso_1'] = 13,   ['torso_2'] = 1,
			['decals_1'] = 0,   ['decals_2'] = 0,
			['arms'] = 104,
			['pants_1'] = 248,   ['pants_2'] = 1,
			['shoes_1'] = 113,   ['shoes_2'] = 0,
			['helmet_1'] = -1,  ['helmet_2'] = 0,
			['chain_1'] = -1,    ['chain_2'] = 0,
			['mask_1'] = -1, ['mask_2'] = 0, 
		}
	},

	bullet_wear = {
		male = { ['bproof_1'] = 6, ['bproof_2'] = 0 },
		female = { ['bproof_1'] = 178, ['bproof_2'] = 0 }
	},
	bullet_wear2 = {
		male = { ['bproof_1'] = 13, ['bproof_2'] = 3 },
		female = { ['bproof_1'] = 180, ['bproof_2'] = 0 }
	},
	bullet_wear3 = {
		male = { ['bproof_1'] = 50, ['bproof_2'] = 1 },
		female = { ['bproof_1'] = 181, ['bproof_2'] = 0 }
	},
	bullet_wear4 = {
		male = { ['bproof_1'] = 12, ['bproof_2'] = 0 },
		female = { ['bproof_1'] = 182, ['bproof_2'] = 0 }
	},
	bullet_wear5 = {
		male = { ['bproof_1'] = 13, ['bproof_2'] = 0 },
		female = { ['bproof_1'] = 183, ['bproof_2'] = 0 }
	},
	bullet_wear6 = {
		male = { ['bproof_1'] = 14, ['bproof_2'] = 0 },
		female = { ['bproof_1'] = 155, ['bproof_2'] = 0 }
	},
	bullet_wear7 = {
		male = { ['bproof_1'] = 133, ['bproof_2'] = 0 },
		female = { ['bproof_1'] = 155, ['bproof_2'] = 0 }
	},
	bullet_wear8 = {
		male = { ['bproof_1'] = 14, ['bproof_2'] = 4 },
		female = { ['bproof_1'] = 181, ['bproof_2'] = 0 }
	},
	bullet_wear9 = {
		male = { ['bproof_1'] = 48, ['bproof_2'] = 0 },
		female = { ['bproof_1'] = 155, ['bproof_2'] = 0 }
	},
	bullet_wear10 = {
		male = { ['bproof_1'] = 14, ['bproof_2'] = 1 },
		female = { ['bproof_1'] = 155, ['bproof_2'] = 0 }
	},
}