local Perk = {
	-- BASE --
	Active = true; -- should appear in game or be deactivated for now
	Unlocked = true; -- if this perk should be unlocked for free at this moment if ever
	Testing = false; -- only appear for tester or above
	
	Name = "Self Defense";
	Image = "rbxassetid://14497863799"; -- image id
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

	
	Tiers = { -- calculated activated times
		20,
		25,
		30,
	};
	
	Stun_Duration = 5; -- Duration of stun from perk
	Ignore_Reduction = true; -- Ignore Stun time reduction perks (Ex: Enduring)
}

function Perk.Configure()
	Perk.Description = "After getting unhooked this perk activates for <b><font color='#0852a6'>"..Perk.Tiers[1].."</font>/<font color='#5007a3'>"..Perk.Tiers[2].."</font>/<font color='#8a060e'>"..Perk.Tiers[3].."</font></b> seconds. If the killer picks you up while this perk is activate, you are given a skill check.Succeeding the Skill Check will allow you to escape and stun the killer for <b><font color='#c2b00e'>"..Perk.Stun_Duration.."</font></b> seconds. Certain actions will deactivate this perk immediately. The Perk Timer is paused at <b><font color='#c2b00e'>5</font></b> seconds during a chase. \n<font color='#e60017'>Greatly increases your chance of being the obsession</font>."
	
	return Perk
end

return Perk.Configure()
