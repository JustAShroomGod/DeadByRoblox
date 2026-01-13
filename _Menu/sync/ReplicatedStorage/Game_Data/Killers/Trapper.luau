local Addon_Storage = game:GetService('ReplicatedStorage'):WaitForChild('Game_Data'):WaitForChild('Addons'):WaitForChild('Killer')
local Offering_Storage = game:GetService('ReplicatedStorage'):WaitForChild('Game_Data'):WaitForChild('Offerings'):WaitForChild('Killer')

local Killer = {
	-- BASE --
	Active = true; -- should appear in game or be deactivated for now
	Testing = false; -- only appear for tester or above
	Unlocked = true; -- if this killer should be unlocked for free at this moment if ever
	
	Killer_Name = "Trapper";
	Killer_Image = "rbxassetid://81923519188962"; -- image id
	
	Power_Name = "Trap";
	Power_Image = "rbxassetid://18566607229"; -- image id
	Power_Color = Color3.fromRGB(56, 46, 43); -- color associated with images
	
	
	Description = "";

	Addons = {};
	Offerings = {};
	
	-- SHOP --
	Gamepasses = {}; -- gamepass id's that unlock this killer automatically

	-- GAMEPLAY --
	Trap_Amount = 8;
	Trap_Duration = 8;
	Trap_Set = 15;
	
	Terror_Radius = 100--studs
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
<b>BEAR TRAP</b>
The Trapper starts the match with <i>]]..Killer.Trap_Amount..[[ Bear Trap</i> equipped.

<b>COLLECTING A BEAR TRAP</b>
Press the <i>Interaction Button</i> while standing near a disarmed <i>Bear Trap</i> to pick it up. The Trapper can carry up to ]]..Killer.Trap_Amount..[[ <i>Bear Traps</i> at a time.

<b>SETTING BEAR TRAPS</b>
Press and hold the <i>Power Button</i> to set and arm a <i>Bear Trap</i> in a valid location infront of The Trapper. 
An armed <i>Bear Trap</i> will trap and immobilise any Survivor that steps into it. If the Survivor was healthy, they will be put into the Injured state.
An armed <i>Bear Trap</i> will also trap The Trapper, if he steps into his own <i>Bear Trap</i>, causing him to get stunned and drop any Survivor they were carrying.
A trapped Survivor can attempt to free themselves from the <i>Bear Trap</i> or have another Survivor rescue them.
]]
	--<b>CATCHING SURVIVORS IN BEAR TRAPS</b>
--	Press the <i>Interaction Button</i>  on a trapped Survivor to lift them out of the <i>Bear Trap</i> and onto The Trapper's shoulder.

	GrabAddons()
	GrabOfferings()
	
	return Killer
end

return Killer.Configure()
