local Killer_Storage = game:GetService('ReplicatedStorage'):WaitForChild('Game_Data'):WaitForChild('Killers')

local Offering = {
	-- BASE --
	Active = true; -- should appear in game or be deactivated for now
	Testing = false; -- only appear for tester or above
	
	Name = "Library Card";
	
	Image = "rbxassetid://100463471732618"; -- image id 
	Color = Color3.fromRGB(13, 80, 6);
	
	Description = "Raises the chances of being sent to the Library map.";
	
	
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
		Killer_Storage:WaitForChild('Phantasm');
	},
	
	Data_Name = script.Name;
	Cost = 2500;
	Shop_Chance = 210; -- chance to appear out of 1000 in purchasing_slot
	
	-- GAMEPLAY --
	
}

function Offering.Configure()
	return Offering
end

return Offering.Configure()
