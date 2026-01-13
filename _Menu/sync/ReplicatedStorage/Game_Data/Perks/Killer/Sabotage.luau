local Perk = {
	-- BASE --
	Active = true; -- should appear in game or be deactivated for now
	Testing = false; -- only appear for tester or above
	Unlocked = false; -- if this perk should be unlocked for free at this moment if ever
	
	Name = "Sabotage";
	Image = "rbxassetid://17699237056"; -- image id
	Colors = {
		Color3.fromRGB(6, 62, 125); -- color associated with images
		Color3.fromRGB(80, 7, 163); -- color associated with images
		Color3.fromRGB(138, 6, 14); -- color associated with images
	},
	
	Description = "";

	-- SHOP --
	Gamepasses = {
		824663392,
		824346718
	}; -- gamepass id's that unlock this perk automatically
	
	-- BLOOD SHOP --
	Data_Name = script.Name;
	Cost = {
		3000,
		5000,
		7000,
	},
	
	-- GAMEPLAY --
	Blind_Time = 6;
	Distance = 7.5;
	
	Tiers = { -- CD
		90,
		60,
		40,
	},
}

function Perk.Configure()
	Perk.Description = "This perk sabotages on the last kicked Generator when active. Sabotaged Generators will explode and blind all Survivors within <b>"..Perk.Distance.." meters</b> for <b>".. Perk.Blind_Time .." seconds</b>, and then goes on cooldown for <b><font color='#0852a6'>"..Perk.Tiers[1].."</font>/<font color='#5007a3'>"..Perk.Tiers[2].."</font>/<font color='#8a060e'>"..Perk.Tiers[3].."</font></b> seconds."
	
	return Perk
end

return Perk.Configure()
