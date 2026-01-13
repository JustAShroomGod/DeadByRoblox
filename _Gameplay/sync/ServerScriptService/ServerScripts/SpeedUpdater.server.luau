local Data_Module = require(game:GetService('ReplicatedStorage'):WaitForChild('Modules'):WaitForChild('Data'))
local Code_Module = require(game:GetService('ReplicatedStorage'):WaitForChild('Modules'):WaitForChild('Code'))
local Events = require(game.ServerScriptService["Event System"].Events)

local Remotes = game.ReplicatedStorage.RemoteEvents
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")

local List = {}
local Runner = nil

function tweenSpeed(Player, TweenTime, Speed, reverse, easing) : "Tweens player to speed arugment"
	if not Player or not workspace:FindFirstChild(Player.Name) then return end
	if (Player.Backpack.Scripts.values.KillerAction.Value == "Attacking") then return end

	local Humanoid = workspace:WaitForChild(Player.Name).Humanoid
	local info = TweenInfo.new(TweenTime, easing, Enum.EasingDirection.In, 0, reverse)

	--print('DESIRED', Speed, ':', Player)

	TweenService:Create(Humanoid, info, {WalkSpeed = Speed}):Play()
end

function startRunner() : "boots up the main heartbeat loop"
	if Runner then return end

	Runner = Events.Server.Heartbeat.Event:Connect(function(delta)
		if not game.ReplicatedStorage.Match.Started.Value then return end

		for index, Player in pairs(Players:GetPlayers()) do
			if not Player.Character or not Code_Module:GetMatchPlayer(Player) then continue end -- skip over no player assigned

			local calcSpeed = _G.GetValue(Player, "Speed").Amount
			local calcMultiplier = _G.GetValue(Player, "SpeedMultiplier").Amount
			local finalSpeed = calcSpeed * calcMultiplier

			tweenSpeed(Player, 0.1, finalSpeed, false, Enum.EasingStyle.Linear)
		end
	end)
end

function tickTimers(Player, Speeds, Multipliers, delta)
	if not Speeds or not Multipliers then return end
	local Speeds = Speeds.Restricted
	local Multipliers = Multipliers.Restricted

	for name, data in pairs(Speeds) do
		data.Length -= delta

		if (data.Length <= 0) then
			List[Player.Name].Speeds.Restricted[name] = nil
		else
			List[Player.Name].Speeds.Restricted[name] = data
		end
	end

	for name, data in pairs(Multipliers) do
		data.Length -= delta

		if (data.Length <= 0) then
			List[Player.Name].Multipliers.Restricted[name] = nil
		else
			List[Player.Name].Multipliers.Restricted[name] = data
		end
	end
end

function calcSpeed(defaultSpeed, Speeds) : "unrestricted speed + restricted speed + default speed"
	local Restricted = Speeds.Restricted
	local Unrestricted = Speeds.Unrestricted

	for name, data in pairs(Unrestricted) do
		defaultSpeed += data.Value
	end

	for name, data in pairs(Restricted) do
		if (data.Length > 0) then
			defaultSpeed += data.Value
		end
	end

	return defaultSpeed
end

