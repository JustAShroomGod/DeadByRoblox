local Killer_Storage = game:GetService('ReplicatedStorage'):WaitForChild('Game_Data'):WaitForChild('Killers')

local Addon = {
	-- BASE --
	Active = true; -- should appear in game or be deactivated for now
	Testing = false; -- only appear for tester or above
	
	Name = "Kenjutsu";
	
	Image = "rbxassetid://97102885410356"; -- image id
	Color = Color3.fromRGB(255,0,0);
	
	Description = "";
	
	
	-- SHOP --
	Killers = { -- killers this addon should show up for | reason for table vs single entry is for killer event addons like blighted serum were 1 addon can show up for mutliple.
		Killer_Storage:WaitForChild('Ninja')
	},
	
	Data_Name = script.Name;
	Cost = 5000;
	Shop_Chance = 5; -- chance to appear out of 1000 in purchasing_slot
	
	-- GAMEPLAY --
	
	
	Dash_Gain = 0.1; -- decrease time to full charge
	Dash_Speed = 0.1; -- increase speed of dash
	CoolDownEffect = 0.05
}

function Addon.Configure()
	Addon.Description = "Increases Dash charge speed by <b><font color='#c2b00e'>"..(Addon.Dash_Gain * 100).."%</font></b> \nIncreases the speed of a Dash by <b><font color='#c2b00e'>"..(Addon.Dash_Speed * 100).."%</font></b>  \nDecreases Dash cooldown by <b><font color='#c2b00e'>"..(Addon.CoolDownEffect * 100).."% </font></b>"

	return Addon
end

return Addon.Configure()
