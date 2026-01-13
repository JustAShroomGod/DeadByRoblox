local Perk = {
	-- BASE --
	Active = true; -- should appear in game or be deactivated for now
	Unlocked = true; -- if this perk should be unlocked for free at this moment if ever
	Testing = false; -- only appear for tester or above
	
	Name = "Assassin";
	Image = "rbxassetid://14497862138"; -- image id
	Colors = {
		Color3.fromRGB(6, 62, 125); -- color associated with images
		Color3.fromRGB(80, 7, 163); -- color associated with images
		Color3.fromRGB(138, 6, 14); -- color associated with images
	},
	
	Description = "";

	-- SHOP --
	Gamepasses = {}; -- gamepass id's that unlock this perk automatically
	
	-- BLOOD SHOP --
	Data_Name = script.Name;
	Cost = {
		3000,
		5000,
		7000,
	},
	
	-- GAMEPLAY --

	Tiers = { -- calculated crouch boost
		1.5,
		1.6,
		1.7,
	};
}

function Perk.Configure()
	Perk.Description = "Allows you to crouch walk <b><font color='#0852a6'>".. math.round((Perk.Tiers[1] - 1) * 100) .."</font>/<font color='#5007a3'>".. math.round((Perk.Tiers[2] - 1) * 100) .."</font>/<font color='#8a060e'>".. math.round((Perk.Tiers[3] - 1) * 100) .."</font></b>% faster."
	
	return Perk
end

return Perk.Configure()
