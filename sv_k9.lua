local settings = {}
settings.restricted = true

local allowedpeds = {
	1581098148, -- S_M_Y_Cop_01
	368603149, -- S_F_Y_Cop_01
	1939545845, -- S_M_Y_HWayCop_01
	-1320879687, -- S_M_Y_Sheriff_01
	1096929346, -- S_F_Y_Sheriff_01
	-1920001264 -- S_M_Y_Swat_01
}

AddEventHandler("chatMessage", function(source, name, message)
	local cm = stringsplit(message, " ")

	if cm[1] == "/k9" then
		CancelEvent()
		if cm[2] == "cmds" then
			TriggerClientEvent("chatMessage", source, "^1K9 COMMANDS:^2 /k9 spawn, /k9 delete, /k9 vehicle, /k9 search")
		elseif cm[2] == "spawn" then
			if settings.restricted == true then
				TriggerEvent("checkPlayerPed", source)
			else
				TriggerClientEvent("spawndog", source)
			end
		elseif cm[2] == "delete" then
			TriggerClientEvent("deletedog", source)
		elseif cm[2] == "vehicle" then
			TriggerClientEvent("vehicletoggle", source)
		elseif cm[2] == "search" then
			TriggerClientEvent("vehicleSearch", source)
		end
	end
end)

AddEventHandler("checkPlayerPed", function(source)
	TriggerClientEvent("sendPlayerPed", source)
end)

RegisterServerEvent("recievePlayerPed")
AddEventHandler("recievePlayerPed", function(ped)
	if checkPedMatch(ped) == true then
		TriggerClientEvent("spawndog", source)
	end
end)

--RegisterServerEvent("sv:attackPlayer")
--AddEventHandler("sv:attackPlayer", function(dog, ped)
--	TriggerClientEvent("cl:attackPlayer", -1, dog, ped)
--end)

function checkPedMatch(ped)
	for k in pairs( allowedpeds ) do
		if allowedpeds[k] == ped then
			return true
		end
	end
	TriggerClientEvent("chatMessage", source, "^1You are not a police officer.")
end

--[[ Other Functions ]]
function stringsplit(inputstr, sep)
    if sep == nil then
        sep = "%s"
    end
    local t={} ; i=1
    for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
        t[i] = str
        i = i + 1
    end
    return t
end