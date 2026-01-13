local Killer_Storage = game:GetService('ReplicatedStorage'):WaitForChild('Game_Data'):WaitForChild('Killers')

local Addon = {
	-- BASE --
	Active = true; -- should appear in game or be deactivated for now
	Testing = false; -- only appear for tester or above
	
	Name = "Silver Pendant";
	
	Image = "rbxassetid://112889581863244"; -- image id
	Color = Color3.fromRGB(80, 7, 163);
	
	Description = "";
	
	
	-- SHOP --
	Killers = { -- killers this addon should show up for | reason for table vs single entry is for killer event addons like blighted serum were 1 addon can show up for mutliple.
		Killer_Storage:WaitForChild('Nurse');
	},
	
	Data_Name = script.Name;
	Cost = 4000;
	Shop_Chance = 150; -- chance to appear out of 100 in purchasing_slot
	
	-- GAMEPLAY --
	
	Charge_Penalty = 35;
}

function Addon.Configure()
	Addon.Description = "Hitting a Survivor with a Blink Attack will recharge 1 Blink. Decreases blink recharge rate by <b><font color='#c2b00e'>"..Addon.Charge_Penalty.."%</font></b>."
	
	return Addon
end

return Addon.Configure()
