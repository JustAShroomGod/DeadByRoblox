local Offering = {
	-- BASE --
	Active = false; -- should appear in game or be deactivated for now
	Testing = false; -- only appear for tester or above
	
	Name = "Eclipse Card";
	
	Image = "rbxassetid://18304657384"; -- image id
	Color = Color3.fromRGB(64, 50, 124);
	
	Description = "Block out the sun and submerge the map in total darkness with this offering";
	
	
	-- SHOP --
	Data_Name = script.Name;
	Cost = 10000;
	Shop_Chance = 100; -- chance to appear out of 100 in purchasing_slot
	
	-- GAMEPLAY --
	
}

function Offering.Configure()
	Offering.Description = "Turns the map into a darker, colder atmosphere."
	
	return Offering
end

return Offering.Configure()
