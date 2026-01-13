local Killer_Storage = game:GetService('ReplicatedStorage'):WaitForChild('Game_Data'):WaitForChild('Killers')

local Addon = {
	-- BASE --
	Active = true; -- should appear in game or be deactivated for now
	Testing = false; -- only appear for tester or above
	
	Name = "Cold Touch";
	
	Image = "rbxassetid://14859003686"; -- image id
	Color = Color3.fromRGB(56, 46, 43);
	
	Description = "";
	
	
	-- SHOP --
	Killers = { -- killers this addon should show up for
		Killer_Storage:WaitForChild('Reaper');
	},
	
	Data_Name = script.Name;
	Cost = 2000;
	Shop_Chance = 900; -- chance to appear out of 100 in purchasing_slot
	
	-- GAMEPLAY --
	
	Slam_Speed_Boost = 0.15;
}

function Addon.Configure()
	Addon.Description = "Increases the speed of the soul-bind animation by <b><font color='#c2b00e'>"..(Addon.Slam_Speed_Boost * 100).."%</font></b>."
	
	return Addon
end

return Addon.Configure()
