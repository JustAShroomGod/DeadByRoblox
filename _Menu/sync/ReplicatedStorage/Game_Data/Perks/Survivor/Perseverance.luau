local Perk = {
	-- BASE --
	Active = true; -- should appear in game or be deactivated for now
	Unlocked = true; -- if this perk should be unlocked for free at this moment if ever
	Testing = false; -- only appear for tester or above
	
	Name = "Perseverance";
	Image = "rbxassetid://105440234176763"; -- image id
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
	--Obsession_Boost = 5; -- 15 = Great, 10 = Signicant, 5 = Slight, 0 = none | can go both way to reduce or increase chance of being obsession;
	-- ^ (optional value if it does not affect obsession chances then you can leave uncommented)
	
	Tiers = {
		80,
		90,
		100,
		
		
	},
	
}

function Perk.Configure()
	Perk.Description = "While injured, your grunts of pain are reduced by <b><font color='#0852a6'>"..Perk.Tiers[1].."%</font>/<font color='#5007a3'>"..Perk.Tiers[2].."%</font>/<font color='#8a060e'>"..Perk.Tiers[3].."%</font></b>"
	
	return Perk
end

return Perk.Configure()
