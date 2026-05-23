isSmokeCigarMouth = false
isSmokeCigarHand = false
throwcigar = false

p_firecigar_particle = "ent_amb_torch_fire"
p_firecigar_particle_asset = "core" 

p_smokecigar_particle = "exp_grd_bzgas_smoke"
p_smokecigar_particle_asset = "core" 


cigar_name = cigar_name or 'prop_cigar_01'
cigarnolight_name = cigarnolight_name or 'prop_cigar_02'
lighter_name = lighter_name or 'ex_prop_exec_lighter_01'

RegisterNetEvent('devcore_smoke:CigarLightingAnim')
AddEventHandler('devcore_smoke:CigarLightingAnim', function(source)
	local playerPed = PlayerPedId()
	local x,y,z = table.unpack(GetEntityCoords(playerPed))
	if isSmokeJointHand == true or isSmokeHand == true or isSmokeCigarHand == true or isSmokeMouth == true or isSmokeCigarMouth == true or isSmokeJointMouth == true then
		--exports['mythic_notify']:DoHudText('inform', _U('already_have'))
	  else


	playAnim('amb@world_human_smoking@male@male_a@enter', 'enter', 1800)
	Citizen.Wait(850)
	cigarnolight = CreateObject(GetHashKey(cigarnolight_name), x, y, z+0.9,  true,  true, true)
	AttachEntityToEntity(cigarnolight, playerPed, GetPedBoneIndex(playerPed, 64097), 0.020, 0.02, -0.008, 100.0, 0.0, -100.0, true, true, false, true, 1, true)
			Citizen.Wait(950)

	lighter = CreateObject(GetHashKey(lighter_name), x, y, z+0.9,  true,  true, true)
	AttachEntityToEntity(lighter, playerPed, GetPedBoneIndex(playerPed, 4089), 0.020, -0.03, -0.010, 100.0, 0.0, 150.0, true, true, false, true, 1, true)

		playAnim('misscarsteal2peeing', 'peeing_loop', 2000)
			Citizen.Wait(800)
			TriggerServerEvent("devcore_smoke:eff_lighter_cigar", ObjToNet(lighter))
			Citizen.Wait(1000)
			DetachEntity(cigarnolight, 1, 1)
			DeleteObject(cigarnolight)

			cigar = CreateObject(GetHashKey(cigar_name), x, y, z+0.9,  true,  true, true)
			AttachEntityToEntity(cigar, playerPed, GetPedBoneIndex(playerPed, 64097), 0.020, 0.02, -0.008, 100.0, 0.0, -100.0, true, true, false, true, 1, true)

			throwcigar = true
			isSmokeCigarHand = true
			isSmokeCigarMouth = false
			Citizen.Wait(1000)
			DetachEntity(lighter, 1, 1)
			DeleteObject(lighter)
			TriggerServerEvent("devcore_smoke:eff_cigar", ObjToNet(cigar))
			
	  end
end)

RegisterNetEvent('devcore_smoke:CigarMouth')
AddEventHandler('devcore_smoke:CigarMouth', function(source)
	local playerPed = PlayerPedId()
	local x,y,z = table.unpack(GetEntityCoords(playerPed))

			playAnim('move_p_m_two_idles@generic', 'fidget_sniff_fingers', 1000)
			Citizen.Wait(800)
		
			AttachEntityToEntity(cigar, playerPed, GetPedBoneIndex(playerPed, 47419), 0.010, 0.0, 0.0, 50.0, 0.0, -80.0, true, true, false, true, 1, true)
			isSmokeCigarHand = false
			isSmokeCigarMouth = true
end)

RegisterNetEvent('devcore_smoke:CigarHand')
AddEventHandler('devcore_smoke:CigarHand', function(source)
	local playerPed = PlayerPedId()
	local x,y,z = table.unpack(GetEntityCoords(playerPed))

			playAnim('move_p_m_two_idles@generic', 'fidget_sniff_fingers', 1000)
			Citizen.Wait(1100)
		
			AttachEntityToEntity(cigar, playerPed, GetPedBoneIndex(playerPed, 64097), 0.020, 0.02, -0.008, 100.0, 0.0, -100.0, true, true, false, true, 1, true)
			isSmokeCigarHand = true
			isSmokeCigarMouth = false
end)



