local Perk = {
	-- BASE --
	Active = true; -- should appear in game or be deactivated for now
	Unlocked = true; -- if this perk should be unlocked for free at this moment if ever
	Testing = false; -- only appear for tester or above
	
	Name = "The Savior";
	Image = "rbxassetid://16227381444"; -- image id
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
	
	Token_Limit = 4;

	Tiers = {
		20,
		25,
		30,
	}
}

function Perk.Configure()
	Perk.Description = "For each Survivor you unhook, gain a <b><font color='#c2b00e'>Token</font></b>, up to <b><font color='#c2b00e'>"..Perk.Token_Limit.."</font></b>.For each <b><font color='#c2b00e'>Token</font></b>, your <b><font color='#c2b00e'>Unhook speed</font></b> is increased by <b><font color='#0852a6'>"..Perk.Tiers[1].."%</font>/<font color='#5007a3'>"..Perk.Tiers[2].."%</font>/<font color='#8a060e'>"..Perk.Tiers[3].."</font></b>%, and when another Survivor is hooked, every Survivor can see your <b><font color='#c2b00e'>Aura</font></b> from any distance."
	
	return Perk
end

return Perk.Configure()
