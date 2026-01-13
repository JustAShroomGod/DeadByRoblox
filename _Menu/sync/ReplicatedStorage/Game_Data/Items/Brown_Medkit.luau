local Item = {
	-- BASE --
	Active = true; -- should appear in game or be deactivated for no
	Equipable = true; -- can equip from inventory
	Testing = false; -- only appear for tester or above
	
	Name = "Basic Aid Pouch";
	
	Variant = "Brown"; -- red/yellow = red flashlight yellow flashlight
	Class = "Medkit"; -- firecracker, medkit, flashlight
	
	Image = "rbxassetid://14730241876"; -- image id
	Color = Color3.fromRGB(56, 46, 43); -- color associated with images

	Description = "Just an Item...";

	Addons = {}; -- redirect/list of addon listings
	-- SHOP --
	Data_Name = script.Name;
	Cost = 1000; -- price to buy
	Shop_Chance = 0; -- chance to appear out of 1000 in purchasing_slot
	
	-- GAMEPLAY --
	Loot_Chance = 800; -- chance to appear out of 1000 in chest
	
	Charges = 16; -- total charges
	Drain = 0.9; -- drain per second of use

	Heal_Rate = 1; -- speed at which you heal yourself
	Heal_Bonus = 1.4; -- 1.4x bonus when used on others
}

function Item.Configure()
	Item.Description = "Allows you to heal yourself at a speed of <b><font color='#c2b00e'>"..math.round(Item.Heal_Rate * 100).."%</font></b>, Drains at a rate of <b><font color='#c2b00e'>"..math.round(Item.Drain * 100 + 10).."%</font></b>, & contains <b><font color='#c2b00e'>"..Item.Charges.."</font></b> Charges. (16 charges are needed for a full heal at normal drain rates)"
	
	return Item
end



return Item.Configure()
