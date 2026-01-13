local Killer_Storage = game:GetService('ReplicatedStorage'):WaitForChild('Game_Data'):WaitForChild('Killers')

local Addon = {
	-- BASE --
	Active = false; -- should appear in game or be deactivated for now
	Testing = false; -- only appear for tester or above
	
	Name = "Training Wheels";
	
	Image = "rbxassetid://124530714644311"; -- image id
	Color = Color3.fromRGB(56, 46, 43);
	
	Description = "";
	
	
	-- SHOP --
	Killers = { -- killers this addon should show up for | reason for table vs single entry is for killer event addons like blighted serum were 1 addon can show up for mutliple.
		Killer_Storage:WaitForChild("Phantasm")
	},
	
	Data_Name = script.Name;
	Cost = 2000;
	Shop_Chance = 500; -- chance to appear out of 100 in purchasing_slot
	
	-- GAMEPLAY --
}

function Addon.Configure()
	Addon.Description = "Teleporting makes you automatically look at the direction of the Survivor After Image you teleported to."
	
	return Addon
end

return Addon.Configure()