RegisterNetEvent("devcore_smoke:c_eff_lighter_cigar")
AddEventHandler("devcore_smoke:c_eff_lighter_cigar", function(lighter)
	createdLighterCigar = UseParticleFxAssetNextCall(p_firecigar_particle_asset)
	createdPartLighterCigar = StartParticleFxLoopedOnEntity(p_firecigar_particle, NetToPed(lighter), 0.0, 0.0, 0.050, 0.0, 0.0, 0.0, 0.03, 0.0, 0.0, 0.0)
	Wait(1200)
	while DoesParticleFxLoopedExist(createdLighterCigar) do
		StopParticleFxLooped(createdLighterCigar, 1)
	  Wait(1)
	end
	while DoesParticleFxLoopedExist(createdPartLighterCigar) do
		StopParticleFxLooped(createdPartLighterCigar, 1)
	  Wait(1)
	end
	while DoesParticleFxLoopedExist(p_firecigar_particle) do
		StopParticleFxLooped(p_firecigar_particle, 1)
	  Wait(1)
	end
	while DoesParticleFxLoopedExist(p_firecigar_particle_asset) do
		StopParticleFxLooped(p_firecigar_particle_asset, 1)
	  Wait(1)
	end 
	Wait(1900)
			RemoveParticleFxFromEntity(lighter)
end)

RegisterNetEvent("devcore_smoke:c_eff_cigar")
AddEventHandler("devcore_smoke:c_eff_cigar", function(cigar)
	createdCigar = UseParticleFxAssetNextCall(p_smokecigar_particle_asset)
	createdPartCigar = StartParticleFxLoopedOnEntity(p_smokecigar_particle, NetToPed(cigar), 0.050, 0.0, 0.0, 0.0, 0.0, 0.0, Config.SmokeSizeCigar, 0.0, 0.0, 0.0)
	Wait(Config.CigarSmokingTime)
	while DoesParticleFxLoopedExist(createdCigar) do
		StopParticleFxLooped(createdCigar, 1)
	  Wait(1)
	end
	while DoesParticleFxLoopedExist(createdPartCigar) do
		StopParticleFxLooped(createdPartCigar, 1)
	  Wait(1)
	end
	while DoesParticleFxLoopedExist(p_smokecigar_particle) do
		StopParticleFxLooped(p_smokecigar_particle, 1)
	  Wait(1)
	end
	while DoesParticleFxLoopedExist(p_smokecigar_particle_asset) do
		StopParticleFxLooped(p_smokecigar_particle_asset, 1)
	  Wait(1)
	end 
	if Config.CancelSmokeCigar then
		if throwcigar then
	Wait(1000)
		SmokeDoneCigar()
		end
	end
end)

p_smoke_location_cigar = {
	20279,
}
p_smokecigarhand_particle = "exp_grd_bzgas_smoke"
p_smokecigarhand_particle_asset = "core" 
RegisterNetEvent("devcore_smoke:c_eff_smokes_cigar")
AddEventHandler("devcore_smoke:c_eff_smokes_cigar", function(c_ped)
	for _,cigarbones in pairs(p_smoke_location_cigar) do
		if DoesEntityExist(NetToPed(c_ped)) and not IsEntityDead(NetToPed(c_ped)) then
		createdSmokeCigarHand = UseParticleFxAssetNextCall(p_smokecigarhand_particle_asset)
		createdPartCigarHand = StartParticleFxLoopedOnEntityBone(p_smokecigarhand_particle, NetToPed(c_ped), 0.0, 0.0, 0.0, 0.0, 0.0, 0.0,  GetPedBoneIndex(NetToPed(c_ped), cigarbones), Config.SmokeCigarMouth, 0.0, 0.0, 0.0)
		Wait(Config.CigarHangTime)
			while DoesParticleFxLoopedExist(createdSmokeCigarHand) do
				StopParticleFxLooped(createdSmokeCigarHand, 1)
			  Wait(1)
			end
			while DoesParticleFxLoopedExist(createdPartCigarHand) do
				StopParticleFxLooped(createdPartCigarHand, 1)
			  Wait(1)
			end
			while DoesParticleFxLoopedExist(p_smokecigarhand_particle) do
				StopParticleFxLooped(p_smokecigarhand_particle, 1)
			  Wait(1)
			end
			while DoesParticleFxLoopedExist(p_smokecigarhand_particle_asset) do
				StopParticleFxLooped(p_smokecigarhand_particle_asset, 1)
			  Wait(1)
			end
			Wait(Config.CigarHangTime)
			RemoveParticleFxFromEntity(NetToPed(c_ped))
			break
		end
	end
end)

