local Perk = {
	-- BASE --
	Active = true; -- should appear in game or be deactivated for now
	Unlocked = true; -- if this perk should be unlocked for free at this moment if ever
	Testing = false; -- only appear for tester or above
	
	Name = "Feather Fall";
	Image = "rbxassetid://14389545918"; -- image id
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
	
	Tiers = { -- calculated exhaustion times
		60,
		50,
		40,
	};
	
	Reduction = 3/4; -- Scale from 0.1 - to inf (how reduced stagger should be) 0.25 or 1/4 = 25% of normal duration
	
	Duration = 4; -- Duration the Speed Lingers for
	Speed_Boost = 50; -- speed when active
}

function Perk.Configure()
	Perk.Description = "When falling from a great height, reduce your fall stagger by <b><font color='#c2b00e'>"..((Perk.Reduction) * 100).."%</font></b>. Upon landing break into a haste of <b><font color='#c2b00e'>"..(Perk.Speed_Boost).."%</font></b> for <b>"..Perk.Duration.."</b> seconds. This perk has a exhaustion cooldown of <b><font color='#0852a6'>"..Perk.Tiers[1].."</font>/<font color='#5007a3'>"..Perk.Tiers[2].."</font>/<font color='#8a060e'>"..Perk.Tiers[3].."</font></b> seconds.\n<font color='#e60017'>Feather Fall cannot be used while Exhausted.</font>"
	
	return Perk
end

return Perk.Configure()
