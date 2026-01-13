local Killer_Storage = game:GetService('ReplicatedStorage'):WaitForChild('Game_Data'):WaitForChild('Killers')

local Addon = {
	-- BASE --
	Active = true; -- should appear in game or be deactivated for now
	Testing = false; -- only appear for tester or above
	
	Name = "Lighter Sledge";
	
	Image = "rbxassetid://18304651481"; -- image id
	Color = Color3.fromRGB(56, 46, 43);
	
	Description = "";
	
	
	-- SHOP --
	Killers = { -- killers this addon should show up for | reason for table vs single entry is for killer event addons like blighted serum were 1 addon can show up for mutliple.
		Killer_Storage:WaitForChild('Architect')
	},
	
	Data_Name = script.Name;
	Cost = 2000;
	Shop_Chance = 1000; -- chance to appear out of 100 in purchasing_slot
	
	-- GAMEPLAY --
	
	--Rage_Loss = 10.1; -- affect speed at which rage passively goes away
	--Rage_Gain = 10.1; -- affects speed at which we gain rage
	--Start_Rage_Increase = 0; -- affect base starting rage (for full start rage build ig)
	--Duration_Increase = 5000; -- affect max capped rage (secondary duration, but punishing as well due to taking longer to build up)
	Turn_Increase = 0.15; -- affects turn speeds
	--Rage_Speed_Gain = 0; -- affects how much speed we gain per object hit in rage
	--Start_Rage_Speed = 20; -- boost or decreases starting rage
}

function Addon.Configure()
	Addon.Description = "Increases your turn rate/speed by <b><font color='#c2b00e'>"..(Addon.Turn_Increase * 100)..'%.</font></b>'
	
	return Addon
end

return Addon.Configure()
