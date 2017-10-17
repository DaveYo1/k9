K9_Config = {}
K9_Config = setmetatable(K9_Config, {})

K9_Config.DogModel = "A_C_Rottweiler"
K9_Config.PedRestricted = true
K9_Config.VehicleRestricted = true
K9_Config.GodmodeDog = true

K9_Config.PedList = {
	-- Police --
	GetHashKey("s_m_y_cop_01"),
	GetHashKey("s_f_y_cop_01"),
	-- Highway --
	GetHashKey("s_m_y_hwaycop_01"),
	-- Sheriff --
	GetHashKey("s_m_y_sheriff_01"),
	GetHashKey("s_f_y_sheriff_01"),
	-- SWAT --
	GetHashKey("s_m_y_swat_01"),
	-- Ranger --
	GetHashKey("s_m_y_ranger_01"),
	GetHashKey("s_f_y_ranger_01"),
}

K9_Config.VehicleList = {
	GetHashKey("POLICET"), -- 456714581
	GetHashKey("FBI"), -- FBI
	GetHashKey("FBI2"), -- FBI2
	GetHashKey("POLICE"), -- Police
	GetHashKey("POLICE2"), -- Police2
	GetHashKey("POLICE3"), -- POlice3
	GetHashKey("POLICE4"), -- Police4
	GetHashKey("PRANGER"), -- Pranger
	GetHashKey("RIOT"), -- Riot
	GetHashKey("SHERIFF"), -- Sheriff
	GetHashKey("SHERIFF2"), -- Sheriff2
}

K9_Config.Notification = function(message)
	SetNotificationTextEntry("STRING")
	AddTextComponentString(message)
	DrawNotification(0, 1)
end