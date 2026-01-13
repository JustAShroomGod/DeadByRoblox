
local Addon = {
	-- BASE --
	Active = true; -- should appear in game or be deactivated for now
	Testing = false; -- only appear for tester or above
	
	Name = "Self Adherent Wrap";
	
	Image = "rbxassetid://138326703721460"; -- image id 
	Color = Color3.fromRGB(0, 85, 0);
	
	Description = "";
	
	
	-- SHOP --
	Class = "Medkit";

	
	Data_Name = script.Name;
	Cost = 3000;
	Shop_Chance = 615; -- chance to appear out of 100 in purchasing_slot
	
	-- GAMEPLAY --
	Charges = 8;
	Speed = 0.15
	
}

function Addon.Configure()
	Addon.Description = "Increases your Medkit charges by <b><font color='#c2b00e'>"..Addon.Charges.."</font></b> and increases healing speed by <b><font color='#c2b00e'>"..(Addon.Speed * 100).."%</font></b>"
	
	return Addon
end

return Addon.Configure()
