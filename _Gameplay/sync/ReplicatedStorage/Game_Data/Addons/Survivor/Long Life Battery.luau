
local Addon = {
	-- BASE --
	Active = true; -- should appear in game or be deactivated for now
	Testing = false; -- only appear for tester or above
	
	Name = "Long Life Battery";
	
	Image = "rbxassetid://137769267039680"; -- image id
	Color = Color3.fromRGB(85, 0, 127);
	
	Description = "";
	
	
	-- SHOP --
	Class = "Flashlight";

	
	Data_Name = script.Name;
	Cost = 4000;
	Shop_Chance = 400; -- chance to appear out of 100 in purchasing_slot
	
	-- GAMEPLAY --
	Charges = 10;
}

function Addon.Configure()
	Addon.Description = "Flashlight battery life is increased by <b><font color='#c2b00e'>"..Addon.Charges.."</font></b> seconds"
	
	return Addon
end

return Addon.Configure()
