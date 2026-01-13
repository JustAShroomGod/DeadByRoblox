local Perk = {
	-- BASE --
	Active = true; -- should appear in game or be deactivated for now
	Unlocked = true; -- if this perk should be unlocked for free at this moment if ever
	Testing = false; -- only appear for tester or above
	
	Name = "Teamwork";
	Image = "rbxassetid://14497864145"; -- image id
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
	
	Tiers = { -- time perk stays activated for
		70,
		80,
		90,
	},
	
	Healing_Boost = 125; -- 100% more speed
}

function Perk.Configure()
	Perk.Description = "After unhooking a Survivor, Teamwork becomes active for <b><font color='#0852a6'>"..Perk.Tiers[1].."</font>/<font color='#5007a3'>"..Perk.Tiers[2].."</font>/<font color='#8a060e'>"..Perk.Tiers[3].."</font></b> seconds. While Teamwork is active, you heal other Survivors <b><font color='#c2b00e'>"..(Perk.Healing_Boost).."%</font></b> faster."
	
	return Perk
end

return Perk.Configure()
