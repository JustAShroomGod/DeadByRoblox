local Perk = {
	-- BASE --
	Active = true; -- should appear in game or be deactivated for now
	Testing = false; -- only appear for tester or above
	Unlocked = true; -- if this perk should be unlocked for free at this moment if ever
	
	Name = "Curse: Reverse Progress";
	Image = "rbxassetid://16122464623"; -- image id
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
	
	Tiers = { -- Progress/Rate Generators auto-regress
		0.75, -- NERFED SEVERELY (want long games not impossible): 1, 1.5, 2x regress
		1,
		1.25,
	},
}

function Perk.Configure()
	Perk.Description = "While this curse is active generators will automatically begin to regress when a survivor is not actively working on it at rates of <b><font color='#0852a6'>"..(Perk.Tiers[1] * 100).."</font>/<font color='#5007a3'>"..(Perk.Tiers[2] * 100).."</font>/<font color='#8a060e'>"..(Perk.Tiers[3] * 100).."</font></b> percent."
	
	return Perk
end

return Perk.Configure()
