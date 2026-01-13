local Killer_Storage = game:GetService('ReplicatedStorage'):WaitForChild('Game_Data'):WaitForChild('Killers')

local Addon = {
	-- BASE --
	Active = true; -- should appear in game or be deactivated for now
	Testing = false; -- only appear for tester or above
	
	Name = "Trapper Sack";
	
	Image = "rbxassetid://133206383010119"; -- image id
	Color = Color3.fromRGB(0, 85, 0);
	
	Description = "";
	
	
	-- SHOP --
	Killers = { -- killers this addon should show up for
		Killer_Storage:WaitForChild('Trapper');
	},
	
	Data_Name = script.Name;
	Cost = 3000;
	Shop_Chance = 450; -- chance to appear out of 100 in purchasing_slot
	
	-- GAMEPLAY --
	Trap_Boost = 2;
}

function Addon.Configure()
	Addon.Description = "Carry an additional <b><font color='#c2b00e'>"..Addon.Trap_Boost.."</font></b> Trap/Traps."
	
	return Addon
end

return Addon.Configure()
