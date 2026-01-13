
local Addon = {
	-- BASE --
	Active = true; -- should appear in game or be deactivated for now
	Testing = false; -- only appear for tester or above
	
	Name = "Bright Bulb";
	
	Image = "rbxassetid://105670152935986"; -- image id 
	Color = Color3.fromRGB(132, 1, 36);
	
	Description = "";
	
	
	-- SHOP --
	Class = "Flashlight";

	
	Data_Name = script.Name;
	Cost = 5000;
	Shop_Chance = 150; -- chance to appear out of 100 in purchasing_slot
	
	-- GAMEPLAY --
	Brightness = 0.5;
	
}

function Addon.Configure()
	Addon.Description = "Increases blinding speed by <b><font color='#c2b00e'>"..(Addon.Brightness * 100).."%</font></b>"
	
	return Addon
end

return Addon.Configure()
