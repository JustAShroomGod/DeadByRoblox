local Perk = {
	-- BASE --
	Active = true; -- should appear in game or be deactivated for now
	Testing = false; -- only appear for tester or above
	Unlocked = true; -- if this perk should be unlocked for free at this moment if ever

	Name = "Serene";
	Image = "rbxassetid://18750108646"; -- image id
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

	Tiers = {
		10,
		15,
		20,
	};

	Speed_Boost = 50; -- speed when active
	Speed_Boost_Duration = 3
}

function Perk.Configure()
	Perk.Description = "Anytime a generator has been completed you see the auras of all generators for <b><font color='#0852a6'>"..Perk.Tiers[1].."</font>/<font color='#5007a3'>"..Perk.Tiers[2].."</font>/<font color='#8a060e'>"..Perk.Tiers[3].."</font></b> seconds, and gain a <b><font color='#c2b00e'>"..(Perk.Speed_Boost).."%</font></b> haste for <b><font color='#c2b00e'>"..Perk.Speed_Boost_Duration.."</font></b> seconds seconds. \n<font color='#e60017'>Serene cannot be used while Exhausted.</font>"
 
	return Perk
end

return Perk.Configure()
