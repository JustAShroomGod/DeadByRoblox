local Player = game.Players.LocalPlayer
local Defaults = 3;

local Action = {
	Key = "Interact2";
	ActionName = "OPEN EXIT";
	InteractDistance = 4.7;
	Priority = 3; -- scale of 1-5
	ActionInfo = {
		Gate = nil;
		Disconnect = nil;
	},
	Debounces = {
		InProgress = false;
		InputEnter = tick();
		InputExit = tick();
	}
}

local function Constraints(actionList) : boolean | "The Requirements to run this action"
	local CanRun = false -- by default false
	local currentValues = actionList.ValueList
	local Gate : Model = actionList.Gate

	if not Gate then return false end
	local generatorRepaired = workspace:WaitForChild("MatchValues"):WaitForChild("GeneratorsRepaired")

	if (Gate:WaitForChild("Port").Position - Player.Character:GetPivot().Position).Magnitude <= Action.InteractDistance -- Distance Check
		and currentValues.HealthState.Value > 0
		and currentValues.Action.Value == "Nothing"
		and generatorRepaired.Value >= 5 -- Generator Count Reached
		and Gate:WaitForChild('Panel'):WaitForChild('Using').Value == "NoUsing"
		and Gate:WaitForChild('Panel'):WaitForChild('Progress').Value < 1000 then

		Action.ActionInfo.Gate = Gate
		CanRun = true
	elseif Action.Debounces.InProgress then -- if in progress do not let go of this interaction
		Action.Priority = 0 -- set Priority to 0 to override any possible incoming interaction
		CanRun = true
	else
		Action.ActionInfo.Gate = nil
	end

	return CanRun
end

function Action:Start(...) : "Start Action?"
	if (tick() - Action.Debounces.InputEnter) < 1.5 or not Action.ActionInfo.Gate or Action.Debounces.InProgress then return --[[warn("Anti-Spam")]] end
	Action.Debounces.InputEnter = tick()
	Action.Debounces.InProgress = true

	local args = {...}
	local actionList, remoteList, modules = args[1], args[2], args[3]
	local currentValues = actionList.ValueList
	local Character = Player.Character
	local gate = Action.ActionInfo.Gate

	modules.UI:Hide(true)
	modules.UI:Progress(gate.Panel.Progress, "OPENING EXIT", "OpeningSpeed", modules.Code.BaseValues.Survivor.Action.OpeningSpeed) -- bind to progress, should show up and be binded
	currentValues.Action.Value = "OpeningGate"

	
	gate:WaitForChild("Panel"):WaitForChild("Exit_Gate"):FireServer("Open")

	repeat task.wait()
	until currentValues.Action.Value == "OpeningGate"

	if Player.Character:GetAttribute("Perk_Defense_Time") then
		remoteList.Perk:FireServer("Self Defense", false) -- de-activate our perk
	end

	local GateAnimation = Character.Humanoid:LoadAnimation(script:WaitForChild('Animation'))
	GateAnimation:Play(.2, 5, 1)

	local Connections = {}

	local function disconnect()
		Action.ActionInfo.Disconnect = nil

		if Connections.HealthStateChanged then Connections.HealthStateChanged:Disconnect() end
		if Connections.Hit then Connections.Hit:Disconnect() end
		if GateAnimation then GateAnimation:Stop() GateAnimation = nil end
		if Connections.Changed then Connections.Changed:Disconnect() end
		if Connections.Action then Connections.Action:Disconnect() end

		gate:WaitForChild('Panel'):WaitForChild('Exit_Gate'):FireServer("Close")
		currentValues.Action.Value = "Nothing"
		repeat task.wait()
		until currentValues.Action.Value == "Nothing"

		Action.Debounces.InProgress = false
		Action.Priority = Defaults -- reset priority back to original
		modules.UI:Hide(false)
		modules.UI:Progress() -- bind to progress, should show up and be binded
	end

	Connections.Changed = gate.Panel.Progress.Changed:Connect(function()
		modules.UI:Progress(gate.Panel.Progress, "OPENING EXIT")
		if gate.Panel.Progress.Value >= 1000 then
			disconnect()
		end
	end)

	Connections.Action = currentValues.Action.Changed:Connect(function()
		if not (currentValues.Action.Value == "OpeningGate") then
			disconnect()
		end
	end)

	Connections.HealthStateChanged = currentValues.HealthState.Changed:Connect(function()
		disconnect()
	end)

	Action.ActionInfo.Disconnect = disconnect
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
	local actionList, remoteList = args[1], args[2]

	if Constraints(actionList) then
		return true
	end

	return false
end

return Action