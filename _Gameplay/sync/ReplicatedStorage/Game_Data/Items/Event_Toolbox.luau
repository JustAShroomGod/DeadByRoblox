local Item = {
	-- BASE --
	Active = true; -- should appear in game or be deactivated for now
	Testing = false; -- only appear for tester or above
	Equipable = true; -- can equip from inventory
	
	Name = "Celebration Kit";
	
	Variant = "Event"; -- red/yellow = red flashlight yellow flashlight
	Class = "Toolbox"; -- firecracker, medkit, flashlight
	
	Image = "rbxassetid://14730395910"; -- image id
	Color = Color3.fromRGB(255, 149, 0); -- color associated with images

	Description = "Just an Item...";

	Addons = {}; -- redirect/list of addon listings
	-- SHOP --
	Data_Name = script.Name;
	Cost = 4000; -- price to buy
	Shop_Chance = 0; -- chance to appear out of 1000  in purchasing_slot
	
	-- GAMEPLAY --
	Loot_Chance = 0; -- chance to appear out of 1000  in chest

	Charges = 16; -- total charges

	Repair_Speed_Multiplier = 1.4; -- 1.3x faster
	Sabatage_Speed_Multiplier = 1.3; -- 1x capable of doing it

	Repair_Drain = .8; -- charges drained per second
	Sabatage_Drain = 1;

	Sabatage_Time_Bonus = 10; -- Add or Subtract to basekit hook down time (seconds)
}

function Item.Configure()
	Item.Description = "Contain <b><font color='#c2b00e'>"..Item.Charges..[[</font></b> Charges
Allows you to sabatage hooks at a rate of <b><font color='#c2b00e'>]]..math.round(Item.Sabatage_Speed_Multiplier * 100).."%</font></b> with an consumpation rate of <b><font color='#c2b00e'>"..math.round(Item.Sabatage_Drain * 100).."%</font></b> and keeps the hooks broken for <b><font color='#c2b00e'>"..math.round(20 + Item.Sabatage_Time_Bonus)..[[</font></b> seconds.
Allows you to repair generators at a rate of <b><font color='#c2b00e'>]]..math.round(Item.Repair_Speed_Multiplier * 100).."%</font></b> with a consumption rate of <b><font color='#c2b00e'>"..math.round(Item.Repair_Drain * 100).."%</font></b>."

	return Item
end



return Item.Configure()
