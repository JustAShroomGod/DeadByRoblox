local Perk = {
	-- BASE --
	Active = true; -- should appear in game or be deactivated for now
	Unlocked = true; -- if this perk should be unlocked for free at this moment if ever
	Testing = false; -- only appear for tester or above
	
	Name = "Enviromental Awareness";
	Image = "rbxassetid://14497864633"; -- image id
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

	Tiers = { -- calculated exhaustion times
		1.50,
		1.60,
		1.70,
	};
	
	
}

function Perk.Configure()
	Perk.Description = "Your Walking Speed is increased by <b><font color='#0852a6'>"..math.round((Perk.Tiers[1] - 1) * 100).."</font>/<font color='#5007a3'>"..math.round((Perk.Tiers[2] - 1) * 100).."</font>/<font color='#8a060e'>"..math.round((Perk.Tiers[3] - 1) * 100).."</font></b>% and gain the ability to see <b><font color='#c2b00e'>Scratch Marks</font></b>."
	
	return Perk
end

return Perk.Configure()
