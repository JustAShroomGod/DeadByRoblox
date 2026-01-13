
local Addon = {
	-- BASE --
	Active = true; -- should appear in game or be deactivated for now
	Testing = false; -- only appear for tester or above
	
	Name = "Clean Rag";
	
	Image = "rbxassetid://119215612411177"; -- image id 
	Color = Color3.fromRGB(0, 85, 0);
	
	Description = "";
	
	
	-- SHOP --
	Class = "Toolbox";

	
	Data_Name = script.Name;
	Cost = 3000;
	Shop_Chance = 500; -- chance to appear out of 100 in purchasing_slot
	
	-- GAMEPLAY --
	RSpeed = .5;
}

function Addon.Configure()
	Addon.Description = "Increases Toolbox repair speed by <b><font color='#c2b00e'>"..(Addon.RSpeed * 10).."%</font></b>"
	
	return Addon
end

return Addon.Configure()
