local Addon_Storage = game:GetService('ReplicatedStorage'):WaitForChild('Game_Data'):WaitForChild('Addons'):WaitForChild('Killer')
local Offering_Storage = game:GetService('ReplicatedStorage'):WaitForChild('Game_Data'):WaitForChild('Offerings'):WaitForChild('Killer')

local Killer = {
	-- BASE --
	Active = true; -- should appear in game or be deactivated for now
	Testing = false; -- only appear for tester or above
	Unlocked = true; -- if this killer should be unlocked for free at this moment if ever

	Killer_Name = "Hillbilly";
	Killer_Image = "rbxassetid://122768838076316"; -- image id

	Power_Name = "Chainsaw";
	Power_Image = "rbxassetid://136812457602908"; -- image id
	Power_Color = Color3.fromRGB(56, 46, 43); -- color associated with images

	Description = "";

	Addons = {};
	Offerings = {};

	-- SHOP --
	Gamepasses = {}; -- gamepass id's that unlock this killer automatically

	-- GAMEPLAY --

	Hitbox = {
		Hit = { -- hitbox for player/breakable
			Radius = 0.75;
			Range = 1;
		},
		Crash = { -- hitbox for crashing
			Radius = 0.75;
			Range = 1;
		},
	},

	Camera = {
		Flick = {
			Sensitivity = Vector2.new(1.5, .2);
			Limits = Vector2.new(500, 75);
		},
		Sprint = {
			Sensitivity = Vector2.new(.5, .125);
			Limits = Vector2.new(65, 35);
		},
	},

	Chainsaw_Refuel = 200; -- roughly 5 seconds between sawing

	Chainsaw_Settings = {
		Saw_Gain_Rate = 375;
		Saw_Loss_Rate = 375;
		Flick = 0.65; -- time to flick
		Mouse_Debounce = 1;
	},

	Animation_Timing = {
		Crash = 4;
		None = 1.5;
		Hit = 2;
	},

	Speeds = {
		Charging = 12;
		Stagger = 1;
		Sprinting = 35;
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

			if Addon.Flick_Turn_Increase then -- increase turn speed and limits
				Killer.Camera.Flick.Limits *= Vector2.new((Addon.Flick_Turn_Increase/100) + 1, 1)
			end

			if Addon.Flick_Turn_Power_Increase then
				Killer.Camera.Flick.Sensitivity *= Vector2.new((Addon.Flick_Turn_Power_Increase/100) + 1, 1)
			end

			if Addon.Sprint_Turn_Increase then
				Killer.Camera.Sprint.Limits *= Vector2.new((Addon.Sprint_Turn_Increase/100) + 1, 1)
			end

			if Addon.Sprint_Turn_Power_Increase then
				Killer.Camera.Sprint.Sensitivity *= Vector2.new((Addon.Sprint_Turn_Power_Increase/100) + 1, 1)
			end

			if Addon.Hitbox then
				Killer.Hitbox.Hit.Radius *= Addon.Hitbox
			end

			if Addon.Chainsaw_Refuel then
				Killer.Chainsaw_Refuel = math.clamp(Killer.Chainsaw_Refuel+ (Killer.Chainsaw_Refuel * (Addon.Chainsaw_Refuel/100)), 100, 999999)
			end

			if Addon.Charging_Speed then
				Killer.Speeds.Charging = math.clamp(Killer.Speeds.Charging / Addon.Charging_Speed, 1, 10)
			end

			if Addon.Sprint_Boost then -- increase speed of chainsaw sprint by percent
				Killer.Speeds.Sprinting = math.clamp(Killer.Speeds.Sprinting + (Killer.Speeds.Sprinting * (Addon.Sprint_Boost/100)), 16, 200)
			end

			if Addon.Crash_Decrease then
				Killer.Animation_Timing.Crash = math.clamp(Killer.Animation_Timing.Crash + (Killer.Animation_Timing.Crash * (Addon.Crash_Decrease/1000)), 1, 2)
			end

			if Addon.Animation then
				Killer.Animation_Timing.Crash = math.clamp(Killer.Animation_Timing.Crash + (Killer.Animation_Timing.Crash * (Addon.Animation/1000)), 8, 10)
				Killer.Animation_Timing.None = math.clamp(Killer.Animation_Timing.None + (Killer.Animation_Timing.None * (Addon.Animation/1000)), 3, 10)
			end

			if Addon.Basic_Cooldown then
				Killer.Chainsaw_Settings.Mouse_Debounce = math.clamp(Killer.Chainsaw_Settings.Mouse_Debounce + Addon.Basic_Cooldown, 0.1, 10)
			end
		end
	end
end

function Killer:Power(Player : Player) : "Boot up / configure power"
	local Data_Module = require(game:GetService('ReplicatedStorage'):WaitForChild('Modules'):WaitForChild('Data'))
	local Gain_Rate = Killer.Chainsaw_Settings.Saw_Gain_Rate
	-- Apply Addons Here | Camera Changes will not work [made dual power booting] | No Speed Changes --

	for _, Addon in pairs(Killer.Addons) do -- cycle through all addons

		if Data_Module:GetAddon("Killer", Player, Addon.Data_Name) then -- have this addon equipped currently

			if Addon.Sprint_Boost then -- increase speed of chainsaw sprint by percent
				Killer.Speeds.Sprinting = math.clamp(Killer.Speeds.Sprinting + (Killer.Speeds.Sprinting * (Addon.Sprint_Boost/100)), 16, 200)
			end

			if Addon.Charge_Gain then -- increase speed of chainsaw sprint by percent
				Gain_Rate = Gain_Rate * (Addon.Charge_Gain/100)
			end

			if Addon.Chainsaw_Refuel then
				Killer.Chainsaw_Refuel = math.clamp(Killer.Chainsaw_Refuel+ (Killer.Chainsaw_Refuel * (Addon.Chainsaw_Refuel/100)), 100, 999999)
			end
		end
	end

	Player.Character:SetAttribute("Power", '0:1000') -- chainsaw revving --
	Player.Character:SetAttribute("Power_Cooldown", '1000:1000') -- visual cd
	Player.Character:SetAttribute("Power_State", "Idle") -- manipulate power

	local connection connection = game:GetService('RunService').Stepped:Connect(function(t, delta)
		if not Player.Character then return end
		local current_rev = string.split(Player.Character:GetAttribute("Power"), ':')
		local current_cd = string.split(Player.Character:GetAttribute("Power_Cooldown"), ':')
		local current_power_state = Player.Character:GetAttribute("Power_State")

		if current_power_state == "Idle" then -- fill it they are idle
			-- do nothing TODO: Refill cooldown

			if tonumber(current_rev[1]) >= tonumber(current_rev[2]) then -- we've gotten over 1k go into saw mode
				--Player.Character:SetAttribute("Power_Cooldown", '1000:'..current_rev[2])
			else
				Player.Character:SetAttribute("Power_Cooldown", math.clamp(tonumber(current_cd[1]) + (delta * Killer.Chainsaw_Refuel), 0, tonumber(current_cd[2]))..':'..current_cd[2])
			end
		elseif current_power_state == "Stun_Animation" then
			Player.Character:SetAttribute("Power", '0:'..current_rev[2])
			Player.Character:SetAttribute("Power_Cooldown", '0:'..current_rev[2])
		elseif current_power_state == "Animation" or current_power_state == "Using" then
			-- DO NOTHING
		elseif current_power_state == "Charging_Up" then -- drain it they are using it

			if tonumber(current_rev[1]) >= tonumber(current_rev[2]) then -- we've gotten over 1k go into saw mode
				Player.Character:SetAttribute("Power_State", "Using")
				Player.Character:SetAttribute("Power", '0:'..current_rev[2])
				Player.Character:SetAttribute("Power_Cooldown", '0:'..current_cd[2])
			else

				Player.Character:SetAttribute("Power", math.clamp(tonumber(current_rev[1]) + (delta * (Gain_Rate)), 0, tonumber(current_rev[2]))..':'..current_rev[2])
			end
		elseif current_power_state == "Charging_Down" then

			if tonumber(current_rev[1]) <= 0 then -- we've gotten over 1k go into saw mode
				Player.Character:SetAttribute("Power_State", "Idle")
			else
				Player.Character:SetAttribute("Power", math.clamp(tonumber(current_rev[1]) - (delta * Killer.Chainsaw_Settings.Saw_Loss_Rate), 0, tonumber(current_rev[2]))..':'..current_rev[2])
			end
		end
	end)

	return Killer
end

function Killer.Configure()
	Killer.Description = [[<b>CHAINSAW</b>
Press and hold the the <i>Power Button</i> to break into a <i>Chainsaw Sprint</i>, moving at twice your regular Movement speed.

While in a <i>Chainsaw Sprint</i>:
	- Any Survivor that collides with The Hillbilly during a <i>Chainsaw Sprint</i> will be immediately put into the dying state.
	- Any Pallet that The Hillbilly collides with will be immediately broken by <i>Chainsaw Sprint</i> and will end <i>Chainsaw Sprint</i>.
	- Any Wall or object that The Hillbilly collides with will cancel <i>Chainsaw Sprint</i>, locking The Hillbilly into place for a few seconds.
]]

	GrabAddons()
	GrabOfferings()

	return Killer
end

return Killer.Configure()