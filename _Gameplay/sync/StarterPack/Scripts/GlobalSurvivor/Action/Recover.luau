local Player = game.Players.LocalPlayer
local Defaults = 3;

local Action = {
	Key = "Interact2";
	ActionName = "SELF-RECOVER";
	Priority = 3; -- scale of 1-5
	ActionInfo = {
		Gate = nil;
		Disconnect = nil;
		Hatch = nil;
	},
	Debounces = {
		Recovering = false;
		InputEnter = tick();
		InputExit = tick();
	}
}

local function Constraints(actionList, modules) : boolean | "The Requirements to run this action"
	local CanRun = false -- by default false
	local currentValues = actionList.ValueList
	local Hatch : Model = actionList.Hatch

	local HasTenacity, TenacityTier = modules.Data:GetPerk("Tenacity")

	if currentValues.HealthState.Value == 0
		and currentValues.Action.Value == "Nothing"
		and not currentValues.Holded.Value
		and (Player.Character.Humanoid.MoveDirection.magnitude == 0 or HasTenacity) 
		and not ((Hatch:WaitForChild("HumanoidRootPart").CFrame.Position - Player.Character:GetPivot().Position).Magnitude <= 5.5) then

		CanRun = true
	elseif Action.Debounces.Recovering then -- if in progress do not let go of this interaction
		Action.Priority = 0 -- set Priority to 0 to override any possible incoming interaction
		CanRun = true
	end

	return CanRun
end

function Action:Start(...) : "Start Action?"
	if (tick() - Action.Debounces.InputEnter) < 1.5 or Action.Debounces.Recovering then return --[[warn("Anti-Spam")]] end
	Action.Debounces.InputEnter = tick()
	Action.Debounces.Recovering = true

	local args = {...}
	local actionList, remoteList, modules, obfuscate = args[1], args[2], args[3], args[4]
	local currentValues = actionList.ValueList
	local Character = Player.Character

	modules.UI:Hide(true)
	modules.UI:Progress(currentValues.HealProgress, "RECOVERING")

	local HasTenacity, TenacityTier = modules.Data:GetPerk('Tenacity')

	task.spawn(function()
		repeat task.wait() 
			if not HasTenacity then
				actionList.MovementScript.MainScript.Disabled = false
				Character.Humanoid.WalkSpeed = 0
			else
				local Speeds = {[1] = 1.4, [2] = 1.7, [3] = 2}
				Character.Humanoid.WalkSpeed = 3.5 * Speeds[TenacityTier]
			end
			if Action.Debounces.Recovering then modules.UI:Progress(currentValues.HealProgress, "RECOVERING") end
		until Action.Debounces.Recovering == false
	end) 

	obfuscate("Bool", currentValues.Recovering, true)
	obfuscate("String", currentValues.Action, "Recover")

	print("Set up Recover")

	local Connections = {}

	local function disconnect(actionv)
		print(actionv)
		obfuscate("Bool", currentValues.Recovering, false)
		modules.UI:Progress()
		if actionv then
		else
			obfuscate("String", currentValues.Action, "Nothing")
			actionList.MovementScript.MainScript.Disabled = false
			if not HasTenacity then
				Character.Humanoid.WalkSpeed = 3.5
			else
				local Speeds = {[1] = 1.4, [2] = 1.7, [3] = 2}
				Character.Humanoid.WalkSpeed = 3.5 * Speeds[TenacityTier]
			end
		end
		modules.UI:Progress()
		if Connections.Action then Connections.Action:Disconnect() end
		if Connections.Health then Connections.Health:Disconnect() end
		Action.Debounces.Recovering = false
		Action.Priority = Defaults
		modules.UI:Hide(false)
		modules.UI:Progress()
	end

	Connections.Action = currentValues.Action.Changed:Connect(function()

		if currentValues.Action.Value ~= "Recover" then
			if currentValues.Action.Value == "Nothing" then
				disconnect()
				print("regular action disconnect")
			else
				print("action changed disconnect")
				disconnect(true)
			end
		end
	end)

	Connections.Health = currentValues.HealthState.Changed:Connect(function()
		print("health state changed")
		disconnect()
	end)

	Action.ActionInfo.Disconnect = disconnect
end

function Action:Stop(...)
	if (tick() - Action.Debounces.InputExit) < 1.5 or not Action.ActionInfo.Disconnect then return warn('Anti-Spam exit') end
	Action.Debounces.InputExit = tick()

	local args = {...}
	print("Stop Run")
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