local Perk = {
	-- BASE --
	Active = true; -- should appear in game or be deactivated for now
	Unlocked = false; -- if this perk should be unlocked for free at this moment if ever
	Testing = false; -- only appear for tester or above
	
	Name = "Ultimate Escape";
	Image = "rbxassetid://17078237471"; -- image id
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
	Haste = 15;
	
	Tiers = {
		5,
		10,
		15,
	},
}

function Perk.Configure()
	Perk.Description = "Whenever you blind the Killer, gain the <b><font color='#c2b00e'>Hidden</font></b> status effect and <b><font color='#c2b00e'>"..Perk.Haste.."%</font></b> Haste for <b><font color='#0852a6'>"..Perk.Tiers[1].."</font>/<font color='#5007a3'>"..Perk.Tiers[2].."</font>/<font color='#8a060e'>"..Perk.Tiers[3].."</font></b> seconds."
	
	return Perk
end

return Perk.Configure()
