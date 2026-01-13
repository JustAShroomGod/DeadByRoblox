local Addon_Storage = game:GetService('ReplicatedStorage'):WaitForChild('Game_Data'):WaitForChild('Addons'):WaitForChild('Killer')
local Offering_Storage = game:GetService('ReplicatedStorage'):WaitForChild('Game_Data'):WaitForChild('Offerings'):WaitForChild('Killer')

local Killer = {
	-- BASE --
	Active = true; -- should appear in game or be deactivated for now
	Testing = false; -- only appear for tester or above
	Unlocked = true; -- if this killer should be unlocked for free at this moment if ever

	Killer_Name = "Huntress";
	Killer_Image = "rbxassetid://113486703909986"; -- image id

	Power_Name = "Hatchet";
	Power_Image = "rbxassetid://93778432493923"; -- image id
	Power_Color = Color3.fromRGB(56, 46, 43); -- color associated with images

	Description = "";

	Addons = {};
	Offerings = {};

	-- SHOP --
	Gamepasses = {}; -- gamepass id's that unlock this killer automatically

	-- GAMEPLAY --
	Hatchet_Count = 5;

	Camera_Offset = CFrame.new(0, -0.5, 0); -- hatchet coming out slightly lower (looks off coming out dead center, but feel free to change)

	Speed_Settings = {
		Aiming = 0.25; -- slow down by 25% while aiming
	},

	Hitbox_Settings = {
		Player = { -- wider, bit shorter
			Radius = 1.15;
			Range = 2.5;
		},
		Object = { -- narrow, but long
			Radius = 0.5;
			Range = 2.65;
		},
	},

	SpeedBoost = 1.2;

	Timing_Settings = {
		Wind_Up = 1; -- time to pull up a hatchet
		Wind_Down = 0.5; -- time to put away a hatchet
		Mouse_Debounce = 3; -- hatchet throw recovery
		Reload = 3.65; -- time to reload from a locker
	},

	Throw_Settings = {
		Wind_Speed = 1000/4; -- 1k / second to reach max power
		Throw_Force_Per_Charge = 20/1000; -- Max Force / 1K
		Min_Throw_Force = 200; -- minimum throw force
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

			if Addon.Hatchet_Boost then
				Killer.Hatchet_Count = math.clamp(Killer.Hatchet_Count + Addon.Hatchet_Boost, 1, 100)
			end

			if Addon.SpeedBoost then
				Killer.SpeedBoost += Addon.SpeedBoost
			end
		end
	end
end

function Killer:Power(Player : Player) : "Boot up / configure power"
	local Data_Module = require(game:GetService('ReplicatedStorage'):WaitForChild('Modules'):WaitForChild('Data'))

	-- Apply Addons Here | Camera Changes will not work [made dual power booting] | No Speed Changes --

	local ismultishot = false

	for _, Addon in pairs(Killer.Addons) do -- cycle through all addons

		if Data_Module:GetAddon("Killer", Player, Addon.Data_Name) then -- have this addon equipped currently

			if not ismultishot then
				if Addon.Hatchet_Boost then
					Killer.Hatchet_Count = math.clamp(Killer.Hatchet_Count + Addon.Hatchet_Boost, 1, 100)
				end
			end

			if Addon.Data_Name == "Multi-Shot" then
				Killer.Hatchet_Count = 1
				ismultishot = true
			end

			if Addon.Reload_Boost then
				Killer.Timing_Settings.Reload = math.clamp(Killer.Timing_Settings.Reload * (1 - (Addon.Reload_Boost/2)), 1, 10)
			end
		end
	end

	Player.Character:SetAttribute("Power", '0:1000')
	Player.Character:SetAttribute("Power_State", "Idle") -- manipulate power
	Player.Character:SetAttribute("Hatchet_Count", Killer.Hatchet_Count) -- give us our hatchets

	local connection connection = game:GetService('RunService').Stepped:Connect(function(t, delta)
		if not Player.Character then return end
		local current_hatchet_power = string.split(Player.Character:GetAttribute("Power"), ':')
		local current_power_state = Player.Character:GetAttribute("Power_State")

		if current_power_state == "Idle" then -- fill it they are idle
			Player.Character:SetAttribute("Power", '0:1000') -- reset to 0
		elseif current_power_state == "Animation" then
			-- DO NOTHING
		elseif current_power_state == "Aiming" then -- fill it they are using it

		end
	end)

	return Killer
end

function Killer.Configure()
	Killer.Description = [[

<b>HUNTING HATCHETS</b>
Press and hold the the <i>Power Button</i> to wind up a <b>Hunting Hatchet</b>.
Release the <i>Power Button</i> to initiate a <b>Hatchet Throw</b>.

	- Start the Trial with ]]..Killer.Hatchet_Count..[[ Hatchets.
	
	- The <b>Hatchet Throw</b> can be charged for maximum distance.
	
	- <b>Hunting Hatchets</b> are consumed on use and can be refilled by searching a Locker.

]]

	GrabAddons()
	GrabOfferings()

	return Killer
end

return Killer.Configure()