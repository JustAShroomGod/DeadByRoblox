local Killer_Storage = game:GetService('ReplicatedStorage'):WaitForChild('Game_Data'):WaitForChild('Killers')

local Addon = {
	-- BASE --
	Active = true; -- should appear in game or be deactivated for now
	Testing = false; -- only appear for tester or above
	
	Name = "Trapper Bag";
	
	Image = "rbxassetid://83416158278063"; -- image id
	Color = Color3.fromRGB(56, 46, 43);
	
	Description = "";
	
	
	-- SHOP --
	Killers = { -- killers this addon should show up for
		Killer_Storage:WaitForChild('Trapper');
	},
	
	Data_Name = script.Name;
	Cost = 2000;
	Shop_Chance = 800; -- chance to appear out of 100 in purchasing_slot
	
	-- GAMEPLAY --
	Trap_Boost = 1;
}

function Addon.Configure()
	Addon.Description = "Carry an additional <b><font color='#c2b00e'>"..Addon.Trap_Boost.."</font></b> Trap/Traps."
	
	return Addon
end

return Addon.Configure()
