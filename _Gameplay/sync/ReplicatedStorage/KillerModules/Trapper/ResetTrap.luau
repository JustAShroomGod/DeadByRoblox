local Player = game.Players.LocalPlayer

local DefaultPriority = 3

local Action = {
	Key = "Interact5";
	ActionName = "Reset Trap";
	Priority = 1; -- scale of 1-5
	InteractDistance = 6.5;
	ActionInfo = {
		Trap = nil;
	},
	Debounces = {
		InputEnter = tick();
		InProgress = false;
	}
}

local function Constraints(actionList, modules) : boolean | "The Requirements to run this action"
	local CanRun = false -- by default false
	local currentValues = actionList.ValueList
	local Trap : Model = actionList.KillerInteractable.Trap
	
	if not Trap then return false end

	local Direction = (Trap:WaitForChild('HumanoidRootPart').Position - (Player.Character:GetPivot() * CFrame.new(0, 0, 2)).Position).Unit

	if (Trap:WaitForChild("HumanoidRootPart").Position - Player.Character:GetPivot().Position).Magnitude <= Action.InteractDistance -- Distance Check
		and Player.Character:GetPivot().LookVector:Dot(Direction) >= 0.5
		and currentValues.KillerAction.Value == "Nothing"
		and not Player.Character:GetAttribute("Carry") -- not allowed while carrying
		and (Trap:WaitForChild('Panel').State.Value == "Disarmed" or Trap:WaitForChild('Panel').State.Value == "Inactive")
		and (currentValues.Parent:WaitForChild("BLOODPOINT"):FindFirstChild("REMOVE") ~= nil)
		and Trap:WaitForChild('Panel').CanPickup.Value
		and Trap:WaitForChild('Panel').User.Value == "" then -- noone is disarming
		
		Action.ActionInfo.Trap = Trap
		CanRun = true
	elseif Action.Debounces.InProgress then -- if in progress do not let go of this interaction
		Action.Priority = 0 -- set Priority to 0 to override any possible incoming interaction
		CanRun = true
	else
		Action.ActionInfo.Trap = nil
	end

	return CanRun
end

function Action:Start(...) : "Start Action?"
	if (tick() - Action.Debounces.InputEnter) < 1 or Action.Debounces.InProgress or not Action.ActionInfo.Trap then return --[[warn("Anti-Spam")]] end
	Action.Debounces.InputEnter = tick()
	Action.Debounces.InProgress = true
	
	local args = {...}
	local actionList, remoteList, modules = args[1], args[2], args[3]
	local currentValues = actionList.ValueList
	local Character = Player.Character
	local Trap = Action.ActionInfo.Trap

	modules.UI:Hide(true)

	actionList.PreventHeadTilt = true
	modules.Camera.Camera.HeadLocked = true

	Character.Humanoid.AutoRotate = false

	local Connections = {}
	
	remoteList.Server:FireServer("Trap", "Reset", Trap)

	repeat task.wait()
	until currentValues.KillerAction.Value == "Resetting"
	
	repeat task.wait()
	until currentValues.KillerAction.Value == "Nothing"

	Character.Humanoid.AutoRotate = true

	modules.Camera.Camera.HeadLocked = false
	actionList.PreventHeadTilt = false
	
	Action.Debounces.InProgress = false
	Action.Priority = DefaultPriority
	modules.UI:Hide(false)
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
