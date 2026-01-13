local Perk = {
	-- BASE --
	Active = true; -- should appear in game or be deactivated for now
	Unlocked = true; -- if this perk should be unlocked for free at this moment if ever
	Testing = false; -- only appear for tester or above
	
	Name = "Persistence";
	Image = "rbxassetid://14497865312"; -- image id
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

	Tiers = { -- calculated exhaustion times
		1.4,
		1.7,
		2,
	};
	
	Audio = 100;
}

function Perk.Configure()
	Perk.Description = "Gain the ability to recover while crawling, crawl <b><font color='#0852a6'>"..(Perk.Tiers[1] * 100).."%</font>/<font color='#5007a3'>"..(Perk.Tiers[2] * 100).."%</font>/<font color='#8a060e'>"..(Perk.Tiers[3] * 100).."%</font></b> faster, and make <b><font color='#c2b00e'>"..Perk.Audio..'%</font></b> less noise.'
	
	return Perk
end

return Perk.Configure()
