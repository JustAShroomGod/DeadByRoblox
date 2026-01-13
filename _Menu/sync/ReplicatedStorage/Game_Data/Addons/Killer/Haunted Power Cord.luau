local Killer_Storage = game:GetService('ReplicatedStorage'):WaitForChild('Game_Data'):WaitForChild('Killers')

local Addon = {
	-- BASE --
	Active = true; -- should appear in game or be deactivated for now
	Testing = false; -- only appear for tester or above
	
	Name = "Haunted Power Cord";
	
	Image = "rbxassetid://91692252543250"; -- image id
	Color = Color3.fromRGB(85, 0, 127);
	
	Description = "";
	
	
	-- SHOP --
	Killers = { -- killers this addon should show up for | reason for table vs single entry is for killer event addons like blighted serum were 1 addon can show up for mutliple.
		Killer_Storage:WaitForChild("Phantasm")
	},
	
	Data_Name = script.Name;
	Cost = 4000;
	Shop_Chance = 250; -- chance to appear out of 100 in purchasing_slot

	-- GAMEPLAY --
	Amount_Spawned = 2;
	Distance_From_Generator = 25; --studs
}

function Addon.Configure()
	Addon.Description = "Every time you hook a Survivor <b><font color='#c2b00e'>"..(Addon.Amount_Spawned)..".</font></b> random After Images will spawn by uncompleted Generators in a <b><font color='#c2b00e'>"..(Addon.Distance_From_Generator)..".</font></b> stud radius."

	return Addon
end

return Addon.Configure()
