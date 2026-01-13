local Perk = {
	-- BASE --
	Active = true; -- should appear in game or be deactivated for now
	Testing = false; -- only appear for tester or above
	Unlocked = true; -- if this perk should be unlocked for free at this moment if ever

	Name = "Tight Grip";
	Image = "rbxassetid://14904708629"; -- image id
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
		0.3,
		0.4,
		0.5,
	},

	Pickup_Reduction = 0.75; -- wiggle speed
}

function Perk.Configure()
	Perk.Description = "Your pick up speed is slowed to <b><font color='#0852a6'>"..(Perk.Tiers[1] * 100).."</font>/<font color='#5007a3'>"..(Perk.Tiers[2] * 100).."</font>/<font color='#8a060e'>"..(Perk.Tiers[3] * 100).."%</font></b>, but survivors wiggle at a rate of <b><font color='#c2b00e'>"..(Perk.Pickup_Reduction * 100).."%</font></b>."

	return Perk
end

return Perk.Configure()