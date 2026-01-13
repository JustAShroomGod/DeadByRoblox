local Killer_Storage = game:GetService('ReplicatedStorage'):WaitForChild('Game_Data'):WaitForChild('Killers')

local Addon = {
	-- BASE --
	Active = true; -- should appear in game or be deactivated for now
	Testing = false; -- only appear for tester or above
	
	Name = "Tune Up";
	
	Image = "rbxassetid://120826584489469"; -- image id
	Color = Color3.fromRGB(85, 0, 127);
	
	Description = "";
	
	
	-- SHOP --
	Killers = { -- killers this addon should show up for | reason for table vs single entry is for killer event addons like blighted serum were 1 addon can show up for mutliple.
		Killer_Storage:WaitForChild('Hillbilly');
	},
	
	Data_Name = script.Name;
	Cost = 4000;
	Shop_Chance = 50; -- chance to appear out of 100 in purchasing_slot
	
	-- GAMEPLAY --

	Flick_Turn_Power_Increase = 100;
	Flick_Turn_Increase = 40;
}

function Addon.Configure()
	Addon.Description = "Increases power of the chainsaw flick-window by <b><font color='#c2b00e'>"..Addon.Flick_Turn_Increase.."%</font></b>."
	
	return Addon
end

return Addon.Configure()
