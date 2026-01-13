local Perk = {
	-- BASE --
	Active = true; -- should appear in game or be deactivated for now
	Testing = false; -- only appear for tester or above
	Unlocked = false; -- if this perk should be unlocked for free at this moment if ever
	
	Name = "Curse: Lockdown";
	Image = "rbxassetid://17078227506"; -- image id
	Colors = {
		Color3.fromRGB(6, 62, 125); -- color associated with images
		Color3.fromRGB(80, 7, 163); -- color associated with images
		Color3.fromRGB(138, 6, 14); -- color associated with images
	},
	
	Description = "";

	-- SHOP --
	Gamepasses = {
		757476321; -- architect bundle
		755047319; -- acrhitect perk pass
	}; -- gamepass id's that unlock this perk automatically
	
	-- BLOOD SHOP --
	Data_Name = script.Name;
	Cost = {
		3000,
		5000,
		7000,
	},
	
	-- GAMEPLAY --
	
	Tiers = {
		150,
		200,
		250,
	}
}

function Perk.Configure()
	Perk.Description = "As long as this curse is active when you hook a survivor, the generator with the most progress will automatically lose <b><font color='#0852a6'>"..(Perk.Tiers[1] / 10).."%</font>/<font color='#5007a3'>"..(Perk.Tiers[2] / 10).."%</font>/<font color='#8a060e'>"..(Perk.Tiers[3] / 10)..'%</font></b> progress.'
	
	return Perk
end

return Perk.Configure()
