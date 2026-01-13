local Killer_Storage = game:GetService('ReplicatedStorage'):WaitForChild('Game_Data'):WaitForChild('Killers')

local Addon = {
	-- BASE --
	Active = true; -- should appear in game or be deactivated for now
	Testing = false; -- only appear for tester or above
	
	Name = "Infantry Belt";
	
	Image = "rbxassetid://97471434520270"; -- image id
	Color = Color3.fromRGB(80, 7, 163);
	
	Description = "";
	
	
	-- SHOP --
	Killers = { -- killers this addon should show up for | reason for table vs single entry is for killer event addons like blighted serum were 1 addon can show up for mutliple.
		Killer_Storage:WaitForChild('Huntress');
	},
	
	Data_Name = script.Name;
	Cost = 3000;
	Shop_Chance = 500; -- chance to appear out of 100 in purchasing_slot
	
	-- GAMEPLAY --
	
	Hatchet_Boost = 2;
}

function Addon.Configure()
	Addon.Description = "Increases Hatchet capacity by <b><font color='#c2b00e'>"..Addon.Hatchet_Boost.."</font></b>."
	
	return Addon
end

return Addon.Configure()
