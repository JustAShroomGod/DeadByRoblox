local Killer_Storage = game:GetService('ReplicatedStorage'):WaitForChild('Game_Data'):WaitForChild('Killers')

local Addon = {
	-- BASE --
	Active = true; -- should appear in game or be deactivated for now
	Testing = false; -- only appear for tester or above
	
	Name = "Remnant From The Past";
	
	Image = "rbxassetid://72522461846949"; -- image id
	Color = Color3.fromRGB(255, 0, 0);
	
	Description = "";
	
	
	-- SHOP --
	Killers = { -- killers this addon should show up for | reason for table vs single entry is for killer event addons like blighted serum were 1 addon can show up for mutliple.
		Killer_Storage:WaitForChild("Phantasm")
	},
	
	Data_Name = script.Name;
	Cost = 5000;
	Shop_Chance = 30; -- chance to appear out of 100 in purchasing_slot
	
	-- GAMEPLAY --
	Phantasm_Lifetime = 60; --secs
	Wave_Recharge = 8; --half of the current
}

function Addon.Configure()
	Addon.Description = "Activating Dark Presence now creates an After Image after you instead of sending out Darkness.In addition to this, Dark Presence charges up twice as slow. Those images disappear after <b><font color='#c2b00e'>".. Addon.Phantasm_Lifetime .. "</font></b> seconds."
	
	return Addon
end

return Addon.Configure()
