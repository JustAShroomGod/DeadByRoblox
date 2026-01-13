local Player = game.Players.LocalPlayer
local Defaults = 1;

local Action = {
	Key = "Interact2";
	ActionName = "DISARM TRAP";
	InteractDistance = 6;
	Priority = 1; -- scale of 1-5
	ActionInfo = {
		Trap = nil;
		Disconnect = nil;
	},
	Debounces = {
		Deploying = false;
		Exiting = false;
		InputEnter = tick();
	}
}

local tween = nil
local v_prog = script:WaitForChild("V_Prog")

local function Constraints(actionList) : boolean | "The Requirements to run this action"
	local CanRun = false -- by default false
	local currentValues = actionList.ValueList
	local Trap : Model = actionList.KillerInteractable.Trap

	if not Trap then return false end
	if not Trap:FindFirstChild("HumanoidRootPart") then return false end

	if (Trap:WaitForChild("HumanoidRootPart").Position - Player.Character:GetPivot().Position).Magnitude <= Action.InteractDistance -- Distance Check
		and currentValues.HealthState.Value > 0
		and not currentValues.Hooked.Value
		and not currentValues.Holded.Value
		and currentValues.Action.Value == "Nothing"
		and Trap:WaitForChild('Panel').State.Value ~= "Disarmed" and Trap:WaitForChild('Panel').State.Value ~= "Inactive" -- has a person trapped or active
		and Trap:WaitForChild('Panel').User.Value == "" then -- noone else is disarming

		Action.ActionInfo.Trap = Trap
		CanRun = true
	elseif Action.Debounces.Deploying then -- if in progress do not let go of this interaction
		Action.Priority = 0 -- set Priority to 0 to override any possible incoming interaction
		CanRun = true
	else
		Action.ActionInfo.Trap = nil
	end

	return CanRun
end

function Action:Start(...) : "Start Action?"
	if (tick() - Action.Debounces.InputEnter) < 1 or not Action.ActionInfo.Trap or Action.Debounces.Deploying then return --[[warn("Anti-Spam")]] end
	Action.Debounces.InputEnter = tick()
	Action.Debounces.Deploying = true

	local args = {...}
	local actionList, remoteList, modules, obfuscate = args[1], args[2], args[3], args[4]
	local currentValues = actionList.ValueList
	local Character = Player.Character

	local trap = Action.ActionInfo.Trap

	modules.UI:Hide(true)

	Character.PrimaryPart.Anchored = true
	Character:PivotTo(CFrame.new(Character:GetPivot().Position, Vector3.new(trap.HumanoidRootPart.Position.X, Character:GetPivot().Position.Y, trap.HumanoidRootPart.Position.Z)))

	local Connections = {}

	tween = game:GetService("TweenService"):Create(v_prog, TweenInfo.new(3.5, Enum.EasingStyle.Linear), {Value = 1000})
	tween:Play()
	modules.UI:Progress(v_prog, "DISARMING")

	remoteList.Server:FireServer('Trap', "Disarm", true, trap)

	local function disconnect()
		if Connections.Hit then Connections.Hit:Disconnect() end
		if Connections.Action then Connections.Action:Disconnect() end

		remoteList.Server:FireServer('Trap', "Disarm", false)
		tween:Pause()
		tween = nil
		modules.UI:Progress()
		v_prog.Value = 0

		repeat task.wait()
		until currentValues.Action.Value == "Nothing"

		Character.PrimaryPart.Anchored = false

		Action.Debounces.Exiting = false
		Action.Debounces.Deploying = false
		Action.Priority = Defaults -- reset priority back to original
		modules.UI:Hide(false)
	end

	Connections.Hit = currentValues.HealthState.Changed:Connect(function(test)
		disconnect()
	end)

	Connections.Action = currentValues.Action.Changed:Connect(function()

		if currentValues.Action.Value == "Nothing" then
			disconnect()
		end
	end)	

	Action.ActionInfo.Disconnect = disconnect
end

function Action:Stop(...)
	if Action.Debounces.Exiting or not Action.ActionInfo.Disconnect then return warn('Anti-Spam exit') end

	local args = {...}
	local actionList, remoteList, modules, obfuscate = args[1], args[2], args[3], args[4]
	local currentValues = actionList.ValueList

	if currentValues.Action.Value ~= "Disarming" then
		repeat task.wait()
		until currentValues.Action.Value == "Disarming"
	end

	Action.ActionInfo.Disconnect()
	Action.ActionInfo.Disconnect = nil
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