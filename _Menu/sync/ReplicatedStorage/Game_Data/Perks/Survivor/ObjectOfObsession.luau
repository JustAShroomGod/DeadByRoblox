local Perk = {
	-- BASE --
	Active = true; -- should appear in game or be deactivated for now
	Unlocked = true; -- if this perk should be unlocked for free at this moment if ever
	
	Name = "Dark Connection";
	Image = "rbxassetid://14389546188"; -- image id
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
	Obsession_Boost = 15; -- 15 = Great, 10 = Signicant, 5 = Slight, 0 = none | can go both way to reduce or increase chance of being obsession;
	-- ^ (optional value if it does not affect obsession chances then you can leave uncommented)
	
	Tiers = {
		108;
		116;
		124;
	},
	
	Min_Distance = 10;
	
	Obsession_Bonus = 20;
}

function Perk.Configure()
	Perk.Description = "When the killer is <b><font color='#c2b00e'>"..Perk.Min_Distance.."</font></b> studs away and not hidden from auras, looking in their direction will reveal them to distances up to <b><font color='#0852a6'>"..Perk.Tiers[1].."</font>/<font color='#5007a3'>"..Perk.Tiers[2].."</font>/<font color='#8a060e'>"..Perk.Tiers[3].."</font></b> studs, but they also see your aura. and as the Obsession you gain a <b><font color='#c2b00e'>"..Perk.Obsession_Bonus.."</font></b> studs bonus to the distance. \n<font color='#e60017'>Greatly increases your chance of being the obsession</font>"
	
	return Perk
end

return Perk.Configure()
