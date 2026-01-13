local Perk = {
	-- BASE --
	Active = true; -- should appear in game or be deactivated for now
	Testing = false; -- only appear for tester or above
	Unlocked = false; -- if this perk should be unlocked for free at this moment if ever
	
	Name = "Curse: Borrowed Light";
	Image = "rbxassetid://14872825487"; -- image id
	Colors = {
		Color3.fromRGB(6, 62, 125); -- color associated with images
		Color3.fromRGB(80, 7, 163); -- color associated with images
		Color3.fromRGB(138, 6, 14); -- color associated with images
	},
	
	Description = "";

	-- SHOP --
	Gamepasses = {
		-- Original Passes --
		262708845;
		262708425;
		-- Dab Passes --
		263241548, -- dlc
		263241765 -- bundle
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
		30,
		50,
		70
	}
}

function Perk.Configure()
	Perk.Description = "As long as this curse is active. Whenever you are <b><font color='#0852a6'>"..Perk.Tiers[1].."</font>/<font color='#5007a3'>"..Perk.Tiers[2].."</font>/<font color='#8a060e'>"..Perk.Tiers[3].."</font></b> studs near any cursed totem you gain the hidden status effect."
	
	return Perk
end

return Perk.Configure()
