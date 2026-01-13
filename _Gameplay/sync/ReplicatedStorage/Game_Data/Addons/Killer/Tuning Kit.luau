local Killer_Storage = game:GetService('ReplicatedStorage'):WaitForChild('Game_Data'):WaitForChild('Killers')

local Addon = {
	-- BASE --
	Active = true; -- should appear in game or be deactivated for now
	Testing = false; -- only appear for tester or above
	
	Name = "Tuning Kit";
	
	Image = "rbxassetid://114818216941788"; -- image id
	Color = Color3.fromRGB(255, 0, 0);
	
	Description = "";
	
	
	-- SHOP --
	Killers = { -- killers this addon should show up for | reason for table vs single entry is for killer event addons like blighted serum were 1 addon can show up for mutliple.
		Killer_Storage:WaitForChild('Hillbilly');
	},
	
	Data_Name = script.Name;
	Cost = 5000;
	Shop_Chance = 100; -- chance to appear out of 100 in purchasing_slot
	
	-- GAMEPLAY --

	Sprint_Boost = 25;
	Charge_Gain = 120;
	Chainsaw_Refuel = 120;
	Animation = -50;
	
}

function Addon.Configure()
	Addon.Description = "Increases speed of the chainsaw sprint by <b><font color='#c2b00e'>"..(Addon.Sprint_Boost).."%</font></b> \nIncreases Charge speed of the Chainsaw by <b><font color='#c2b00e'>"..(Addon.Charge_Gain / 10).."%</font></b> \nDecreases Chainsaw cooldown by <b><font color='#c2b00e'>"..(Addon.Chainsaw_Refuel / 10).."%</font></b> \nIncreases the time of crashing and ending the Chainsaw by <b><font color='#c2b00e'>"..(Addon.Animation * -1).."%</font></b>"
	
	return Addon
end

return Addon.Configure()
