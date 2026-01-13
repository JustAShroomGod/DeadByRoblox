local Cosmetic = {
	-- BASE --
	Active = true; -- should appear in game or be deactivated for now
	Unlocked = false; -- if this set should be unlocked for free/auto at this moment if ever
	
	Emote_Name = "Shake it";
	Emote_Asset = "rbxassetid://10258272240"; -- animation id
	Description = "Show off your dancing skills!";
	
	Data_Name = script.Name;
	
	Emote_Color = Color3.fromRGB(116, 116, 116),
	
	-- SHOP --
	Gamepasses = {}; -- gamepass id's that unlock this emote automatically
	
	Cost = 100000; -- only uncommented if for sale
}

return Cosmetic
