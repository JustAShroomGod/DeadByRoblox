local Perk = {
	-- BASE --
	Active = true; -- should appear in game or be deactivated for now
	Unlocked = true; -- if this perk should be unlocked for free at this moment if ever
	Testing = false; -- only appear for tester or above
	
	Name = "Just A Scratch";
	Image = "rbxassetid://14497865972"; -- image id
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
	Obsession_Boost = -15; -- 15 = Great, 10 = Signicant, 5 = Slight, 0 = none | can go both way to reduce or increase chance of being obsession;
	-- ^ (optional value if it does not affect obsession chances then you can leave uncommented)

	Tiers = { -- calculated exhaustion times
		1.15,
		1.25,
		1.35,
	};

	
}

function Perk.Configure()
	Perk.Description = "You are affected by the <b><font color='#c2b00e'>Broken Status Effect</font></b> for the duration of the Trial and start the Match in the Injured State. You don't leave <b><font color='#c2b00e'>Pools of Blood</font></b> or <b><font color='#c2b00e'>Scratch Marks</font></b>. You gain the ability to fully recover from the <b><font color='#c2b00e'>Dying State</font></b> and recover <b><font color='#0852a6'>".. math.round((Perk.Tiers[1] - 1) * 100) .."</font>/<font color='#5007a3'>".. math.round((Perk.Tiers[2] - 1) * 100) .."</font>/<font color='#8a060e'>".. math.round((Perk.Tiers[3] - 1) * 100) .."</font></b>% faster. Grunts of Pain and Breathing are reduced by <b><font color='#c2b00e'>100%</font></b>. \n<font color='#e60017'>Greatly decreases your chance of being the obsession</font>"
	
	return Perk
end

return Perk.Configure()
