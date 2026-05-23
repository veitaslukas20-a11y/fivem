isSmokeJointMouth = false
isSmokeJointHand = false
noeffectjoint = false
throwcigarette = false
effect = false

p_firejoint_particle = "ent_amb_torch_fire"
p_firejoint_particle_asset = "core" 

p_joint_particle = "exp_grd_bzgas_smoke"
p_joint_particle_asset = "core"


joint_name = joint_name or 'prop_sh_joint_01'
jointnolight_name = jointnolight_name or 'p_cs_joint_02'
lighterjoint_name = lighterjoint_name or 'ex_prop_exec_lighter_01'

RegisterNetEvent('devcore_smoke:JointLightingAnim')
AddEventHandler('devcore_smoke:JointLightingAnim', function(source)
	local playerPed = PlayerPedId()
	local x,y,z = table.unpack(GetEntityCoords(playerPed))
	if isSmokeJointHand == true or isSmokeHand == true or isSmokeCigarHand == true or isSmokeMouth == true or isSmokeCigarMouth == true or isSmokeJointMouth == true then
		--exports['mythic_notify']:DoHudText('inform', _U('already_have'))
	  else

	playAnim('amb@world_human_smoking@male@male_a@enter', 'enter', 1800)
	Citizen.Wait(1000)
	jointnolight = CreateObject(GetHashKey(jointnolight_name), x, y, z+0.9,  true,  true, true)
	AttachEntityToEntity(jointnolight, playerPed, GetPedBoneIndex(playerPed, 64097), 0.020, 0.02, -0.008, 100.0, 0.0, 100.0, true, true, false, true, 1, true)
			Citizen.Wait(800)

			lighterjoint = CreateObject(GetHashKey(lighterjoint_name), x, y, z+0.9,  true,  true, true)
			AttachEntityToEntity(lighterjoint, playerPed, GetPedBoneIndex(playerPed, 4089), 0.020, -0.03, -0.010, 100.0, 0.0, 150.0, true, true, false, true, 1, true)

			playAnim('misscarsteal2peeing', 'peeing_loop', 2000)
			Citizen.Wait(800)
			TriggerServerEvent("devcore_smoke:eff_lighter_joint", ObjToNet(lighterjoint))
			Citizen.Wait(1000)
			DetachEntity(jointnolight, 1, 1)
			DeleteObject(jointnolight)

			joint = CreateObject(GetHashKey(joint_name), x, y, z+0.9,  true,  true, true)
			AttachEntityToEntity(joint, playerPed, GetPedBoneIndex(playerPed, 64097), 0.020, 0.02, -0.008, 100.0, 0.0, 100.0, true, true, false, true, 1, true)

			throwjoint = true
			isSmokeJointHand = true
			isSmokeJointMouth = false
			Citizen.Wait(1000)
			DetachEntity(lighterjoint, 1, 1)
			DeleteObject(lighterjoint)
			TriggerServerEvent("devcore_smoke:eff_joint", ObjToNet(joint))
			
	  end
end)

RegisterNetEvent('devcore_smoke:JointMouth')
AddEventHandler('devcore_smoke:JointMouth', function(source)
	local playerPed = PlayerPedId()
	local x,y,z = table.unpack(GetEntityCoords(playerPed))

			playAnim('move_p_m_two_idles@generic', 'fidget_sniff_fingers', 1000)
			Citizen.Wait(800)
		
			AttachEntityToEntity(joint, playerPed, GetPedBoneIndex(playerPed, 47419), 0.010, 0.0, 0.0, 50.0, 0.0, 80.0, true, true, false, true, 1, true)
			isSmokeJointHand = false
			isSmokeJointMouth = true
end)

