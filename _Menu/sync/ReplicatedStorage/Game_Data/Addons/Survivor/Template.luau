
local Addon = {
	-- BASE --
	Active = false; -- should appear in game or be deactivated for now
	Testing = false; -- only appear for tester or above
	
	Name = "Template";
	
	Image = ""; -- image id
	Color = Color3.fromRGB(255, 0, 0);
	
	Description = "";
	
	
	-- SHOP --
	Class = "";

	
	Data_Name = script.Name;
	Cost = 0;
	Shop_Chance = 0; -- chance to appear out of 100 in purchasing_slot
	
	-- GAMEPLAY --
	
}

function Addon.Configure()
	Addon.Description = "Insert Values"
	
	return Addon
end

return Addon.Configure()
