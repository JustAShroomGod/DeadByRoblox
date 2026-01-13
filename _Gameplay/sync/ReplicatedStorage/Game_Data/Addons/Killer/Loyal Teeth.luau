local Killer_Storage = game:GetService('ReplicatedStorage'):WaitForChild('Game_Data'):WaitForChild('Killers')

local Addon = {
	-- BASE --
	Active = true; -- should appear in game or be deactivated for now
	Testing = false; -- only appear for tester or above

	Name = "Loyal Teeth";

	Image = "rbxassetid://16579099419"; -- image id
	Color = Color3.fromRGB(0, 85, 0);

	Description = "";


	-- SHOP --
	Killers = { -- killers this addon should show up for | reason for table vs single entry is for killer event addons like blighted serum were 1 addon can show up for mutliple.
		Killer_Storage:WaitForChild('Trapper');
	},

	Data_Name = script.Name;
	Cost = 3000;
	Shop_Chance = 30; -- chance to appear out of 1000 in purchasing_slot
}

function Addon.Configure()
	Addon.Description = "Traps now completely ignore you allowing you to walk over them without disarming them or being stunned."

	return Addon
end

return Addon.Configure()
