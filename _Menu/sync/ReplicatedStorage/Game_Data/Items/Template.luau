local Item = {
	-- BASE --
	Active = false; -- should appear in game or be deactivated for now
	Testing = false; -- only appear for tester or above
	Equipable = false; -- can equip from inventory
	
	Variant = "Template"; -- red/yellow = red flashlight yellow flashlight
	Class = "Template"; -- firecracker, medkit, flashlight
	
	Image = ""; -- image id
	Color = Color3.fromRGB(255, 255, 255); -- color associated with images

	Description = "Just an Item...";

	Addons = {}; -- redirect/list of addon listings
	-- SHOP --
	Data_Name = script.Name;
	Cost = 0; -- price to buy
	Shop_Chance = 0; -- chance to appear out of 1000  in purchasing_slot
	
	-- GAMEPLAY --
	Loot_Chance = 0; -- chance to appear out of 1000  in chest
	
}

return Item
