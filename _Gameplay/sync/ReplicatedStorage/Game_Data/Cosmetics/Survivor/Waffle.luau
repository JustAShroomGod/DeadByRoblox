local Cosmetic = {
	-- BASE --
	Active = true; -- should appear in game or be deactivated for now
	Unlocked = false; -- if this set should be unlocked for free/auto at this moment if ever
	
	Set_Name = "Waffle";
	Set_Asset = ""; -- image id
	Description = "Why did you put it on your back?";
	Set_Color = Color3.fromRGB(116, 116, 116),
	
	Content = { -- pieces in this set
		--"Head",
		"Torso",
		--"Legs",
	},
	
	-- SHOP --
	Gamepasses = {}; -- gamepass id's that unlock this set automatically
	
	Cost = { -- No Prices if not for sale
		--Set = 50000; -- Entire Set Cost
		--Torso = 1000; -- amount this part of the set cost
	},
	
}

return Cosmetic
