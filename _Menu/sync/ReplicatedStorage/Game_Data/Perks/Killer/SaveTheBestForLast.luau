local Perk = {
	-- BASE --
	Active = true; -- should appear in game or be deactivated for now
	Testing = false; -- only appear for tester or above
	Unlocked = true; -- if this perk should be unlocked for free at this moment if ever

	Name = "Preserve your Prey";
	Image = "rbxassetid://18430121180"; -- image id
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
		3,
		2,
		1,
	},


	MaxStacks = 
		{
			6,
			7,
			8
		},

	Bonuses = 
		{
			4,
			6,
			8
		},

}

function Perk.Configure()
	Perk.Description = "Every time you hit a survivor you gain a stack up to <b><font color='#0852a6'>"..Perk.MaxStacks[1].."</font>/<font color='#5007a3'>"..Perk.MaxStacks[2].."</font>/<font color='#8a060e'>"..Perk.MaxStacks[3].."</font></b> \nEach stack grants a <b><font color='#0852a6'>"..Perk.Bonuses[1].."%</font>/<font color='#5007a3'>"..Perk.Bonuses[2].."%</font>/<font color='#8a060e'>"..Perk.Bonuses[3].."%</font></b> speed boost to hit cooldowns. \nHitting your obsession will remove <b><font color='#0852a6'>"..Perk.Tiers[1].."</font>/<font color='#5007a3'>"..Perk.Tiers[2].."</font>/<font color='#8a060e'>"..Perk.Tiers[3].."</font></b> stacks."
	
	return Perk
end

return Perk.Configure()