local Offering = {
	-- BASE --
	Active = false; -- should appear in game or be deactivated for now
	Testing = false; -- only appear for tester or above
	
	Name = "Full-Moon Card";
	
	Image = "rbxassetid://18304653277"; -- image id
	Color = Color3.fromRGB(64, 115, 255);
	
	Description = "";
	
	
	-- SHOP --
	Data_Name = script.Name;
	Cost = 10000;
	Shop_Chance = 200; -- chance to appear out of 100 in purchasing_slot
	
	-- GAMEPLAY --
	
}

function Offering.Configure()
	Offering.Description = "In this well lit night everything becomes clearer"
	
	return Offering
end

return Offering.Configure()
