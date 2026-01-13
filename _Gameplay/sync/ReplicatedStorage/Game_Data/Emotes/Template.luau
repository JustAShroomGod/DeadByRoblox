local Cosmetic = {
	-- BASE --
	Active = false; -- should appear in game or be deactivated for now
	Unlocked = false; -- if this set should be unlocked for free/auto at this moment if ever
	
	Emote_Name = "Template";
	Emote_Asset = ""; -- animation id
	Description = "Bla bla";

	Data_Name = script.Name;
	
	Emote_Color = Color3.fromRGB(116, 116, 116),
	
	-- SHOP --
	Gamepasses = {}; -- gamepass id's that unlock this set automatically
	
	--Cost = 0; -- only uncommented if for sale
}

return Cosmetic
