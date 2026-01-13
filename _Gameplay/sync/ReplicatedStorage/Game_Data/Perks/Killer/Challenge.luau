local Perk = {
	-- BASE --
	Active = true; -- should appear in game or be deactivated for now
	Testing = false; -- only appear for tester or above
	Unlocked = true; -- if this perk should be unlocked for free at this moment if ever
	
	Name = "Challenge";
	Image = "rbxassetid://99646790755941"; -- image id
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
	
	Tiers = { -- cooldown for challenge
		45,
		30,
		15,
	},
	
	Exposed_Time = 30; -- time a survivor stays exposed for per activation
	
	Activation_Distance = 30; -- how close to activate challenge
}

function Perk.Configure()
	Perk.Description = "When a survivor crouch spams within <b><font color='#c2b00e'>"..Perk.Activation_Distance.."</font></b> studs of you they become exposed for <b><font color='#c2b00e'>"..Perk.Exposed_Time.."</font></b> seconds and this perk goes on cooldown for <b><font color='#0852a6'>"..Perk.Tiers[1].."</font>/<font color='#5007a3'>"..Perk.Tiers[2].."</font>/<font color='#8a060e'>"..Perk.Tiers[3].."</font></b> seconds."
	
	return Perk
end

return Perk.Configure()
