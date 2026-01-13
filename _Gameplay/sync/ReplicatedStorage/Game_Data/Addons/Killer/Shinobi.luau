local Killer_Storage = game:GetService('ReplicatedStorage'):WaitForChild('Game_Data'):WaitForChild('Killers')

local Addon = {
	-- BASE --
	Active = true; -- should appear in game or be deactivated for now
	Testing = false; -- only appear for tester or above
	
	Name = "Shinobi-iri";
	
	Image = "rbxassetid://120637848674888"; -- image id
	Color = Color3.fromRGB(255, 0, 0);
	
	Description = "";
	
	
	-- SHOP --
	Killers = { -- killers this addon should show up for | reason for table vs single entry is for killer event addons like blighted serum were 1 addon can show up for mutliple.
		Killer_Storage:WaitForChild('Ninja')
	},
	
	Data_Name = script.Name;
	Cost = 4000;
	Shop_Chance = 30; -- chance to appear out of 1000 in purchasing_slot
	
	-- GAMEPLAY --
	
	Radius = 56; -- half of terror radius range
	Crouch_Speed = 0.15; -- reduction of penality 0.2 -> 0.1
	--Dash_Gain = 0.3;
	--Rage_Loss = 10.1; -- affect speed at which rage passively goes away
}

function Addon.Configure()
	Addon.Description = "Reduce crouch speed penalty by <b><font color='#c2b00e'>"..(Addon.Crouch_Speed * 100).."%</font></b> and View Survivor Aura's when in stealth mode up to <b><font color='#c2b00e'>"..(Addon.Radius/2).."</font></b> studs away."
	
	return Addon
end

return Addon.Configure()
