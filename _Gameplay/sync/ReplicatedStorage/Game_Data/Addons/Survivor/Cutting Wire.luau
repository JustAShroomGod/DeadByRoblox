
local Addon = {
	-- BASE --
	Active = true; -- should appear in game or be deactivated for now
	Testing = false; -- only appear for tester or above
	
	Name = "Cutting Wire";
	
	Image = "rbxassetid://72594558634481"; -- image id
	Color = Color3.fromRGB(0, 85, 0);
	
	Description = "";
	
	
	-- SHOP --
	Class = "Toolbox";

	
	Data_Name = script.Name;
	Cost = 3000;
	Shop_Chance = 550; -- chance to appear out of 100 in purchasing_slot
	
	-- GAMEPLAY --
	SSpeed = 1.2;
}

function Addon.Configure()
	Addon.Description = "Increases Toolbox sabotaging speed by <b><font color='#c2b00e'>"..(Addon.SSpeed * 10).."%</font></b>"
	
	return Addon
end

return Addon.Configure()