RegisterNetEvent('devcore_smoke:JointHand')
AddEventHandler('devcore_smoke:JointHand', function(source)
	local playerPed = PlayerPedId()
	local x,y,z = table.unpack(GetEntityCoords(playerPed))

			playAnim('move_p_m_two_idles@generic', 'fidget_sniff_fingers', 1000)
			Citizen.Wait(1100)
		
			AttachEntityToEntity(joint, playerPed, GetPedBoneIndex(playerPed, 64097), 0.020, 0.02, -0.008, 100.0, 0.0, 100.0, true, true, false, true, 1, true)
		isSmokeJointHand = true
		isSmokeJointMouth = false
end)



RegisterNetEvent("devcore_smoke:c_eff_lighter_joint")
AddEventHandler("devcore_smoke:c_eff_lighter_joint", function(lighterjoint)
	createdLighterJoint = UseParticleFxAssetNextCall(p_firejoint_particle_asset)
	createdPartLighterJoint = StartParticleFxLoopedOnEntity(p_firejoint_particle, NetToPed(lighterjoint), 0.0, 0.0, 0.050, 0.0, 0.0, 0.0, 0.03, 0.0, 0.0, 0.0)
	Wait(1200)
	while DoesParticleFxLoopedExist(createdLighterJoint) do
		StopParticleFxLooped(createdLighterJoint, 1)
	  Wait(1)
	end
	while DoesParticleFxLoopedExist(createdPartLighterJoint) do
		StopParticleFxLooped(createdPartLighterJoint, 1)
	  Wait(1)
	end
	while DoesParticleFxLoopedExist(p_firejoint_particle) do
		StopParticleFxLooped(p_firejoint_particle, 1)
	  Wait(1)
	end
	while DoesParticleFxLoopedExist(p_firejoint_particle_asset) do
		StopParticleFxLooped(p_firejoint_particle_asset, 1)
	  Wait(1)
	end 
	Wait(1900)
			RemoveParticleFxFromEntity(lighterjoint)
end)

RegisterNetEvent("devcore_smoke:c_eff_joint")
AddEventHandler("devcore_smoke:c_eff_joint", function(joint)
	createdSmokeJoint = UseParticleFxAssetNextCall(p_joint_particle_asset)
	createdPartJoint = StartParticleFxLoopedOnEntity(p_joint_particle, NetToPed(joint), -0.090, 0.0, 0.0, 0.0, 0.0, 0.0, Config.SmokeSizeJoint, 0.0, 0.0, 0.0)
	Wait(Config.JointSmokingTime)
	while DoesParticleFxLoopedExist(createdSmokeJoint) do
		StopParticleFxLooped(createdSmokeJoint, 1)
	  Wait(1)
	end
	while DoesParticleFxLoopedExist(createdPartJoint) do
		StopParticleFxLooped(createdPartJoint, 1)
	  Wait(1)
	end
	while DoesParticleFxLoopedExist(p_joint_particle) do
		StopParticleFxLooped(p_joint_particle, 1)
	  Wait(1)
	end
	while DoesParticleFxLoopedExist(p_joint_particle_asset) do
		StopParticleFxLooped(p_joint_particle_asset, 1)
	  Wait(1)
	end 
	if Config.CancelSmokeJoint then
	if throwjoint then
	Wait(1000)
		SmokeDoneJoint()
		end
	end
end)

p_smoke_location_joint = {
	20279,
}
p_effjoint_particle = "exp_grd_bzgas_smoke"
p_effjoint_particle_asset = "core" 
RegisterNetEvent("devcore_smoke:c_eff_smokes_joint")
AddEventHandler("devcore_smoke:c_eff_smokes_joint", function(c_ped)
	for _,bonesjoint in pairs(p_smoke_location_joint) do
		if DoesEntityExist(NetToPed(c_ped)) and not IsEntityDead(NetToPed(c_ped)) then
		createdeffjoint = UseParticleFxAssetNextCall(p_effjoint_particle_asset)
		createdParteffjoint = StartParticleFxLoopedOnEntityBone(p_effjoint_particle, NetToPed(c_ped), 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, GetPedBoneIndex(NetToPed(c_ped), bonesjoint), Config.SmokeJointMouth, 0.0, 0.0, 0.0)
		Wait(Config.JointHangTime)
			while DoesParticleFxLoopedExist(createdeffjoint) do
				StopParticleFxLooped(createdeffjoint, 1)
			  Wait(1)
			end
			while DoesParticleFxLoopedExist(createdParteffjoint) do
				StopParticleFxLooped(createdParteffjoint, 1)
			  Wait(1)
			end
			while DoesParticleFxLoopedExist(p_effjoint_particle) do
				StopParticleFxLooped(p_effjoint_particle, 1)
			  Wait(1)
			end
			while DoesParticleFxLoopedExist(p_effjoint_particle_asset) do
				StopParticleFxLooped(p_effjoint_particle_asset, 1)
			  Wait(1)
			end
			Wait(Config.JointHangTime)
			RemoveParticleFxFromEntity(NetToPed(c_ped))
			break
			end
		end
	end)

