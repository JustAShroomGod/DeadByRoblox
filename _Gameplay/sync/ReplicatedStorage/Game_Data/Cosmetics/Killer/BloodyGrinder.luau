local Killer_Storage = game:GetService('ReplicatedStorage'):WaitForChild('Game_Data'):WaitForChild('Killers')

local Cosmetic = {
	-- BASE --
	Active = true; -- should appear in game or be deactivated for now
	Unlocked = false; -- if this set should be unlocked for free at this moment if ever

	Set_Name = "Bloody Grinder";
	Set_Asset = ""; -- image id
	Description = "Show off that you are a og";
	Set_Color = Color3.fromRGB(138, 6, 14),

	Content = { -- pieces in this set
		"Head",
		"Weapon",
		"Torso",
	},

	-- SHOP --
	Gamepasses = {}; -- gamepass id's that unlock this set automatically
	Cost = { -- No Prices if not for sale
		--Set = 50000; -- Entire Set Cost
		--Head = 1000; -- amount this part of the set cost
	},

	Killers = { -- killers that can get this cosmetic
		Killer_Storage:WaitForChild('Trapper');
		Killer_Storage:WaitForChild('Hillbilly');
		Killer_Storage:WaitForChild('Priest');
		Killer_Storage:WaitForChild('Wraith');
		Killer_Storage:WaitForChild('Huntress');
		Killer_Storage:WaitForChild('Stalker');
		Killer_Storage:WaitForChild('Psychopath');
		Killer_Storage:WaitForChild('Nurse');
	},
}

return Cosmetic
