local Perk = {
	-- BASE --
	Active = true; -- should appear in game or be deactivated for now
	Unlocked = true; -- if this perk should be unlocked for free at this moment if ever
	Testing = false; -- only appear for tester or above
	
	Name = "Better Than Ever";
	Image = "rbxassetid://120121948741185"; -- image id
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
	

	Tiers = { -- calculated times
		30,
		50,
		70,
	};
	
	Speed_Boost = 10; -- speed when active
}

function Perk.Configure()
	Perk.Description = "After being unhooked, Better Than Ever activates for <b><font color='#0852a6'>"..Perk.Tiers[1].."</font>/<font color='#5007a3'>"..Perk.Tiers[2].."</font>/<font color='#8a060e'>"..Perk.Tiers[3].."</font></b> seconds. \n You gain <b><font color='#c2b00e'>"..(Perk.Speed_Boost).."</font></b>% repairing,healing and cleansing speed for the duration. You also see the obsession's aura for the duration."
	
	return Perk
end

return Perk.Configure()
