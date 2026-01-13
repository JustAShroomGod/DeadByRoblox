local Perk = {
	-- BASE --
	Active = true; -- should appear in game or be deactivated for now
	Unlocked = true; -- if this perk should be unlocked for free at this moment if ever
	Testing = false; -- only appear for tester or above

	Name = "Scrapper";
	Image = "rbxassetid://74985226059073"; -- image id
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
	Obsession_Boost = 15; --Obsession_Boost = 5; -- 15 = Great, 10 = Signicant, 5 = Slight, 0 = none | can go both way to reduce or increase chance of being obsession;
	-- ^ (optional value if it does not affect obsession chances then you can leave uncommented)
	
	Tiers = { -- calculated exhaustion times
		20,
		15,
		10,
	};
	
	Stun_Duration = 3; -- Duration of stun from ds
	
	Ignore_Reduction = false; -- Ignore Stun time reduction perks (Ex: Enduring)


}

function Perk.Configure()
	Perk.Description = "Collect a bone scrap from totems to craft a bone shard and run into the killer to stab them for <b><font color='#c2b00e'>"..Perk.Stun_Duration.."</font></b> seconds. \n<font color='#e60017'>Greatly increases your chance of being the obsession</font> \n<font color='#e60017'>Scrapper is effected by Pain Resistance</font>"

	return Perk
end

return Perk.Configure()
