local Perk = {
	-- BASE --
	Active = true; -- should appear in game or be deactivated for now
	Unlocked = true; -- if this perk should be unlocked for free at this moment if ever
	Testing = false; -- only appear for tester or above

	Name = "Blessing: Healing Aid";  -- Temp Name
	Image = "rbxassetid://72552114165821"; -- image id
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
	Obsession_Boost = 15; -- 15 = Great, 10 = Signicant, 5 = Slight, 0 = none | can go both way to reduce or increase chance of being obsession;
	-- ^ (optional value if it does not affect obsession chances then you can leave uncommented)

	Tier_Ranges = 
		{
			25,
			50,
			75
		},

	Tiers = 
		{
			1.1,
			1.15,
			1.2
		},

}

function Perk.Configure()
	--Perk.Description = "Apply this blessing to any dull totem and survivors within <b><font color='#0852a6'>"..(Perk.Tier_Ranges[1]) .."</font>/<font color='#5007a3'>"..(Perk.Tier_Ranges[2]).."</font>/<font color='#8a060e'>"..(Perk.Tier_Ranges[3]).."</font></b> studs will be able to Self Heal without a Medkit at normal speed, additionally will gain a <b><font color='#0852a6'>"..((1 - Perk.Tiers[1]) * 100).."%</font>/<font color='#5007a3'>"..((1 - Perk.Tiers[2]) * 100).."%</font>/<font color='#8a060e'>"..((1 - Perk.Tiers[3]) * 100).."x</font></b> Healing Boost to other survivors. \n<font color='#e60017'>Greatly increases your chance of being the obsession</font>"
	Perk.Description = "Apply this blessing to any dull totem and survivors within <b><font color='#0852a6'>"..Perk.Tier_Ranges[1].."</font>/<font color='#5007a3'>"..Perk.Tier_Ranges[2].."</font>/<font color='#8a060e'>"..Perk.Tier_Ranges[3].."</font></b> studs will be able to Self Heal without a Medkit at normal speed, additionally will gain a <b><font color='#0852a6'>"..math.floor((Perk.Tiers[1] - 1) * 100 + 0.5).."%</font>/<font color='#5007a3'>"..math.floor((Perk.Tiers[2] - 1) * 100 + 0.5).."%</font>/<font color='#8a060e'>"..math.floor((Perk.Tiers[3] - 1) * 100 + 0.5).."%</font></b> Healing Boost to other survivors. \n<font color='#e60017'>Greatly increases your chance of being the Obsession.</font>"
	return Perk
end

return Perk.Configure()
