local Addon_Storage = game:GetService('ReplicatedStorage'):WaitForChild('Game_Data'):WaitForChild('Addons'):WaitForChild('Killer')
local Offering_Storage = game:GetService('ReplicatedStorage'):WaitForChild('Game_Data'):WaitForChild('Offerings'):WaitForChild('Killer')

local Killer = {
	-- BASE --
	Active = true; -- should appear in game or be deactivated for now
	Testing = true; -- only appear for tester or above
	Unlocked = false; -- if this killer should be unlocked for free at this moment if ever

	Killer_Name = "Scientist";
	Killer_Image = "rbxassetid://136024258126709"; -- image id

	Power_Name = "Time Dilation";
	Power_Image = "rbxassetid://72592676566403"; -- image id
	Power_Color = Color3.fromRGB(56, 46, 43); -- color associated with images

	Description = "";

	Addons = {};
	Offerings = {};

	-- SHOP --
	Gamepasses = {}; -- gamepass id's that unlock this killer automatically

	-- GAMEPLAY --
	PowerValues = {
		Current = 0;
		Killer_Effectiveness = 0.85;
		Recharge_Rate = 100 / 80;
		Reverse_Duration = 0.5;
		Drop_Off_Distance = 80;
		Scale_Interval = 0.25;
		Dilation_Radius = 120;
		Drop_Off_Limit = 0.5;
		Time_To_Reverse = 5;
		Min_Scale = 0.25;
		Max_Scale = 2.0;
	};
	
	
	Terror_Radius = 120; --studs
	
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
<b>Time Manipulation</b>

- He does stuff lol
]]

	GrabAddons()
	GrabOfferings()

	return Killer
end

return Killer.Configure()