function getFinalMultiplier(Multipliers, Player: Player) : "Restricted mult + unrestricted multi + 1"
	local finalMultiplier = 1
	local Restricted = Multipliers.Restricted
	local Unrestricted = Multipliers.Unrestricted

	for name, data in pairs(Unrestricted) do
		finalMultiplier += data.Value

		if (#Restricted > 0) then print(Unrestricted) end

		if (data.Value == 0) then
			return 0 -- if any unrestricted multi is 0 then return only 0
		end
	end

	for name, data in pairs(Restricted) do

		if (data.Length > 0) then
			finalMultiplier += data.Value

			if (data.Value == 0) then
				--warn(name, data, 'set to 0')
				return 0 -- if any Restricted multi is 0 then return only 0
			end
		end
	end

	-- testing --
	local Haste, Slow = Code_Module:GetEffect("Haste", Player), Code_Module:GetEffect("Slow", Player)

	if Haste then
		finalMultiplier += (Haste.Value/100)
	end

	if Slow then
		finalMultiplier = math.clamp(finalMultiplier - (Slow.Value/100), 0, math.huge)
	end

	--[[if Player.Team == game.Teams.Survivor and Player.Character then
		
		if Player:WaitForChild('Backpack'):WaitForChild('Scripts'):WaitForChild('values'):WaitForChild('HealthState').Value <= 0 then
			finalMultiplier += Code_Module.Speeds.Survivor.Crawling
		elseif Player.Character:GetAttribute("Crouch") then
			finalMultiplier += Code_Module.Speeds.Survivor.Crouching
		elseif Player:WaitForChild('Backpack'):WaitForChild('Scripts'):WaitForChild('values'):WaitForChild('Action').Value == "UsingFlashlight" then
			-- do nothing / using flashlight --
		elseif Player.Character:GetAttribute("Sprint") then
			finalMultiplier += Code_Module.Speeds.Survivor.Running
		end
	end]]--
	-- testing --

	return finalMultiplier -- return 1 + restrict/unrestricted
end

function calcFinalSpeed(calcSpeed, Multipliers, Player : Player) : "Calculates the final speed"
	local finalMultiplier = 1
	local Restricted = Multipliers.Restricted
	local Unrestricted = Multipliers.Unrestricted

	for name, data in pairs(Unrestricted) do
		finalMultiplier += data.Value

		if (data.Value == 0) then
			return 0
		end
	end

	for name, data in pairs(Restricted) do
		if (data.Length > 0) then
			finalMultiplier += data.Value

			if (data.Value == 0) then
				return 0
			end
		end
	end

	-- testing --
	local Haste, Slow = Code_Module:GetEffect("Haste", Player), Code_Module:GetEffect("Slow", Player)

	if Haste then
		finalMultiplier += (Haste.Value/100)
	end

	if Slow then
		finalMultiplier = math.clamp(finalMultiplier - (Slow.Value/100), 0, math.huge)
	end

	--[[if Player.Team == game.Teams.Survivor and Player.Character then
		
		if Player:WaitForChild('Backpack'):WaitForChild('Scripts'):WaitForChild('values'):WaitForChild('HealthState').Value <= 0 then
			finalMultiplier += Code_Module.Speeds.Survivor.Crawling
		elseif Player.Character:GetAttribute("Crouch") then
			finalMultiplier += Code_Module.Speeds.Survivor.Crouching
		elseif Player:WaitForChild('Backpack'):WaitForChild('Scripts'):WaitForChild('values'):WaitForChild('Action').Value == "UsingFlashlight" then
			-- do nothing / using flashlight --
		elseif Player.Character:GetAttribute("Sprint") then
			finalMultiplier += Code_Module.Speeds.Survivor.Running
		end
	end]]--

	if Player.Character and Player.Character:GetAttribute("Motion_Locked") then
		finalMultiplier = 0
	end
	-- testing --

	return (calcSpeed * finalMultiplier) -- does final multi * calc speed assuming not final multis are 0
end

function addToList(Name) : "add to global list"
	List[Name] = {
		Speeds = {
			Restricted = {};
			Unrestricted = {};
		};
		Multipliers = {
			Restricted = {};
			Unrestricted = {};
		};
	}
end

function removeFromList(Name) : "set our entry to nil and thus removes us"
	List[Name] = nil
end

function addSpeed(Player, EffectName, Amount, Time)

	if (List[Player.Name] ~= nil) then
		local NewEntry = {
			Value = Amount;
			Length = Time;
		}

		if (Time > 0) then
			List[Player.Name]["Speeds"]["Restricted"][EffectName] = NewEntry
		else
			List[Player.Name]["Speeds"]["Unrestricted"][EffectName] = NewEntry
		end
	end

	_G.GetValue(Player, "Speed"):Add(EffectName, Amount, Time)
end

function removeSpeed(Player, EffectName)
	if (List[Player.Name] ~= nil) then

		if (List[Player.Name]["Speeds"]["Unrestricted"][EffectName] ~= nil) then
			List[Player.Name]["Speeds"]["Unrestricted"][EffectName] = nil
		end

		if (List[Player.Name]["Speeds"]["Restricted"][EffectName] ~= nil) then
			List[Player.Name]["Speeds"]["Restricted"][EffectName] = nil
		end

	end
	
	_G.GetValue(Player, "Speed"):Remove(EffectName)
end

function addMultiplier(Player, EffectName, Amount, Time)

	if (List[Player.Name] ~= nil) then
		local NewEntry = {
			Value = Amount;
			Length = Time;
		}

		if (Time > 0) then
			List[Player.Name]["Multipliers"]["Restricted"][EffectName] = NewEntry
		else
			List[Player.Name]["Multipliers"]["Unrestricted"][EffectName] = NewEntry
		end
	end

	_G.GetValue(Player, "SpeedMultiplier"):Add(EffectName, Amount, Time)
end

function removeMultiplier(Player, EffectName)

	if (List[Player.Name] ~= nil) then

		if (List[Player.Name]["Multipliers"]["Unrestricted"][EffectName] ~= nil) then
			List[Player.Name]["Multipliers"]["Unrestricted"][EffectName] = nil
		end

		if (List[Player.Name]["Multipliers"]["Restricted"][EffectName] ~= nil) then
			List[Player.Name]["Multipliers"]["Restricted"][EffectName] = nil
		end

	end
	
	_G.GetValue(Player, "SpeedMultiplier"):Remove(EffectName)
end

function UpdateSpeed(Player, Action, Type, ...)
	local args = {...}

	if (Action == "Add") then
		if (Type == "Speed") then
			addSpeed(Player, args[1], args[2], args[3])
		end

		if (Type == "Multiplier") then
			addMultiplier(Player, args[1], args[2], args[3])
		end

		if (Type == "User") then
			addToList(Player.Name)
		end

	end

	if (Action == "Remove") then
		if (Type == "Speed") then
			removeSpeed(Player, args[1])
		end

		if (Type == "Multiplier") then
			removeMultiplier(Player, args[1])
		end

		if (Type == "User") then
			removeFromList(Player.Name)
		end

	end

end

startRunner()

Remotes.ClientToServer.UpdateSpeed.OnServerEvent:Connect(UpdateSpeed)
Remotes.ServerBindable.UpdateSpeed.Event:Connect(UpdateSpeed)