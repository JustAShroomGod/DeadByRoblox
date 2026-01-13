local Killer_Storage = game:GetService('ReplicatedStorage'):WaitForChild('Game_Data'):WaitForChild('Killers')

local Addon = {
	-- BASE --
	Active = true; -- should appear in game or be deactivated for now
	Testing = false; -- only appear for tester or above
	
	Name = "Chi-mon";
	
	Image = "rbxassetid://99692662411543"; -- image id
	Color = Color3.fromRGB(85, 0, 127);
	
	Description = "";
	
	
	-- SHOP --
	Killers = { -- killers this addon should show up for | reason for table vs single entry is for killer event addons like blighted serum were 1 addon can show up for mutliple.
		Killer_Storage:WaitForChild('Ninja')
	},
	
	Data_Name = script.Name;
	Cost = 5000;
	Shop_Chance = 250; -- chance to appear out of 1000 in purchasing_slot
	
	-- GAMEPLAY --

	Crouch_Speed = 0.25; -- reduction of penality 0.2 -> 0.1
	--Aim_Speed = 0.5; -- reduction to aim speed penalty 0.5 -> 0.25
	--Dash_Gain = 0.15; -- decrease time to full charge
	--Stab_Reduction = 0.1; -- reduction to stab time length
	--Wipe_Reduction = 0.3; -- reduction to wipe time length
	
	--Dash_Speed = 0.5; -- increase speed of dash
	
	--Dash_Minimum = 1; -- increase of minimum dash
	--Dash_Charge = 0.1; -- increase time per charge
}

function Addon.Configure()
	Addon.Description = "Reduce crouch speed penalty by <b><font color='#c2b00e'>"..(Addon.Crouch_Speed * 100).."%.</font></b>"

	return Addon
end

return Addon.Configure()
