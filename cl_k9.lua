local current_dog = nil
local following = false
local attacking = false
local animation_played = nil
local dog_name = "Max"

local other_ped_attacked = nil

RegisterNetEvent("K9:ToggleDog")
AddEventHandler("K9:ToggleDog", function()
	if current_dog == nil then
		-- Spawn Dog
		local model = GetHashKey(K9_Config.DogModel)
		RequestModel(model)
		while not HasModelLoaded(model) do
			RequestModel(model)
			Citizen.Wait(100)
		end

		local plypos = GetOffsetFromEntityInWorldCoords(GetPlayerPed(PlayerId()), 0.0, 2.0, 0.0)
		local plyhead = GetEntityHeading(GetPlayerPed(PlayerId()))
		local spawned_entity = CreatePed(GetPedType(model), model, plypos.x, plypos.y, plypos.z, plyhead, 1, 1)
		SetBlockingOfNonTemporaryEvents(spawned_entity, true)
		SetPedFleeAttributes(spawned_entity, 0, 0)
		current_dog = spawned_entity
		local blip = AddBlipForEntity(current_dog)
		SetBlipAsFriendly(blip, true)
		SetBlipSprite(blip, 442)
		BeginTextCommandSetBlipName("STRING");
		AddTextComponentString(tostring("K9"))
		EndTextCommandSetBlipName(blip)
		if K9_Config.GodmodeDog == true then
			SetEntityInvincible(spawned_entity, true)
		end
		K9_Config.Notification("Your dog " .. dog_name .. " is in service.")
	else
		SetEntityAsMissionEntity(current_dog, true, true)
		DeleteEntity(current_dog)
		K9_Config.Notification("Your dog " .. dog_name .. " is out of service.")
		current_dog = nil
	end
end)

RegisterNetEvent("K9:Vehicle")
AddEventHandler("K9:Vehicle", function()
	if current_dog ~= nil then
		if IsPedInAnyVehicle(current_dog, false) then

			TaskLeaveVehicle(current_dog, GetVehiclePedIsIn(current_dog, false), 256)

		else
			local plyPos = GetEntityCoords(GetPlayerPed(-1), false)
			local vehicle = GetClosestVehicle(plyPos['x'], plyPos['y'], plyPos['z'], 3.0, 0, 23)

			if K9_Config.VehicleRestricted == true then

				if CheckVehicleRestriction(vehicle) == true then
					TaskEnterVehicle(current_dog, vehicle, -1, 2, 2.0, 1, 0)
					following = false
					attacking = false
				end

			else

				TaskEnterVehicle(current_dog, vehicle, -1, 2, 2.0, 1, 0)
				following = false
				attacking = false

			end

		end
	end
end)

RegisterNetEvent("K9:Follow")
AddEventHandler("K9:Follow", function()
	if current_dog ~= nil then
		if following == false then
			TaskFollowToOffsetOfEntity(current_dog, GetPlayerPed(PlayerId()), 0.5, 0.0, 0.0, 5.0, -1, 0.0, 1)
			following = true
			K9_Config.Notification(tostring(dog_name .. " Hier!")) -- Come
		else
			ClearPedTasks(current_dog)
			following = false
			K9_Config.Notification(tostring(dog_name .. " Bleib!")) -- Stay
		end
	end
end)

RegisterNetEvent("K9:Attack")
AddEventHandler("K9:Attack", function()
	local dog_ped = current_dog
	local bool, other_ped = GetEntityPlayerIsFreeAimingAt(PlayerId())
	other_ped_attacked = other_ped

	if attacking == false then
		if IsEntityAPed(other_ped) then
			if not IsEntityDead(other_ped) then
				SetCanAttackFriendly(dog_ped, true, true)
				TaskPutPedDirectlyIntoMelee(dog_ped, other_ped, 0.0, -1.0, 0.0, 0)
				other_ped_attacked = other_ped
				attacking = true
				following = false
				K9_Config.Notification(tostring(dog_name .. " Fass!")) -- Attack
			end
		end
	else
		attacking = false
		other_ped_attacked = nil
		ClearPedTasks(dog_ped)
		K9_Config.Notification(tostring(dog_name .. " Zei Brav!")) -- Stopping Dog (Good Dog)
	end
end)

RegisterNetEvent("K9:Animations")
AddEventHandler("K9:Animations", function(choice)

	if animation_played ~= nil then -- Clear Animation Before Doing another action

		if animation_played == "sit" then -- Sit End
			sit(current_dog)
		elseif animation_played == "laydown" then
			laydown(current_dog)
		end

	else -- Start animation 

		if choice == "sit" then -- Sit Start
			sit(current_dog)
		elseif choice == "laydown" then -- Laydown Start
			laydown(current_dog)
		end

	end

	attacking = false
	following = false

end)

--[[ ANIMATION FUNCTIONS ]]--
function sit(entity)
	local animdicstart = "creatures@rottweiler@amb@world_dog_sitting@base"
	local animnamestart = "base"
	local animdicend = "creatures@rottweiler@amb@world_dog_sitting@exit"
	local animnameend = "exit"

	if IsEntityPlayingAnim(entity, animdicstart, animnamestart, 3) then
			RequestAnimDict(animdicend)
			while not HasAnimDictLoaded(animdicend) do
				Citizen.Wait(100)
				RequestAnimDict(animdicend)
			end
		TaskPlayAnim(current_dog, animdicend, animnameend, 1.0, -1, -1, 2, 0, 0, 0, 0)
		if HasEntityAnimFinished(current_dog, animdicend, animnameend, 3) then
			ClearPedSecondaryTask(current_dog)
		end
		animation_played = nil
		K9_Config.Notification(tostring(dog_name .. " Stehen!"))
	else
		RequestAnimDict(animdicstart)
		while not HasAnimDictLoaded(animdicstart) do
			Citizen.Wait(100)
			RequestAnimDict(animdicstart)
		end
		TaskPlayAnim(current_dog, animdicstart, animnamestart, 1.0, -1, -1, 2, 0, 0, 0, 0)
		animation_played = "sit"
		K9_Config.Notification(tostring(dog_name .. " Sitz!"))
	end
