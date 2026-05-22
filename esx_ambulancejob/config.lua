Config                            = {}

Config.DrawDistance               = 20.0 -- How close do you need to be in order for the markers to be drawn (in GTA units).

Config.MarkerType                 = {Cloakrooms = 20, BossActions = 22, Vehicles = 36, Helicopters = 34}
Config.MarkerSize                 = {x = 0.5, y = 1.5, z = 0.5}
Config.MarkerColor                = {r = 200, g = 0, b = 50}

Config.ReviveReward               = 700  -- Revive reward, set to 0 if you don't want it enabled
Config.AntiCombatLog              = true -- Enable anti-combat logging? (Removes Items when a player logs back after intentionally logging out while dead.)
Config.LoadIpl                    = false -- Disable if you're using fivem-ipl or other IPL loaders

Config.Locale                     = 'en'

Config.EarlyRespawnTimer          = 60000 * 6  -- time til respawn is available
Config.BleedoutTimer              = 60000 * 10 -- time til the player bleeds out
Config.BedTimer				 	  = 1000 * 1 -- time til the player is revived in bed	

Config.EnablePlayerManagement     = true -- Enable society managing (If you are using esx_society).

Config.RemoveWeaponsAfterRPDeath  = true
Config.RemoveCashAfterRPDeath     = true
Config.RemoveItemsAfterRPDeath    = true

-- Let the player pay for respawning early, only if he can afford it.
Config.EarlyRespawnFine           = false
Config.EarlyRespawnFineAmount     = 2000

Config.BeMediku = 5000

Config.RespawnPoint = {coords = vector3(295.5393, -606.4487, 43.3269), heading = 80.5580}

Config.Hospitals = {
	CentralLosSantos = {

		Blip = {
			coords = vector3(-438.8205, -307.9001, 34.9105),
			sprite = 61,
			scale  = 0.8,
			color  = 75
		},

		Cloakrooms = {
			vec3(-438.8205, -307.9001, 34.9105),
			vec3(-444.7018, -310.2592, 34.9105)
		},

		BossActions = {
			vec3(-509.9301, -300.1330, 69.5230)
		},


		Vehicles = {
			{
				Spawner = vector3(-497.1075, -335.9798, 34.5017),
				InsideShop = vector4(-491.8591, -336.3938, 34.3728, 170.4755),
				Marker = {type = 36, x = 1.0, y = 1.0, z = 1.0, r = 100, g = 50, b = 200, a = 100, rotate = true},
				SpawnPoints = {
					{coords = vector3(-491.8591, -336.3938, 34.3728), heading = 170.4755, radius = 4.0},
				}
			}
		},

		Helicopters = {
			{
				Spawner = vector3(-449.6893, -322.4921, 78.1646),
				InsideShop = vector3(-456.4578, -291.1801, 78.1646),
				Marker = {type = 34, x = 1.5, y = 1.5, z = 1.5, r = 100, g = 150, b = 150, a = 100, rotate = true},
				SpawnPoints = {
					{coords = vector3(-447.4434, -312.4910, 78.1645), heading = 23.6931, radius = 10.0}
				}
			}
		}
	},

	SandyShores = {

		Blip = {
			coords = vector3(1972.5234, 3779.7761, 32.5495),
			sprite = 61,
			scale  = 0.8,
			color  = 75
		},

		Cloakrooms = {
			vector3(1972.5234, 3779.7761, 32.5495)
		},

		BossActions = {
			vec3(1962.0089, 3767.6191, 35.9631),
		},

		Vehicles = {
			{
				Spawner = vector3(1969.6006, 3764.0461, 26.3210),
				InsideShop = vector4(1964.6085, 3760.0264, 26.1558, 208.3297),
				Marker = {type = 36, x = 1.0, y = 1.0, z = 1.0, r = 100, g = 50, b = 200, a = 100, rotate = true},
				SpawnPoints = {
					{coords = vector3(1960.6198, 3748.9175, 26.1558), heading = 300.1647, radius = 3.0},
					{coords = vector3(1962.8463, 3744.9663, 26.1558), heading = 300.1647, radius = 3.0},
					{coords = vector3(1974.6732, 3742.1987, 26.1558), heading = 32.2577, radius = 3.0},
					{coords = vector3(1978.5737, 3744.6382, 26.1558), heading = 32.2577, radius = 3.0},
				}
			}
		},

		Helicopters = {
			{
				Spawner = vector3(1981.3787, 3764.0337, 68.4647),
				InsideShop = vector4(1982.1962, 3771.0364, 68.5199, 27.6974),
				Marker = {type = 34, x = 1.5, y = 1.5, z = 1.5, r = 100, g = 150, b = 150, a = 100, rotate = true},
				SpawnPoints = {
					{coords = vector3(1982.1962, 3771.0364, 68.5199), heading = 27.6974, radius = 10.0}
				}
			}
		}
	},
}

