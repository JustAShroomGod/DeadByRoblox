local Perk = {
	-- BASE --
	Active = true; -- should appear in game or be deactivated for now
	Unlocked = true; -- if this perk should be unlocked for free at this moment if ever
	Testing = false; -- only appear for tester or above
	
	Name = "Sprint Boost";
	Image = "rbxassetid://14445532287"; -- image id
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

	Tiers = { -- calculated exhaustion times
		60,
		45,
		40,
	};

	Duration = 3; -- Duration the Speed Lingers for
	Speed_Boost = 50; -- speed when active
}

function Perk.Configure()
	Perk.Description = "When sprinting this perk grants you haste of <b><font color='#c2b00e'>"..(Perk.Speed_Boost).."%</font></b> for <b><font color='#c2b00e'>"..Perk.Duration.."</font></b> seconds. Perk has a exhaustion cooldown of <b><font color='#0852a6'>"..Perk.Tiers[1].."</font>/<font color='#5007a3'>"..Perk.Tiers[2].."</font>/<font color='#8a060e'>"..Perk.Tiers[3].."</font></b> seconds. \n<font color='#e60017'>Sprint Boost cannot be used while Exhausted.</font>"
	
	return Perk
end

return Perk.Configure()
