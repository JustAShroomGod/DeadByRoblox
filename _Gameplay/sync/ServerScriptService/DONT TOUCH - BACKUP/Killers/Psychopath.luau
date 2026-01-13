local Addon_Storage = game:GetService('ReplicatedStorage'):WaitForChild('Game_Data'):WaitForChild('Addons'):WaitForChild('Killer')
local Offering_Storage = game:GetService('ReplicatedStorage'):WaitForChild('Game_Data'):WaitForChild('Offerings'):WaitForChild('Killer')

local Killer = {
	-- BASE --
	Active = true; -- should appear in game or be deactivated for now
	Testing = false; -- only appear for tester or above
	Unlocked = false; -- if this killer should be unlocked for free at this moment if ever
	
	Amount = 750000; -- Amount to purchase with blood-points (for free-to-play), uncomment this if the killer is a game-pass killer you want to be unlockable at any point
	
	Killer_Name = "Psychopath";
	Killer_Image = "rbxassetid://10098762023"; -- image id
	
	Power_Name = "Blood Rage";
	Power_Image = "rbxassetid://10098704485"; -- image id
	Power_Color = Color3.fromRGB(56, 46, 43); -- color associated with images
	
	Description = "";

	Addons = {};
	Offerings = {};
	
	-- SHOP --
	Gamepasses = {
		263243375; -- new pass
		118389731; -- old pass
	}; -- gamepass id's that unlock this killer automatically

	-- GAMEPLAY --
	
	Starting_Amount = 25; -- percent of starting amount
	
	Duration = 30; -- seconds
	
	Aura_Distance = 150; -- in studs
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
<b>POWER GAUGE</b>
You start the trial with ]]..Killer.Starting_Amount..[[% of your <i>Power Gauge</i> filled.

You can fill your <i>Power Gauge</i> by the following actions:
	-Breaking pallets or breakable walls
	-Successfully attacking a survivor

When your <i>Power Gauge</i> reaches 100%, press <i>Power Button</i> to activate <i>Blood Rage</i>

<b>BLOOD RAGE</b>
When <i>Blood Rage</i> is activated, it lasts ]]..Killer.Duration..[[ seconds and grants the following effects:
	-Increased pallet breaking speed
	-Increased movement speed
	-Aura-reading on survivors for up to ]]..Killer.Aura_Distance..[[ studs
	
The following actions will deactivate <i>Blood Rage</i>:
	-Picking up a survivor
	-Getting stunned by any means
	-Searching lockers
]]

	GrabAddons()
	GrabOfferings()
	
	return Killer
end

return Killer.Configure()
