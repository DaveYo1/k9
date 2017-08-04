AddEventHandler("chatMessage", function(source, name, message)
	local cm = stringsplit(message, " ")

	if message == "/k9cmds" then
		CancelEvent()
		TriggerClientEvent("chatMessage", source, "K9 COMMANDS: /spawnk9, /deletek9, /vehicle, /k9search")
	end

	if message == "/spawnk9" then
		CancelEvent()
		TriggerClientEvent("spawndog", source)
	elseif message == "/deletek9" then
		CancelEvent()
		TriggerClientEvent("deletedog", source)
	end

	if message == "/vehicle" then
		CancelEvent()
		TriggerClientEvent("vehicletoggle", source)
	end

	if message == "/k9search" then
		CancelEvent()
		TriggerClientEvent("vehicleSearch", source)
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