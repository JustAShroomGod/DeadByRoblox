
local Addon = {
	-- BASE --
	Active = true; -- should appear in game or be deactivated for now
	Testing = false; -- only appear for tester or above
	
	Name = "High-End Sapphire Lens";
	
	Image = "rbxassetid://132798819983176"; -- image id 
	Color = Color3.fromRGB(85, 0, 127);
	
	Description = "";
	
	
	-- SHOP --
	Class = "Flashlight";

	
	Data_Name = script.Name;
	Cost = 4000;
	Shop_Chance = 250; -- chance to appear out of 100 in purchasing_slot
	
	-- GAMEPLAY --
	Range = 40;
}

function Addon.Configure()
	Addon.Description = "Increases Flashlight range by <b><font color='#c2b00e'>"..Addon.Range.."</font></b> studs"
	
	return Addon
end

return Addon.Configure()
