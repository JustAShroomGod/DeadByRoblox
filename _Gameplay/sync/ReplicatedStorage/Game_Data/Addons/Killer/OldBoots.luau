local Killer_Storage = game:GetService('ReplicatedStorage'):WaitForChild('Game_Data'):WaitForChild('Killers')

local Addon = {
	-- BASE --
	Active = true; -- should appear in game or be deactivated for now
	Testing = false; -- only appear for tester or above
	
	Name = "Old Boots";
	
	Image = "rbxassetid://127663089440191"; -- image id
	Color = Color3.fromRGB(56, 46, 43);
	
	Description = "";
	
	
	-- SHOP --
	Killers = { -- killers this addon should show up for | reason for table vs single entry is for killer event addons like blighted serum were 1 addon can show up for mutliple.
		Killer_Storage:WaitForChild('Hillbilly');
	},
	
	Data_Name = script.Name;
	Cost = 2000;
	Shop_Chance = 900; -- chance to appear out of 100 in purchasing_slot
	
	-- GAMEPLAY --

	--Flick_Turn_Power_Increase = 20;
	--Flick_Turn_Increase = 20;
	
	--Hitbox = 0; -- multiply by amount
	Crash_Decrease = 50;
}

function Addon.Configure()
	Addon.Description = "Decreases Chainsaw crash time by <b><font color='#c2b00e'>"..Addon.Crash_Decrease.."%</font></b>"
	
	return Addon
end

return Addon.Configure()
