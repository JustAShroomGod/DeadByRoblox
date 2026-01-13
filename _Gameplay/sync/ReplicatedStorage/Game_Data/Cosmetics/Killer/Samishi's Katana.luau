local Killer_Storage = game:GetService('ReplicatedStorage'):WaitForChild('Game_Data'):WaitForChild('Killers')

local Cosmetic = {
	-- BASE --
	Active = true; -- should appear in game or be deactivated for now
	Unlocked = false; -- if this set should be unlocked for free at this moment if ever

	Set_Name = "Samishi's Katana";
	Set_Asset = ""; -- image id
	Description = "He only has 1 week of studio?!";
	Set_Color = Color3.fromRGB(138, 6, 14),

	Content = { -- pieces in this set
		"Weapon",
	},

	-- SHOP --
	Gamepasses = {}; -- gamepass id's that unlock this set automatically
	Cost = { -- No Prices if not for sale
	--	Set = 1; -- Entire Set Cost
		--Head = 1000; -- amount this part of the set cost
	},

	Killers = { -- killers that can get this cosmetic
		Killer_Storage:WaitForChild('Ninja');
	},
}

return Cosmetic
