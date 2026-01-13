local Perk = {
	-- BASE --
	Active = true; -- should appear in game or be deactivated for now
	Testing = false; -- only appear for tester or above
	Unlocked = true; -- if this perk should be unlocked for free at this moment if ever

	Name = "Ruthless";
	Image = "rbxassetid://18462272991"; -- image id
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

	Tiers_Air = {
		20,
		25,
		30,
	},

	Tiers_Hit = {
		10,
		15,
		20
	},
}

function Perk.Configure()
	Perk.Description = "After swinging your miss cooldown is reduced by <b><font color='#0852a6'>"..Perk.Tiers_Air[1].."</font>/<font color='#5007a3'>"..Perk.Tiers_Air[2].."</font>/<font color='#8a060e'>"..Perk.Tiers_Air[3].."</font></b>% and your successful attack cooldown is decreased by <b><font color='#0852a6'>"..Perk.Tiers_Hit[1].."</font>/<font color='#5007a3'>"..Perk.Tiers_Hit[2].."</font>/<font color='#8a060e'>"..Perk.Tiers_Hit[3].."</font></b>%."

	return Perk
end

return Perk.Configure()
