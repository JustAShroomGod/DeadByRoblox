local Addon_Storage = game:GetService('ReplicatedStorage'):WaitForChild('Game_Data'):WaitForChild('Addons'):WaitForChild('Killer')
local Offering_Storage = game:GetService('ReplicatedStorage'):WaitForChild('Game_Data'):WaitForChild('Offerings'):WaitForChild('Killer')

local Killer = {
	-- BASE --
	Active = true; -- should appear in game or be deactivated for now
	Testing = false; -- only appear for tester or above
	Unlocked = true; -- if this killer should be unlocked for free at this moment if ever
	
	Killer_Name = "Wraith";
	Killer_Image = "rbxassetid://90418121304545"; -- image id
	
	Power_Name = "Cloak";
	Power_Image = "rbxassetid://18752316856"; -- image id
	Power_Color = Color3.fromRGB(56, 46, 43); -- color associated with images
	
	Description = "";

	Addons = {};
	Offerings = {};
	
	-- SHOP --
	Gamepasses = {}; -- gamepass id's that unlock this killer automatically

	-- GAMEPLAY --
	
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

<b>UNCLOAK</b>
Press and hold the <i>Power Button</i> to <i>Cloak</i>,press and hold the <i>Power Button</i> to <i>Uncloak</i> which grants a temporarily speed boost after <i>Uncloaking</i>.

<b>CLOAK</b>
Grants increased movement speed.
The <i>Wraith</i> is nearly fully invisible up close, but fades out the further he is.
Grants <i>Hidden</i> status effect.
You aren't able to attack while <i>Cloaked</i> but can interact with enviromental objects.

]]

	GrabAddons()
	GrabOfferings()
	
	return Killer
end

return Killer.Configure()
