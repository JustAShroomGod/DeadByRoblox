local Killer_Storage = game:GetService('ReplicatedStorage'):WaitForChild('Game_Data'):WaitForChild('Killers')

local Addon = {
	-- BASE --
	Active = true; -- should appear in game or be deactivated for now
	Testing = false; -- only appear for tester or above
	
	Name = "Heart Locket";
	
	Image = "rbxassetid://130963575902560"; -- image id
	Color = Color3.fromRGB(0, 85, 0);
	
	Description = "";
	
	
	-- SHOP --
	Killers = { -- killers this addon should show up for | reason for table vs single entry is for killer event addons like blighted serum were 1 addon can show up for mutliple.
		Killer_Storage:WaitForChild('Stalker');
	},
	
	Data_Name = script.Name;
	Cost = 3000;
	Shop_Chance = 600; -- chance to appear out of 100 in purchasing_slot
	
	-- GAMEPLAY --
	
	Stalk_Gain = 0.3;
}

function Addon.Configure()
	Addon.Description = "Increases the stalk gained by <b><font color='#c2b00e'>"..(Addon.Stalk_Gain * 100).."%</font></b>."
	
	return Addon
end

return Addon.Configure()
