local Killer_Storage = game:GetService('ReplicatedStorage'):WaitForChild('Game_Data'):WaitForChild('Killers')

local Addon = {
	-- BASE --
	Active = true; -- should appear in game or be deactivated for now
	Testing = false; -- only appear for tester or above

	Name = "Bloody Shoes";

	Image = "rbxassetid://88815648476405"; -- image id
	Color = Color3.fromRGB(85, 0, 127);

	Description = "";


	-- SHOP --
	Killers = { -- killers this addon should show up for | reason for table vs single entry is for killer event addons like blighted serum were 1 addon can show up for mutliple.
		Killer_Storage:WaitForChild('Psychopath')
	},

	Data_Name = script.Name;
	Cost = 4000;
	Shop_Chance = 700; -- chance to appear out of 100 in purchasing_slot

	-- GAMEPLAY --

	Speed = 1
}

function Addon.Configure()
	Addon.Description = "Increases movement speed by <b><font color='#c2b00e'>"..(Addon.Speed + 5).."%</font></b>. "

	return Addon
end

return Addon.Configure()