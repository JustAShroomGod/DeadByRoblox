local Killer_Storage = game:GetService('ReplicatedStorage'):WaitForChild('Game_Data'):WaitForChild('Killers')

local Addon = {
	-- BASE --
	Active = true; -- should appear in game or be deactivated for now
	Testing = false; -- only appear for tester or above
	
	Name = "Pocket of Souls";
	
	Image = "rbxassetid://118814164896712"; -- image id
	Color = Color3.fromRGB(56, 46, 43);
	
	Description = "";
	
	
	-- SHOP --
	Killers = { -- killers this addon should show up for
		Killer_Storage:WaitForChild('Reaper');
	},
	
	Data_Name = script.Name;
	Cost = 2000;
	Shop_Chance = 1000; -- chance to appear out of 100 in purchasing_slot
	
	-- GAMEPLAY --

	Duration_Increase = 0.5;
}

function Addon.Configure()
	Addon.Description = "Increases the duration of the soul-bound effect to be <b><font color='#c2b00e'>"..(Addon.Duration_Increase * 100).."%</font></b> longer."

	return Addon
end

return Addon.Configure()