local Remotes = game.ReplicatedStorage.RemoteEvents
local Player = game.Players.LocalPlayer
local Defaults = 1;

local Action = {
	Key = "Interact2";
	ActionName = "MEND-SELF";
	Priority = 1; -- scale of 1-5
	ActionInfo = {
		Gate = nil;
		Disconnect = nil;
	},
	Debounces = {
		Mending = false;
		InputEnter = tick();
		InputExit = tick();
	}
}

local function Constraints(actionList, modules) : boolean | "The Requirements to run this action"
	local CanRun = false -- by default false
	local currentValues = actionList.ValueList


	if currentValues.HealthState.Value >= 1
		and currentValues.Action.Value == "Nothing"
		and not currentValues.Hooked.Value
		and not currentValues.Holded.Value
		and Player.Character:GetAttribute("Gash")
		and (Player.Character.Humanoid.MoveDirection.magnitude == 0) then

		CanRun = true
	elseif Action.Debounces.Mending then -- if in progress do not let go of this interaction
		Action.Priority = 0 -- set Priority to 0 to override any possible incoming interaction
		CanRun = true
	end

	return CanRun
end

function Action:Start(...) : "Start Action?"
	if (tick() - Action.Debounces.InputEnter) < 1.5 or Action.Debounces.Mending then return --[[warn("Anti-Spam")]] end
	Action.Debounces.InputEnter = tick()
	Action.Debounces.Mending = true

	local args = {...}
	local actionList, remoteList, modules, obfuscate = args[1], args[2], args[3], args[4]
	local currentValues = actionList.ValueList
	local Character = Player.Character

	modules.UI:Hide(true)
	modules.UI:Progress(currentValues.MendProgress, "MENDING")

	actionList.MovementScript.MainScript.Disabled = true
	Character.Humanoid.WalkSpeed = 0

	currentValues.Action.Value = "Mending"
	
	local HealingConfig = {
		SelfHealing = true;
		IsMending = true;
		RestrictValues = false;
	}

	Remotes.ClientToServer.HealingEvent:FireServer(Player.Name, "Start", HealingConfig)

	local Track = script:WaitForChild('Animation'):Clone()
	local MendTrack = Character.Humanoid:LoadAnimation(Track)
	MendTrack:Play(.2, 4, 1)

	local Connections = {}

	local function disconnect()
		if MendTrack then MendTrack:Stop() MendTrack = nil Track:Destroy() end

		currentValues.Action.Value = "Nothing"
		Remotes.ClientToServer.HealingEvent:FireServer(Player.Name, "Stop")

		actionList.MovementScript.MainScript.Disabled = false

		if Connections.Hit then Connections.Hit:Disconnect() end
		if Connections.Progress then Connections.Progress:Disconnect() end
		if Connections.Action then Connections.Action:Disconnect() end

		Action.Debounces.Mending = false
		Action.Priority = Defaults
		modules.UI:Hide(false)
		modules.UI:Progress()
	end

	Connections.Hit = currentValues.HealthState.Changed:Connect(function()
		disconnect()
	end)


	Connections.Progress = currentValues.MendProgress.Changed:Connect(function()
		if currentValues.MendProgress.Value >= 1000 then
			remoteList.Info:FireServer('Survival', 200, 'MENDED')
			disconnect()
		end
	end)

	Connections.Action = currentValues.Action.Changed:Connect(function()
		if not (currentValues.Action.Value == "Mending") then
			disconnect()
		end
	end)	

	Connections.Effect = Character:GetAttributeChangedSignal("Gash"):Connect(function()
		if not Character:GetAttribute("Gash") then
			disconnect()
		end
	end)
	
	Action.ActionInfo.Disconnect = disconnect
end

function Action:Stop(...)
	if (tick() - Action.Debounces.InputExit) < 1.5 or not Action.ActionInfo.Disconnect then return --[[warn('Anti-Spam exit')]] end
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