end

function laydown(entity)
	local animdicstart = "creatures@rottweiler@amb@sleep_in_kennel@"
	local animnamestart = "sleep_in_kennel"
	local animdicend = "creatures@rottweiler@amb@sleep_in_kennel@"
	local animnameend = "exit_kennel"

	if IsEntityPlayingAnim(entity, animdicstart, animnamestart, 3) then
			RequestAnimDict(animdicend)
			while not HasAnimDictLoaded(animdicend) do
				Citizen.Wait(100)
				RequestAnimDict(animdicend)
			end
		TaskPlayAnim(current_dog, animdicend, animnameend, 1.0, -1, -1, 2, 0, 0, 0, 0)
		if HasEntityAnimFinished(current_dog, animdicend, animnameend, 3) then
			ClearPedSecondaryTask(current_dog)
		end
		animation_played = nil
		K9_Config.Notification(tostring(dog_name .. " Stehen!"))
	else
		RequestAnimDict(animdicstart)
		while not HasAnimDictLoaded(animdicstart) do
			Citizen.Wait(100)
			RequestAnimDict(animdicstart)
		end
		TaskPlayAnim(current_dog, animdicstart, animnamestart, 1.0, -1, -1, 2, 0, 0, 0, 0)
		animation_played = "laydown"
		K9_Config.Notification(tostring(dog_name .. " Platz!"))
	end

end
--]]

-- Handling Key Bindings and Attacking auto stop --
Citizen.CreateThread(function()
	while true do
		Citizen.Wait(0)

		-- Follow Key --
		if IsControlJustPressed(1, 47) and not IsPlayerFreeAiming(PlayerId()) then
			TriggerEvent("K9:Follow")
		end

		-- Attacking Key --
		if IsPlayerFreeAiming(PlayerId()) and IsControlJustPressed(1, 47) then
			TriggerEvent("K9:Attack")
		end

		-- If other ped attacking dies it stops attacking --
		if attacking == true then
			if IsPedDeadOrDying(other_ped_attacked, 1) then
				K9_Config.Notification("Pust!") -- Release Bite
				TriggerEvent("K9:Attack")
			end
		end
	end
end)

-- [[ WARMENU MENU ]] --
Citizen.CreateThread(function()
	WarMenu.CreateMenu('k9menu', "K9 Options")
	WarMenu.CreateSubMenu("k9anims", "k9menu")
	WarMenu.SetTitleBackgroundColor('k9menu', 2, 120, 217, 1.0)
	WarMenu.SetTitleBackgroundColor('k9anims', 2, 120, 217, 1.0)
	WarMenu.debug = true

	while true do
		-- K9 MENU --
	  if WarMenu.IsMenuOpened('k9menu') then

			if WarMenu.Button('K9 Toggle [Spawn | Delete]') then
		  		TriggerEvent("K9:ToggleDog")
		   elseif WarMenu.Button("K9 Vehicle [Enter | Exit]") then
		  		TriggerEvent("K9:Vehicle")
		   elseif WarMenu.Button("K9 Search") then
		  		K9_Config.Notification("Not Implemented Yet.")
		  	elseif WarMenu.MenuButton("K9 Animations", "k9anims") then

		   elseif WarMenu.Button("Close Menu") then
			   WarMenu.CloseMenu()
			end

	  		WarMenu.Display()
	  elseif WarMenu.IsMenuOpened('k9anims') then
	  		if WarMenu.Button("K9 [Sit]") then
	  			TriggerEvent("K9:Animations", "sit")
	  		elseif WarMenu.Button("K9 [Laydown]") then
	  			TriggerEvent("K9:Animations", "laydown")
	  		elseif WarMenu.MenuButton("Back", "k9menu") then
	  			-- Go Back To Prev menu
	  		elseif WarMenu.Button("Close Menu") then
	  			WarMenu.CloseMenu()
	  		end
	  		WarMenu.Display()
	  end

	  -- Key Toggling
	  if IsControlPressed(1, 19) and IsControlJustPressed(1,20) then -- LEFTALT + Z

	  		if K9_Config.PedRestricted == true then

	  			if CheckPedRestriction(GetPlayerPed(-1)) == true then

	  				TriggerEvent("K9:OpenMenu")

	  			else
	  				K9_Config.Notification("You are not an LEO.")
	  			end

	  		else
	  			TriggerEvent("K9:OpenMenu")
	  		end

	  end

	  Citizen.Wait(0)
	end
end)

RegisterNetEvent("K9:OpenMenu")
AddEventHandler("K9:OpenMenu", function()
	WarMenu.OpenMenu('k9menu')
end)

--[[ EXTRA FUNCTIONS ]]--
function CheckVehicleRestriction(vehicle)
	for i = 1, #K9_Config.VehicleList do
		if K9_Config.VehicleList[i] == GetEntityModel(vehicle) then
			return true
		end
	end
	return false
end

function CheckPedRestriction(ped)
	for i = 1, #K9_Config.PedList do
		if K9_Config.PedList[i] == GetEntityModel(ped) then
			return true
		end
	end
	return false
end
--]]