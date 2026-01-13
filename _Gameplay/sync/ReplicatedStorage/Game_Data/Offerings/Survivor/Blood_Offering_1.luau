local Offering = {
	-- BASE --
	Active = true; -- should appear in game or be deactivated for now
	Testing = false; -- only appear for tester or above
	
	Name = "Golden Hay";
	
	Image = "rbxassetid://18304653697"; -- image id
	Color = Color3.fromRGB(177, 131, 22);
	
	Description = "";
	
	
	-- SHOP --
	Data_Name = script.Name;
	Cost = 3000;
	Shop_Chance = 500; -- chance to appear out of 100 in purchasing_slot
	
	-- GAMEPLAY --
	Multiplier = 1;
}

function Offering.Configure()
	Offering.Description = "The Sacred Cow will be pleased with this Offer; When using this Offering you will gain <b><font color='#c2b00e'>"..tostring(Offering.Multiplier * 100).."</font></b>% more blood in the match!"
	
	return Offering
end

return Offering.Configure()
