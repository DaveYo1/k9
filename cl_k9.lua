local follow = false
local invehicle = false
local dog = nil

local items = {
	legal = {
		"nothing",
		"a pair of socks",
		"box of condoms",
		"nothing",
		"one gram of marijuana",
		"two grams of marijuana",
		"nothing",
		"pack of cigarettes",
		"six pack of beer",
		"nothing"
	},
	illegal = {
		"open beer container",
		"one kilo of marijuana",
		"one kilo of marijuana with a scale and small baggies",
		"two kilos of marijuana",
		"two kilos of marijuana with a scale and small baggies",
		"heroin needle",
		"heroin needles"
	},
	majorillegal = {
		"one kilo of cocaine",
		"two kilos of cocaine",
		"brief case of cocaine",
		"two brief cases of cocaine",
		"one meth rock",
		"dime bag of meth",
		"plastic bag of meth with a scale"
	},
}

RegisterNetEvent("spawndog")
AddEventHandler("spawndog", function()
	Citizen.CreateThread(function()
		if dog == nil then
			local dogmodel = GetHashKey("A_C_Rottweiler")

			RequestModel(dogmodel)
			while not HasModelLoaded(dogmodel) do
				RequestModel(dogmodel)
				Citizen.Wait(100)
			end

			local plypos = GetOffsetFromEntityInWorldCoords(GetPlayerPed(PlayerId()), 0.0, 2.0, 0.0)
			local plyhead = GetEntityHeading(GetPlayerPed(PlayerId()))
			local spawned = CreatePed(28, dogmodel, plypos.x, plypos.y, plypos.z, plyhead, 1, 1)
			SetEntityMaxSpeed(spawned, 25.0)
			SetBlockingOfNonTemporaryEvents(spawned, true, false)
			SetCanAttackFriendly(spawned, true, 1)
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
		follow = false
		invehicle = false
		dog = nil
	else
		TriggerEvent("chatMessage", "You don't have a dog to delete.")
		return
	end
end)

RegisterNetEvent("vehicletoggle")
AddEventHandler("vehicletoggle", function()
	Citizen.CreateThread(function()
		if invehicle ~= true then
			local plyCoords = GetEntityCoords(GetPlayerPed(PlayerId()), 1)
			local veh = GetClosestVehicle(plyCoords.x, plyCoords.y, plyCoords.z, 3.0, 0, 23)
			Citizen.Trace("Closest Vehicle: " .. tostring(veh))
			TaskEnterVehicle(dog, veh, -1, 2, 2.0, 1, 0)
			follow = false
			invehicle = true
		else
			local dveh = GetVehiclePedIsIn(dog, false)
			TaskLeaveVehicle(dog, dveh, 256)
			invehicle = false
		end
	end)
end)

-- Vehicle Searching --
function searchstatus()
	local legalstatus = math.random(3)
	local itemchoice = nil

	if legalstatus == 1 then
		local legalchoice = math.random(6)
		itemchoice = items.legal[legalchoice]
	elseif legalstatus == 2 then
		local illegalchoice = math.random(7)
		itemchoice = items.illegal[illegalchoice]
	elseif legalstatus == 3 then
		local majorillegalchoice = math.random(7)
		itemchoice = items.majorillegal[majorillegalchoice]
	end

	return itemchoice
end

RegisterNetEvent("vehicleSearch")
AddEventHandler("vehicleSearch", function()
	Citizen.CreateThread(function()
		local plyCoords = GetEntityCoords(GetPlayerPed(PlayerId()), false)
		local veh = GetClosestVehicle(plyCoords.x, plyCoords.y, plyCoords.z, 3.0, 0, 23)
		Citizen.Trace(veh)
		local vehCoords = GetOffsetFromEntityInWorldCoords(veh, 3.0, 0.0, 0.0)
		local vehHead = GetEntityHeading(veh)

		if dog ~= nil then
			if veh ~= 0 then
				--TaskGoToCoordAnyMeans(dog, vehCoords.x, vehCoords.y, vehCoords.z, 5.0, 1, 1, 1, 1)
				TaskFollowNavMeshToCoord(dog, vehCoords.x, vehCoords.y, vehCoords.z, 5.0, -1, 2.0, 1, 1)
				Citizen.Wait(5000)
				TaskAchieveHeading(dog, vehHead - 270, -1)
				Citizen.Wait(5000)
				SetVehicleDoorOpen(veh, 0, false)
				SetVehicleDoorOpen(veh, 1, false)
				SetVehicleDoorOpen(veh, 2, false)
				SetVehicleDoorOpen(veh, 3, false)
				SetVehicleDoorOpen(veh, 5, false)
				SetVehicleDoorOpen(veh, 6, false)
				SetVehicleDoorOpen(veh, 7, false)
				Citizen.Wait(5000)
				TriggerEvent("chatMessage", "Your K9 has found " .. tostring(searchstatus()) .. ".")
				Citizen.Wait(1000)
				SetVehicleDoorShut(veh, 0, false)
				SetVehicleDoorShut(veh, 1, false)
				SetVehicleDoorShut(veh, 2, false)
				SetVehicleDoorShut(veh, 3, false)
				SetVehicleDoorShut(veh, 4, false)
				SetVehicleDoorShut(veh, 5, false)
				SetVehicleDoorShut(veh, 6, false)
				SetVehicleDoorShut(veh, 7, false)
			else
				TriggerEvent("chatMessage", "You are too far away from the vehicle. Get Closer!")
			end
		else
			TriggerEvent("chatMessage", "You are not a K9 handler.")
		end
	end)
end)

 -- Follow Function --
Citizen.CreateThread(function()
	while true do
		Citizen.Wait(1)
		if not IsPlayerFreeAiming(PlayerId()) and IsControlJustPressed(1, 47) then
			if follow ~= true and invehicle ~= true then
				if dog ~= nil then
					TaskFollowToOffsetOfEntity(dog, GetPlayerPed(PlayerId()), 0.5, 0.0, 0.0, 5.0, -1, 0.0, 1)
					follow = true
					invehicle = false
					TriggerEvent("chatMessage", "The dog is following you.")
				else
					TriggerEvent("chatMessage", "There is no dog to follow you.")
				end
			else
				ClearPedTasks(dog)
				follow = false
				invehicle = false
				TriggerEvent("chatMessage", "The dog is not following you.")
			end
		end
	end
end)

-- Attack Function --
--[[
Citizen.CreateThread(function()
	while true do
		Citizen.Wait(1)
		if IsPlayerFreeAiming(PlayerId()) and IsControlJustPressed(1, 47) and not invehicle then
			local isAimingAtSomething, enemy = GetEntityPlayerIsFreeAimingAt(PlayerId())
			follow = false
			invehicle = false
			ClearPedTasks(dog)
			TaskCombatPed(dog, enemy, 0, 16)
		end
	end
end)
--]]


--[[ DEBUGGING SCRIPT ]]--
Citizen.CreateThread(function()
	local debug = true
	while true do
		Citizen.Wait(2500)
		if debug then
			--Citizen.Trace("Your Dog: " .. tostring(dog))
			--Citizen.Trace("Following Status: " .. tostring(follow))
			--Citizen.Trace("Players ID: " .. tostring(PlayerId()))
			--Citizen.Trace("Server ID: " .. tostring(GetPlayerServerId(PlayerId())))
			--Citizen.Trace("Get Player From ID: " .. tostring(GetPlayerFromServerId(GetPlayerServerId(PlayerId()))))
		end
	end
end)

AddEventHandler("clientconsole", function(message1, message2)
	Citizen.CreateThread(function()
		Citizen.Trace(message1 .. message2)
	end)
end)
--]]