local Addon_Storage = game:GetService('ReplicatedStorage'):WaitForChild('Game_Data'):WaitForChild('Addons'):WaitForChild('Killer')
local Offering_Storage = game:GetService('ReplicatedStorage'):WaitForChild('Game_Data'):WaitForChild('Offerings'):WaitForChild('Killer')

local Killer = {
	-- BASE --
	Active = true; -- should appear in game or be deactivated for now
	Testing = false; -- only appear for tester or above
	Unlocked = false; -- if this killer should be unlocked for free at this moment if ever
	
	Amount = 1000000;
	
	Killer_Name = "Phantasm";
	Killer_Image = "rbxassetid://129185623191596"; -- image id
	
	Power_Name = "Dark Presence";
	Power_Image = "rbxassetid://111350089634811"; -- image id
	Power_Color = Color3.fromRGB(56, 46, 43); -- color associated with images
	
	Description = "";

	Addons = {};
	Offerings = {};
	
	-- SHOP --
	Gamepasses = {
		"1233201309";--bundle
		"1233324882"; --killer unlock
	}; -- gamepass id's that unlock this perk automatically


	-- GAMEPLAY --
	
	Wave_Recharge = 16;
	Wave_Start_Percentage = 0;
	Wave_Distance = 65;
	Wave_Travel_Time = 0.03;
	
	Darkness_Duration = 14;
	Phantasm_Frequency = 4.5;
	Phantasm_Lifetime = 26;
	Phantasm_Maximum = 4;
	
	Teleport_Curve = 1;
	Teleport_Boost_Duration = 2;
	Teleport_Boost_Percentage = 30;
	Teleport_Slow_Duration = 2;
	Teleport_Slow_Percentage = 40;
	
	Terror_Radius = 100 --studs
}

function GrabAddons() : "Attach our addons"

	for _, addon_module in pairs(Addon_Storage:GetChildren()) do
		if not addon_module:IsA('ModuleScript') then continue end -- not a module?
		addon_module = require(addon_module)

		for _, addon_killer in pairs(addon_module.Killers) do -- if it's a addon for our killer we attach it

			if addon_killer == script then
				table.insert(Killer.Addons, addon_module) -- attach to us
				break -- close thinking early
			end
		end
	end
end

function GrabOfferings() : "Attach our offerings"

	for _, offering_module in pairs(Offering_Storage:GetChildren()) do
		if not offering_module:IsA('ModuleScript') then continue end
		offering_module = require(offering_module)

		for _, offering_killer in pairs(offering_module.Killers) do

			if offering_killer == script then
				table.insert(Killer.Offerings, offering_module)
				break
			end
		end
	end
end

function Killer.Configure()
	Killer.Description = [=[
<b>Dark Presence</b>

<b>Active Ability:</b> Send Wave
- Press the <i>Power Button</i> to send out a Wave of Darkness:
- Survivors hit by the Wave will be inflicted with Darkness for ]=] .. Killer.Darkness_Duration .. [=[ seconds

<b>While suffering from Darkness</b>:
- Survivors leave a Trail that lingers for a short time
- An After Image of the Survivor is created every ]=] .. Killer.Phantasm_Frequency .. [=[ seconds
- Only ]=] .. Killer.Phantasm_Maximum .. [=[ After Images of a Survivor can exist at a time
- After Images are destroyed after ]=] .. Killer.Phantasm_Lifetime .. [=[ seconds

<b>Alternative Ability:</b> Teleport
- Press the <i>Secondary Power Button</i> to teleport to an After Image:
- Teleporting to an After Image destroys it immediately
- After the Teleport you gain a ]=] .. Killer.Teleport_Boost_Percentage .. [=[% Haste Bonus for ]=] .. Killer.Teleport_Boost_Duration .. [=[ seconds
- When the Haste Bonus expires you gain a ]=] .. Killer.Teleport_Slow_Percentage .. [=[% Slow Debuff for ]=] .. Killer.Teleport_Slow_Duration .. [=[ seconds
]=]

	GrabAddons()
	GrabOfferings()
	
	return Killer
end

return Killer.Configure()
