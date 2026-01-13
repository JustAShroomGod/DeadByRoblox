local Killer_Storage = game:GetService('ReplicatedStorage'):WaitForChild('Game_Data'):WaitForChild('Killers')

local Addon = {
	-- BASE --
	Active = true; -- should appear in game or be deactivated for now
	Testing = false; -- only appear for tester or above
	
	Name = "Bajutsu";
	
	Image = "rbxassetid://137778879494449"; -- image id
	Color = Color3.fromRGB(0, 85, 0);
	
	Description = "";
	
	
	-- SHOP --
	Killers = { -- killers this addon should show up for | reason for table vs single entry is for killer event addons like blighted serum were 1 addon can show up for mutliple.
		Killer_Storage:WaitForChild('Ninja')
	},
	
	Data_Name = script.Name;
	Cost = 3000;
	Shop_Chance = 250; -- chance to appear out of 1000 in purchasing_slot
	
	-- GAMEPLAY --
	
	CoolDownEffect = 0.20
}

function Addon.Configure()
	Addon.Description = "Decreases Dash cooldown by <b><font color='#c2b00e'>"..(Addon.CoolDownEffect * 100).."%</font></b>" 
	
	return Addon
end

return Addon.Configure()
