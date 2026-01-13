local game_data = game.ReplicatedStorage:WaitForChild('Game_Data')
local Killer_Module = require(game_data:WaitForChild('Killers'):WaitForChild('Psychopath'))

local Player = game.Players.LocalPlayer
local DefaultPriority = 3

local Action = {
	Key = "Interact3";
	ActionName = "Start Blood Rage";
	Priority = 3; -- scale of 1-5
	ActionInfo = {
		POWER_BUTTON = "UP";
		Connections = {};
		Base_Controls = require(game.Players.LocalPlayer:WaitForChild('PlayerScripts'):WaitForChild('PlayerModule')):GetControls();
	},
	Debounces = {
		InputEnter = tick();
		InProgress = false;
	}
}

local Tracks = {}

local function Constraints(actionList) : boolean | "The Requirements to run this action"
	local CanRun = false -- by default false
	local currentValues = actionList.ValueList
	local Power = Player.Character:GetAttribute("Power")
	local Power_State = Player.Character:GetAttribute("Power_State")

	if not Power or not Power_State then return false end
	Power = string.split(Power, ':')

	if not Killer_Module.Client_Power_Boot and Killer_Module.Power_Client then
		Killer_Module.Client_Power_Boot = true -- booted values from client side
		Killer_Module:Power_Client(game.Players.LocalPlayer)
	end

	if currentValues.KillerAction.Value == "Nothing"
		and not Player.Character:GetAttribute("Carry") -- not allowed while carrying
		and (currentValues.Parent:WaitForChild("BLOODPOINT"):FindFirstChild("REMOVE") ~= nil)
		and Power_State == "Idle" -- current not using power or in animation
		and tonumber(Power[1]) >= tonumber(Power[2]) -- at max capacity to start using power
		and not Player.Character:GetAttribute("Swing") -- not swinging currently
		and Action.ActionInfo.POWER_BUTTON == "UP" then -- power button not held

		CanRun = true
	elseif Action.Debounces.InProgress then -- if in progress do not let go of this interaction
		Action.Priority = 0 -- set Priority to 0 to override any possible incoming interaction
		CanRun = true
	end

	return CanRun
end

