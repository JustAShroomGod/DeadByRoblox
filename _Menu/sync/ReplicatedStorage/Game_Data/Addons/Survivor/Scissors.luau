
local Addon = {
	-- BASE --
	Active = true; -- should appear in game or be deactivated for now
	Testing = false; -- only appear for tester or above
	
	Name = "Scissors";
	
	Image = "rbxassetid://111575828689765"; -- image id
	Color = Color3.fromRGB(0, 85, 0);
	
	Description = "";
	
	
	-- SHOP --
	Class = "Medkit";

	
	Data_Name = script.Name;
	Cost = 2500;
	Shop_Chance = 600; -- chance to appear out of 100 in purchasing_slot
	
	-- GAMEPLAY --
	Speed = 0.25;
	
}

function Addon.Configure()
	Addon.Description = "increases healing speed by <b><font color='#c2b00e'>"..(Addon.Speed * 100).."%</font></b>"
	
	return Addon
end

return Addon.Configure()
