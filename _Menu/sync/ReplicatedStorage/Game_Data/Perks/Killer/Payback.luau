local Perk = {
	-- BASE --
	Active = true; -- should appear in game or be deactivated for now
	Unlocked = false; -- if this perk should be unlocked for free at this moment if ever
	Testing = false; -- only appear for tester or above

	Name = "Payback";
	Image = "rbxassetid://82020840995106"; -- image id
	Colors = {
		Color3.fromRGB(6, 62, 125); -- color associated with images
		Color3.fromRGB(80, 7, 163); -- color associated with images
		Color3.fromRGB(138, 6, 14); -- color associated with images
	},

	Description = "";

	-- SHOP --
	Gamepasses = {
		"1233273094"; --perk pack
		"1233201309" --bundle
	}; -- gamepass id's that unlock this perk automatically
	

	-- BLOOD SHOP --
	Data_Name = script.Name;
	Cost = {
		3000,
		5000,
		7000,
	},
	
	SkillChecks = 3;
	Duration = 6;
	
	Tiers = {
		6,
		7,
		8,
	};
	
	
}

function Perk.Configure()
	Perk.Description = "When hit by a Pallet, the Survivor performing the action is faced with <b><font color='#c2b00e'>" .. Perk.SkillChecks.. "</font></b> difficult SkillChecks. For each failed SkillCheck, the Survivor receives a stackable <b><font color='#0852a6'> " .. Perk.Tiers[1] .. "</font></b>/<b><font color='#5007a3'>".. Perk.Tiers[2] .."</font></b>/<b><font color='#8a060e'>".. Perk.Tiers[3] .."</font></b>% Slowness Effect. The Effect lasts for <b><font color='#c2b00e'>" .. Perk.Duration.. "</font></b> Seconds."

	return Perk
end

return Perk.Configure()
