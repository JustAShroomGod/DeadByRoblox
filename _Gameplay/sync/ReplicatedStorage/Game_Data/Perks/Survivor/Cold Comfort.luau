local Perk = {
	-- BASE --
	Active = true; -- should appear in game or be deactivated for now
	Unlocked = false; -- if this perk should be unlocked for free at this moment if ever
	Testing = false; -- only appear for tester or above
	
	Name = "Cold Comfort";
	Image = "rbxassetid://14389545708"; -- image id
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
	
	Tiers = { -- chase times 
		40,
		35,
		30,
	};
	
	Slowness_Percentage = 0.25; --25%
}

function Perk.Configure()
	Perk.Description = "After being chased for <b><font color='#0852a6'>"..Perk.Tiers[1].."</font>/<font color='#5007a3'>"..Perk.Tiers[2].."</font>/<font color='#8a060e'>"..Perk.Tiers[3].."</font></b> seconds, you unlock the ability to turn a hook into it's icy form. Survivors hooked on icy hooks die 15% slower. \n<font color='#e60017'>The icy effect wears off once the Survivor has been rescued from an icy hook.</font>"
	return Perk
end

return Perk.Configure()
