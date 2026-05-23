Config = {}

Config.MaxStorages = {
  all = 1,
  small = 2,
  medium = 2,
  large = 1,
}

Config.Storages = {
  small = {price = 40000, slots = 80, weight = 250},
  medium = {price = 80000, slots = 100, weight = 500},
  large = {price = 200000, slots = 120, weight = 800},
}

Config.Warehouses = {
  {pos = vec3(437.3822, -624.6271, 28.7083)},
  {pos = vec3(-17.2275, 6303.5415, 31.3744), requiredVIP = 2},
  {pos = vec3(1683.8918, 3663.6814, 35.1815), requiredVIP = 2},
  {pos = vec3(-537.1099, -886.5461, 25.2065)},
  {pos = vec3(-570.9100, -1776.0770, 23.1710)}
}

Config.VIPs = {
  [2] = {
    weightMultiplier = 2,
    slotMultiplier = 2,
  },
  [3] = {
    weightMultiplier = 4,
    slotMultiplier = 2,
  },
}

