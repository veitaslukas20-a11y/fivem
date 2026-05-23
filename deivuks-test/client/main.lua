---------------------------------------
-- DISABLED NPC VEHICLES & PEDS
---------------------------------------
local DisabledNPCVehicles = {
  `blimp`, `blimp2`, `blimp3`, `titan`, `hydra`, `jet`, `avenger`, `avenger2`,
  `bombushka`, `cargoplane`, `cargoplane2`, `howard`, `lazer`, `mogul`, `strikeforce`,
  `tula`, `volatol`, `rhino`, `trailersmall2`, `khanjali`, `minitank`, `halftrack`,
  `apc`, `barrage`, `chernobog`, `akula`, `buzzard`, `hunter`, `savage`, `valkyrie`,
  `valkyrie2`, `cerberus`, `cerberus3`, `patrolboat`, `dinghy5`, `technical`, `technical2`,
  `technical3`
}

local DisabledNPCPeds = {
  `s_m_m_doctor_01`, `a_m_m_skater_01`, `a_m_y_busicas_01`, `a_m_y_motox_02`,
  `a_m_y_beachvesp_01`, `a_m_m_bevhills_01`, `s_m_m_gentransport`, `a_m_y_motox_01`,
  `a_m_y_skater_02`, `a_m_y_stlat_01`, `a_m_m_polynesian_01`, `a_m_y_genstreet_01`,
  `a_m_y_dhill_01`, `g_m_y_famfor_01`, `a_f_y_tourist_01`, `a_m_y_bevhills_01`,
  `a_m_y_roadcyc_01`, `g_m_y_azteca_01`, `a_m_y_ktown_01`, `a_m_m_genfat_02`,
  `g_m_y_famca_01`, `a_m_m_malibu_01`, `a_f_m_downtown_01`, `g_m_y_lost_01`,
  `a_m_m_stlat_02`, `a_m_y_genstreet_02`, `a_f_y_soucent_01`, `g_m_m_mexboss_01`,
  `a_m_y_beachvesp_02`, `a_m_y_hipster_01`, `a_m_y_eastsa_02`, `a_m_y_polynesian_01`,
  `g_m_y_mexgoon_02`
}

Citizen.CreateThread(function()
  for _, v in pairs(DisabledNPCVehicles) do
    SetVehicleModelIsSuppressed(v, true)
  end
  for _, p in pairs(DisabledNPCPeds) do
    SetPedModelIsSuppressed(p, true)
  end
end)

---------------------------------------
-- PROP FIX COMMAND
---------------------------------------
RegisterCommand("propfix", function()
  local ped = PlayerPedId()
  for _, object in pairs(GetGamePool("CObject")) do
    if IsEntityAttachedToEntity(ped, object) then
      SetEntityAsMissionEntity(object, true, true)
      DeleteEntity(object)
    end
  end
end)

---------------------------------------
-- LOCK INTERVAL (Disable Exit When Locked)
---------------------------------------
function LockInterval(vehicle)
  Citizen.CreateThread(function()
    while DoesEntityExist(vehicle) do
      if GetVehicleDoorLockStatus(vehicle) == 2 then
        DisableControlAction(0, 75, true)
      end
      Citizen.Wait(10)
    end
  end)
end

---------------------------------------
-- CAMERA AIM DIRECTION
---------------------------------------
local function RotationToDirection()
  local rot = GetGameplayCamRot(2)
  local rotZ = rot.z * (math.pi / 180.0)
  local rotX = rot.x * (math.pi / 180.0)
  local c = math.cos(rotX)
  local multXY = math.abs(c)
  return vector3((math.sin(rotZ) * -1) * multXY, math.cos(rotZ) * multXY, math.sin(rotX))
end

local function GetCoordsInFrontOfCam(dist)
  local coords = GetGameplayCamCoord()
  local dir = RotationToDirection()
  return vector3(coords.x + (dist * dir.x), coords.y + (dist * dir.y), coords.z + (dist * dir.z))
end

---------------------------------------
-- AIM FIRE RESTRICTION & CONTROL DISABLE
---------------------------------------
Citizen.CreateThread(function()
  while true do
    local ped = PlayerPedId()
    DisableControlAction(0, 44, true) -- Disable cover
    if IsPedDiving(ped) then
      DisableControlAction(0, 73, true) -- Disable vehicle exit underwater
    end
    local aiming, entity = GetEntityPlayerIsFreeAimingAt(PlayerId())
    if aiming and entity ~= 0 then
      local start = GetGameplayCamCoord()
      local fin = GetCoordsInFrontOfCam(200.0)
      local _, hit = GetShapeTestResult(StartShapeTestRay(start.x, start.y, start.z, fin.x, fin.y, fin.z, -1, ped, 0))
      if hit == 0 then
        DisablePlayerFiring(ped, true)
      end
    end
    Citizen.Wait(1)
  end
end)

---------------------------------------
-- VEHICLE CAMERA AUTO SWITCH
---------------------------------------
local aktif = false
local miktar = 0
Citizen.CreateThread(function()
	while true do
		local wait = 1000
		local ped = PlayerPedId()
		local veh = GetVehiclePedIsIn(ped, false)
		if veh ~= 0 then
			wait = 1
			if IsPlayerFreeAiming(PlayerId()) and not aktif and GetFollowVehicleCamViewMode() ~= 4 then
				SetFollowVehicleCamViewMode(4)
				aktif = true
			elseif not IsPlayerFreeAiming(PlayerId()) and aktif then
				aktif = false
			elseif miktar == 1 then
				SetFollowVehicleCamViewMode(4)
				aktif = true
			end

			if IsControlJustPressed(0, 330) and not IsPlayerFreeAiming(PlayerId()) and GetFollowVehicleCamViewMode() ~= 4 then
				miktar = 1
			else
				miktar = 0
			end

			if aktif and IsPlayerFreeAiming(PlayerId()) and GetFollowVehicleCamViewMode() ~= 4 then
				SetFollowVehicleCamViewMode(4)
			end
		else
			if aktif then aktif = false end
		end
		Citizen.Wait(wait)
	end
end)

---------------------------------------
-- DISABLE NPC / VEHICLE SPAWNS
---------------------------------------
Citizen.CreateThread(function()
  while true do
    Citizen.Wait(0)
    SetCreateRandomCops(false)
    SetCreateRandomCopsNotOnScenarios(false)
    SetCreateRandomCopsOnScenarios(false)
    SetGarbageTrucks(false)
    SetRandomBoats(false)
    SetVehicleDensityMultiplierThisFrame(0.0)
    SetPedDensityMultiplierThisFrame(0.0)
    SetRandomVehicleDensityMultiplierThisFrame(0.0)
    SetScenarioPedDensityMultiplierThisFrame(0.0, 0.0)
    SetParkedVehicleDensityMultiplierThisFrame(0.0)

    local x, y, z = table.unpack(GetEntityCoords(PlayerPedId()))
    ClearAreaOfVehicles(x, y, z, 1000.0, false, false, false, false, false)
    RemoveVehiclesFromGeneratorsInArea(x - 500.0, y - 500.0, z - 500.0, x + 500.0, y + 500.0, z + 500.0)
  end
end)
