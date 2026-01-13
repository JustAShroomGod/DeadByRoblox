local Perk = {
	-- BASE --
	Active = true; -- should appear in game or be deactivated for now
	Unlocked = true; -- if this perk should be unlocked for free at this moment if ever
	Testing = false; -- only appear for tester or above
	
	Name = "Medical Remains";
	Image = "rbxassetid://14497866196"; -- image id
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
	};
	
	-- GAMEPLAY --
	Tiers = {
		20;
		25;
		30;
	};
	
	MaxCharges = 50
}

function Perk.Configure()
	Perk.Description = "When Healing others or yourself, Medical Remains gains Charges, up to a maximum of <b><font color='#c2b00e'>" .. Perk.MaxCharges .. "</font></b> Charges. You repair Generators <b><font color='#0852a6'> " .. Perk.Tiers[1] .. "</font></b>/<b><font color='#5007a3'>".. Perk.Tiers[2] .."</font></b>/<b><font color='#8a060e'>".. Perk.Tiers[3] .."</font></b>% faster as long as this Perk has Charges."
	
	return Perk
end

return Perk.Configure()
