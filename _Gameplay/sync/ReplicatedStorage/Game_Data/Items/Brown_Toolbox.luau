local Item = {
	-- BASE --
	Active = true; -- should appear in game or be deactivated for now
	Equipable = true; -- can equip from inventory
	Testing = false; -- only appear for tester or above
	
	Name = "Worn-Out Tools";
	
	Variant = "Brown"; -- red/yellow = red flashlight yellow flashlight
	Class = "Toolbox"; -- firecracker, medkit, flashlight
	
	Image = "rbxassetid://14730239991"; -- image id
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
	
	Repair_Speed_Multiplier = 1.2; -- 1.3x faster
	Sabatage_Speed_Multiplier = 1; -- 1x capable of doing it
	
	Repair_Drain = 1; -- charges drained per second
	Sabatage_Drain = 1;
	
	Sabatage_Time_Bonus = 10; -- Add or Subtract to basekit hook down time (seconds)
}

function Item.Configure()
	Item.Description = "Contain <b><font color='#c2b00e'>"..Item.Charges..[[</font></b> Charges
Allows you to sabotage hooks at a rate of <b><font color='#c2b00e'>]]..math.round(Item.Sabatage_Speed_Multiplier * 100).."%</font></b> with an consumpation rate of <b><font color='#c2b00e'>"..math.round(Item.Sabatage_Drain * 100).."%</font></b> and keeps the hooks broken for <b><font color='#c2b00e'>"..math.round(20 + Item.Sabatage_Time_Bonus)..[[</font></b> seconds.
Allows you to repair generators at a rate of <b><font color='#c2b00e'>]]..math.round(Item.Repair_Speed_Multiplier * 100).."%</font></b> with a consumption rate of <b><font color='#c2b00e'>"..math.round(Item.Repair_Drain * 100).."%</font></b>."

	return Item
end



return Item.Configure()

