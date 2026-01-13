local Killer_Storage = game:GetService('ReplicatedStorage'):WaitForChild('Game_Data'):WaitForChild('Killers')

local Addon = {
	-- BASE --
	Active = true; -- should appear in game or be deactivated for now
	Testing = false; -- only appear for tester or above
	
	Name = "Iridescent Stone";
	
	Image = "rbxassetid://18566609526"; -- image id
	Color = Color3.fromRGB(255, 0, 0);
	
	Description = "";
	
	-- SHOP --
	Killers = { -- killers this addon should show up for
		Killer_Storage:WaitForChild('Trapper');
	},
	
	Data_Name = script.Name;
	Cost = 5000;
	Shop_Chance = 50; -- chance to appear out of 100 in purchasing_slot
	
	-- GAMEPLAY --
	Reset_Time = 35;
}

function Addon.Configure()
	Addon.Description = "Automatically resets an inactive Trap after <b><font color='#c2b00e'>"..Addon.Reset_Time..'</font></b> '
	
	return Addon
end

return Addon.Configure()
