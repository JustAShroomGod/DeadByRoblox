local Perk = {
	-- BASE --
	Active = true; -- should appear in game or be deactivated for now
	Unlocked = false; -- if this perk should be unlocked for free at this moment if ever
	Testing = false; -- only appear for tester or above
	
	Name = "Fearless";
	Image = "rbxassetid://14497863078"; -- image id
	Colors = {
		Color3.fromRGB(6, 62, 125); -- color associated with images
		Color3.fromRGB(80, 7, 163); -- color associated with images
		Color3.fromRGB(138, 6, 14); -- color associated with images
	},
	
	Description = "";

	-- SHOP --
	Gamepasses = {
		197783753;
		263242509;
	}; -- gamepass id's that unlock this perk automatically
	
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

	
	Tiers = { -- calculated exhaustion times
		250,
		180,
		130,
	};

	Stun_Duration = 2.5; -- Duration of stun from ds

	Ignore_Reduction = true; -- Ignore Stun time reduction perks (Ex: Enduring)
}

function Perk.Configure()
	Perk.Description = "When you are healthy, Fearless becomes active. You can stun the Killer, within a short distance, for <b><font color='#c2b00e'>"..Perk.Stun_Duration.."</font></b> seconds with a exhaustion of <b><font color='#0852a6'>"..Perk.Tiers[1].."</font>/<font color='#5007a3'>"..Perk.Tiers[2].."</font>/<font color='#8a060e'>"..Perk.Tiers[3].."</font></b> seconds. \n<font color='#e60017'>Greatly increases your chance of being the obsession</font> \n<font color='#e60017'>Fearless is not effected by Pain Resistance</font> \n<font color='#e60017'>Fearless cannot be used while Exhausted.</font>"
	
	return Perk
end

return Perk.Configure()
