
local Addon = {
	-- BASE --
	Active = true; -- should appear in game or be deactivated for now
	Testing = false; -- only appear for tester or above
	
	Name = "Focus Lens";
	
	Image = "rbxassetid://135690394093527"; -- image id 
	Color = Color3.fromRGB(0, 85, 0);
	
	Description = "";
	
	
	-- SHOP --
	Class = "Flashlight";

	
	Data_Name = script.Name;
	Cost = 3000;
	Shop_Chance = 690; -- chance to appear out of 100 in purchasing_slot
	
	-- GAMEPLAY --
	Range = 25;
}

function Addon.Configure()
	Addon.Description = "Increases Flashlight range by <b><font color='#c2b00e'>"..Addon.Range.."</font></b> studs"
	
	return Addon
end

return Addon.Configure()
