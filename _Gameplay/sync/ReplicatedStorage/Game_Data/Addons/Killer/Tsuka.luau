local Killer_Storage = game:GetService('ReplicatedStorage'):WaitForChild('Game_Data'):WaitForChild('Killers')

local Addon = {
	-- BASE --
	Active = true; -- should appear in game or be deactivated for now
	Testing = false; -- only appear for tester or above
	
	Name = "Tsuka-maki";
	
	Image = "rbxassetid://96694738427180"; -- image id
	Color = Color3.fromRGB(56, 46, 43);
	
	Description = "";
	
	
	-- SHOP --
	Killers = { -- killers this addon should show up for | reason for table vs single entry is for killer event addons like blighted serum were 1 addon can show up for mutliple.
		Killer_Storage:WaitForChild('Ninja')
	},
	
	Data_Name = script.Name;
	Cost = 2000;
	Shop_Chance = 600; -- chance to appear out of 100 in purchasing_slot
	
	-- GAMEPLAY --
	
	
	Dash_Gain = 0.2;
}

function Addon.Configure()
	Addon.Description = "Increase charging speed by <b><font color='#c2b00e'>"..(Addon.Dash_Gain * 100).."%</font></b>."
	
	return Addon
end

return Addon.Configure()
