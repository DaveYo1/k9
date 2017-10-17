AddEventHandler("chatMessage", function(source, name, message)
	cm = stringsplit(message, " ", " ")

	if cm[1] == "/k9" then
        CancelEvent()
        TriggerClientEvent("K9:OpenMenu", source)
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