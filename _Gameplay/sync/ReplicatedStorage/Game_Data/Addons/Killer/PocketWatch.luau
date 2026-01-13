local Killer_Storage = game:GetService('ReplicatedStorage'):WaitForChild('Game_Data'):WaitForChild('Killers')

local Addon = {
	-- BASE --
	Active = true; -- should appear in game or be deactivated for now
	Testing = false; -- only appear for tester or above
	
	Name = "Pocket Watch";
	
	Image = "rbxassetid://15153440765"; -- image id
	Color = Color3.fromRGB(56, 46, 43);
	
	Description = "";
	
	
	-- SHOP --
	Killers = { -- killers this addon should show up for | reason for table vs single entry is for killer event addons like blighted serum were 1 addon can show up for mutliple.
		Killer_Storage:WaitForChild('Nurse');
	},
	
	Data_Name = script.Name;
	Cost = 2000;
	Shop_Chance = 1000; -- chance to appear out of 100 in purchasing_slot
	
	-- GAMEPLAY --
	
	Window_Boost = 0.5
}

function Addon.Configure()
	Addon.Description = "Increases time to swing before blink fatigue by <b><font color='#c2b00e'>"..Addon.Window_Boost.."</font></b> seconds."
	
	return Addon
end

return Addon.Configure()
