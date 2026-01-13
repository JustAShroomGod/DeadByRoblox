local Killer_Storage = game:GetService('ReplicatedStorage'):WaitForChild('Game_Data'):WaitForChild('Killers')

local Addon = {
	-- BASE --
	Active = true; -- should appear in game or be deactivated for now
	Testing = false; -- only appear for tester or above
	
	Name = "Anxiety Pills";
	
	Image = "rbxassetid://121762303250802"; -- image id
	Color = Color3.fromRGB(0, 85, 0);
	
	Description = "";
	
	
	-- SHOP --
	Killers = { -- killers this addon should show up for | reason for table vs single entry is for killer event addons like blighted serum were 1 addon can show up for mutliple.
		Killer_Storage:WaitForChild("Phantasm")
	},
	
	Data_Name = script.Name;
	Cost = 3000;
	Shop_Chance = 350; -- chance to appear out of 100 in purchasing_slot
	
	-- GAMEPLAY --
	Phantasm_Frequency = 2.25 --current halfed
}

function Addon.Configure()
	Addon.Description = "The time it takes for a Survivor to place an After Image while infected is reduced to <b><font color='#c2b00e'>"..(Addon.Phantasm_Frequency) .. "</font></b> seconds."
	
	return Addon
end

return Addon.Configure()
