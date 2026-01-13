local Cosmetic = {
	-- BASE --
	Active = true; -- should appear in game or be deactivated for now
	Unlocked = false; -- if this set should be unlocked for free/auto at this moment if ever
	
	Emote_Name = "Get Em";
	Emote_Asset = "rbxassetid://15919624781"; -- animation id
	Description = "Throw a pallet down and do this emote to assert dominance!";
	
	Data_Name = script.Name;
	
	Emote_Color = Color3.fromRGB(116, 116, 116),
	
	-- SHOP --
	Gamepasses = {}; -- gamepass id's that unlock this emote automatically
	
	Cost = 100000; -- only uncommented if for sale
}

return Cosmetic
