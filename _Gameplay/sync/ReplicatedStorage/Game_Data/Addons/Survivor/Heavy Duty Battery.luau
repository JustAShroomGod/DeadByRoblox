
local Addon = {
	-- BASE --
	Active = true; -- should appear in game or be deactivated for now
	Testing = false; -- only appear for tester or above
	
	Name = "Heavy Duty Battery";
	
	Image = "rbxassetid://97987512614662"; -- image id
	Color = Color3.fromRGB(0, 85, 0);
	
	Description = "";
	
	
	-- SHOP --
	Class = "Flashlight";

	
	Data_Name = script.Name;
	Cost = 3000;
	Shop_Chance = 660; -- chance to appear out of 100 in purchasing_slot
	
	-- GAMEPLAY --
	Charges = 6;
}

function Addon.Configure()
	Addon.Description = "Flashlight battery life is increased by <b><font color='#c2b00e'>"..Addon.Charges.."</font></b> seconds"
	
	return Addon
end

return Addon.Configure()
