local Perk = {
	-- BASE --
	Active = true; -- should appear in game or be deactivated for now
	Unlocked = true; -- if this perk should be unlocked for free at this moment if ever
	Testing = false; -- only appear for tester or above
	
	Name = "Guardian";
	Image = "rbxassetid://14497865709"; -- image id
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
	Obsession_Boost = 4; -- 15 = Great, 10 = Signicant, 5 = Slight, 0 = none | can go both way to reduce or increase chance of being obsession;
	-- ^ (optional value if it does not affect obsession chances then you can leave uncommented)

	Tiers = { -- calculated exhaustion times
		20,
		30,
		40,
	},
	
	Cooldown = 10; -- cooldown between guardian uses
}

function Perk.Configure()
	Perk.Description = "While fully healthy and within <b><font color='#0852a6'>"..Perk.Tiers[1].."</font>/<font color='#5007a3'>"..Perk.Tiers[2].."</font>/<font color='#8a060e'>"..Perk.Tiers[3].."</font></b> studs of a <b><font color='#c2b00e'>injured Survivor</font></b> without "..Perk.Name.." equipped, form a chain with them. When the chained Survivor takes damage that would have downed them, instead you take the damage and become <b><font color='#c2b00e'>injured</font></b>. Then this perk goes on cooldown for <b><font color='#c2b00e'>"..Perk.Cooldown.."</font></b> seconds. \n<font color='#e60017'>Slightly increases your chance of being the Obsession.</font>"
	
	return Perk
end

return Perk.Configure()