Config.AuthorizedVehicles = {
	car = {
		ambulance = {
			{model = 'gcgmp3', price = 1},
			{model = 'gcgmp1', price = 1},
			{model = 'rs6nn', price = 1},
			{model = 'nm_z71', price = 1},
			{model = 'dcmd5', price = 1},
		},

		doctor = {	
			{model = 'gcgmp3', price = 1},
			{model = 'gcgmp1', price = 1},
			{model = 'rs6nn', price = 1},
			{model = 'nm_z71', price = 1},
			{model = 'dcmd5', price = 1},
		},
		
		chief_doctor = {
			{model = 'gcgmp3', price = 1},
			{model = 'gcgmp1', price = 1},
			{model = 'rs6nn', price = 1},
			{model = 'nm_z71', price = 1},
			{model = 'dcmd5', price = 1},
		},

		vyrdaktaras = {
			{model = 'gcgmp3', price = 1},
			{model = 'gcgmp1', price = 1},
			{model = 'rs6nn', price = 1},
			{model = 'nm_z71', price = 1},
			{model = 'dcmd5', price = 1},
		},
		
		chief_doctor = {
			{model = 'gcgmp3', price = 1},
			{model = 'gcgmp1', price = 1},
			{model = 'rs6nn', price = 1},
			{model = 'nm_z71', price = 1},
			{model = 'dcmd5', price = 1},
		},

		boss = {
			{model = 'adder', price = 1},
			{model = 'gcgmp1', price = 1},
			{model = 'rs6nn', price = 1},
			{model = 'nm_z71', price = 1},
			{model = 'dcmd5', price = 1},
		}
	},

	helicopter = {
		rezidentas = {},

		paramedikas = {},
		
		chirurgas = {},

		doctor = {
			{model = 'bcgmphel1', props = {modLivery = 2}, price = 1000},
			{model = 'supervolito', props = {modLivery = 2}, price = 1000}
		},

		chief_doctor = {
			{model = 'bcgmphel1', props = {modLivery = 2}, price = 1000},
			{model = 'supervolito', props = {modLivery = 2}, price = 1000}
		},

		boss = {
			{model = 'bcgmphel1', props = {modLivery = 2}, price = 1000},
			{model = 'supervolito', props = {modLivery = 2}, price = 1000}
		}
	}
}

