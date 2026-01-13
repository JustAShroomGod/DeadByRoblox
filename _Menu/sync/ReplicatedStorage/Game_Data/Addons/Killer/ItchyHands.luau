local Killer_Storage = game:GetService('ReplicatedStorage'):WaitForChild('Game_Data'):WaitForChild('Killers')

local Addon = {
	-- BASE --
	Active = true; -- should appear in game or be deactivated for now
	Testing = false; -- only appear for tester or above
	
	Name = "Itchy Hands";
	
	Image = "rbxassetid://16579099708"; -- image id
	Color = Color3.fromRGB(0, 85, 0);
	
	Description = "";
	
	
	-- SHOP --
	Killers = { -- killers this addon should show up for | reason for table vs single entry is for killer event addons like blighted serum were 1 addon can show up for mutliple.
		Killer_Storage:WaitForChild('Huntress');
	},
	
	Data_Name = script.Name;
	Cost = 3000;
	Shop_Chance = 1000; -- chance to appear out of 100 in purchasing_slot
	
	-- GAMEPLAY --
	
	Reload_Boost = 0.25;
}

function Addon.Configure()
	Addon.Description = "Reload hatchets <b><font color='#c2b00e'>"..(Addon.Reload_Boost * 100).."</font></b>% faster."
	
	return Addon
end

return Addon.Configure()
