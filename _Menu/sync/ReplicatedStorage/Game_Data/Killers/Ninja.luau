local Addon_Storage = game:GetService('ReplicatedStorage'):WaitForChild('Game_Data'):WaitForChild('Addons'):WaitForChild('Killer')
local Offering_Storage = game:GetService('ReplicatedStorage'):WaitForChild('Game_Data'):WaitForChild('Offerings'):WaitForChild('Killer')

local Killer = {
	-- BASE --
	Active = true; -- should appear in game or be deactivated for now
	Testing = false; -- only appear for tester or above
	Unlocked = false; -- if this killer should be unlocked for free at this moment if ever

	Amount = 1000000; -- Amount to purchase with blood-points (for free-to-play), uncomment this if the killer is a game-pass killer you want to be unlockable at any point

	Killer_Name = "Ninja";
	Killer_Image = "rbxassetid://116188425559575"; -- image id

	Power_Name = "Swift Charge";
	Power_Image = "rbxassetid://116625343647959"; -- image id
	Power_Color = Color3.fromRGB(56, 46, 43); -- color associated with images

	Description = "";
	Addons = {};
	Offerings = {};

	--[[Camera = {
		Flick = {
			Sensitivity = Vector2.new(1.5, .2);
			Limits = Vector2.new(500, 75);
		},
		Sprint = {
			Sensitivity = Vector2.new(.5, .125);
			Limits = Vector2.new(65, 35);
		},
	},]]--

	-- SHOP --
	Gamepasses = {
		824346718, -- Killer Unlock Pass
		824769343, -- Killer Bundle
	}; -- gamepass id's that unlock this killer automatically

	-- GAMEPLAY --
	Base_Swiftness = 0;
	Max_Swiftness = 1000;

	Speeds = {
		Dash = 4; -- 1x default killer speed
		Aim = 0.4; -- 0.5x slower or 50% speed i think
		Slash = 0.45; --85% slower or 15% speed remaining
		Stab = 0.84; -- 1x slower or 100% speed remova (full stop)
		Crouch = 0.1; -- 0.15x slower or 85% of walking speed
	},

	Hitboxes = {
		Attack = {
			Radius = 2.4;
			Range = 2.4;
		},
		Dash = {
			Radius = 1.6;
			Range = 2.8;
		},
	},

	Cool_Down_Time = 7;
	Collision_IFrames = 0.35; --time in secs from the start of the dash during which ninja cant hit walls and stuff :smirk:


	Dash_Gain = 402.5;
	Dash_Per_Charge = 1.15/1000; -- divide time by 1000 (base swiftness) so that it evens out and we can get more per charge or shorter charge at cost of less dist
	Dash_Min_Charge = 150; -- minimum distance gained always (would be stupid af to travel 1 stud)

	Timings = {
		Aim = 0.5;
		Slash = 2.7;
		Wipe = 3.5;
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

			if Addon.Dash_Speed then -- more power per unit
				Killer.Speeds.Dash = math.clamp(Killer.Speeds.Dash * (Addon.Dash_Speed + 1), 2, 99999)
			end

			if Addon.Dash_Minimum then -- more power per unit
				Killer.Dash_Min_Charge = math.clamp(Killer.Dash_Min_Charge * (Addon.Dash_Minimum + 1), 0, 99999)
			end

			if Addon.CoolDownEffect then
				Killer.Cool_Down_Time = Killer.Cool_Down_Time - (9 * Addon.CoolDownEffect)
			end

			if Addon.Dash_Charge then -- more power per unit
				--print(Killer.Dash_Per_Charge, Addon.Dash_Charge)
				Killer.Dash_Per_Charge = math.clamp(Killer.Dash_Per_Charge * (Addon.Dash_Charge + 1), 0.00001, 99999)

				--print(Killer.Dash_Per_Charge)
			end
		end
	end
end

function Killer:Power(Player : Player) : "Boot up / configure power"
	local Data_Module = require(game:GetService('ReplicatedStorage'):WaitForChild('Modules'):WaitForChild('Data'))
	local KillerAction = Player.Backpack:WaitForChild("Scripts"):WaitForChild("values"):WaitForChild("KillerAction")
	local Server_Remote = game:GetService("ReplicatedStorage"):WaitForChild("RemoteEvents"):WaitForChild("Server_Event")

	-- Apply Addons Here | Camera Changes will not work [made dual power booting] | No Speed Changes --

	for _, Addon in pairs(Killer.Addons) do -- cycle through all addons

		if Data_Module:GetAddon("Killer", Player, Addon.Data_Name) then -- have this addon equipped currently

			if Addon.Dash_Length then -- more total length
				Killer.Max_Swiftness = math.clamp(Killer.Max_Swiftness * (Addon.Dash_Length + 1), 100, 99999)
			end

			if Addon.Dash_Gain then
				Killer.Dash_Gain = math.clamp(Killer.Dash_Gain * (Addon.Dash_Gain + 1), 0.1, 99999)
			end

			if Addon.CoolDownEffect then
				Killer.Cool_Down_Time = Killer.Cool_Down_Time - (16 * Addon.CoolDownEffect)
			end

			if Addon.Crouch_Speed then
				Killer.Speeds.Crouch = math.clamp(Killer.Speeds.Crouch * (-Addon.Crouch_Speed + 1), 0, 1)
			end

			if Addon.Aim_Speed then
				Killer.Speeds.Aim = math.clamp(Killer.Speeds.Aim * (-Addon.Aim_Speed + 1), 0, 1)
			end

			if Addon.Stab_Reduction then
				Killer.Timings.Slash = math.clamp(Killer.Timings.Slash * (-Addon.Stab_Reduction + 1), 0.1, 10)
			end

			if Addon.Wipe_Reduction then
				Killer.Timings.Wipe = math.clamp(Killer.Timings.Wipe * (-Addon.Wipe_Reduction + 1), 0.1, 10)
			end
		end
	end

	Player.Character:SetAttribute("Power", '0:'..Killer.Max_Swiftness)
	Player.Character:SetAttribute("Power_State", "Idle") -- manipulate power

	local connection connection = game:GetService('RunService').Stepped:Connect(function(t, delta)
		if not Player.Character then return end
		local current_swiftness = string.split(Player.Character:GetAttribute("Power"), ':')
		local current_power_state = Player.Character:GetAttribute("Power_State")

		if current_power_state == "Charging" then -- fill it they are idle

			if tonumber(current_swiftness[1]) < tonumber(current_swiftness[2]) then
				Player.Character:SetAttribute("Power", math.clamp(tonumber(current_swiftness[1]) + (delta * Killer.Dash_Gain), 0, tonumber(current_swiftness[2]))..':'..current_swiftness[2])
			end
		elseif current_power_state == "Animation" or current_power_state == "Hidden" then
			-- DO NOTHING
		elseif current_power_state == "Idle" then -- drain it they are using it
			Player.Character:SetAttribute("Power", '0:1000')
		end
	end)

	local StunnedConnection StunnedConnection = KillerAction.Changed:Connect(function()
		if KillerAction.Value == 'Stun' then
			Server_Remote:FireServer("Swift Charge", 'Switch_Stance')
		end
	end)

	return Killer
end

function Killer.Configure()
	Killer.Description = "Primary Power: Swift Dash \nAim your sword, charge and strike through any Survivor in your path. Goes on cooldown after every use. \nSecondary Power: \nPressing your secondary power button will switch your stance to stealth mode turning off the ability to use your primary power in exchange for no terror radius. \n \n"

	GrabAddons()
	GrabOfferings()

	return Killer
end

return Killer.Configure()
