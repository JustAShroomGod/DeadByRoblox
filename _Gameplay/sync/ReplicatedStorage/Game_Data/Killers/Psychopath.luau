local Addon_Storage = game:GetService('ReplicatedStorage'):WaitForChild('Game_Data'):WaitForChild('Addons'):WaitForChild('Killer')
local Offering_Storage = game:GetService('ReplicatedStorage'):WaitForChild('Game_Data'):WaitForChild('Offerings'):WaitForChild('Killer')

local Killer = {
	-- BASE --
	Active = true; -- should appear in game or be deactivated for now
	Testing = false; -- only appear for tester or above
	Unlocked = false; -- if this killer should be unlocked for free at this moment if ever

	Amount = 1000000; -- Amount to purchase with blood-points (for free-to-play), uncomment this if the killer is a game-pass killer you want to be unlockable at any point

	Killer_Name = "Psychopath";
	Killer_Image = "rbxassetid://78450098156622"; -- image id

	Power_Name = "Blood Rage";
	Power_Image = "rbxassetid://136553427148870"; -- image id
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

	Base_Rage = 0;
	Base_Max_Rage = 1000;

	AuraDuration = 3; --secs

	Aura_Distances = {
		Min = 0;
		Max = 10000
	};

	Rage_Speed = {
		Rage = 18;
		Fatigue = 3;
	};

	Rage_Gain = {
		Passive = 33; -- roughly a 30 secs (do 1000/time)
		Break = 100; -- pallets/walls
		Attack = 300; --survivor hits
		Miss_Attack = -250
	};

	Rage_Loss = {
		Passive = 65; -- roughly a 15 secs (do 1000/time)
		Hit = 0;
	};

	Timings = {
		Fatigue = 3
	};
	
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

			if Addon.Aura then
				Killer.Aura_Distances.Max *= (Addon.Aura/100)
			end

			if Addon.Speed then
				Killer.Rage_Speed.Rage += Addon.Speed
			end

		end
	end
end

function Killer:Power(Player : Player) : "Boot up / configure power"
	local Data_Module = require(game:GetService('ReplicatedStorage'):WaitForChild('Modules'):WaitForChild('Data'))

	local KillerAction = Player.Backpack:WaitForChild("Scripts"):WaitForChild("values"):WaitForChild("KillerAction")

	local Connections = {}

	-- Apply Addons Here | Camera Changes will not work [made dual power booting] | No Speed Changes --

	for _, Addon in pairs(Killer.Addons) do -- cycle through all addons

		if Data_Module:GetAddon("Killer", Player, Addon.Data_Name) then -- have this addon equipped currently

			if Addon.Duration_Increase then -- increase duration of rage
				Killer.Base_Max_Rage = math.clamp(Killer.Base_Max_Rage + Addon.Duration_Increase, 500, 999999)
			end

			if Addon.PlayerHit_Increase then
				Killer.Rage_Gain.Attack = math.clamp(Killer.Rage_Gain.Attack + Addon.PlayerHit_Increase, 0, 999999)
			end

			if Addon.Start_MaxRage then
				Killer.Base_Rage = math.clamp(Killer.Base_Rage + Addon.Start_MaxRage, 0, 999999)
			end

			if Addon.Passive then
				Killer.Rage_Gain.Passive = math.clamp(Killer.Rage_Gain.Passive + Addon.Passive, 0, 999999)
			end

			if Addon.BreakGain_Increase then
				Killer.Rage_Gain.Break = math.clamp(Killer.Rage_Gain.Break + Addon.BreakGain_Increase, 0, 999999)
			end
		end
	end

	Player.Character:SetAttribute("Power", math.clamp(Killer.Base_Rage, 0, Killer.Base_Max_Rage)..':'..Killer.Base_Max_Rage)
	Player.Character:SetAttribute("Power_State", "Idle") -- manipulate power

	Connections["State"] = game:GetService('RunService').Stepped:Connect(function(t, delta)
		if not Player.Character then return end
		local current_rage = string.split(Player.Character:GetAttribute("Power"), ':')
		local current_power_state = Player.Character:GetAttribute("Power_State")

		if current_power_state == "Idle" then -- fill it they are idle

			if tonumber(current_rage[1]) < tonumber(current_rage[2]) then
				Player.Character:SetAttribute("Power", math.clamp(tonumber(current_rage[1]) + (delta * Killer.Rage_Gain.Passive), 0, tonumber(current_rage[2]))..':'..current_rage[2])
			end
		elseif current_power_state == "Animation" then
			-- DO NOTHING
		elseif current_power_state == "Using" then -- drain it they are using it

			if tonumber(current_rage[1]) > 0 then
				Player.Character:SetAttribute("Power", math.clamp(tonumber(current_rage[1]) - (delta * Killer.Rage_Loss.Passive), 0, tonumber(current_rage[2]))..':'..current_rage[2])
			end
		end
	end)

	return Killer
end


function Killer.Configure()
	Killer.Description = [[
<b>POWER GAUGE</b>
You can fill your <i>Power Gauge</i> by the following actions:
	-Breaking pallets or breakable walls
	-Successfully attacking a survivor
	-Passively charging
	
When your <i>Power Gauge</i> reaches 100%, press <i>Power Button</i> to activate <i>Blood Rage</i>

<b>BLOOD RAGE</b>
When <i>Blood Rage</i> is activated, it grants the following effects:
	-Increased pallet & wall breaking speed
	-Increased movement speed
	-A ]]..Killer.AuraDuration ..[[ seconds aura read
	
The following actions will deactivate <i>Blood Rage</i>:
	-Pressing <i>Power Button</i> once again
	-Picking up a survivor
	-Getting stunned by any means
]]

	GrabAddons()
	GrabOfferings()

	return Killer
end

return Killer.Configure()