local Cosmetic = {
	-- BASE --
	Active = true; -- should appear in game or be deactivated for now
	Unlocked = false; -- if this set should be unlocked for free at this moment if ever
	
	Set_Name = "Crown";
	Set_Asset = 15299630568; -- asset id to import w/ insert service
	Description = "Want to feel like royalty? Buy me!"; -- works
	Set_Color = Color3.fromRGB(80, 7, 163), --TODO: MAKE THIS WORK 253, 255, 124
	
	Content = { -- pieces in this set
		"Head",
	},
	
	-- SHOP --
	Gamepasses = {}; -- gamepass id's that unlock this set automatically
	Cost = {
		--Set = 50000; -- Entire Set Cost
		--Head = 1000; -- amount this part of the set cost
	}
}

return Cosmetic
