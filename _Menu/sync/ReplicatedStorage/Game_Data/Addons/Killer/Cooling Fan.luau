local Killer_Storage = game:GetService('ReplicatedStorage'):WaitForChild('Game_Data'):WaitForChild('Killers')

local Addon = {
	-- BASE --
	Active = true; -- should appear in game or be deactivated for now
	Testing = false; -- only appear for tester or above
	
	Name = "Cooling Fan";
	
	Image = "rbxassetid://70911080193628"; -- image id
	Color = Color3.fromRGB(0, 85, 0);
	
	Description = "";
	
	
	-- SHOP --
	Killers = { -- killers this addon should show up for | reason for table vs single entry is for killer event addons like blighted serum were 1 addon can show up for mutliple.
		Killer_Storage:WaitForChild('Hillbilly');
	},
	
	Data_Name = script.Name;
	Cost = 3000;
	Shop_Chance = 500; -- chance to appear out of 100 in purchasing_slot
	
	-- GAMEPLAY --

	--Flick_Turn_Power_Increase = 20;
	--Flick_Turn_Increase = 20;
	
	--Hitbox = 0; -- multiply by amount
	Sprint_Turn_Increase = 30;
}

function Addon.Configure()
	Addon.Description = "Increases Chainsaw turn rate by <b><font color='#c2b00e'>"..Addon.Sprint_Turn_Increase.."%</font></b>"
	
	return Addon
end

return Addon.Configure()
