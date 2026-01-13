local Killer_Storage = game:GetService('ReplicatedStorage'):WaitForChild('Game_Data'):WaitForChild('Killers')

local Addon = {
	-- BASE --
	Active = true; -- should appear in game or be deactivated for now
	Testing = false; -- only appear for tester or above

	Name = "Soul Fuel";

	Image = ""; -- image id
	Color = Color3.fromRGB(0, 85, 0);

	Description = "";


	-- SHOP --
	Killers = { -- killers this addon should show up for
		Killer_Storage:WaitForChild('Reaper');
	},

	Data_Name = script.Name;
	Cost = 3000;
	Shop_Chance = 700; -- chance to appear out of 100 in purchasing_slot

	-- GAMEPLAY --

	Start_Charges = 4;
}

function Addon.Configure()
	Addon.Description = "Start with 3 more Charges."

	return Addon
end

return Addon.Configure()
