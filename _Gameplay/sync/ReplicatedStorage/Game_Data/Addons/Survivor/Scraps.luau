
local Addon = {
	-- BASE --
	Active = true; -- should appear in game or be deactivated for now
	Testing = false; -- only appear for tester or above
	
	Name = "Scraps";
	
	Image = "rbxassetid://77575935996497"; -- image id
	Color = Color3.fromRGB(56, 46, 43);
	
	Description = "";
	
	
	-- SHOP --
	Class = "Toolbox";

	
	Data_Name = script.Name;
	Cost = 2000;
	Shop_Chance = 800; -- chance to appear out of 100 in purchasing_slot
	
	-- GAMEPLAY --
	Charges = 8;
}

function Addon.Configure()
	Addon.Description = "Increases Toolbox charges by <b><font color='#c2b00e'>"..Addon.Charges.."</font></b>"
	
	return Addon
end

return Addon.Configure()
