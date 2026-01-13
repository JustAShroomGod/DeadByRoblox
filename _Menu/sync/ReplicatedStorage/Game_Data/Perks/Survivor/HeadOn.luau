local Perk = {
	-- BASE --
	Active = true; -- should appear in game or be deactivated for now
	Unlocked = true; -- if this perk should be unlocked for free at this moment if ever
	Testing = false; -- only appear for tester or above
	
	Name = "Hidden Tactics";
	Image = "rbxassetid://14389545708"; -- image id
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
		60,
		50,
		40,
	};
	
	Range = 8; -- range to hrp to stun
	Charge_Duration = 1.5; -- Duration it takes to charge up the perk
	Stun_Duration = 3; -- Duration of stun from perk
	
	Ignore_Reduction = false; -- Ignore Stun time reduction perks (Ex: Enduring)
}

function Perk.Configure()
	Perk.Description = "After being inside a Locker for <b><font color='#c2b00e'>"..Perk.Charge_Duration.."</font></b> seconds, Hidden Tactics become active. Performing a rushed exit stuns a nearby Killer for <b><font color='#c2b00e'>"..Perk.Stun_Duration.."</font></b> seconds. This perk has a exhaustion cooldown of <b><font color='#0852a6'>"..Perk.Tiers[1].."</font>/<font color='#5007a3'>"..Perk.Tiers[2].."</font>/<font color='#8a060e'>"..Perk.Tiers[3].."</font></b> seconds. \n<font color='#e60017'>Hidden Tactics cannot be used while Exhausted.</font>"
	
	return Perk
end

return Perk.Configure()
