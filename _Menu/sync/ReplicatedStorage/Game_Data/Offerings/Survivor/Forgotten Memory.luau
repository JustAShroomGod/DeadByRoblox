local Offering = {
	-- BASE --
	Active = false; -- should appear in game or be deactivated for now
	Testing = false; -- only appear for tester or above
	
	Name = "Forgotten Memory Card";

	Image = "rbxassetid://130068985755840"; -- image id
	Color = Color3.fromRGB(13, 80, 6);

	Description = "Raises the chances of being sent to the Forgotten Memory map.";
	
	-- SHOP --
	Data_Name = script.Name;
	Cost = 2500;
	Shop_Chance = 200; -- chance to appear out of 1000 in purchasing_slot
	
	-- GAMEPLAY --
	
}

function Offering.Configure()
	return Offering
end

return Offering.Configure()
