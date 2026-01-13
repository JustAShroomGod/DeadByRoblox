local Addon_Storage = game:GetService('ReplicatedStorage'):WaitForChild('Game_Data'):WaitForChild('Addons'):WaitForChild('Killer')
local Offering_Storage = game:GetService('ReplicatedStorage'):WaitForChild('Game_Data'):WaitForChild('Offerings'):WaitForChild('Killer')

local Killer = {
	-- BASE --
	Active = true; -- should appear in game or be deactivated for now
	Testing = false; -- only appear for tester or above
	Unlocked = false; -- if this killer should be unlocked for free at this moment if ever

	Amount = 1000000; -- Amount to purchase with blood-points (for free-to-play), uncomment this if the killer is a game-pass killer you want to be unlockable at any point

	Killer_Name = "Reaper";
	Killer_Image = "rbxassetid://16870650350"; -- image id

	Power_Name = "Soul-Bind";
	Power_Image = "rbxassetid://14832382341"; -- image id
	Power_Color = Color3.fromRGB(56, 46, 43); -- color associated with images

	Description = "";

	Addons = {};
	Offerings = {};

	-- SHOP --
	Gamepasses = {
		-- flytrap group
		258123138,
		262708425,
		-- new group --
		263241247, -- dlc
		263241765, -- bundle
	}; -- gamepass id's that unlock this killer automatically

	-- GAMEPLAY --
	Charges = {
		Base = 1;
		Max = 5;
		Gain = 1;
	},

	Speeds = {
		Slam_Reduction = 1;
		Post_Slam = 4;
	},

	Timings = {
		Slam = 2.8;
	},

	Soul_Bound = {
		Radius = 120;
		Wave_Speed = 50;
		Duration = 27;
	},
	
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

function Killer:Power_Client(Player : Player) : "Adjust Power on Client Side"
	if not game["Run Service"]:IsClient() then return end -- not for server use
	local Data_Module = require(game:GetService('ReplicatedStorage'):WaitForChild('Modules'):WaitForChild('Data'))

	-- Apply Addons Here --

	for _, Addon in pairs(Killer.Addons) do -- cycle through all addons

		if Data_Module:GetAddon("Killer", Player, Addon.Data_Name) then -- have this addon equipped currently

		end
	end
end

function Killer:Power(Player : Player) : "Boot up / configure power"
	local Data_Module = require(game:GetService('ReplicatedStorage'):WaitForChild('Modules'):WaitForChild('Data'))

	-- Apply Addons Here | Camera Changes will not work [made dual power booting] | No Speed Changes --

	for _, Addon in pairs(Killer.Addons) do -- cycle through all addons

		if Data_Module:GetAddon("Killer", Player, Addon.Data_Name) then -- have this addon equipped currently

			if Addon.Slam_Haste then
				Killer.Speeds.Post_Slam = math.clamp(Killer.Speeds.Post_Slam + Addon.Slam_Haste, 0, 1.5)
			end

			if Addon.Start_Charges then
				Killer.Charges.Base = math.clamp(Killer.Charges.Base + Addon.Start_Charges, 0, tonumber(Killer.Charges.Max))
			end
			
			if Addon.Wave_Speed_Boost then
				Killer.Soul_Bound.Wave_Speed = math.clamp(Killer.Soul_Bound.Wave_Speed + Addon.Wave_Speed_Boost,10, 2000)
			end

			if Addon.Max_Charges then
				Killer.Charges.Max = math.clamp(Killer.Charges.Max + Addon.Max_Charges, 1, 10)
			end

			if Addon.Slam_Speed_Boost then
				Killer.Timings.Slam = math.clamp(Killer.Timings.Slam/(1 + Addon.Slam_Speed_Boost), 1, 50)
			end
			
			if Addon.Charges_Gain then
				Killer.Charges.Gain = math.clamp(Killer.Charges.Gain + Addon.Charges_Gain, 1, 10)
			end

			if Addon.Radius_Increase then
				Killer.Soul_Bound.Radius = math.clamp(Killer.Soul_Bound.Radius * (1 + Addon.Radius_Increase), 10, 2000)
			end

			if Addon.Duration_Increase then
				Killer.Soul_Bound.Duration = math.clamp(Killer.Soul_Bound.Duration * (1 + Addon.Duration_Increase), 10, 120)
			end
		end
	end

	Player.Character:SetAttribute("Power", Killer.Charges.Base..':'..Killer.Charges.Max)
	Player.Character:SetAttribute("Power_State", "Idle") -- manipulate power

	return Killer
end

function Killer.Configure()
	Killer.Description = [[
<b>SOUL-BIND</b>
You and your scythe are bonded, you must satiate it's hunger by utilizing the power of soul-bind. After all the chain is only as strong as it's weakest link.
	<i> "Feed me" - The Scythe </i>
 
<b>SOUL BOUND</b>
Consume a charge and use the scythe's power to send out a shock-wave of energy. Survivors caught in this energy will suffer the soul-bound effect for 30 seconds.
	- Soul-Bound : When you or any other currently binded survivor are damaged you all suffer damage and lose the effect. This damage can be avoided if hiding inside a locker, but the effect will remain.  

<b>CHARGES</b>
Start with 1 Charge, you gain charges by landing a hit on any survivor not afflicted with the soul-bound status.	

<b>SPEED BOOST</b>
After consuming a soul charge, you will get a speed boost that lasts 10 seconds.

]]

	GrabAddons()
	GrabOfferings()

	return Killer
end

return Killer.Configure()