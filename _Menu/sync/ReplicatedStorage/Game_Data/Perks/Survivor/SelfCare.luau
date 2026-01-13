local Perk = {
	-- BASE --
	Active = true; -- should appear in game or be deactivated for now
	Unlocked = true; -- if this perk should be unlocked for free at this moment if ever

	Name = "Self-Heal";
	Image = "rbxassetid://14497862845"; -- image id
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
	Obsession_Boost = 10; -- 15 = Great, 10 = Signicant, 5 = Slight, 0 = none | can go both way to reduce or increase chance of being obsession;
	-- ^ (optional value if it does not affect obsession chances then you can leave uncommented)

	Tiers = { -- calculated healing speed times
		0.5,
		0.6,
		0.7,
	};

	EffectMedkit = 
		{
			0.95,
			0.90,
			0.85
		},

}

function Perk.Configure()
	Perk.Description = "Unlocks the ability to heal yourself without a medkit at a rate of <b><font color='#0852a6'>"..(Perk.Tiers[1] * 100).."%</font>/<font color='#5007a3'>"..(Perk.Tiers[2] * 100).."%</font>/<font color='#8a060e'>"..(Perk.Tiers[3] * 100).."%</font></b> \nIncreases Medkit efficiency by <b><font color='#0852a6'>"..((Perk.EffectMedkit[1]) * 100).."%</font>/<font color='#5007a3'>"..((Perk.EffectMedkit[2]) * 100).."%</font>/<font color='#8a060e'>"..((Perk.EffectMedkit[3]) * 100).."%</font></b> when healing yourself.  \n<font color='#e60017'>Greatly increases your chance of being the obsession</font> \n<font color='#e60017'>Does not stack with other healing modifiers.</font> "

	return Perk
end

return Perk.Configure()