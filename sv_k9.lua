AddEventHandler("chatMessage", function(source, name, message)
	local cm = stringsplit(message, " ")

	if cm[1] == "/k9" then
		CancelEvent()
		if cm[2] == "cmds" then
			TriggerClientEvent("chatMessage", source, "^2K9 COMMANDS:^1 /k9 spawn, /k9 delete, /k9 vehicle, /k9 search")
		elseif cm[2] == "spawn" then
			TriggerClientEvent("spawndog", source)
		elseif cm[2] == "delete" then
			TriggerClientEvent("deletedog", source)
		elseif cm[2] == "vehicle" then
			TriggerClientEvent("vehicletoggle", source)
		elseif cm[2] == "search" then
			TriggerClientEvent("vehicleSearch", source)
		end
	end
end)

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