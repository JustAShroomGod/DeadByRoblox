local Offering = {
	-- BASE --
	Active = true; -- should appear in game or be deactivated for now
	Testing = false; -- only appear for tester or above
	
	Name = "Dead Dawg Saloon Card";
	
	Image = "rbxassetid://110366526714347"; -- image id
	Color = Color3.fromRGB(13, 80, 6);
	
	Description = "Raises the chances of being sent to the Dead Dawg Saloon map.";
	
	-- SHOP --
	Data_Name = script.Name;
	Cost = 2500;
	Shop_Chance = 500; -- chance to appear out of 1000 in purchasing_slot
	
	-- GAMEPLAY --
	
}

function Offering.Configure()
	return Offering
end

return Offering.Configure()
