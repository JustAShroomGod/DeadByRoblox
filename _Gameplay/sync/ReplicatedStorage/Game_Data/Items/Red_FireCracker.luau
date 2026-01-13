local Item = {
	-- BASE --
	Active = true; -- should appear in game or be deactivated for now
	Testing = false; -- only appear for tester or above
	Equipable = true; -- can equip from inventory

	Name = "Firecracker";

	Variant = "Red"; -- red/yellow = red flashlight yellow flashlight
	Class = "FireCracker"; -- firecracker, medkit, flashlight

	Image = "rbxassetid://14730238970"; -- image id
	Color = Color3.fromRGB(255, 0, 0); -- color associated with images

	Description = "Just an Item...";

	Addons = {}; -- redirect/list of addon listings
	-- SHOP --
	Data_Name = script.Name;
	Cost = 3000; -- price to buy
	Shop_Chance = 0; -- chance to appear out of 1000  in purchasing_slot

	-- GAMEPLAY --
	Loot_Chance = 0; -- chance to appear out of 1000  in chest

	Charge_Time = 1.5

}

function Item.Configure()
	Item.Description = "Allows you to drop a firework that instantly blinds the killer after <b><font color='#c2b00e'>"..Item.Charge_Time..[[</font></b> seconds.]]

	return Item
end



return Item.Configure()

