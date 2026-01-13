	local Killer_Storage = game:GetService('ReplicatedStorage'):WaitForChild('Game_Data'):WaitForChild('Killers')

local Addon = {
	-- BASE --
	Active = true; -- should appear in game or be deactivated for now
	Testing = false; -- only appear for tester or above

	Name = "True Ghost";

	Image = "rbxassetid://99626635335747"; -- image id
	Color = Color3.fromRGB(255, 0, 0);

	Description = "";


	-- SHOP --
	Killers = { -- killers this addon should show up for | reason for table vs single entry is for killer event addons like blighted serum were 1 addon can show up for mutliple.
		Killer_Storage:WaitForChild('Wraith');
	},

	Data_Name = script.Name;
	Cost = 5000;
	Shop_Chance = 50; -- chance to appear out of 1000 in purchasing_slot

	-- GAMEPLAY --
	Cloak_Boost = -20; -- percent
	Uncloak_Boost = -25;
}

function Addon.Configure()
	Addon.Description = "While cloaked you are fully invisible, but you are <b><font color='#c2b00e'>"..(Addon.Cloak_Boost * -1).."</font></b>% slower in cloak, and your uncloak haste boost is reduced by <b><font color='#c2b00e'>"..(Addon.Uncloak_Boost * -1).."</font></b>%"

	return Addon
end

return Addon.Configure()
