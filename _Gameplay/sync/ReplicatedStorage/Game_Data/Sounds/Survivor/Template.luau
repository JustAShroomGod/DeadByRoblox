local Sound_Storage = game:GetService('ReplicatedStorage'):WaitForChild('Game_Assets'):WaitForChild('Sounds')

local Sound_Pack = {
	-- BASE --
	Active = false; -- should appear in game or be deactivated for now
	Unlocked = false; -- if this sound-pack should be unlocked for free at this moment if ever
	Testing = false; -- only appear for tester or above

	Name = "Template";

	Image = ""; -- image id
	Color = Color3.fromRGB(255, 0, 0);

	Description = "";


	-- SHOP --
	Gamepasses = {}; -- gamepass ids that unlock this sound pack automatically
	--Cost = 0; -- Uncomment if purchasable sound pack in blood-store

	Data_Name = script.Name;

	-- GAMEPLAY --
	Hook_Scream = Sound_Storage:WaitForChild('Hooked'); -- hook scream sound for survivor
	Hit_Scream = Sound_Storage:WaitForChild('OnHit'); -- scream on hit
	Hit_Sound = Sound_Storage:WaitForChild('Hit_Sound');
	Hit_Down = Sound_Storage:WaitForChild('OnDown'):WaitForChild('Default');
	Injured = Sound_Storage:WaitForChild('Injured'):WaitForChild('Default'); -- Injured Audio/Loop for Survivor
	Step_Sound = Sound_Storage:WaitForChild('Walking'); -- walking for survivor
}

function Sound_Pack.Configure()
	Sound_Pack.Description = "Insert Values"

	return Sound_Pack
end

return Sound_Pack.Configure()
