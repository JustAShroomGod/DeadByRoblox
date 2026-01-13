local Cosmetic = {
	-- BASE --
	Active = true; -- should appear in game or be deactivated for now
	Unlocked = true; -- if this set should be unlocked for free/auto at this moment if ever
	
	Emote_Name = "Follow";
	Emote_Asset = "rbxassetid://16520472961"; -- animation id
	Description = "Bla bla";
	
	Data_Name = script.Name;
	
	Emote_Color = Color3.fromRGB(116, 116, 116),
	
	-- SHOP --
	Gamepasses = {}; -- gamepass id's that unlock this emote automatically
	
	--Cost = 0; -- only uncommented if for sale
}

return Cosmetic
