local Killer_Storage = game:GetService('ReplicatedStorage'):WaitForChild('Game_Data'):WaitForChild('Killers')

local Addon = {
	-- BASE --
	Active = true; -- should appear in game or be deactivated for now
	Testing = false; -- only appear for tester or above
	
	Name = "Rocket Fuel";
	
	Image = "rbxassetid://135839403202895"; -- image id
	Color = Color3.fromRGB(255,0,0);
	
	Description = "";
	
	
	-- SHOP --
	Killers = { -- killers this addon should show up for | reason for table vs single entry is for killer event addons like blighted serum were 1 addon can show up for mutliple.
		Killer_Storage:WaitForChild('Hillbilly');
	},
	
	Data_Name = script.Name;
	Cost = 5000;
	Shop_Chance = 150; -- chance to appear out of 100 in purchasing_slot
	
	-- GAMEPLAY --
	
	Sprint_Boost = 200; -- boost
	
	Chainsaw_Refuel = -25; -- additional cd chainsaw use
	
	Hitbox = 0; -- multiply by amount
	

	Sprint_Turn_Power_Increase = 300;
	Sprint_Turn_Increase = 300;
}

function Addon.Configure()
	Addon.Description = "Increases chainsaw sprint speed by <b><font color='#c2b00e'>"..Addon.Sprint_Boost.."%</font></b>,removes all chainsaw collisions, and increases the cooldown between chainsaw sprints by <b><font color='#c2b00e'>"..-Addon.Chainsaw_Refuel.."</font></b>%"
	
	return Addon
end

return Addon.Configure()
