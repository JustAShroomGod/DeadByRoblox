local Item = {
	-- BASE --
	Active = false; -- should appear in game or be deactivated for now
	Testing = false; -- only appear for tester or above
	Equipable = false; -- can equip from inventory
	
	Name = "Bone Knife";
	
	Variant = "Purple"; -- red/yellow = red flashlight yellow flashlight
	Class = "Key"; -- firecracker, medkit, flashlight
	
	Image = "rbxassetid://14122274659"; -- image id
	Color = Color3.fromRGB(108, 0, 118); -- color associated with images

	Description = "Just an Item...";

	Addons = {}; -- redirect/list of addon listings
	-- SHOP --
	Data_Name = script.Name;
	Cost = 0; -- price to buy
	Shop_Chance = 0; -- chance to appear out of 1000  in purchasing_slot | must be at least 0.01 to spawn
	
	-- GAMEPLAY --
	Loot_Chance = 0; -- chance to appear out of 1000  in chest
	Stun_Duration = 3;
	
}

function Item.Configure()
	Item.Description = "Stabby stabby"

	return Item
end



return Item.Configure()
