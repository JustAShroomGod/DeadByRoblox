local Killer_Storage = game:GetService('ReplicatedStorage'):WaitForChild('Game_Data'):WaitForChild('Killers')

local Addon = {
	-- BASE --
	Active = true; -- should appear in game or be deactivated for now
	Testing = false; -- only appear for tester or above
	
	Name = "Temper Tantrum";
	
	Image = "rbxassetid://18430123238"; -- image id
	Color = Color3.fromRGB(71, 99, 18);
	
	Description = "";
	
	
	-- SHOP --
	Killers = { -- killers this addon should show up for | reason for table vs single entry is for killer event addons like blighted serum were 1 addon can show up for mutliple.
		Killer_Storage:WaitForChild('Architect')
	},
	
	Data_Name = script.Name;
	Cost = 3500;
	Shop_Chance = 500; -- chance to appear out of 100 in purchasing_slot
	
	-- GAMEPLAY --

	--Rage_Loss = 10.1; -- affect speed at which rage passively goes away
	Rage_Gain = 0.3; -- affects speed at which we gain rage
	--Start_Rage_Increase = 0; -- affect base starting rage (for full start rage build ig)
	Turn_Increase = 0.05; -- affects turn speeds
	--Rage_Speed_Gain = 0; -- affects how much speed we gain per object hit in rage
	--Start_Rage_Speed = 20; -- boost or decreases starting rage
	--Duration_Increase = 250;
}

function Addon.Configure()
	Addon.Description = "Increases the speed of rage recharge by <b><font color='#c2b00e'>"..(Addon.Rage_Gain * 100)..'%.</font></b> and increases turnrate by 10%'
	
	return Addon
end

return Addon.Configure()
