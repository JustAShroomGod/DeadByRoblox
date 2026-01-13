local Killer_Storage = game:GetService('ReplicatedStorage'):WaitForChild('Game_Data'):WaitForChild('Killers')

local Offering = {
	-- BASE --
	Active = true; -- should appear in game or be deactivated for now
	Testing = false; -- only appear for tester or above
	
	Name = "Golden Hay";
	
	Image = "rbxassetid://18304653697"; -- image id
	Color = Color3.fromRGB(177, 131, 22);
	
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
	},
	
	
	Data_Name = script.Name;
	Cost = 3000;
	Shop_Chance = 800; -- chance to appear out of 100 in purchasing_slot
	
	-- GAMEPLAY --
	
	Multiplier = 1;
}

function Offering.Configure()
	Offering.Description = "The Sacred Cow will be pleased with this Offer; When using this Offering you will gain <b><font color='#c2b00e'>"..tostring(Offering.Multiplier * 100).."</font></b>% more blood in the match!"
	
	return Offering
end

return Offering.Configure()
