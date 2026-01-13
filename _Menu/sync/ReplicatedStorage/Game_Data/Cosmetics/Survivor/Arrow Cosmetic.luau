local Cosmetic = {
	-- BASE --
	Active = true; -- should appear in game or be deactivated for now
	Unlocked = false; -- if this set should be unlocked for free/auto at this moment if ever

	Set_Name = "Arrow Cosmetic";
	Set_Asset = ""; -- image id
	Description = "You should tunnel me, honestly!";
	Set_Color = Color3.fromRGB(80, 7, 16),

	Content = { -- pieces in this set
		"Head",
	},

	-- SHOP --
	Gamepasses = {}; -- gamepass id's that unlock this set automatically

	Cost = { -- No Prices if not for sale
		--Set = 100000; -- Entire Set Cost
		--Head = 1000; -- amount this part of the set cost
	},

}

return Cosmetic
