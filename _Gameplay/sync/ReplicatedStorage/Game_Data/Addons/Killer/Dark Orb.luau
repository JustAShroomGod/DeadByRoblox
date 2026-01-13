local Killer_Storage = game:GetService('ReplicatedStorage'):WaitForChild('Game_Data'):WaitForChild('Killers')

local Addon = {
	-- BASE --
	Active = true; -- should appear in game or be deactivated for now
	Testing = false; -- only appear for tester or above
	
	Name = "Dark Orb";
	
	Image = "rbxassetid://92225433937649"; -- image id
	Color = Color3.fromRGB(255, 0, 0);
	
	Description = "";
	
	
	-- SHOP --
	Killers = { -- killers this addon should show up for | reason for table vs single entry is for killer event addons like blighted serum were 1 addon can show up for mutliple.
		Killer_Storage:WaitForChild("Phantasm")
	},
	
	Data_Name = script.Name;
	Cost = 5000;
	Shop_Chance = 100; -- chance to appear out of 100 in purchasing_slot
	
	-- GAMEPLAY --
	Phantasm_Maximum = 1; --1 per surv
	InstantlySpawn = true --spawns after image on hit and doesn't give darkness
}

function Addon.Configure()
	Addon.Description = "Limits max After Images per survivor to <b><font color='#c2b00e'>"..(Addon.Phantasm_Maximum)..".</font></b>\n.Hitting a Survivor with Wave of Darkness no longer inflicts Darkness on them. Survivors hit by Wave of Darkness spawn an After Image upon contact; after the After Image of the said Survivor has been spawned, you won't be able to hit the said Survivor until the After Image disappears."
	
	return Addon
end

return Addon.Configure()
