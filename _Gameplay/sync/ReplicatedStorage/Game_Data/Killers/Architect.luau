local Addon_Storage = game:GetService('ReplicatedStorage'):WaitForChild('Game_Data'):WaitForChild('Addons'):WaitForChild('Killer')
local Offering_Storage = game:GetService('ReplicatedStorage'):WaitForChild('Game_Data'):WaitForChild('Offerings'):WaitForChild('Killer')

local Killer = {
	-- BASE --
	Active = true; -- should appear in game or be deactivated for now
	Testing = false; -- only appear for tester or above
	Unlocked = false; -- if this killer should be unlocked for free at this moment if ever

	Amount = 1000000; -- Amount to purchase with blood-points (for free-to-play), uncomment this if the killer is a game-pass killer you want to be unlockable at any point

	Killer_Name = "Architect";
	Killer_Image = "rbxassetid://16870645802"; -- image id

	Power_Name = "Uncontrolled Rage";
	Power_Image = "rbxassetid://17652310018"; -- image id
	Power_Color = Color3.fromRGB(56, 46, 43); -- color associated with images

	Description = "";
	Addons = {};
	Offerings = {};

	-- SHOP --
	Gamepasses = {
		716365354, -- Killer Unlock Pass
		757476321, -- Killer Bundle
	}; -- gamepass id's that unlock this killer automatically

	-- GAMEPLAY --
	Base_Rage = 0;
	Base_Max_Rage = 1000;

	Min_rage = 50/100;

	Knockdown_Time = 1.5; -- seconds of a survivor being knocked downed

	Hitbox = {
		Radius = 2.4;
		Range = 2.4;
	},

	Camera = {
		Sensitivity = Vector2.new(1.155, 0.55);
		Limits = Vector2.new(125, 100);
	},

	Rage_Gain = {
		Passive = 6.5; -- Updated
		Break = 100;
		Injure = 250;
	},

	Rage_Loss = {
		Passive = 20; -- 25s to 50s of power duration  
		Break = -0;
		Injure = 250;
	},

	Rage_Speeds = {
		Base = 22;
		Gain = 2;
	},

	Timings = {
		Scream = 2;
		Wind = 1.5;
		Cancel = 2.7;
		Exhaust = 3;
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

			if Addon.Turn_Increase then -- increase turn speed and limits
				Killer.Camera.Sensitivity *= Vector2.new(require(Addon_Storage:WaitForChild('Lighter Sledge')).Turn_Increase + 1, 1)
				Killer.Camera.Limits *= Vector2.new(require(Addon_Storage:WaitForChild('Lighter Sledge')).Turn_Increase + 1, 1)
			end

			if Addon.Start_Rage_Speed then
				Killer.Rage_Speeds.Base = math.clamp(Killer.Rage_Speeds.Base + Addon.Start_Rage_Speed, 14, 99999)
			end

			if Addon.Rage_Speed_Gain then
				Killer.Rage_Speeds.Gain = math.clamp(Killer.Rage_Speeds.Gain + Addon.Rage_Speed_Gain, 0, 999999)
			end
		end
	end
end

function Killer:Power(Player : Player) : "Boot up / configure power"
	local Data_Module = require(game:GetService('ReplicatedStorage'):WaitForChild('Modules'):WaitForChild('Data'))

	-- Apply Addons Here | Camera Changes will not work [made dual power booting] | No Speed Changes --

	for _, Addon in pairs(Killer.Addons) do -- cycle through all addons

		if Data_Module:GetAddon("Killer", Player, Addon.Data_Name) then -- have this addon equipped currently

			if Addon.Duration_Increase then -- increase duration of rage
				Killer.Base_Max_Rage = math.clamp(Killer.Base_Max_Rage + Addon.Duration_Increase, 500, 999999)
			end

			if Addon.Start_Rage_Increase then
				Killer.Base_Rage += Addon.Start_Rage_Increase
			end

			if Addon.Rage_Gain then
				Killer.Rage_Gain.Passive = math.clamp(Killer.Rage_Gain.Passive * (Addon.Rage_Gain + 1), 1, 999999)
			end

			if Addon.Rage_Loss then
				Killer.Rage_Loss.Passive = math.clamp(Killer.Rage_Loss.Passive * (1 - Addon.Rage_Loss), 1, 999999)
			end
		end
	end

	Player.Character:SetAttribute("Power", math.clamp(Killer.Base_Rage, 0, Killer.Base_Max_Rage)..':'..Killer.Base_Max_Rage)
	Player.Character:SetAttribute("Power_State", "Idle") -- manipulate power

	local connection connection = game:GetService('RunService').Stepped:Connect(function(t, delta)
		if not Player.Character then return end
		local current_rage = string.split(Player.Character:GetAttribute("Power"), ':')
		local current_power_state = Player.Character:GetAttribute("Power_State")

		if current_power_state == "Idle" then -- fill it they are idle

			if tonumber(current_rage[1]) < tonumber(current_rage[2]) then
				Player.Character:SetAttribute("Power", math.clamp(tonumber(current_rage[1]) + (delta * Killer.Rage_Gain.Passive), 0, tonumber(current_rage[2]))..':'..current_rage[2])
			end
		elseif current_power_state == "Animation" then
			-- DO NOTHING
		elseif current_power_state == "PowerUsage" then -- drain it they are using it

			if tonumber(current_rage[1]) > 0 then
				Player.Character:SetAttribute("Power", math.clamp(tonumber(current_rage[1]) - (delta * Killer.Rage_Loss.Passive), 0, tonumber(current_rage[2]))..':'..current_rage[2])
			end

			if Player.Character.PrimaryPart and Player.Character.PrimaryPart:FindFirstChild("Stomp") then
				local sound_audio = Player.Character.PrimaryPart:WaitForChild("Stomp")
				local current_shift = (Player.Character.PrimaryPart.AssemblyLinearVelocity.Magnitude/Killer.Rage_Speeds.Base)

				sound_audio.Volume = math.clamp(current_shift * .8, 0.8, 1.6)
				sound_audio.PlaybackSpeed = math.clamp(current_shift * 0.9, 0.9, 1.8)
			end
		end
	end)

	return Killer
end

function Killer.Configure()
	Killer.Description = "Start the trial with <b><font color='#c2b00e'>".. Killer.Base_Rage.."</font></b>% rage that gradually fills up during the trial. Hitting survivors will give <b><font color='#c2b00e'>".. (Killer.Rage_Gain.Injure/Killer.Base_Max_Rage)*100 .."</font></b>% rage, Pallets and Breakable Walls give <b><font color='#c2b00e'>".. (Killer.Rage_Gain.Break/Killer.Base_Max_Rage)*100 .."</font></b>% rage, and breaking pallets and breakable walls will give <b><font color='#c2b00e'>".. Killer.Rage_Speeds.Gain.."</font></b> studs of additional speed. \n \nWhen the rage has reached at least <b><font color='#c2b00e'>"..(Killer.Min_rage * 100).."</font></b>%, Entering power will stop you in place for <b><font color='#c2b00e'>"..(Killer.Timings.Scream + Killer.Timings.Wind).."</font></b> seconds, then go into a charge that drains <b><font color='#c2b00e'>".. Killer.Rage_Loss.Passive.."</font></b> charges per second. \n \nYour sensitivity will be drastically decreased during the charge. \n \nWhile charging, you can instantly break pallets and breakable walls and injure survivors. Each object rammed gives 2 additional walkspeed, and ramming into survivors will injure them and depletes <b><font color='#c2b00e'>"..(Killer.Rage_Loss.Injure / 10).."</font></b>% rage. \n \nThe Architect will slam their sledge down for 3 seconds when rage ends. \n \n*A survivor can be rammed into again during the same charge after 10 seconds \n*Survivors will enter the dying state when rammed into while injured \n*The Architect can not hit any survivors or pallets or breakable walls for 1 second after previously doing so \n*Survivors rammed into will be stunned for 2 seconds and slowed down by 5% for 10 seconds \n*The Architect can not pull survivors out of lockers during Uncontrolled Rage."

	GrabAddons()
	GrabOfferings()

	return Killer
end

return Killer.Configure()
