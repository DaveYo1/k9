AddEventHandler("chatMessage", function(source, name, message)
	if message == "/spawnk9" then
		CancelEvent()
		TriggerClientEvent("spawndog", source)
	elseif message == "/deletek9" then
		CancelEvent()
		TriggerClientEvent("deletedog", source)
	end
end)