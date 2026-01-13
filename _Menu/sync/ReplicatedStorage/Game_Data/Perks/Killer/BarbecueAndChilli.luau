local Perk = {
	-- BASE --
	Active = true; -- should appear in game or be deactivated for now
	Testing = false; -- only appear for tester or above
	Unlocked = true; -- if this perk should be unlocked for free at this moment if ever
	
	Name = "Experience from the Past";
	Image = "rbxassetid://16122466622"; -- image id
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
	
	Tiers = { -- DISTANCE NEEDED TO SEE SURVIVORS
		140,
		120,
		100,
	},
	
	Length = 5; -- amount of time aura is revealed when survivor is hooked
}

function Perk.Configure()
	Perk.Description = "After hooking a survivor you can see the location of all survivors for <b><font color='#c2b00e'>"..Perk.Length.."</font></b> seconds. When they are futher than <b><font color='#0852a6'>"..Perk.Tiers[1].."</font>/<font color='#5007a3'>"..Perk.Tiers[2].."</font>/<font color='#8a060e'>"..Perk.Tiers[3].."</font></b> studs away from you."
	
	return Perk
end

return Perk.Configure()