function SmokeDoneJoint()
	local playerPed = PlayerPedId()
		if isSmokeJointMouth == true then
			Citizen.Wait(600)
			throwjoint = false
			playAnim('move_p_m_two_idles@generic', 'fidget_sniff_fingers', 1000)
				Citizen.Wait(1000)
					AttachEntityToEntity(joint, playerPed, GetPedBoneIndex(playerPed, 64097), 0.020, 0.02, -0.008, 100.0, 0.0, 100.0, true, true, false, true, 1, true)
					Citizen.Wait(1000)
					DetachEntity(joint, 1, 1)
					isSmokeJointHand = false
					Citizen.Wait(2000)
					DeleteObject(joint)
					RemoveParticleFxFromEntity(joint)
					isSmokeJointMouth = false
					noeffectjoint = true
					effect = false
			else
				throwjoint = false
					DetachEntity(joint, 1, 1)
					isSmokeJointHand = false
					Citizen.Wait(2000)
					DeleteObject(joint)
					RemoveParticleFxFromEntity(joint)
					isSmokeJointMouth = false
					noeffectjoint = true
					effect = false
			end
	end

Citizen.CreateThread(function(source)
	while true do
		Wait(7)
		 if isSmokeJointMouth then
			local playerPed = PlayerPedId()
			ESX.ShowHelpNotification(_U('Ciggaret_mouth'))
			if multiplier > maxhighdone then
				--exports['mythic_notify']:DoHudText('inform', _U('have_enough'))
				throwjoint = false
				playAnim('move_p_m_two_idles@generic', 'fidget_sniff_fingers', 1000)
				Citizen.Wait(1000)
					AttachEntityToEntity(joint, playerPed, GetPedBoneIndex(playerPed, 64097), 0.020, 0.02, -0.008, 100.0, 0.0, 100.0, true, true, false, true, 1, true)
					Citizen.Wait(1000)
					DetachEntity(joint, 1, 1)
					isSmokeJointHand = false
					Citizen.Wait(2000)
					DeleteObject(joint)
					RemoveParticleFxFromEntity(joint)
					isSmokeJointMouth = false
					noeffectjoint = true
					effect = false
			else
			if IsEntityInWater(playerPed) then
				Citizen.Wait(800)
				SmokeDoneJoint()
			else
			if IsControlJustPressed(0, Config.Smoke) then
				local ped = GetPlayerPed(-1)
				Citizen.Wait(2200)
				TriggerServerEvent("devcore_smoke:eff_smokes_joint", PedToNet(ped))
				Citizen.Wait(1200)
						noeffectjoint = false
						effect = true
							Citizen.Wait(1000)
							multiplier = multiplier * increasephaseeff
			elseif IsControlJustPressed(0, Config.Throw) then
				if IsPedInAnyVehicle(playerPed, true) then
					throwjoint = false
					playAnim('move_p_m_two_idles@generic', 'fidget_sniff_fingers', 1000)
					Citizen.Wait(1000)
						AttachEntityToEntity(joint, playerPed, GetPedBoneIndex(playerPed, 64097), 0.020, 0.02, -0.008, 100.0, 0.0, 100.0, true, true, false, true, 1, true)
						Citizen.Wait(250)
						DetachEntity(joint, 1, 1)
						isSmokeJointHand = false
						DeleteObject(joint)
						RemoveParticleFxFromEntity(joint)
						isSmokeJointMouth = false

						noeffectjoint = true
						effect = false
				else
				SmokeDoneJoint()
			end
			elseif IsControlJustPressed(0, Config.Mouth) then
					TriggerEvent('devcore_smoke:JointHand')
					end
				end
			end
		else
			Wait(500)
		end
	end
end)


