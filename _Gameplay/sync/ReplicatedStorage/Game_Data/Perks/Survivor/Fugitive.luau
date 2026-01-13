local Perk = {
	-- BASE --
	Active = true; -- should appear in game or be deactivated for now
	Testing = false; -- only appear for tester or above
	Unlocked = true; -- if this perk should be unlocked for free at this moment if ever
	
	Name = "Fugitive";
	Image = "rbxassetid://18566607945"; -- image id
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
	
	Aura_Tiers = {
		10,
		11,
		12,
	};
	
	Hook_Tiers = {
		60,
		80,
		120
	};
}

function Perk.Configure()
	Perk.Description = "Anytime you are unhooked or unhook yourself from a hook, that hook breaks and you see the Killers aura for <b><font color='#0852a6'>"..Perk.Aura_Tiers[1].."</font>/<font color='#5007a3'>"..Perk.Aura_Tiers[2].."</font>/<font color='#8a060e'>"..Perk.Aura_Tiers[3].."</font></b> seconds. A hook broken by this perk is sabotaged for <b><font color='#0852a6'>"..Perk.Hook_Tiers[1].."</font>/<font color='#5007a3'>"..Perk.Hook_Tiers[2].."</font>/<font color='#8a060e'>"..Perk.Hook_Tiers[3].."</font></b> seconds"
	
	return Perk
end

return Perk.Configure()
