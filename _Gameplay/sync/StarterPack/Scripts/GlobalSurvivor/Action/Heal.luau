local Remotes = game.ReplicatedStorage.RemoteEvents
local Player = game.Players.LocalPlayer
local Defaults = 2;

local Action = {
	Key = "Interact2";
	ActionName = "HEAL";
	Priority = 1; -- scale of 1-5
	InteractionDistance = 5;
	AnimationTracks = nil;
	ActionInfo = {
		Survivor = nil;
		Disconnect = nil;
	},
	Debounces = {
		Healing = false;
		InputEnter = tick();
		InputExit = tick();
	}
}

local function Constraints(actionList, modules) : boolean | "The Requirements to run this action"
	local CanRun = false -- by default false
	local currentValues = actionList.ValueList
	local Survivor = actionList.Player

	if not Survivor or not Survivor.Character then return false end
	if not Survivor:WaitForChild('Backpack'):FindFirstChild('Scripts') or not Survivor:WaitForChild('Backpack'):WaitForChild('Scripts'):FindFirstChild('values') then return false end

	local IsKiller = Survivor.Backpack.Scripts.Killer
	local SurvivorSettings = Survivor.Backpack.Scripts.values
	local TheirShift = Survivor.Backpack.Scripts.MovementSpeedScript.Shift

	local Broken = modules.Code:GetEffect("Broken", Survivor)

	if not IsKiller.Value
		and not modules.Code:GetEffect("Cloaked")
		and Survivor.Character
		and currentValues.HealthState.Value > 0
		and currentValues.Action.Value == "Nothing"
		and not currentValues.Hooked.Value
		and not currentValues.Holded.Value
		and not Player.Character:GetAttribute("Gash")
		and SurvivorSettings:WaitForChild('HealthState').Value < 2
		and (SurvivorSettings.Action.Value == "Nothing" or SurvivorSettings.Action.Value == "GettingHealing" or SurvivorSettings.Action.Value == "Recover" or SurvivorSettings.Action.Value == "InCarry")
		and not SurvivorSettings.Holded.Value
		and not Player.Character:GetAttribute("Sprint")
		and not SurvivorSettings.Hooked.Value
		and not Survivor.Character:GetAttribute("Gash")
		and ((not Broken or (Broken and not Broken.Active)) or SurvivorSettings.HealthState.Value == 0) -- if broken or down on the ground
		and not TheirShift.Value
		and (Survivor.Character:GetPivot().Position - Player.Character:GetPivot().Position).Magnitude <= Action.InteractionDistance
		and Player.Character.Humanoid.MoveDirection.magnitude == 0 then

		Action.ActionInfo.Survivor = Survivor
		CanRun = true
	elseif Action.Debounces.Healing then -- if in progress do not let go of this interaction
		Action.Priority = 0 -- set Priority to 0 to override any possible incoming interaction
		CanRun = true
	else
		Action.ActionInfo.Survivor = nil
		CanRun = false
	end

	return CanRun
end

