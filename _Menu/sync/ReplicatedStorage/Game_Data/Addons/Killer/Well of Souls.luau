local Killer_Storage = game:GetService('ReplicatedStorage'):WaitForChild('Game_Data'):WaitForChild('Killers')

local Addon = {
	-- BASE --
	Active = true; -- should appear in game or be deactivated for now
	Testing = false; -- only appear for tester or above
	
	Name = "Well of Souls";
	
	Image = "rbxassetid://87551390153404"; -- image id
	Color = Color3.fromRGB(85, 0, 127);
	
	Description = "";
	
	
	-- SHOP --
	Killers = { -- killers this addon should show up for
		Killer_Storage:WaitForChild('Reaper');
	},
	
	Data_Name = script.Name;
	Cost = 4000;
	Shop_Chance = 400; -- chance to appear out of 100 in purchasing_slot
	
	-- GAMEPLAY --
	
	Radius_Increase = 0.3;
}

function Addon.Configure()
	Addon.Description = "Increases the size of your power's shockwave by <b><font color='#c2b00e'>"..(Addon.Radius_Increase * 100).."%</font></b>."
	
	return Addon
end

return Addon.Configure()
