local Killer_Storage = game:GetService('ReplicatedStorage'):WaitForChild('Game_Data'):WaitForChild('Killers')

local Addon = {
	-- BASE --
	Active = true; -- should appear in game or be deactivated for now
	Testing = false; -- only appear for tester or above
	
	Name = "Poltergeist In A Jar";
	
	Image = "rbxassetid://117322857711915"; -- image id
	Color = Color3.fromRGB(85, 0, 127);
	
	Description = "";
	
	
	-- SHOP --
	Killers = { -- killers this addon should show up for | reason for table vs single entry is for killer event addons like blighted serum were 1 addon can show up for mutliple.
		Killer_Storage:WaitForChild("Phantasm")
	},
	
	Data_Name = script.Name;
	Cost = 4000;
	Shop_Chance = 300; -- chance to appear out of 100 in purchasing_slot

	-- GAMEPLAY --
	
	Interactable_Block_Duration = 5;--secs (TODO: add pallets blocking too since its only windows for now.)
	Wave_Recharge = 8; --half of the current
}

function Addon.Configure()
	Addon.Description = "Can no longer infect Survivors. \n Any window that gets hit by the Wave gets blocked for <b><font color='#c2b00e'>".. Addon.Interactable_Block_Duration .. "</font></b> seconds; additionally Dark Presence charges up twice as slow."
	
	return Addon
end

return Addon.Configure()