function Action:Start(...) : "Start Action?"
	if (tick() - Action.Debounces.InputEnter) < 1 or Action.Debounces.InProgress then return --[[warn("Anti-Spam")]] end
	Action.Debounces.InputEnter = tick()
	Action.Debounces.InProgress = true

	local args = {...}
	local actionList, remoteList, modules = args[1], args[2], args[3]
	local currentValues = actionList.ValueList
	local Character = Player.Character

	modules.UI:Hide(true)
	--modules.UI:HideSpecific(Action.ActionName,true)

	modules.UI:ChangeName(Action.ActionName, "End Blood Rage")

	Action.ActionInfo.POWER_BUTTON = "DOWN"

	if not Tracks.Fatigue then
		Tracks.Fatigue = Character:WaitForChild('Humanoid'):LoadAnimation(script:WaitForChild('Fatigue'))
	end

	local function finalize() : "Finish disconnect sequence"
		Action.Priority = DefaultPriority
		modules.UI:ChangeName(Action.ActionName, "Start Blood Rage")

		Action.ActionInfo.Base_Controls:Enable()
		Action.ActionInfo.POWER_BUTTON = "UP"

		Action.Debounces.InProgress = false
		modules.UI:Hide(false)
	end


	local function disconnect(Forced : "If should cancel animation")
		modules.UI:Hide(true)
		if Action.ActionInfo.POWER_BUTTON == "UP" then return end
		if Action.ActionInfo.Disconnect then Action.ActionInfo.Disconnect = nil end
		if Action.ActionInfo.Connections.Animation then Action.ActionInfo.Connections.Animation:Disconnect() Action.ActionInfo.Connections.Animation = nil end
		if Action.ActionInfo.Connections.Rage then Action.ActionInfo.Connections.Rage:Disconnect() Action.ActionInfo.Connections.Rage = nil end
		if Action.ActionInfo.Connections.Action then Action.ActionInfo.Connections.Action:Disconnect() Action.ActionInfo.Connections.Action = nil end
		if Action.ActionInfo.Connections.Carrying then Action.ActionInfo.Connections.Carrying:Disconnect() Action.ActionInfo.Connections.Carrying = nil end

		if Forced then
			remoteList.Server:FireServer("BloodRage", "End_Rage", true)
			Character.Humanoid.WalkSpeed = modules.Code.Speeds.Global_Settings.Base_Speed * (1 + modules.Code:GetSpeed("Movement"))

			finalize()
			return
		end

		if Player.Character:GetAttribute("Power_State") == "Using"  then
			remoteList.Server:FireServer("BloodRage", "End_Rage") --Fire to start state changes

			if Action.ActionInfo.Connections.Animation then
				Action.ActionInfo.Connections.Animation:Disconnect()
			end

			Action.ActionInfo.Connections.Rage = game["Run Service"].Heartbeat:Connect(function(step)
				Character.Humanoid.WalkSpeed = Killer_Module.Rage_Speed.Fatigue
			end)

			Action.ActionInfo.Connections.Animation = Character:GetAttributeChangedSignal("Animation"):Connect(function()
				local Animation = Character:GetAttribute("Animation")

				if Animation and Animation ~= "" and script:FindFirstChild(Animation) then
					Action.ActionInfo.Connections.Animation:Disconnect() -- remove doing animation when it's not our turn and do not force overload of signals
					Action.ActionInfo.Connections.Animation = nil -- remove variables do not force overuse of memory/ram

					if not Action.ActionInfo.Connections[Animation] then -- build and store animation
						Action.ActionInfo.Connections[Animation] = Player.Character:WaitForChild('Humanoid'):WaitForChild('Animator'):LoadAnimation(script:FindFirstChild(Animation))
					end

					local A_Length = if Action.ActionInfo.Connections[Animation].Length < 0.1 then 10 else Action.ActionInfo.Connections[Animation].Length
					local True_Length : number = 0 - (workspace:GetServerTimeNow() - Character:GetAttribute("Animation_Time")) or Killer_Module.Timings.Fatigue

					Action.ActionInfo.Connections[Animation]:Play() -- play animation
					Action.ActionInfo.Connections[Animation]:AdjustSpeed(A_Length/True_Length) -- both animations should end at same time/sync
					Action.ActionInfo.Connections[Animation].Stopped:Wait() -- wait for finish

					if Action.ActionInfo.Connections.Rage then 
						Action.ActionInfo.Connections.Rage:Disconnect() 
						Action.ActionInfo.Connections.Rage = nil

						Character.Humanoid.WalkSpeed = modules.Code.Speeds.Global_Settings.Base_Speed * 1.15
					end

					finalize()
				end
			end)
			--else
			--	finalize()
		end
	end

	local function beginpower()
		if Action.ActionInfo.Connections.Animation then
			Action.ActionInfo.Connections.Animation:Disconnect()
			Action.ActionInfo.Connections.Animation = nil
		end

		if Action.ActionInfo.Connections.Rage then
			Action.ActionInfo.Connections.Rage:Disconnect()
			Action.ActionInfo.Connections.Rage = nil
		end

		if Action.ActionInfo.Connections.Action then
			Action.ActionInfo.Connections.Action:Disconnect()
			Action.ActionInfo.Connections.Action = nil
		end

		if Action.ActionInfo.Connections.Carrying then
			Action.ActionInfo.Connections.Carrying:Disconnect()
			Action.ActionInfo.Connections.Carrying = nil
		end

		local Current_Speed = Killer_Module.Rage_Speed.Rage

		Action.ActionInfo.Connections.Rage = game["Run Service"].Heartbeat:Connect(function(step)
			if not Character:GetAttribute("Swing") then
				Character.Humanoid.WalkSpeed = Current_Speed
			end
			-- Early Ending --
			local rage_progress = string.split(Character:GetAttribute("Power"), ':')

			if tonumber(rage_progress[1]) <= 0 then
				disconnect(false)
			end
		end)

		Action.ActionInfo.Connections.Action = currentValues.KillerAction.Changed:Connect(function()
			if currentValues.KillerAction.Value == "Stun" or currentValues.KillerAction.Value == "GraspBegin" or currentValues.KillerAction.Value == "Searching" then
				disconnect(true)
			end
		end)

		Action.ActionInfo.Connections.Carrying = Character:GetAttributeChangedSignal("Carry"):Connect(function()
			if Character:GetAttribute("Carry") then
				disconnect(true)
			end
		end)


		task.delay(1.5,function()
			modules.UI:Hide(false)
			Action.ActionInfo.Disconnect = disconnect
		end)
	end

	remoteList.Server:FireServer("BloodRage", "Start_Rage") --Fire to start state changes

	beginpower()
end

function Action:Stop(...)
	if not Action.ActionInfo.Disconnect then return warn('Anti-Spam Exit') end

	Action.ActionInfo.Disconnect(false)
end


function Action:Process(...) : boolean | "Returns true if this action can be ran"
	local args = {...}
	local actionList, remoteList = args[1], args[2]

	if Constraints(actionList) then
		return true
	end

	return false
end

return Action