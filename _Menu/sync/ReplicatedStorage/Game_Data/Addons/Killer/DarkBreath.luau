local Killer_Storage = game:GetService('ReplicatedStorage'):WaitForChild('Game_Data'):WaitForChild('Killers')

local Addon = {
	-- BASE --
	Active = false; -- should appear in game or be deactivated for now
	Testing = false; -- only appear for tester or above
	
	Name = "Dark Breath";
	
	Image = "rbxassetid://9637320889"; -- image id
	Color = Color3.fromRGB(255, 0, 0);
	
	Description = "";
	
	
	-- SHOP --
	Killers = { -- killers this addon should show up for | reason for table vs single entry is for killer event addons like blighted serum were 1 addon can show up for mutliple.
		Killer_Storage:WaitForChild('Nurse');
	},
	
	Data_Name = script.Name;
	Cost = 5000;
	Shop_Chance = 6; -- chance to appear out of 100 in purchasing_slot
	
	-- GAMEPLAY --
	Recharge_Penalty = 65;
	
}

function Addon.Configure()
	Addon.Description = "Hitting a Survivor with a Blink Attack will immediately put them in the <b><font color='#c2b00e'> dying state.</font></b> Sets Maximum Blinks to 1. Decreases the rate of blink recharge by <b><font color='#c2b00e'>"..Addon.Recharge_Penalty..'%</font></b>.'
	
	return Addon
end

return Addon.Configure()
