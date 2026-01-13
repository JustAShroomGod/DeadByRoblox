local Perk = {
	-- BASE --
	Active = true; -- should appear in game or be deactivated for now
	Unlocked = true; -- if this perk should be unlocked for free at this moment if ever
	Testing = false; -- only appear for tester or above

	Name = "Stunning Encore";
	Image = "rbxassetid://80616366565901"; -- image id
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
	
	Travel_Time = 0.5;
	Stun_Duration = 5;
	Cooldown = 30;
	
	Tiers = {
		15,
		20,
		25,
	}
}

function Perk.Configure()
	Perk.Description = "Hooking a Survivor will detonate an EMP from all hooks with a <b><font color='#0852a6'>"..Perk.Tiers[1].."</font>/<font color='#5007a3'>"..Perk.Tiers[2].."</font>/<font color='#8a060e'>"..Perk.Tiers[3].."</font></b> Stud Radius.\nWhen any Survivor is hit by the Shockwave, they become paralyzed and unable to walk for <b><font color='#c2b00e'>"..Perk.Stun_Duration.."</font></b> Seconds.\nThis Perk has a cooldown of <b><font color='#c2b00e'>"..Perk.Cooldown.."</font></b> Seconds"

	return Perk
end

return Perk.Configure()
