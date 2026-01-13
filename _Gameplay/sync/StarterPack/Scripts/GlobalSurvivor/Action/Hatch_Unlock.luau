local Player = game.Players.LocalPlayer
local Default = 3

local Action = {
	Key = "Interact2";
	ActionName = "UNLOCK HATCH";
	Priority = 2; -- scale of 1-5
	InteractionDistance = 5;
	ActionInfo = {
		Connections = {};
	},
	Debounces = {
		InputEnter = tick();
		InputExit = tick();
		Using = false;
	}
}

function Constraints(actionList, modules) : boolean | "Return true if can do action"
	local CanRun = false
	local currentValues = actionList.ValueList
	local Hatch = actionList.Hatch

	local HasPerk, PerkTier = modules.Data:GetPerk("Focused")
	
	if HasPerk and #game.Teams:WaitForChild('Survivor'):GetPlayers() <= 1 then
		CanRun = true
	end
	
	if CanRun and not currentValues.Hooked.Value
		and Hatch:GetAttribute("State") == "Idle"
		and not Hatch:GetAttribute("User")
		and (Hatch.HumanoidRootPart.CFrame.Position - Player.Character:GetPivot().Position).Magnitude <= Action.InteractionDistance
		and currentValues.Action.Value == "Nothing"
		and currentValues.HealthState.Value > 0
		and not Player.Character.PrimaryPart.Anchored
		and not currentValues.Holded.Value then -- can use key in general
		
		Action.ActionInfo.Hatch = Hatch
	elseif Action.Debounces.Using then
		Action.Priority = 0
		CanRun = true
	else
		Action.ActionInfo.Hatch = nil
		CanRun = false
	end

	return CanRun
end

function Action:Start(...) : "Start Using"
	if (tick() - Action.Debounces.InputEnter) < 1 or Action.Debounces.Using then return --[[warn("Anti-Spam")]] end
	Action.Debounces.InputEnter = tick()
	Action.Debounces.Using = true
	
	local args = {...}
	local actionList, remoteList, modules = args[1], args[2], args[3]
	local currentValues = actionList.ValueList
	local Character = Player.Character
	local Hatch = Action.ActionInfo.Hatch
	local State = Hatch:GetAttribute("State")

	modules.UI:Hide(true)
	modules.UI:Progress(Hatch:GetAttribute("Progress"), "UNLOCKING")
	
	
	local function disconnect()
		remoteList.Hatch:FireServer("Stop_Unlock")
	end

	if not Action.ActionInfo.Connections.Hatch_Unlocking then
		Action.ActionInfo.Connections.Hatch_Unlocking = Character:WaitForChild('Humanoid'):WaitForChild('Animator'):LoadAnimation(script:WaitForChild('Unlocking'))
	end

	remoteList.Hatch:FireServer("Unlock")
	Action.ActionInfo.Connections.Hatch_Unlocking:Play()

	repeat task.wait()
		State = Hatch:GetAttribute("State")
	until State == "Open" or State == "Unlocking"

	Action.ActionInfo.Connections.Disconnect = disconnect

	repeat task.wait()
		modules.UI:Progress(Hatch:GetAttribute("Progress"), "UNLOCKING")
		State = Hatch:GetAttribute("State")
	until State == "Open" or State == "Idle"

	Action.ActionInfo.Connections.Disconnect = nil

	if Action.ActionInfo.Connections.Hatch_Unlocking.IsPlaying then
		Action.ActionInfo.Connections.Hatch_Unlocking:Stop()
	end

	Action.Debounces.Using = false
	
	Action.Priority = Default
	modules.UI:Hide(false)

	modules.UI:Progress()
end

function Action:Stop(...) : "Stop Using"
	if (tick() - Action.Debounces.InputExit) < 1 or not Action.ActionInfo.Connections.Disconnect then return warn('Anti-Spam exit') end
	Action.Debounces.InputExit = tick()

	local args = {...}

	Action.ActionInfo.Connections.Disconnect()
	Action.ActionInfo.Connections.Disconnect = nil
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
