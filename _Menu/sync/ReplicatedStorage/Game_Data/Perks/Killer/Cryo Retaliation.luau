local Perk = {
	-- BASE --
	Active = true; -- should appear in game or be deactivated for now
	Testing = false; -- only appear for tester or above
	Unlocked = false; -- if this perk should be unlocked for free at this moment if ever
	
	Name = "Cryo Retaliation";
	Image = "rbxassetid://16122466622"; -- image id
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
	
	Tiers = { -- freeze duration
		1;
		2.5;
		3;
	},
	
	
	Slowness_Percentage = 60; -- 50% of their speed
	Cooldown = 15; -- between uses
}

function Perk.Configure()
	Perk.Description = "Every time a Survivor stuns you with a pallet, you call upon [REDACTED] to slow them down for <b><font color='#0852a6'>"..Perk.Tiers[1].."</font>/<font color='#5007a3'>"..Perk.Tiers[2].."</font>/<font color='#8a060e'>"..Perk.Tiers[3].."</font></b>. Perk has a cooldown of <b><font color='#c2b00e'>"..Perk.Cooldown.."</font></b> seconds between uses."
	
	return Perk
end

return Perk.Configure()
