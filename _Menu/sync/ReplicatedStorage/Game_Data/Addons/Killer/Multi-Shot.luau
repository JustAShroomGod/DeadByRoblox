local Killer_Storage = game:GetService('ReplicatedStorage'):WaitForChild('Game_Data'):WaitForChild('Killers')

local Addon = {
	-- BASE --
	Active = true; -- should appear in game or be deactivated for now
	Testing = false; -- only appear for tester or above
	
	Name = "Multi-Shot";
	
	Image = "rbxassetid://18566608900"; -- image id
	Color = Color3.fromRGB(255,0,0);
	
	Description = "rbxassetid://14123676262";
	
	
	-- SHOP --
	Killers = { -- killers this addon should show up for | reason for table vs single entry is for killer event addons like blighted serum were 1 addon can show up for mutliple.
		Killer_Storage:WaitForChild('Huntress');
	},
	
	Data_Name = script.Name;
	Cost = 5000;
	Shop_Chance = 100; -- chance to appear out of 100 in purchasing_slot
	
	-- GAMEPLAY --

	Hatchet_Boost = -4; -- take away 4 hatchets

}

function Addon.Configure()
	Addon.Description = "Allows you to instantly down a Survivor with a Hatchet. \nPermanently Decreases Hatchet Capacity to <b><font color='#c2b00e'>1</font></b> Hatchet."

	return Addon
end

return Addon.Configure()