Config.Uniforms = {
	studentas_wear = {
		male = {
			tshirt_1 = 15,  tshirt_2 = 0,
			torso_1 = 143,   torso_2 = 7,
			decals_1 = 0,   decals_2 = 0,
			arms = 106,
			pants_1 = 27,   pants_2 = 5,
			chain_1 = 193, chain_2 = 0,
			shoes_1 = 8,   shoes_2 = 0,
			helmet_1 = -1,  helmet_2 = 0,
			ears_1 = -1,     ears_2 = 0,
			mask_1 = 0,   mask_2 = 0,
			bags_1 = -1, bags_2 = 0
		},
		female = {
			tshirt_1 = 6,  tshirt_2 = 0,
			torso_1 = 341,   torso_2 = 8,
			decals_1 = 0,   decals_2 = 0,
			arms = 148,
			pants_1 = 87,   pants_2 = 7,
			shoes_1 = 38,   shoes_2 = 0,
			helmet_1 = -1,  helmet_2 = 0,
			ears_1 = -1,     ears_2 = 0,
			mask_1 = 0,   mask_2 = 0,
			bags_1 = -1, bags_2 = 0
		}
	},

	pirmas_wear = {
		male = {
			tshirt_1 = 15,  tshirt_2 = 0,
			torso_1 = 143,   torso_2 = 3,
			decals_1 = 0,   decals_2 = 0,
			arms = 106,     arms_2 = 1,
			pants_1 = 32,   pants_2 = 5,
			chain_1 = 212, chain_2 = 0,
			shoes_1 = 8,   shoes_2 = 0,
			helmet_1 = -1,  helmet_2 = 0,
			ears_1 = -1,     ears_2 = 0,
			mask_1 = 0,   mask_2 = 0,
			bags_1 = -1, bags_2 = 0
		},
		female = {
			tshirt_1 = 7,  tshirt_2 = 6,
			torso_1 = 341,   torso_2 = 1,
			decals_1 = 0,   decals_2 = 0,
			arms = 148, arms_2 = 1,
			chain_1 = 0, chain_2 = 0,
			pants_1 = 246,   pants_2 = 10,
			shoes_1 = 69,   shoes_2 = 0,
			helmet_1 = -1,  helmet_2 = 0,
			ears_1 = -1,     ears_2 = 0,
			mask_1 = 0,   mask_2 = 0,
			bags_1 = -1, bags_2 = 0
		}
	},

	antras_wear = {
		male = {
			tshirt_1 = 15,  tshirt_2 = 0,
			torso_1 = 583,   torso_2 = 0,
			decals_1 = 0,   decals_2 = 0,
			arms = 99,      arms_2 = 1,
			pants_1 = 32,   pants_2 = 5,
			chain_1 = 192, chain_2 = 7,
			shoes_1 = 8,   shoes_2 = 0,
			helmet_1 = -1,  helmet_2 = 0,
			ears_1 = -1,     ears_2 = 0,
			mask_1 = 0,   mask_2 = 0,
			bags_1 = -1, bags_2 = 0
		},
		female = {
			tshirt_1 = 7,  tshirt_2 = 6,
			torso_1 = 341,   torso_2 = 3,
			decals_1 = 0,   decals_2 = 0,
			arms = 148,     arms_2 = 1,
			pants_1 = 246,   pants_2 = 10,
			shoes_1 = 69,   shoes_2 = 0,
			helmet_1 = -1,  helmet_2 = 0,
			ears_1 = -1,     ears_2 = 0,
			mask_1 = 0,   mask_2 = 0,
			bags_1 = -1, bags_2 = 0
		}
	},

	trecias_wear = {
		male = {
			tshirt_1 = 15,  tshirt_2 = 0,
			torso_1 = 143,   torso_2 = 4,
			decals_1 = 0,   decals_2 = 0,
			arms = 106, arms_2 = 1,
			pants_1 = 32,   pants_2 = 5,
			chain_1 = 192, chain_2 = 2,
			shoes_1 = 8,   shoes_2 = 0,
			helmet_1 = -1,  helmet_2 = 0,
			ears_1 = -1,     ears_2 = 0,
			mask_1 = 0,   mask_2 = 0,
			bags_1 = -1, bags_2 = 0
		},
		female = {
			tshirt_1 = 7,  tshirt_2 = 6,
			torso_1 = 341,   torso_2 = 6,
			decals_1 = 0,   decals_2 = 0,
			arms = 148,     arms_2 = 1,
			pants_1 = 246,   pants_2 = 10,
			shoes_1 = 69,   shoes_2 = 0,
			helmet_1 = -1,  helmet_2 = 0,
			ears_1 = -1,     ears_2 = 0,
			mask_1 = 0,   mask_2 = 0,
			bags_1 = -1, bags_2 = 0
		}
	},

	ketvirtas_wear = {
		male = {
			tshirt_1 = 15,  tshirt_2 = 0,
			torso_1 = 143,   torso_2 = 1,
			decals_1 = 0,   decals_2 = 0,
			arms = 106, arms_2 = 1,
			pants_1 = 32,   pants_2 = 5,
			chain_1 = 192, chain_2 = 2,
			shoes_1 = 8,   shoes_2 = 0,
			helmet_1 = -1,  helmet_2 = 0,
			ears_1 = -1,     ears_2 = 0,
			mask_1 = 0,   mask_2 = 0,
			bags_1 = -1, bags_2 = 0
		},
		female = {
			tshirt_1 = 7,  tshirt_2 = 6,
			torso_1 = 341,   torso_2 = 0,
			decals_1 = 0,   decals_2 = 0,
			arms = 148,     arms_2 = 1,
			chain_1 = 187, chain_2 = 0,
			pants_1 = 246,   pants_2 = 10,
			shoes_1 = 69,   shoes_2 = 0,
			helmet_1 = -1,  helmet_2 = 0,
			ears_1 = -1,     ears_2 = 0,
			mask_1 = 0,   mask_2 = 0,
			bags_1 = -1, bags_2 = 0
		}
	},

	penktas_wear = {
		male = {
			tshirt_1 = 15,  tshirt_2 = 0,
			torso_1 = 15,   torso_2 = 0,
			decals_1 = 0,   decals_2 = 0,
			arms = 205, arms_2 = 0,
			pants_1 = 12,   pants_2 = 0,
			chain_1 = 212, chain_2 = 0,
			shoes_1 = 8,   shoes_2 = 0,
			helmet_1 = -1,  helmet_2 = 0,
			ears_1 = -1,     ears_2 = 0,
			mask_1 = 0,   mask_2 = 0,
			bags_1 = -1, bags_2 = 0
		},
		female = {
			tshirt_1 = 42,  tshirt_2 = 1,
			torso_1 = 194,   torso_2 = 0,
			decals_1 = 0,   decals_2 = 0,
			arms = 159,
			chain_1 = 141, chain_2 = 0,
			pants_1 = 158,   pants_2 = 0,
			shoes_1 = 63,   shoes_2 = 3,
			helmet_1 = -1,  helmet_2 = 0,
			ears_1 = -1,     ears_2 = 0,
			mask_1 = 0,   mask_2 = 0,
			bags_1 = -1, bags_2 = 0
		}
	},

	sestas_wear = {
		male = {
			tshirt_1 = 15,  tshirt_2 = 0,
			torso_1 = 15,   torso_2 = 0,
			decals_1 = 0,   decals_2 = 0,
			arms = 205, arms_2 = 0,
			pants_1 = 12,   pants_2 = 2,
			chain_1 = 212, chain_2 = 0,
			shoes_1 = 8,   shoes_2 = 0,
			helmet_1 = -1,  helmet_2 = 0,
			ears_1 = -1,     ears_2 = 0,
			bags_1 = -1, bags_2 = 0
		},
		female = {
			tshirt_1 = 42,  tshirt_2 = 5,
			torso_1 = 194,   torso_2 = 0,
			decals_1 = 0,   decals_2 = 0,
			arms = 159,		arms_2 = 1,
			pants_1 = 158,   pants_2 = 0,
			shoes_1 = 44,   shoes_2 = 3,
			helmet_1 = -1,  helmet_2 = 0,
			chain_1 = 186,    chain_2 = 0,
			mask_1 = 0,   mask_2 = 0,
			ears_1 = -1,     ears_2 = 0
		}
	},

	septintas_wear = {
		male = {
			tshirt_1 = 142,  tshirt_2 = 2,
			torso_1 = 405,   torso_2 = 4,
			decals_1 = 0,   decals_2 = 0,
			arms = 4, arms_2 = 0,
			pants_1 = 65,   pants_2 = 3,
			chain_1 = 192, chain_2 = 0,
			shoes_1 = 203,   shoes_2 = 3,
			helmet_1 = -1,  helmet_2 = 0,
			ears_1 = -1,     ears_2 = 0,
			mask_1 = 0,   mask_2 = 0,
			bags_1 = -1, bags_2 = 0
		},
		female = {
			tshirt_1 = 42,  tshirt_2 = 5,
			torso_1 = 372,   torso_2 = 0,
			decals_1 = 0,   decals_2 = 0,
			arms = 159,		arms_2 = 0,
			pants_1 = 158,   pants_2 = 0,
			shoes_1 = 63,   shoes_2 = 3,
			helmet_1 = -1,  helmet_2 = 0,
			chain_1 = 186,    chain_2 = 0,
			mask_1 = 0,   mask_2 = 0,
			ears_1 = -1,     ears_2 = 0
		}
	},

	sauga_wear = {
		male = {
			tshirt_1 = 374,  tshirt_2 = 0,
			torso_1 = 15,   torso_2 = 0,
			decals_1 = 0,   decals_2 = 0,
			arms = 0,
			pants_1 = 65,   pants_2 = 7,
			chain_1 = 192, chain_2 = 2,
			shoes_1 = 163,   shoes_2 = 0,
		},
		female = {
			tshirt_1 = 6,  tshirt_2 = 0,
			torso_1 = 307,   torso_2 = 10,
			decals_1 = 0,   decals_2 = 0,
			arms = 2,		arms_2 = 0,
			pants_1 = 6,   pants_2 = 0,
			shoes_1 = 69,   shoes_2 = 0,
			helmet_1 = -1,  helmet_2 = 0,
			chain_1 = 186,    chain_2 = 0,
			mask_1 = 0,   mask_2 = 0,
			ears_1 = -1,     ears_2 = 0
		}
	},

	chirurgas_wear = {
		male = {
			tshirt_1 = 15,  tshirt_2 = 0,
			torso_1 = 15,   torso_2 = 0,
			decals_1 = 0,   decals_2 = 0,
			arms = 205, arms_2 = 0,
			pants_1 = 12,   pants_2 = 0,
			chain_1 = 212, chain_2 = 0,
			shoes_1 = 8,   shoes_2 = 0,
			helmet_1 = -1,  helmet_2 = 0,
			ears_1 = -1,     ears_2 = 0,
			mask_1 = 71,   mask_2 = 0,
			bags_1 = -1, bags_2 = 0
		},
		female = {
			tshirt_1 = 42,  tshirt_2 = 1,
			torso_1 = 194,   torso_2 = 0,
			decals_1 = 0,   decals_2 = 0,
			arms = 159,
			chain_1 = 141, chain_2 = 0,
			pants_1 = 158,   pants_2 = 0,
			shoes_1 = 63,   shoes_2 = 3,
			helmet_1 = -1,  helmet_2 = 0,
			ears_1 = -1,     ears_2 = 0,
			mask_1 = 0,   mask_2 = 0,
			bags_1 = -1, bags_2 = 0
		}
	},

	astuntas_wear = {
		male = {
			tshirt_1 = 142,  tshirt_2 = 2,
			torso_1 = 405,   torso_2 = 4,
			decals_1 = 0,   decals_2 = 0,
			arms = 4, arms_2 = 0,
			pants_1 = 65,   pants_2 = 3,
			chain_1 = 192, chain_2 = 0,
			shoes_1 = 203,   shoes_2 = 3,
			helmet_1 = -1,  helmet_2 = 0,
			ears_1 = -1,     ears_2 = 0,
			mask_1 = 0,   mask_2 = 0,
			bags_1 = -1, bags_2 = 0
		},
		female = {
			tshirt_1 = 293,  tshirt_2 = 0,
			torso_1 = 251,   torso_2 = 0,
			decals_1 = 0,   decals_2 = 0,
			arms = 5,		arms_2 = 0,
			pants_1 = 245,   pants_2 = 3,
			shoes_1 = 69,   shoes_2 = 0,
			helmet_1 = -1,  helmet_2 = 0,
			chain_1 = 65,    chain_2 = 0,
			mask_1 = 0,   mask_2 = 0,
			ears_1 = -1,     ears_2 = 0
		}
	}
}

Config.Inventory = {
	Default = {
		Slots = 50,
		Weigth = 30000
	},
	InDuty = {
		Slots = 50,
		Weigth = 60000
	},
}