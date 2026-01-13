local Perk = {
	-- BASE --
	Active = true; -- should appear in game or be deactivated for now
	Unlocked = false; -- if this perk should be unlocked for free at this moment if ever
	Testing = false; -- only appear for tester or above
	
	Name = "Focused";
	Image = "rbxassetid://16579087978"; -- image id
	Colors = {
		Color3.fromRGB(6, 62, 125); -- color associated with images
		Color3.fromRGB(80, 7, 163); -- color associated with images
		Color3.fromRGB(138, 6, 14); -- color associated with images
	},
	
	Description = "";

	-- SHOP --
	Gamepasses = {
		197783753;
		263242509;
	}; -- gamepass id's that unlock this perk automatically
	
	-- BLOOD SHOP --
	Data_Name = script.Name;
	Cost = {
		3000,
		5000,
		7000,
	},
	
	-- GAMEPLAY --
	Obsession_Boost = 10; -- 15 = Great, 10 = Signicant, 5 = Slight, 0 = none | can go both way to reduce or increase chance of being obsession;
	-- ^ (optional value if it does not affect obsession chances then you can leave uncommented)
	
	Tiers = {
		30,
		40,
		50,
	};
	
	MinDistance = 15;
	MaxDistance = 100;
}

function Perk.Configure()
	Perk.Description = "When you are the last Survivor remaining, you gain the ability see the <b><font color='#c2b00e'>Hatch</font></b> within <b><font color='#c2b00e'>" .. Perk.MaxDistance .. "</font></b> studs. Additionally, you gain the ability to open the <b><font color='#c2b00e'>Hatch</font></b> without a key at <b><font color='#0852a6'>"..Perk.Tiers[1].."%</font>/<font color='#5007a3'>"..Perk.Tiers[2].."%</font>/<font color='#8a060e'>"..Perk.Tiers[3].."%</font></b> of the normal opening speed. \n<font color='#e60017'>Moderately increases your chance of being the obsession</font>"
	
	return Perk
end

return Perk.Configure()
