local follow    = false
local searching = false
local invehicle = false
local dog       = nil

local items = {
	legal = {
		"nothing",
		"nothing",
		"a pair of socks",
		"box of condoms",
		"nothing",
		"nothing",
		"one gram of marijuana",
		"two grams of marijuana",
		"nothing",
		"nothing",
		"pack of cigarettes",
		"six pack of beer",
		"nothing",
		"nothing"
	},
	illegal = {
		"nothing",
		"nothing",
		"open beer container",
		"one kilo of marijuana",
		"nothing",
		"nothing",
		"one kilo of marijuana with a scale and small baggies",
		"two kilos of marijuana",
		"nothing",
		"nothing",
		"two kilos of marijuana with a scale and small baggies",
		"a heroin needle",
		"nothing",
		"nothing",
		"heroin needles"
	},
	majorillegal = {
		"one kilo of cocaine",
		"nothing",
		"nothing",
		"nothing",
		"two kilos of cocaine",
		"a brief case of cocaine",
		"nothing",
		"nothing",
		"nothing",
		"two brief cases of cocaine",
		"one meth rock",
		"nothing",
		"nothing",
		"nothing",
		"a dime bag of meth",
		"plastic baggies of meth with a scale",
		"nothing",
		"nothing",
		"nothing"
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
			GiveWeaponToPed(spawned, GetHashKey("WEAPON_ANIMAL"), 200, true, true)
			SetBlockingOfNonTemporaryEvents(spawned, true, false)
			SetPedFleeAttributes(spawned, 0, 0)
			dog = spawned
			notification("K9 Spawned")
		else
			TriggerEvent("chatMessage", "You can only spawn one dog.")
			return
		end
	end)
end)

RegisterNetEvent("deletedog")
AddEventHandler("deletedog", function()
	if dog ~= nil then
		SetEntityAsMissionEntity(dog, true, true)
        DeleteEntity(dog)
		follow = false
		invehicle = false
		dog = nil
		notification("K9 Deleted")
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
		local legalchoice = math.random(14)
		itemchoice = items.legal[legalchoice]
	elseif legalstatus == 2 then
		local illegalchoice = math.random(15)
		itemchoice = items.illegal[illegalchoice]
	elseif legalstatus == 3 then
		local majorillegalchoice = math.random(19)
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
		follow = false
		invehicle = false

		if dog ~= nil then
			if veh ~= 0 then
				if searching == false then
					searching = true
					TaskFollowNavMeshToCoord(dog, vehCoords.x, vehCoords.y, vehCoords.z, 5.0, -1, 2.0, 1, 1)
					Citizen.Wait(5000)
					TaskAchieveHeading(dog, vehHead - 270, -1)
					Citizen.Wait(5000)
					notification("Your K9 is searching the vehicle.")
					SetVehicleDoorOpen(veh, 0, false)
					SetVehicleDoorOpen(veh, 1, false)
					SetVehicleDoorOpen(veh, 2, false)
					SetVehicleDoorOpen(veh, 3, false)
					SetVehicleDoorOpen(veh, 5, false)
					SetVehicleDoorOpen(veh, 6, false)
					SetVehicleDoorOpen(veh, 7, false)
					Citizen.Wait(5000)
					TriggerEvent("chatMessage", "Your K9 has found ^1" .. tostring(searchstatus()) .. ".")
					Citizen.Wait(1000)
					SetVehicleDoorShut(veh, 0, false)
					SetVehicleDoorShut(veh, 1, false)
					SetVehicleDoorShut(veh, 2, false)
					SetVehicleDoorShut(veh, 3, false)
					SetVehicleDoorShut(veh, 4, false)
					SetVehicleDoorShut(veh, 5, false)
					SetVehicleDoorShut(veh, 6, false)
					SetVehicleDoorShut(veh, 7, false)
					searching = false
				end
			else
				TriggerEvent("chatMessage", "You are too far away from the vehicle. Get Closer!")
			end
		else
			TriggerEvent("chatMessage", "You are not a K9 handler.")
		end
	end)
end)

-- Attack Function --
--RegisterNetEvent("cl:attackPlayer")
--AddEventHandler("cl:attackPlayer", function(k9dog, otherPed)
--	TaskPutPedDirectlyIntoMelee(k9dog, otherPed, 0.0, -1.0, 0.0, 0.0)
--end)

--Citizen.CreateThread(function()
--	while true do
--		Citizen.Wait(1)
--		if IsControlJustPressed(1, 47) and IsPlayerFreeAiming(PlayerId()) then
--			local bool, enemyPed = GetEntityPlayerIsFreeAimingAt(PlayerId())
--			TriggerServerEvent("sv:attackPlayer", dog, enemyPed)
--		end
--	end
--end)

 -- Follow Function --
Citizen.CreateThread(function()
	while true do
		Citizen.Wait(1)
		if not IsPlayerFreeAiming(PlayerId()) and IsControlJustPressed(1, 47) then
			if follow ~= true then
				if dog ~= nil then
					TaskFollowToOffsetOfEntity(dog, GetPlayerPed(PlayerId()), 0.5, 0.0, 0.0, 5.0, -1, 0.0, 1)
					follow = true
					invehicle = false
					notification("The dog is following you.")
				else
					notification("There is no dog to follow you.")
				end
			else
				ClearPedTasks(dog)
				follow = false
				invehicle = false
				notification("The dog is not following you.")
			end
		end
	end
end)


--[[ Other Functions ]]--
RegisterNetEvent("sendPlayerPed")
AddEventHandler("sendPlayerPed", function()
	local getPedModel = GetEntityModel(GetPlayerPed(PlayerId()))
	TriggerServerEvent("recievePlayerPed", getPedModel)
end)

function notification(message)
	SetNotificationTextEntry("STRING")
	AddTextComponentString(message)
	DrawNotification(0,1)
end
--]]