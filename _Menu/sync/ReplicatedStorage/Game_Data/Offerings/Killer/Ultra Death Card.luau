local Killer_Storage = game:GetService('ReplicatedStorage'):WaitForChild('Game_Data'):WaitForChild('Killers')

local Offering = {
	-- BASE --
	Active = true; -- should appear in game or be deactivated for now
	Testing = false; -- only appear for tester or above
	
	Name = "Ultra Death Card";
	
	Image = "rbxassetid://18566608334"; -- image id
	Color = Color3.fromRGB(85, 0, 127);
	
	Description = "";
	
	
	-- SHOP --
	Killers = { -- killers this addon should show up for | reason for table vs single entry is for killer event addons like blighted serum were 1 addon can show up for mutliple.
		Killer_Storage:WaitForChild('Trapper');
		Killer_Storage:WaitForChild('Hillbilly');
		Killer_Storage:WaitForChild('Wraith');
		Killer_Storage:WaitForChild('Architect');
		Killer_Storage:WaitForChild('Doctor');
		Killer_Storage:WaitForChild('Huntress');
		Killer_Storage:WaitForChild('Ninja');
		Killer_Storage:WaitForChild('Nurse');
		Killer_Storage:WaitForChild('Psychopath');
		Killer_Storage:WaitForChild('Reaper');
		Killer_Storage:WaitForChild('Stalker');
		Killer_Storage:WaitForChild('Phantasm')
	},
	
	Data_Name = script.Name;
	Cost = 10000;
	Shop_Chance = 250; -- chance to appear out of 1000 in purchasing_slot
	
	-- GAMEPLAY --
	-- Basically dbr version of mori --
}

function Offering.Configure()
	Offering.Description = "Allows you to kill all 4 survivors manually, if they are on their final hook."
	
	return Offering
end

return Offering.Configure()
