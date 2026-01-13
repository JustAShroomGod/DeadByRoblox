
local Addon = {
	-- BASE --
	Active = true; -- should appear in game or be deactivated for now
	Testing = false; -- only appear for tester or above
	
	Name = "Brand New Part";
	
	Image = "rbxassetid://105243808400918"; -- image id
	Color = Color3.fromRGB(132, 1, 36);
	
	Description = "";
	
	
	-- SHOP --
	Class = "Toolbox";

	
	Data_Name = script.Name;
	Cost = 5000;
	Shop_Chance = 100; -- chance to appear out of 100 in purchasing_slot
	
	-- GAMEPLAY --
	
}

function Addon.Configure()
	Addon.Description = "Instantly repairs 15% of a generator, Toolbox is delpeted on use."
	
	return Addon
end

return Addon.Configure()
