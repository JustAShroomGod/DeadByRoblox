local Perk = {
	-- BASE --
	Active = true; -- should appear in game or be deactivated for now
	Unlocked = true; -- if this perk should be unlocked for free at this moment if ever
	Testing = false; -- only appear for tester or above

	Name = "Quick Fix";
	Image = "rbxassetid://14389545495"; -- image id
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

	Tiers = { -- amount to restore in %
		25,
		50,
		75
	},

	Charge_Time = 15; -- time for full charge
}

function Perk.Configure()
	Perk.Description = "After repairing a generator for <b><font color='#c2b00e'>"..Perk.Charge_Time.."</font></b> seconds you gain the ability to restore the item in your hand by <b><font color='#0852a6'>"..Perk.Tiers[1].."</font>/<font color='#5007a3'>"..Perk.Tiers[2].."</font>/<font color='#8a060e'>"..Perk.Tiers[3].."</font></b>%. \n <b><font color='#a1100b'>Fan Made Perk By: Peashooder#5697 </font></b>"

	return Perk
end

return Perk.Configure()
