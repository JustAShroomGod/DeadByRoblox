
local Addon = {
	-- BASE --
	Active = true; -- should appear in game or be deactivated for now
	Testing = false; -- only appear for tester or above
	
	Name = "Life Spark";
	
	Image = "rbxassetid://123288269558604"; -- image id
	Color = Color3.fromRGB(132, 1, 36);
	
	Description = "";
	
	
	-- SHOP --
	Class = "Medkit";

	
	Data_Name = script.Name;
	Cost = 5000;
	Shop_Chance = 10; -- chance to appear out of 100 in purchasing_slot
	
	-- GAMEPLAY --
}

function Addon.Configure()
	Addon.Description = "This apple can cure anything! \nInstantly heal 1 Health State, Medkit is depleted on use."
	
	return Addon
end

return Addon.Configure()
