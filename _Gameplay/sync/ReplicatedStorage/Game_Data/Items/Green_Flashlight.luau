local Item = {
	-- BASE --
	Active = true; -- should appear in game or be deactivated for now
	Testing = false; -- only appear for tester or above
	Equipable = true; -- can equip from inventory
	
	Name = "Industrial Flashbeam";
	
	Variant = "Green"; -- red/yellow = red flashlight yellow flashlight
	Class = "Flashlight"; -- firecracker, medkit, flashlight
	
	Image = "rbxassetid://14730240423"; -- image id
	Color = Color3.fromRGB(29, 120, 39); -- color associated with images

	Description = "Just an Item...";

	Addons = {}; -- redirect/list of addon listings
	-- SHOP --
	Data_Name = script.Name;
	Cost = 3000; -- price to buy
	Shop_Chance = 220; -- chance to appear out of 1000 in purchasing_slot
	
	-- GAMEPLAY --
	Loot_Chance = 600; -- chance to appear out of 1000 in chest

	Charges = 16; -- total charges
	Drain = 0.75; -- charges drained per second

	Range = 40; -- studs/distance of beam
	Spread = 1.5; -- width of window to hit/aim for
	Brightness = 1.5; -- rate/speed of blinding
}

function Item.Configure()
	Item.Description = "Contains <b><font color='#c2b00e'>"..Item.Charges..[[</font></b> charges
Drain Rate - <b><font color='#c2b00e'>]]..math.round(Item.Drain * 100)..[[%</font></b>
Range of Beam - <b><font color='#c2b00e'>]]..Item.Range..[[</font></b> studs
Spread of Beam - <b><font color='#c2b00e'>]]..Item.Spread..[[</font></b> studs
Brightness - <b><font color='#c2b00e'>]]..math.round(Item.Brightness * 100).."%</font></b>."

	return Item
end

return Item.Configure()
