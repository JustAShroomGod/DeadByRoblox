local Perk = {
	-- BASE --
	Active = true; -- should appear in game or be deactivated for now
	Unlocked = true; -- if this perk should be unlocked for free at this moment if ever
	Testing = false; -- only appear for tester or above
	
	Name = "Salvation";
	Image = "rbxassetid://14445533510"; -- image id
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
	Obsession_Boost = 5; -- 15 = Great, 10 = Signicant, 5 = Slight, 0 = none | can go both way to reduce or increase chance of being obsession;
	-- ^ (optional value if it does not affect obsession chances then you can leave uncommented)


	Tiers = { -- calculated broken time
		80,
		60,
		50,
	},
	
}

function Perk.Configure()
	Perk.Description = "After unhooking a Survivor, Salvation becomes active. You now have a 100% chance of unhooking yourself during your first Hook Stage. After Unhooking yourself, you suffer from the <b><font color='#c2b00e'>Broken</font></b> status effect for <b><font color='#0852a6'>"..Perk.Tiers[1].."</font>/<font color='#5007a3'>"..Perk.Tiers[2].."</font>/<font color='#8a060e'>"..Perk.Tiers[3].."</font></b> seconds. \n<font color='#e60017'>Slightly increases your chance of being the obsession</font>"
	
	return Perk
end

return Perk.Configure()
