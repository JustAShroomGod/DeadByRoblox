local Killer_Storage = game:GetService('ReplicatedStorage'):WaitForChild('Game_Data'):WaitForChild('Killers')

local Addon = {
	-- BASE --
	Active = true; -- should appear in game or be deactivated for now
	Testing = false; -- only appear for tester or above

	Name = "Kiss of Death";

	Image = "rbxassetid://77993188303575"; -- image id
	Color = Color3.fromRGB(255, 0, 0);

	Description = "";


	-- SHOP --
	Killers = { -- killers this addon should show up for
		Killer_Storage:WaitForChild('Reaper');
	},

	Data_Name = script.Name;
	Cost = 5000;
	Shop_Chance = 150; -- chance to appear out of 100 in purchasing_slot

	-- GAMEPLAY --

	Charges_Gain = 1;
	
}

function Addon.Configure()
	Addon.Description = "Increases the amount of charges you gain when hitting a survivor by <b><font color='#c2b00e'>"..(Addon.Charges_Gain).."</font></b>."

	return Addon
end

return Addon.Configure()