Citizen.CreateThread(function(source)
	while true do
		Wait(7)
		 if isSmokeJointHand then
			local playerPed = PlayerPedId()
			ESX.ShowHelpNotification(_U('Ciggaret_hand'))
			if multiplier > maxhighdone then
				--exports['mythic_notify']:DoHudText('inform', _U('have_enough'))
				throwjoint = false
					DetachEntity(joint, 1, 1)
					isSmokeJointHand = false
					Citizen.Wait(2000)
					DeleteObject(joint)
					RemoveParticleFxFromEntity(joint)
					isSmokeJointMouth = false
					noeffectjoint = true
					effect = false
			else
			if IsPedInAnyVehicle(playerPed, true) then
				local playerVeh = GetVehiclePedIsIn(playerPed, false)
				RollDownWindow(playerVeh, 0)
				Citizen.Wait(1500)
				TriggerEvent('devcore_smoke:JointMouth')
			else
				if IsEntityInWater(playerPed) then
					Citizen.Wait(800)
					SmokeDoneJoint()
			else
			if IsControlJustPressed(0, Config.Throw) then
				SmokeDoneJoint()
			elseif IsControlJustPressed(0, Config.inHand) then
				TriggerEvent('devcore_smoke:JointMouth')
			elseif IsControlJustPressed(0, Config.Smoke) then

				local ped = GetPlayerPed(-1)

					playAnim('amb@world_human_aa_smoke@male@idle_a', 'idle_a',2800)
					Citizen.Wait(4000)
					TriggerServerEvent("devcore_smoke:eff_smokes_joint", PedToNet(ped))
					Citizen.Wait(1000)

						noeffectjoint = false
						effect = true
							Citizen.Wait(1000)
							multiplier = multiplier * increasephaseeff
			end
					end
				end
			end
		else
			Wait(500)
		end
	end
end)

	multiplier = 0.1
	increasephaseeff = 1.249949
	minusphase4 = 0.014048
	maxhighdone = 0.8309426647617
	maxhigh = 0.9309426647617
	minhigh = 0.1249949


Citizen.CreateThread(function(source)
	while true do
		Wait(3000)
		if effect then	


		if multiplier > maxhigh then
			SetPedMovementClipset(GetPlayerPed(-1), "move_m@drunk@verydrunk", true)
			else
				SetTimecycleModifier("spectator9")
				SetPedIsDrunk(GetPlayerPed(-1), true)
				SetPedMotionBlur(GetPlayerPed(-1), true)
				SetTimecycleModifierStrength(multiplier)
			end
		end
	end
end)


--V1
Citizen.CreateThread(function(source)
	while true do
		Citizen.Wait(5000)
		local player = PlayerId()

			  if noeffectjoint then

			  if multiplier > minhigh then
					SetTimecycleModifier("spectator9")
					SetTimecycleModifierStrength(multiplier)
					multiplier = multiplier - minusphase4
				else		
					Citizen.Wait(30000)
					stopeffect()
			end
		end
	end
end)

	function stopeffect()
		noeffectjoint = false
		effect = false
		Citizen.Wait(5000)
		ResetPedMovementClipset(GetPlayerPed(-1), 0)
		ClearTimecycleModifier()
		ResetScenarioTypesEnabled()
		SetPedIsDrunk(GetPlayerPed(-1), false)
		SetPedMotionBlur(GetPlayerPed(-1), false)
	end
