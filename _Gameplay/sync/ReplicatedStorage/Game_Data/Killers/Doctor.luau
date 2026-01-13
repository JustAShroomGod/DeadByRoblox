local Addon_Storage = game:GetService('ReplicatedStorage'):WaitForChild('Game_Data'):WaitForChild('Addons'):WaitForChild('Killer')
local Offering_Storage = game:GetService('ReplicatedStorage'):WaitForChild('Game_Data'):WaitForChild('Offerings'):WaitForChild('Killer')

local Killer = {
	-- BASE --
	Active = false; -- should appear in game or be deactivated for now
	Testing = false; -- only appear for tester or above
	Unlocked = false; -- if this killer should be unlocked for free at this moment if ever
	
	Killer_Name = "Doctor";
	Killer_Image = "rbxassetid://9629333067"; -- image id
	
	Power_Name = "Shock";
	Power_Image = "rbxassetid://9637319785"; -- image id
	Power_Color = Color3.fromRGB(56, 46, 43); -- color associated with images
	
	Description = [[
<b>SHOCK</b>
Press and hold the <i>Power Button</i> to use your power.

<b>PUNISH</b>
Normal weapon stance.

<b>TREATMENT</b>
You can <i>Shock</i> the survivors that are in the range of your <i>Shock</i> making them not able to do interactions.
]];

	Addons = {};
	Offerings = {};
	
	-- SHOP --
	Gamepasses = {}; -- gamepass id's that unlock this killer automatically

	-- GAMEPLAY --
	
	Speed_Settings = {
		Charging = 0.25; -- slow down by 25% while shock
	},

	Timing_Settings = {
		Wind_Up = 1; -- time to pull upshock
		Wind_Down = 0.5; -- time to put away shock
		Mouse_Debounce = 3; -- shock recovery
	},

	Throw_Settings = {
		Wind_Speed = 1000/4; -- 1k / second to reach max power
		Distance_Force_Per_Charge = 20/1000; -- Max Force / 1K
		Min_Distance_Force = 200; -- minimum throw force
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

		end
	end

	Player.Character:SetAttribute("Power", '0:1000')
	Player.Character:SetAttribute("Power_State", "Idle") -- manipulate power

	local connection connection = game:GetService('RunService').Stepped:Connect(function(t, delta)
		if not Player.Character then return end
		local current_shock_power = string.split(Player.Character:GetAttribute("Power"), ':')
		local current_power_state = Player.Character:GetAttribute("Power_State")

		if current_power_state == "Idle" then -- fill it they are idle
			Player.Character:SetAttribute("Power", '0:1000') -- reset to 0
		elseif current_power_state == "Animation" then
			-- DO NOTHING
		elseif current_power_state == "Charging" then -- fill it they are using it

			if tonumber(current_shock_power[1]) < tonumber(current_shock_power[2]) then
				Player.Character:SetAttribute("Power", math.clamp(tonumber(current_shock_power[1]) + (delta * Killer.Throw_Settings.Wind_Speed), 0, tonumber(current_shock_power[2]))..':'..current_shock_power[2])
			end
		end
	end)

	return Killer
end
function Killer.Configure()
	Killer.Description = "SHOCK Press and hold the Power Button to use your power. PUNISH, Normal weapon stance. TREATMENT, You can <i>Shock</i> the survivors that are in the range of your <i>Shock</i> making them not able to do interactions."

	GrabAddons()
	GrabOfferings()
	
	return Killer
end

return Killer.Configure()
