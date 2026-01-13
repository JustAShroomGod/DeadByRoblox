local Killer_Storage = game:GetService('ReplicatedStorage'):WaitForChild('Game_Data'):WaitForChild('Killers')

local Addon = {
	-- BASE --
	Active = true; -- should appear in game or be deactivated for now
	Testing = false; -- only appear for tester or above
	
	Name = "Serpent";
	
	Image = "rbxassetid://14863551035"; -- image id
	Color = Color3.fromRGB(0, 85, 0);
	
	Description = "";
	
	
	-- SHOP --
	Killers = { -- killers this addon should show up for | reason for table vs single entry is for killer event addons like blighted serum were 1 addon can show up for mutliple.
		Killer_Storage:WaitForChild('Wraith');
	},
	
	Data_Name = script.Name;
	Cost = 3000;
	Shop_Chance = 300; -- chance to appear out of 100 in purchasing_slot
	
	-- GAMEPLAY --
	
	Uncloak_Boost = 35;
}

function Addon.Configure()
	Addon.Description = "Automatically uncloak after breaking a pallet/wall. Uncloak speed during this will be increased by <b><font color='#c2b00e'>"..Addon.Uncloak_Boost.."%</font></b>."
	
	return Addon
end

return Addon.Configure()
