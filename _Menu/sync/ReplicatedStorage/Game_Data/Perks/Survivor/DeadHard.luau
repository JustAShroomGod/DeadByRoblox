local Perk = {
	-- BASE --
	Active = true; -- should appear in game or be deactivated for now
	Unlocked = true; -- if this perk should be unlocked for free at this moment if ever
	Testing = false; -- only appear for tester or above
	
	Name = "Dodge";
	Image = "rbxassetid://14497866540"; -- image id
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
	Obsession_Boost = 3; -- 15 = Great, 10 = Signicant, 5 = Slight, 0 = none | can go both way to reduce or increase chance of being obsession;
	-- ^ (optional value if it does not affect obsession chances then you can leave uncommented)

	
	Tiers = { -- calculated exhaustion times
		60,
		50,
		40,
	};
	
	Duration = .65; -- visually looks the best tbh
	IFrame_Duration = .5; -- linger a bit after since it's suppose to be 1 second
	
	Speed = 20; -- Speed must be equal to 15 / Duration
}

function Perk.Configure()
	Perk.Description = "While injured, Dodge becomes active. Press the perk activation key to activate Dodge, which dashes you a short distance infront of you and avoid all damage for <b><font color='#c2b00e'>"..Perk.IFrame_Duration.."</font></b> seconds. This perk has a exhaustion cooldown of <b><font color='#0852a6'>"..Perk.Tiers[1].."</font>/<font color='#5007a3'>"..Perk.Tiers[2].."</font>/<font color='#8a060e'>"..Perk.Tiers[3].."</font></b> seconds. \n<font color='#e60017'>Slightly increases your chance of being the obsession</font> \n<font color='#e60017'>Dodge cannot be used while Exhausted.</font>"
	Perk.Speed = 20/Perk.Duration
	
	return Perk
end

return Perk.Configure()
