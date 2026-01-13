local Killer_Storage = game:GetService('ReplicatedStorage'):WaitForChild('Game_Data'):WaitForChild('Killers')

local Addon = {
	-- BASE --
	Active = true; -- should appear in game or be deactivated for now
	Testing = false; -- only appear for tester or above
	
	Name = "Fastening Tools";
	
	Image = "rbxassetid://111206914176283"; -- image id
	Color = Color3.fromRGB(85, 0, 127);
	
	Description = "";
	
	
	-- SHOP --
	Killers = { -- killers this addon should show up for
		Killer_Storage:WaitForChild('Trapper');
	},
	
	Data_Name = script.Name;
	Cost = 3000;
	Shop_Chance = 600; -- chance to appear out of 100 in purchasing_slot
	
	-- GAMEPLAY --
	Trap_Boost = 50; --10%
}

function Addon.Configure()
	Addon.Description = "Increases the speed of Placing/Resetting the Bear Trap by <b><font color='#c2b00e'>"..Addon.Trap_Boost.."</font></b>%."
	
	return Addon
end

return Addon.Configure()
