local Killer_Storage = game:GetService('ReplicatedStorage'):WaitForChild('Game_Data'):WaitForChild('Killers')

local Addon = {
	-- BASE --
	Active = true; -- should appear in game or be deactivated for now
	Testing = false; -- only appear for tester or above
	
	Name = "Rusted Blade";
	
	Image = "rbxassetid://103149586079717"; -- image id
	Color = Color3.fromRGB(0, 85, 0);
	
	Description = "rbxassetid://104309672430952";
	
	
	-- SHOP --
	Killers = { -- killers this addon should show up for | reason for table vs single entry is for killer event addons like blighted serum were 1 addon can show up for mutliple.
		Killer_Storage:WaitForChild('Psychopath')
	},
	
	Data_Name = script.Name;
	Cost = 3000;
	Shop_Chance = 750; -- chance to appear out of 100 in purchasing_slot
	
	-- GAMEPLAY --
	
	PlayerHit_Increase = 25; --/90 * 100 to get the % (considering 90 is the base max value)
}

function Addon.Configure()
	Addon.Description = "Increase the amount of Blood Rage you recieve when hitting a survivor by <b><font color='#c2b00e'>".. math.round((Addon.PlayerHit_Increase / 100) * 100) .."%</font></b>."
	
	return Addon
end

return Addon.Configure()