function SmokeDoneCigar()
	local playerPed = PlayerPedId()
		if isSmokeCigarMouth == true then
			Citizen.Wait(600)
			throwcigar = false
			playAnim('move_p_m_two_idles@generic', 'fidget_sniff_fingers', 1000)
				Citizen.Wait(1000)
					AttachEntityToEntity(cigar, playerPed, GetPedBoneIndex(playerPed, 64097), 0.020, 0.02, -0.008, 100.0, 0.0, -100.0, true, true, false, true, 1, true)
					Citizen.Wait(1000)
					DetachEntity(cigar, 1, 1)
					isSmokeCigarHand = false
					Citizen.Wait(2000)
					DeleteObject(cigar)
					RemoveParticleFxFromEntity(cigar)
					isSmokeCigarMouth = false
			else
				Citizen.Wait(600)
				throwcigar = false
					DetachEntity(cigar, 1, 1)
					isSmokeCigarHand = false
					Citizen.Wait(2000)
					DeleteObject(cigar)
					RemoveParticleFxFromEntity(cigar)
					isSmokeCigarMouth = false
			end
	end

Citizen.CreateThread(function(source)
	while true do
		Citizen.Wait(7)
		 if isSmokeCigarMouth then
			local playerPed = PlayerPedId()
			ESX.ShowHelpNotification(_U('Ciggaret_mouth'))
			if IsEntityInWater(playerPed) then
				Citizen.Wait(800)
				SmokeDoneCigar()
			else
			if IsControlJustPressed(0, Config.Smoke) then
				local ped = GetPlayerPed(-1)
				Citizen.Wait(2200)
				TriggerServerEvent("devcore_smoke:eff_smokes_cigar", PedToNet(ped))
			elseif IsControlJustPressed(0, Config.Throw) then
				if IsPedInAnyVehicle(playerPed, true) then
					throwcigar = false
					playAnim('move_p_m_two_idles@generic', 'fidget_sniff_fingers', 1000)
					Citizen.Wait(1000)
						AttachEntityToEntity(cigar, playerPed, GetPedBoneIndex(playerPed, 64097), 0.020, 0.02, -0.008, 100.0, 0.0, -100.0, true, true, false, true, 1, true)
						Citizen.Wait(250)
						DetachEntity(cigar, 1, 1)
						isSmokeCigarHand = false
						DeleteObject(cigar)
						RemoveParticleFxFromEntity(cigar)
						isSmokeCigarMouth = false
				else
				SmokeDoneCigar()
			end
			elseif IsControlJustPressed(0, Config.Mouth) then
					TriggerEvent('devcore_smoke:CigarHand')
				end
			end
		else
			Wait(500)
		end
	end
end)


Citizen.CreateThread(function(source)
	while true do
		Citizen.Wait(7)
		 if isSmokeCigarHand then
			local playerPed = PlayerPedId()
			ESX.ShowHelpNotification(_U('Ciggaret_hand'))
			if IsPedInAnyVehicle(playerPed, true) then
				local playerVeh = GetVehiclePedIsIn(playerPed, false)
				RollDownWindow(playerVeh, 0)
				Citizen.Wait(1500)
			TriggerEvent('devcore_smoke:CigarMouth')
			else
				if IsEntityInWater(playerPed) then
					Citizen.Wait(800)
					SmokeDoneCigar()
				else
			if IsControlJustPressed(0, Config.Smoke) then
				local ped = GetPlayerPed(-1)
				playAnim('amb@world_human_aa_smoke@male@idle_a', 'idle_a', 4000)
				Citizen.Wait(4000)
				TriggerServerEvent("devcore_smoke:eff_smokes_cigar", PedToNet(ped))
			elseif IsControlJustPressed(0, Config.Throw) then
				SmokeDoneCigar()
			elseif IsControlJustPressed(0, Config.inHand) then
				TriggerEvent('devcore_smoke:CigarMouth')
				end
			end
		end
			else
				Wait(500)
		end
	end
end)
