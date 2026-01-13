local Killer_Storage = game:GetService('ReplicatedStorage'):WaitForChild('Game_Data'):WaitForChild('Killers')
local Sound_Storage = game:GetService('ReplicatedStorage'):WaitForChild('Game_Assets'):WaitForChild('Sounds')

local Sound_Pack = {
	-- BASE --
	Active = false; -- should appear in game or be deactivated for now
	Unlocked = false; -- if this sound-pack should be unlocked for free at this moment if ever
	Testing = false; -- only appear for tester or above
	
	Name = "Default Sound Pack";
	
	Image = ""; -- image id
	Color = Color3.fromRGB(94, 94, 94);
	
	Description = "";
	
	
	-- SHOP --
	Gamepasses = {}; -- gamepass ids that unlock this sound pack automatically
	--Cost = 0; -- Uncomment if purchasable sound pack in blood-store
	
	Killers = { -- killers this sound pack should show up for
		Killer_Storage:WaitForChild('Trapper');
		Killer_Storage:WaitForChild('Reaper');
		Killer_Storage:WaitForChild('Wraith');
		Killer_Storage:WaitForChild('Huntress');
		Killer_Storage:WaitForChild('Architect');
		Killer_Storage:WaitForChild('Ninja');
		Killer_Storage:WaitForChild('Hillbilly');
		Killer_Storage:WaitForChild('Nurse');
		Killer_Storage:WaitForChild('Psychopath');
		Killer_Storage:WaitForChild('Stalker')
	},
	
	Data_Name = script.Name;
	
	-- GAMEPLAY --
	Heartbeat = Sound_Storage:WaitForChild('Heartbeat'):WaitForChild('Default'); -- heartbeat sound/music for killer
	Stunned = Sound_Storage:WaitForChild('Stuns'):WaitForChild('Killer_Default'); -- stun sound for killer
	Chase = Sound_Storage:WaitForChild('Chase_Music'):WaitForChild('Chase_Default'); -- chase music for killer
	Step_Sound = Sound_Storage:WaitForChild('Footsteps'):WaitForChild('Killer_Walk_Default'); -- walking for killer
	Swing = Sound_Storage:WaitForChild('Swing'):WaitForChild('LungeSound');
	Attack = Sound_Storage:WaitForChild('Attack'):WaitForChild('SwingSound')
}

function Sound_Pack.Configure()
	
	Sound_Pack.Description = "Insert Values"
	
	return Sound_Pack
end

return Sound_Pack.Configure()
