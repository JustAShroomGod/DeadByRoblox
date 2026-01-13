local Perk = {
	-- BASE --
	Active = true; -- should appear in game or be deactivated for now
	Unlocked = false; -- if this perk should be unlocked for free at this moment if ever
	Testing = false; -- only appear for tester or above

	Name = "Growing Fixation";
	Image = "rbxassetid://126543393282943"; -- image id
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
	
	Aura_Duration = 3.5;
	
	Tiers = {
		0.2,
		0.35,
		0.5
	}
}

function Perk.Configure()
	Perk.Description = "When a Survivor unhooks someone, their Aura is revealed for "..Perk.Aura_Duration.." Seconds and this Perk receives a Token. Auras last <b><font color='#0852a6'>"..Perk.Tiers[1].."</font>/<font color='#5007a3'>"..Perk.Tiers[2].."</font>/<font color='#8a060e'>"..Perk.Tiers[3].."</font></b> Seconds longer for each Token."

	return Perk
end

return Perk.Configure()
