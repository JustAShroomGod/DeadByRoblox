local Killer_Storage = game:GetService('ReplicatedStorage'):WaitForChild('Game_Data'):WaitForChild('Killers')

local Addon = {
	-- BASE --
	Active = true; -- should appear in game or be deactivated for now
	Testing = false; -- only appear for tester or above
	
	Name = "Bōryaku";
	
	Image = "rbxassetid://124302729790726"; -- image id
	Color = Color3.fromRGB(0, 85, 0);
	
	Description = "";
	
	
	-- SHOP --
	Killers = { -- killers this addon should show up for | reason for table vs single entry is for killer event addons like blighted serum were 1 addon can show up for mutliple.
		Killer_Storage:WaitForChild('Ninja')
	},
	
	Data_Name = script.Name;
	Cost = 3000;
	Shop_Chance = 125; -- chance to appear out of 1000 in purchasing_slot
	
	-- GAMEPLAY --
	
	Dash_Minimum = 0.3; -- increase of minimum dash
	Aim_Speed = 0.1; -- reduction to aim speed penalty 0.5 -> 0.25
	Stab_Reduction = 0.1; -- reduction to stab time length
	Wipe_Reduction = 0.15; -- reduction to wipe time length
	--Dash_Gain = 0.15; -- decrease time to full charge
	--Crouch_Speed = 0.5; -- reduction of penality 0.2 -> 0.1
	--Dash_Gain = 0.15; -- decrease time to full charge
	--Dash_Charge = 0.1; -- increase time per charge
	--Dash_Speed = 0.5; -- increase speed of dash
	--Rage_Loss = 10.1; -- affect speed at which rage passively goes away
}

function Addon.Configure()
	Addon.Description = "Increase distance of minimum dashes by <b><font color='#c2b00e'>"..(Addon.Dash_Minimum * 100).."%</font></b>, Reduce speed penalty from power use by <b><font color='#c2b00e'>"..(Addon.Aim_Speed * 100).."%</font></b>, and Decrease the length of wipe cooldowns by <b><font color='#c2b00e'>"..(Addon.Wipe_Reduction * 100).."%</font></b>."
	
	return Addon
end

return Addon.Configure()
