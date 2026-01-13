local Killer_Storage = game:GetService('ReplicatedStorage'):WaitForChild('Game_Data'):WaitForChild('Killers')

local Addon = {
	-- BASE --
	Active = true; -- should appear in game or be deactivated for now
	Testing = false; -- only appear for tester or above

	Name = "Ataxic Respiration";

	Image = "rbxassetid://110424942690215"; -- image id
	Color = Color3.fromRGB(29, 120, 39);

	Description = "";


	-- SHOP --
	Killers = { -- killers this addon should show up for | reason for table vs single entry is for killer event addons like blighted serum were 1 addon can show up for mutliple.
		Killer_Storage:WaitForChild('Nurse');
	},

	Data_Name = script.Name;
	Cost = 2000;
	Shop_Chance = 100; -- chance to appear out of 1000 in purchasing_slot

	-- GAMEPLAY --
	
	Recharge_Boost = 25;
}

function Addon.Configure()
	Addon.Description = "Increases the rate of blink recharge by <b><font color='#c2b00e'>"..Addon.Recharge_Boost..'%</font></b>.'

	return Addon
end

return Addon.Configure()
