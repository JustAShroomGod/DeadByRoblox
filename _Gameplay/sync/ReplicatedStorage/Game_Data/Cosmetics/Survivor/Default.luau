local Cosmetic = {
	-- BASE --
	Active = true; -- should appear in game or be deactivated for now
	Unlocked = true; -- if this set should be unlocked for free/auto at this moment if ever
	
	Set_Name = "Default";
	Set_Asset = ""; -- image id
	Description = "Default Clothing";
	Set_Color = Color3.fromRGB(6, 62, 125),
	
	Content = { -- pieces in this set
		"Head",
		"Torso",
		"Legs",
	},
	
	-- SHOP --
	Gamepasses = {}; -- gamepass id's that unlock this set automatically
	
	Cost = { -- No Prices if not for sale
		--Set = 50000; -- Entire Set Cost
		--Head = 1000; -- amount this part of the set cost
	},
	
}

return Cosmetic
