local Sound_Storage = game:GetService('ReplicatedStorage'):WaitForChild('Game_Assets'):WaitForChild('Sounds')

local Sound_Pack = {
	-- BASE --
	Active = false; -- should appear in game or be deactivated for now
	Unlocked = false; -- if this sound-pack should be unlocked for free at this moment if ever
	Testing = false; -- only appear for tester or above

	Name = "Default Sound Pack";

	Image = ""; -- image id
	Color = Color3.fromRGB(77, 77, 77);

	Description = "";


	-- SHOP --
	Gamepasses = {}; -- gamepass ids that unlock this sound pack automatically
	--Cost = 0; -- Uncomment if purchasable sound pack in blood-store

	Data_Name = script.Name;

	-- ========= GAMEPLAY ========== --
	
	-- Character --
	Hook_Scream = Sound_Storage:WaitForChild('OnHooked'):WaitForChild('Default'); -- hook scream sound for survivor
	Hit_Scream = Sound_Storage:WaitForChild('OnHit'):WaitForChild('Default'); -- scream on hit
	Hit_Sound = Sound_Storage:WaitForChild('Hit_Sound'):WaitForChild('Survivor');
	DownOnHit_Sound = Sound_Storage:WaitForChild('OnHit'):WaitForChild('Default_Down');
	Injured = Sound_Storage:WaitForChild('Injured'):WaitForChild('Default'); -- Injured Audio/Loop for Survivor
	Walk_Step_Sound = Sound_Storage:WaitForChild('Footsteps'):WaitForChild('Survivor_Walk_Default'); -- walking for survivor
	Run_Step_Sound = Sound_Storage:WaitForChild('Footsteps'):WaitForChild('Survivor_Run_Default'); -- running for survivor
	Healing = nil;
	
	-- Skill Checks --
	Skill_Alert = Sound_Storage:WaitForChild('Skill_Checks'):WaitForChild('Default_Alert');
	Skill_Good = Sound_Storage:WaitForChild('Skill_Checks'):WaitForChild('Default_Good');
	Skill_Great = Sound_Storage:WaitForChild('Skill_Checks'):WaitForChild('Default_Great');
	Skill_Miss = Sound_Storage:WaitForChild('Skill_Checks'):WaitForChild('Default_Alert');
	
	-- Items --
	Flashlight = {
		On = Sound_Storage:WaitForChild('Items'):WaitForChild('Flashlight'):WaitForChild('Default_Toggle_On');
		Off = Sound_Storage:WaitForChild('Items'):WaitForChild('Flashlight'):WaitForChild('Default_Toggle_Off');
	},
}

function Sound_Pack.Configure()
	Sound_Pack.Description = "Insert Values"

	return Sound_Pack
end

return Sound_Pack.Configure()
