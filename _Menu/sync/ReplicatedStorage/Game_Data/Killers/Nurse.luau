local Addon_Storage = game:GetService('ReplicatedStorage'):WaitForChild('Game_Data'):WaitForChild('Addons'):WaitForChild('Killer')
local Offering_Storage = game:GetService('ReplicatedStorage'):WaitForChild('Game_Data'):WaitForChild('Offerings'):WaitForChild('Killer')

local Killer = {
	-- BASE --
	Active = true; -- should appear in game or be deactivated for now
	Testing = false; -- only appear for tester or above
	Unlocked = true; -- if this killer should be unlocked for free at this moment if ever
	
	Killer_Name = "Nurse";
	Killer_Image = "rbxassetid://104752000783531"; -- image id
	
	Power_Name = "Blink";
	Power_Image = "rbxassetid://87772277127004"; -- image id
	Power_Color = Color3.fromRGB(56, 46, 43); -- color associated with images
	
	Description = "";

	Addons = {};
	Offerings = {};
	
	-- SHOP --
	Gamepasses = {}; -- gamepass id's that unlock this killer automatically

	-- GAMEPLAY --
	
	Base_Max_Blinks = 2;
	
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
	Killer.Description = [[
<b>BLINK</b>
The Nurse passively recharges her Blink Charges when not in use.

When the <i>Power Gauge</i> is filled, the Nurse gains a Blink Charge.

Hold down the <i>Power Button</i> to start charging a Blink:
- Charging a Blink for longer causes the Nurse to teleport further.
- Releasing a Blink consumes a Blink Charge.

Releasing a charged Blink will teleport the Nurse to her destination.

After teleporting the Nurse is given 2 options:
- Charge a Chain Blink (When at least one Blink Charge is left)
- Perform a Blink Attack

When none of those options is chosen the Nurse will enter <i>Fatigue</i>.
The Nurse can hold up to ]]..Killer.Base_Max_Blinks..[[ Blinks .
]] 


	GrabAddons()
	GrabOfferings()
	
	return Killer
end

return Killer.Configure()
