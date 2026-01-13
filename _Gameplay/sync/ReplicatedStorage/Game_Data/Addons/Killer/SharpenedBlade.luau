local Killer_Storage = game:GetService('ReplicatedStorage'):WaitForChild('Game_Data'):WaitForChild('Killers')

local Addon = {
	-- BASE --
	Active = true; -- should appear in game or be deactivated for now
	Testing = false; -- only appear for tester or above
	
	Name = "Sharpened Blade";
	
	Image = "rbxassetid://103589274410560"; -- image id
	Color = Color3.fromRGB(80, 7, 163);
	
	Description = "rbxassetid://10367200986";
	
	
	-- SHOP --
	Killers = { -- killers this addon should show up for | reason for table vs single entry is for killer event addons like blighted serum were 1 addon can show up for mutliple.
		Killer_Storage:WaitForChild('Psychopath')
	},
	
	Data_Name = script.Name;
	Cost = 4000;
	Shop_Chance = 600; -- chance to appear out of 100 in purchasing_slot
	
	-- GAMEPLAY --
	
	Start_MaxRage = 1000; --/90 * 100 to get the % (considering 90 is the base max value)
	Passive = 15;
}

function Addon.Configure()
	Addon.Description = "Start the match with full Power. \n Increases Blood Rage passive rate by <b><font color='#c2b00e'>".. math.round((Addon.Passive / 100) * 100) .."%</font></b>."
	
	return Addon
end

return Addon.Configure()
