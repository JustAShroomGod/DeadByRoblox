
local Addon = {
	-- BASE --
	Active = true; -- should appear in game or be deactivated for now
	Testing = false; -- only appear for tester or above
	
	Name = "Battery";
	
	Image = "rbxassetid://121929311979255"; -- image id
	Color = Color3.fromRGB(56, 46, 43);
	
	Description = "";
	
	
	-- SHOP --
	Class = "Flashlight";

	
	Data_Name = script.Name;
	Cost = 2000;
	Shop_Chance = 820; -- chance to appear out of 100 in purchasing_slot
	
	-- GAMEPLAY --
	Charges = 4;
}

function Addon.Configure()
	Addon.Description = "Flashlight battery life is increased by <b><font color='#c2b00e'>"..Addon.Charges.."</font></b> seconds"
	
	return Addon
end

return Addon.Configure()
