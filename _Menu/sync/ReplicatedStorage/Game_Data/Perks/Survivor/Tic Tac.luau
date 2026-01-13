local Perk = {
	-- BASE --
	Active = true; -- should appear in game or be deactivated for now
	Unlocked = false; -- if this perk should be unlocked for free at this moment if ever
	Testing = false; -- only appear for tester or above
	
	Name = "Tic Tac";
	Image = "rbxassetid://16547098766"; -- image id
	Colors = {
		Color3.fromRGB(6, 62, 125); -- color associated with images
		Color3.fromRGB(80, 7, 163); -- color associated with images
		Color3.fromRGB(138, 6, 14); -- color associated with images
	},
	
	Description = "";

	-- SHOP --
	Gamepasses = {
		-- Original Passes --
		262708845;
		262708425;
		-- Dab Passes --
		263241548, -- dlc
		263241765 -- bundle
	}; -- gamepass id's that unlock this perk automatically
	
	-- BLOOD SHOP --
	Data_Name = script.Name;
	Cost = {
		3000,
		5000,
		7000,
	},
	
	-- GAMEPLAY --

	Tiers = { -- calculated timer times
		20,
		15,
		10,
	};
	
	Radius = 40; -- radius perk starts filling (killer-distance-to-hook)
	
	Stun_Duration = 5; -- Duration of stun from perk

	Ignore_Reduction = true; -- Ignore Stun time reduction perks (Ex: Enduring)
}

function Perk.Configure()
	Perk.Description = "Perk charges when the killer is within <b><font color='#c2b00e'>"..Perk.Radius.."</font></b> studs of you while on hook. When fully charged pressing the perk activation key will stun the killers for <b><font color='#c2b00e'>"..Perk.Stun_Duration.."</font></b> seconds. This perk takes <b><font color='#0852a6'>"..Perk.Tiers[1].."</font>/<font color='#5007a3'>"..Perk.Tiers[2].."</font>/<font color='#8a060e'>"..Perk.Tiers[3].."</font></b> seconds to fully charge and will deplete all charges upon being unhooked."
	
	return Perk
end

return Perk.Configure()
