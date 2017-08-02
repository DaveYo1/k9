local follow = false
local dog = nil

RegisterNetEvent("spawndog")
AddEventHandler("spawndog", function()
	Citizen.CreateThread(function()
		if dog == nil then
			local dogmodel = GetHashKey("A_C_shepherd")

			RequestModel(dogmodel)
			while not HasModelLoaded(dogmodel) do
				RequestModel(dogmodel)
				Citizen.Wait(100)
			end

			local plypos = GetOffsetFromEntityInWorldCoords(GetPlayerPed(PlayerId()), 0.0, 2.0, 0.0)
			local plyhead = GetEntityHeading(GetPlayerPed(PlayerId()))
			local spawned = CreatePed(28, dogmodel, plypos.x, plypos.y, plypos.z, plyhead, 1, 1)
			SetBlockingOfNonTemporaryEvents(spawned, true)
			dog = spawned
		else
			TriggerEvent("chatMessage", "You can only spawn one dog.")
			return
		end
	end)
end)

RegisterNetEvent("deletedog")
AddEventHandler("deletedog", function()
	if dog ~= nil then
		SetEntityAsMissionEntity(dog, 1, 1)
		SetEntityAsNoLongerNeeded(dog)
		DeletePed(dog)
		stay = false
		follow = false
		attack = false
		dog = nil
	else
		TriggerEvent("chatMessage", "You don't have a dog to delete.")
		return
	end
end)

 -- Follow Function --
Citizen.CreateThread(function()
	while true do
		Citizen.Wait(1)
		if not IsPlayerFreeAiming(PlayerId()) and IsControlJustPressed(1, 47) then
			if follow ~= true then
				if dog ~= nil then
					--TaskFollowToOffsetOfEntity(ped, entity, offsetX, offsetY, offsetZ, movementSpeed, timeout, stoppingRange, persistFollowing)
					TaskFollowToOffsetOfEntity(dog, GetPlayerPed(PlayerId()), 0.5, 0.0, 0.0, 5.0, -1, 0.0, 1)
					follow = true
					TriggerEvent("chatMessage", "The dog is following you.")
				else
					TriggerEvent("chatMessage", "There is no dog to follow you.")
				end
			else
				ClearPedTasks(dog)
				follow = false
				TriggerEvent("chatMessage", "The dog is not following you.")
			end
		end
	end
end)

-- Attack Function --
Citizen.CreateThread(function()
	while true do
		Citizen.Wait(1)
		if IsPlayerFreeAiming(PlayerId()) and IsControlJustPressed(1, 47) then
			local isAimingAtSomething, enemy = GetEntityPlayerIsFreeAimingAt(PlayerId())
			follow = false
			ClearPedTasks(dog)
			TaskCombatPed(dog, enemy, 0, 16)
		end
	end
end)