function Action:Start(...) : "Start Action?"
	if (tick() - Action.Debounces.InputEnter) < 1.5 or Action.Debounces.Healing then return --[[warn("Anti-Spam")]] end
	Action.Debounces.InputEnter = tick()
	Action.Debounces.Healing = true

	local args = {...}
	local actionList, remoteList, modules, obfuscate = args[1], args[2], args[3], args[4]
	local currentValues = actionList.ValueList
	local Character = Player.Character

	local SurvivorSettings = Action.ActionInfo.Survivor.Backpack.Scripts.values

	modules.UI:Hide(true)
	modules.UI:Progress(SurvivorSettings.HealProgress, 'HEALING', "HealingSpeed", modules.Code.BaseValues.Survivor.Action.HealingSpeed)

	actionList.MovementScript.MainScript.Disabled = true
	Character.Humanoid.WalkSpeed = 0
	Character:PivotTo(CFrame.new(Character:GetPivot().Position, Action.ActionInfo.Survivor.Character:GetPivot().Position))
	
	local HealingConfig = {
		SelfHealing = false;
		IsMending = false;
		RestrictValues = false;
	}

	currentValues.Action.Value = "OtherHealing"
	Remotes.ClientToServer.HealingEvent:FireServer(Action.ActionInfo.Survivor.Name, "Start", HealingConfig)

	if Player.Character:GetAttribute("Perk_Defense_Time") then
		remoteList.Perk:FireServer("Self Defense", false) -- de-activate our perk
	end
	
	if (Action.AnimationTracks == nil) then
		Action.AnimationTracks = {
			MissTrack = Character.Humanoid:LoadAnimation(script:WaitForChild('Skill_Miss'));
			HealTrack = Character.Humanoid:LoadAnimation(script:WaitForChild('Animation'));
		}
	end
	
	Action.AnimationTracks.HealTrack:Play(.2, 4, 1)

	local Connections = {}

	local function disconnect()
		if Action.AnimationTracks.HealTrack then Action.AnimationTracks.HealTrack:Stop() end
		if Action.AnimationTracks.MissTrack then Action.AnimationTracks.MissTrack:Stop() end

		if SurvivorSettings:FindFirstChild('Action') then -- could be missing cause they leave?
			Remotes.ClientToServer.HealingEvent:FireServer(Action.ActionInfo.Survivor.Name, "Stop")
		end
		
		currentValues.Action.Value = "Nothing"

		actionList.MovementScript.MainScript.Disabled = false
		if Connections.HealthStateChanged then Connections.HealthStateChanged:Disconnect() end
		if Connections.Hit then Connections.Hit:Disconnect() end
		if Connections.Shift then Connections.Shift:Disconnect() end
		if Connections.Health then Connections.Health:Disconnect() end
		if Connections.Action then Connections.Action:Disconnect() end
		if Connections.Miss then Connections.Miss:Disconnect() end

		Action.Debounces.Healing = false
		Action.Priority = Defaults
		modules.UI:Hide(false)
		modules.UI:Progress()
	end
	
	Connections.Miss = Remotes.SkillCheckResult.Event:Connect(function(Context, Result)
		
		if (Context ~= "Heal" or (Result ~= "Fail" and Result ~= "Miss")) then
			return
		end
		
		Action.AnimationTracks.MissTrack:Play()
	end)

	Connections.Shift = Action.ActionInfo.Survivor.Backpack.Scripts.MovementSpeedScript.Shift.Changed:Connect(function()
		disconnect()
	end)

	Connections.Hit = Character:GetAttributeChangedSignal("LastHit"):Connect(function(test)
		disconnect()
	end)

	Connections.Health = SurvivorSettings.HealthState.Changed:Connect(function()
		
		if (SurvivorSettings.HealthState.Value < 2) then
			return
		end
		
		disconnect()
	end)

	Connections.Action = currentValues.Action.Changed:Connect(function()
		if not (currentValues.Action.Value == "OtherHealing") then
			disconnect()
		end
	end)	

	Connections.HealthStateChanged = currentValues.HealthState.Changed:Connect(function(value)
		disconnect()
	end)

	Action.ActionInfo.Disconnect = disconnect

	coroutine.resume(coroutine.create(function()
		repeat task.wait() 
			actionList.MovementScript.MainScript.Disabled = true
			Character.Humanoid.WalkSpeed = 0
		until currentValues.Action.Value == "Nothing"
		actionList.MovementScript.MainScript.Disabled = false
	end))
end

function Action:Stop(...)
	if (tick() - Action.Debounces.InputExit) < 1.5 or not Action.ActionInfo.Disconnect then return warn('Anti-Spam exit') end
	Action.Debounces.InputExit = tick()

	local args = {...}
	Action.ActionInfo.Disconnect()
	Action.ActionInfo.Disconnect = nil
end

function Action:Process(...) : boolean | "Returns true if this action can be ran"
	local args = {...}
	local actionList, remoteList, modules = args[1], args[2], args[3]

	if Constraints(actionList, modules) then
		return true
	end

	return false
end

return Action