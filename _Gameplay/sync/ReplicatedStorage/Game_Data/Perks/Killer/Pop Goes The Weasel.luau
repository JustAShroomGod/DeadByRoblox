local Perk = {
	-- BASE --
	Active = true; -- should appear in game or be deactivated for now
	Testing = false; -- only appear for tester or above
	Unlocked = true; -- if this perk should be unlocked for free at this moment if ever
	
	Name = "Rage";
	Image = "rbxassetid://18430120663"; -- image ids
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
	
	Tiers = { -- amount of time perk is active
		30,
		45,
		65,
	},
	
	Regression_Bonus = 35;
}

function Perk.Configure()
	Perk.Description = "After hooking a survivor this perk becomes active for <b><font color='#0852a6'>"..Perk.Tiers[1].."</font>/<font color='#5007a3'>"..Perk.Tiers[2].."</font>/<font color='#8a060e'>"..Perk.Tiers[3].."</font></b> seconds. The next generator you kick will deactivate this perk and reduce the generators progress by <b><font color='#c2b00e'>"..Perk.Regression_Bonus.."%</font></b>."
	
	return Perk
end

return Perk.Configure()
