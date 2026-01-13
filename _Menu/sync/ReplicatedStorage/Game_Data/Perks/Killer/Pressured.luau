local Perk = {
	-- BASE --
	Active = true; -- should appear in game or be deactivated for now
	Testing = false; -- only appear for tester or above
	Unlocked = false; -- if this perk should be unlocked for free at this moment if ever
	
	Name = "Pressured";
	Image = "rbxassetid://17078227378"; -- image id
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
		6,
		8,
		16,
	},
}

function Perk.Configure()
	Perk.Description = "Gain a stack with each hooked survivor. With every stack increase the speed of Generator Skillchecks by <b><font color='#0852a6'>"..Perk.Tiers[1].."%</font>/<font color='#5007a3'>"..Perk.Tiers[2].."%</font>/<font color='#8a060e'>"..Perk.Tiers[3]..'%</font></b>.'
	
	return Perk
end

return Perk.Configure()
