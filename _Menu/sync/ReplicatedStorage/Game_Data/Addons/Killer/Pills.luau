local Killer_Storage = game:GetService('ReplicatedStorage'):WaitForChild('Game_Data'):WaitForChild('Killers')

local Addon = {
	-- BASE --
	Active = true; -- should appear in game or be deactivated for now
	Testing = false; -- only appear for tester or above
	
	Name = "Pills";
	
	Image = "rbxassetid://18566608678"; -- image id
	Color = Color3.fromRGB(0, 85, 0);
	
	Description = "rbxassetid://10367200986";
	
	
	-- SHOP --
	Killers = { -- killers this addon should show up for | reason for table vs single entry is for killer event addons like blighted serum were 1 addon can show up for mutliple.
		Killer_Storage:WaitForChild('Psychopath')
	},
	
	Data_Name = script.Name;
	Cost = 2000;
	Shop_Chance = 1000; -- chance to appear out of 100 in purchasing_slot
	
	-- GAMEPLAY --
	
	Duration_Increase = 250; --/1000 * 100 to get the % (considering 1000 is the base max value)
}

function Addon.Configure()
	Addon.Description = "Increase the duration of Blood Rage by <b><font color='#c2b00e'>".. (Addon.Duration_Increase / 1000) * 100 .."%</font></b>."
	
	return Addon
end

return Addon.Configure()
