
local Addon = {
	-- BASE --
	Active = true; -- should appear in game or be deactivated for now
	Testing = false; -- only appear for tester or above
	
	Name = "Wire Spool";
	
	Image = "rbxassetid://101236391713114"; -- image id
	Color = Color3.fromRGB(0, 85, 0);
	
	Description = "";
	
	
	-- SHOP --
	Class = "Toolbox";

	
	Data_Name = script.Name;
	Cost = 3000;
	Shop_Chance = 950; -- chance to appear out of 100 in purchasing_slot
	
	-- GAMEPLAY --
	Charges = 16;
}

function Addon.Configure()
	Addon.Description = "Increases Toolbox charges by <b><font color='#c2b00e'>"..Addon.Charges.."</font></b>"
	
	return Addon
end

return Addon.Configure()
