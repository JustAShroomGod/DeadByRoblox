local Player = game.Players.LocalPlayer
local Defaults = 1;

local Action = {
	Key = "Interact2";
	ActionName = "STRUGGLE";
	InteractDistance = 6.8;
	Priority = 1; -- scale of 1-5
	ActionInfo = {
		Trap = nil;
	},
	Debounces = {
		InputEnter = tick();
		Deploying = false;
		Exiting = false;
	}
}

local function Constraints(actionList) : boolean | "The Requirements to run this action"
	local CanRun = false -- by default false
	local currentValues = actionList.ValueList
	local Trap : Model = actionList.KillerInteractable.Trap

	if not Trap then return false end
	
	
	if (Trap:WaitForChild("HumanoidRootPart").Position - Player.Character:GetPivot().Position).Magnitude <= Action.InteractDistance -- Distance Check
		and currentValues.Action.Value == "Trapped" -- we are trapped
		and Trap:WaitForChild('Panel').Trapped.Value == Player.Character -- it's our character
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
	Action.Debounces.Deploying = true
	
	local args = {...}
	local actionList, remoteList, modules = args[1], args[2], args[3]
	local currentValues = actionList.ValueList
	local Character = Player.Character

	local trap = Action.ActionInfo.Trap
	
	modules.UI:Hide(true)
	modules.UI:Progress(trap.Panel.Progress, "STRUGGLING")
	
	local Connections = {}

	remoteList.Server:FireServer('Trap', "Struggle", true, trap)
	 
	local function disconnect()
		if Connections.Hit then Connections.Hit:Disconnect() end
		if Connections.Action then Connections.Action:Disconnect() end

		remoteList.Server:FireServer('Trap', "Struggle", false)

		repeat task.wait()
		until (currentValues.Action.Value == "Nothing" or currentValues.Action.Value == "Trapped")

		Action.Debounces.Exiting = false
		Action.Debounces.Deploying = false
		Action.Priority = Defaults -- reset priority back to original
		modules.UI:Hide(false)
		modules.UI:Progress()
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
	local actionList, remoteList, modules = args[1], args[2], args[3]
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
